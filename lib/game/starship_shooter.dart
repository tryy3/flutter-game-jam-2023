import 'dart:math';

import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart' hide OverlayRoute;
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/l10n/l10n.dart';

enum SideView { left, right }

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.gameBloc,
    required this.entityBloc,
  }) {
    images.prefix = '';
  }

  final GameBloc gameBloc;
  final EntityBloc entityBloc;
  late RouterComponent router;
  late GameConfig config;

  @override
  bool get debugMode => false;

  static const Color lightBlack80 = Color(0x80000000);
  static const Color lightGrey50 = Color(0x50ffffff);
  static final borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = lightGrey50;

  final AppLocalizations l10n;
  final audio_player.AudioPlayer effectPlayer;
  final TextStyle textStyle;

  double timerCounter = 0;
  double timerLimit = 0;
  int counter = 0;

  final player1 = Player(
    entity: Entity.player1,
    side: SideView.left,
    playerType: PlayerType.hot,
  );
  final player2 = Player(
    entity: Entity.player2,
    side: SideView.right,
    playerType: PlayerType.cold,
  );

  @override
  Color backgroundColor() => Colors.grey[900]!;

  @override
  Future<void> onLoad() async {
    await images.load('assets/images/sprite_sheet.png');

    final world = World(
      children: [],
    );

    final camera = CameraComponent(
      world: world,
    );

    await addAll([
      world,
      camera,
    ]);

    config = GameConfig(camera: camera);

    await add(FpsTextComponent(position: Vector2(0, size.y - 24)));

    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<EntityBloc, EntityState>.value(
            value: entityBloc,
          ),
          FlameBlocProvider<GameBloc, GameState>.value(
            value: gameBloc,
          ),
        ],
        children: [player1, player2],
      ),
    );

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    // When a round start (someone clicks on button) check if any
    // player can actually continue before continuing changing state
    gameBloc
      ..on<RoundStartsEvent>((event, emit) {
        if (player1.canContinue() || player2.canContinue()) {
          emit(
            gameBloc.state.copyWith(
              status: GameStatus.roundStarts,
            ),
          );
        }
      })
      ..on<GameOverEvent>((event, emit) async {
        emit(
          gameBloc.state.copyWith(
            status: GameStatus.gameOver,
          ),
        );

        overlays.add('PauseMenu');
        pauseEngine();
      });

    entityBloc
      ..on<CardUsedEvent>((event, emit) {
        // Get the heat/cold and subtract by the event depending on which one
        // was used at the time
        final heat = event.heat != null
            ? entityBloc.state.entities[event.entity]!.heat - event.heat!
            : null;
        final cold = event.cold != null
            ? entityBloc.state.entities[event.entity]!.cold - event.cold!
            : null;
        emit(
          entityBloc.state.copyWith(
            entity: event.entity,
            heat: heat,
            cold: cold,
          ),
        );
      })
      ..on<DamageEvent>((event, emit) {
        if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
          Entity enemy;
          if (event.entity == Entity.player1) {
            enemy = Entity.player2;
          } else {
            enemy = Entity.player1;
          }

          final newHealth =
              entityBloc.state.entities[enemy]!.health - event.damage;

          emit(
            entityBloc.state.copyWith(
              entity: enemy,
              health: newHealth,
            ),
          );
        }
      })
      ..on<HealingEvent>((event, emit) {
        const maxHealth = 20; // TODO(tryy3): Change this to const/player object
        final newHealth =
            entityBloc.state.entities[event.entity]!.health + event.health;

        emit(
          entityBloc.state.copyWith(
            entity: event.entity,
            health: min(maxHealth, newHealth),
          ),
        );
      })
      ..on<EntityDeath>((event, emit) {
        if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
          // When it's PvP we can simply end the game if anyone dies
          gameBloc.add(const GameOverEvent());
        } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
          // In PvE mode it will be a bit different because we might have
          // different levels and it might be possible to continue
          // playing even if 1 player dies
        }
      });
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    // TODO(tryy3): Move this to wiki
    // Event logic works like this:
    // 1. Check if any player can continue
    // 2. If they can start sending events
    // 2-1. Change state to Round starts
    // 3. Start processing the turn
    // 3-1. Find which player or enemy should begin this turn
    // 3-2. Update state to turnStarts and the entity who's turn it is
    // 3-3. Update state to turnProcess.
    // 3-4. Update state to turnEnds.
    // 4. Check if any player can continue
    // 4.1 If none can and state is not waitingForRoundStart then update state
    // to RoundEnds

    final status = gameBloc.state.status;
    if (status == GameStatus.inBetweenTurns || status == GameStatus.roundEnds) {
      timerCounter += dt;
    }

    if (status == GameStatus.gameStarts) {
      // TODO(tryy3): Maybe check if game is fully loaded at this point?
      gameBloc.add(const WaitingForRoundStartsEvent());
    } else if (status == GameStatus.roundStarts ||
        (status == GameStatus.inBetweenTurns && timerCounter >= timerLimit)) {
      // Check for next entity to play, by checking current player against who
      // is next and if they are actually able to play again if next player is
      // unable to continue we'll automatically continue with same entity
      // The player order might differ depending on gameMode
      var nextEntity = gameBloc.state.currentEntity;

      if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
        if (nextEntity == Entity.none && player1.canContinue()) {
          nextEntity = Entity.player1;
        } else if (nextEntity == Entity.none && player2.canContinue()) {
          nextEntity = Entity.player2;
        } else if (nextEntity == Entity.player1 && player2.canContinue()) {
          nextEntity = Entity.player2;
        } else if (nextEntity == Entity.player2 && player1.canContinue()) {
          nextEntity = Entity.player1;
        }
      } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
        // TODO(tryy3): Implement this... requires an actualy enemy object
        // to continue, could make a 'fake' one
      }
      gameBloc.add(TurnStartsEvent(currentEntity: nextEntity));
    } else if (status == GameStatus.turnStarts) {
      gameBloc
          .add(TurnProcessEvent(currentEntity: gameBloc.state.currentEntity));
    } else if (status == GameStatus.turnProcess) {
      gameBloc.add(TurnEndsEvent(currentEntity: gameBloc.state.currentEntity));
    } else if (status == GameStatus.turnEnds) {
      // Reset the counter everytime
      timerCounter = 0; // Reset counter
      timerLimit = 2; // Set timerLimit

      // Check if there is still anyone that can play
      if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
        if (!player1.canContinue() && !player2.canContinue()) {
          gameBloc.add(const RoundEndsEvent());
        } else {
          // Someone can continue, go to inBetweenTurns and reset timerCounter
          gameBloc.add(const InBetweenTurnsEvent());
        }
      } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
        // TODO(tryy3): Implement this... requires an actualy enemy object
        // to continue, could make a 'fake' one
      }
    } else if (status == GameStatus.roundEnds && timerCounter >= timerLimit) {
      gameBloc.add(const WaitingForRoundStartsEvent());
    }
  }

  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );
}

Sprite spriteSheet(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('assets/images/sprite_sheet.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
