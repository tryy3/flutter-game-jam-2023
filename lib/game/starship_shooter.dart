import 'dart:math';

import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart' hide OverlayRoute;
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/entity_component_manager.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/l10n/l10n.dart';

enum SideView { left, right, bottom }

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.gameBloc,
    required this.entityBloc,
  }) : _entityComponentManager =
            EntityComponentManager(entityBloc: entityBloc) {
    images.prefix = '';
  }

  final GameBloc gameBloc;
  final EntityBloc entityBloc;
  late RouterComponent router;
  late GameConfig config;
  final EntityComponentManager _entityComponentManager;

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

  @override
  Color backgroundColor() => Colors.grey[900]!;

  @override
  Future<void> onLoad() async {
    // Pre load the sprite sheet
    await images.load('assets/images/sprite_sheet.png');

    // Create the world and camera object
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

    // FPS component for debug
    await add(FpsTextComponent(position: Vector2(0, size.y - 24)));

    // Add players to the game
    final players = <Component>[];
    switch (gameBloc.state.playerMode) {
      case PlayerMode.onePlayer:
        final player = Player(side: SideView.bottom);
        _entityComponentManager.addEntity(player);
        players.add(player);
      case PlayerMode.twoPlayers:
        final player1 = Player(side: SideView.left);
        final player2 = Player(side: SideView.right);
        _entityComponentManager.addEntity(player1);
        _entityComponentManager.addEntity(player2);
        players.add(player1);
        players.add(player2);
    }
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
        children: players,
      ),
    );

    // Center the viewfinder
    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    // When a round start (someone clicks on button) check if any
    // player can actually continue before continuing changing state
    gameBloc
      ..on<RoundStartsEvent>((event, emit) {
        if (_entityComponentManager.playersCanContinue()) {
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
      })
      ..on<GameRestartEvent>((event, emit) {
        emit(
          gameBloc.state.copyWith(
            status: GameStatus.gameRestarts,
          ),
        );

        overlays.remove('PauseMenu');
        resumeEngine();
      });

    entityBloc
      ..on<CardUsedEvent>((event, emit) {
        // Get the heat/cold and subtract by the event depending on which one
        // was used at the time
        final heat = event.heat != null
            ? entityBloc.state.entities[event.id]!.heat - event.heat!
            : null;
        final cold = event.cold != null
            ? entityBloc.state.entities[event.id]!.cold - event.cold!
            : null;
        emit(
          entityBloc.state.copyWith(
            id: event.id,
            heat: heat,
            cold: cold,
          ),
        );
      })
      ..on<DamageEvent>((event, emit) {
        if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
          final enemyID = _entityComponentManager.nextPlayerID(event.id);
          final newHealth =
              entityBloc.state.entities[enemyID]!.health - event.damage;

          emit(
            entityBloc.state.copyWith(
              id: enemyID,
              health: newHealth,
            ),
          );
        }
      })
      ..on<HealingEvent>((event, emit) {
        final newHealth =
            entityBloc.state.entities[event.id]!.health + event.health;

        emit(
          entityBloc.state.copyWith(
            id: event.id,
            health: newHealth,
          ),
        );
      })
      ..on<EntityDeath>((event, emit) {
        // Update the entity's ID to dead
        emit(
          entityBloc.state.copyWith(
            id: event.id,
            status: EntityStatus.dead,
          ),
        );

        if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
          // When it's PvP we can simply end the game if anyone dies
          gameBloc.add(const GameOverEvent());
        } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
          // In PvE mode it will be a bit different because we might have
          // different levels and it might be possible to continue
          // playing even if 1 player dies
        }
      });

    // Last thing we do in onLoad is change game state to starting the game
    gameBloc.add(const GameStartsEvent());
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
      // TODO(Tryy3): Move the card spawning logic to here too
      _entityComponentManager.initializePlayerAttributes();
      gameBloc.add(const WaitingForRoundStartsEvent());
    } else if (status == GameStatus.gameRestarts) {
      for (final player in _entityComponentManager.players) {
        await player.clearCards();
      }
      gameBloc.add(const GameStartsEvent());
    } else if (status == GameStatus.roundStarts ||
        (status == GameStatus.inBetweenTurns && timerCounter >= timerLimit)) {
      // Check for next entity to play, by checking current player against who
      // is next and if they are actually able to play again if next player is
      // unable to continue we'll automatically continue with same entity
      // The player order might differ depending on gameMode
      final nextEntityID = _entityComponentManager
          .nextPlayableEntityID(gameBloc.state.currentEntityID);
      gameBloc.add(TurnStartsEvent(currentEntityID: nextEntityID));
    } else if (status == GameStatus.turnStarts) {
      gameBloc.add(
          TurnProcessEvent(currentEntityID: gameBloc.state.currentEntityID));
    } else if (status == GameStatus.turnProcess) {
      gameBloc
          .add(TurnEndsEvent(currentEntityID: gameBloc.state.currentEntityID));
    } else if (status == GameStatus.turnEnds) {
      // Reset the counter everytime
      timerCounter = 0; // Reset counter
      timerLimit = 2; // Set timerLimit

      // Check if there is still anyone that can play
      if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
        if (!_entityComponentManager.playersCanContinue()) {
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
