import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart' hide OverlayRoute;
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/enemies/boss_enemy.dart';
import 'package:starship_shooter/game/components/enemies/simple_boss.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/entity.dart';
import 'package:starship_shooter/game/entity_component_manager.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/l10n/l10n.dart';

enum SideView { left, right, bottom, bossBottom }

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.gameBloc,
  }) {
    images.prefix = '';
    entityComponentManager = EntityComponentManager(
      gameBloc: gameBloc,
    );
  }

  final GameBloc gameBloc;
  late RouterComponent router;
  late GameConfig config;
  late EntityComponentManager entityComponentManager;

  @override
  bool get debugMode => false;

  static const Color lightBlack80 = Color(0x80000000);
  static const Color lightGrey50 = Color(0x50ffffff);
  static const Color lightGrey70 = Color(0x70ffffff);
  static final borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = lightGrey50;

  final AppLocalizations l10n;
  final audio_player.AudioPlayer effectPlayer;
  final TextStyle textStyle;

  StreamSubscription<GameState>? gameBlocStream;

  double timerCounter = 0;
  double timerLimit = 0;
  int counter = 0;

  @override
  Color backgroundColor() => Colors.grey[900]!;

  @override
  void onDispose() {
    super.onDispose();
    gameBlocStream?.cancel();
    entityComponentManager.onDispose();
  }

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

    // Add entities to the game
    final entities = <Component>[];
    switch (gameBloc.state.playerMode) {
      case PlayerMode.onePlayer:
        entities.add(
          Player(
            side: SideView.bottom,
          ),
        );
      case PlayerMode.twoPlayers:
        entities.add(
          Player(
            side: SideView.left,
          ),
        );
        entities.add(
          Player(
            side: SideView.right,
          ),
        );
    }
    if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
      entities.add(SimpleBoss());
    }
    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<GameBloc, GameState>.value(
            value: gameBloc,
          ),
        ],
        children: entities,
      ),
    );
    for (final entity in entities) {
      entityComponentManager.addEntity(entity as Entity);
    }

    // Center the viewfinder
    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    // When a round start (someone clicks on button) check if any
    // player can actually continue before continuing changing state
    gameBlocStream = gameBloc.stream.listen((event) {
      if (event.status == GameStatus.roundStarts &&
          !entityComponentManager.playersCanContinue()) {
        gameBloc.add(const WaitingForRoundStartsEvent());
      }
      if (event.status == GameStatus.gameOver ||
          event.status == GameStatus.turnEnds) {
        // Reset the counter everytime
        timerCounter = 0; // Reset counter
        timerLimit = GameConfig.delayBetweenRounds; // Set timerLimit
      }
      if (event.status == GameStatus.gameRestarts) {
        overlays.remove('PauseMenu');
        resumeEngine();
      }
    });

    // entityBlocStream = entityBloc.stream.listen((state) {
    //   if (gameBloc.state.status != GameStatus.gameOver) {
    //     // Check for game over state, in PvP mode this will be if anyone dies
    //     // in PvE mode it will be when either the boss is dead or when all
    //     // players are dead
    //     if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
    //       final deadPlayers = state.entities.entries
    //           .where((element) => element.value.status == EntityStatus.dead);
    //       if (deadPlayers.isNotEmpty) {
    //         gameBloc.add(const GameOverEvent());
    //       }
    //     }
    //   }
    // });

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
    if (status == GameStatus.inBetweenTurns ||
        status == GameStatus.roundEnds ||
        status == GameStatus.gameOver) {
      timerCounter += dt;
    }

    // Check for game over state, in PvP mode this will be if anyone dies
    // in PvE mode it will be when either the boss is dead or when all
    // players are dead
    if (gameBloc.state.isGameStarted()) {
      if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
        final deadPlayers = entityComponentManager.findDeadPlayerEntities();
        if (deadPlayers.isNotEmpty) {
          gameBloc.add(const GameOverEvent());
        }
      } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
        // First check if boss is dead
        final deadBosses = entityComponentManager.findDeadBosses();
        if (deadBosses.isNotEmpty) {
          gameBloc.add(const GameOverEvent());
          return;
        }

        // Next check if there is still any players alive
        final alivePlayers = entityComponentManager.findAlivePlayerEntities();
        if (alivePlayers.isEmpty) {
          gameBloc.add(const GameOverEvent());
          return;
        }
      }
    }

    if (status == GameStatus.gameStarts) {
      // TODO(tryy3): Maybe check if game is fully loaded at this point?
      entityComponentManager.spawnEntities();
      gameBloc.add(const WaitingForRoundStartsEvent());
    } else if (status == GameStatus.gameRestarts) {
      for (final player in entityComponentManager.players) {
        await player.clearCards();
      }
      gameBloc.add(const GameStartsEvent());
    } else if (status == GameStatus.gameOver && timerCounter >= timerLimit) {
      overlays.add('PauseMenu');
      pauseEngine();
    } else if (status == GameStatus.roundStarts ||
        (status == GameStatus.inBetweenTurns && timerCounter >= timerLimit)) {
      // Check for next entity to play, by checking current player against who
      // is next and if they are actually able to play again if next player is
      // unable to continue we'll automatically continue with same entity
      // The player order might differ depending on gameMode
      final nextEntityID = entityComponentManager
          .nextPlayableEntityID(gameBloc.state.currentEntityID);
      gameBloc.add(TurnStartsEvent(currentEntityID: nextEntityID));
    } else if (status == GameStatus.turnStarts) {
      gameBloc.add(
        TurnProcessEvent(currentEntityID: gameBloc.state.currentEntityID),
      );
    } else if (status == GameStatus.turnProcess) {
      gameBloc
          .add(TurnEndsEvent(currentEntityID: gameBloc.state.currentEntityID));
    } else if (status == GameStatus.turnEnds) {
      // Check if there is still anyone that can play
      if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
        if (!entityComponentManager.playersCanContinue()) {
          gameBloc.add(const RoundEndsEvent());
        } else {
          // Someone can continue, go to inBetweenTurns and reset timerCounter
          gameBloc.add(const InBetweenTurnsEvent());
        }
      } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
        // We need to determine if we can continue playing or if the round is
        // round is over.
        // Normally to check who the next entity is we go by ID and start with
        // last playedEntity.
        // If lastPlayed entity was a Player and next one is a boss then boss
        // should always play
        // But if last played was the boss and player can't continue then we
        // need to end
        // So we only really need to check if nextPlayableEntity is a boss and
        // lastPlayedEntity was a boss
        final nextPlayableEntity = entityComponentManager
            .nextPlayableEntity(gameBloc.state.currentEntityID);
        final lastPlayedEntity =
            entityComponentManager.findEntity(gameBloc.state.currentEntityID);
        if (nextPlayableEntity is BossEnemy && lastPlayedEntity is BossEnemy) {
          gameBloc.add(const RoundEndsEvent());
        } else {
          // Someone can continue, go to inBetweenTurns and reset timerCounter
          gameBloc.add(const InBetweenTurnsEvent());
        }
      }
    } else if (status == GameStatus.roundEnds && timerCounter >= timerLimit) {
      gameBloc.add(const WaitingForRoundStartsEvent());
    }
  }
}

Sprite spriteSheet(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('assets/images/sprite_sheet.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
