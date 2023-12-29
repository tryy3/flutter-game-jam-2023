import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/bloc/player/player_bloc.dart';
import 'package:starship_shooter/game/bloc/player/player_state.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/l10n/l10n.dart';

enum SideView { left, right }

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.gameBloc,
    required this.playerBloc,
  }) {
    images.prefix = '';

    gameBloc.on<RoundStartsEvent>((event, emit) {
      if (player1.canContinue() || player2.canContinue()) {
        emit(
          gameBloc.state.copyWith(
            status: GameStatus.roundStarts,
          ),
        );
      }
    });

    // gameBloc.on<BeginRoundEvent>((event, emit) {
    //   // TODO(tryy3): Move this to wiki
    //   // Event logic works like this:
    //   // 1. Check if any player can continue
    //   // 2. If they can start sending events
    //   // 2-1. Change state to Round starts
    //   // 3. Start processing the turn
    //   // 3-1. Find which player or enemy should begin this turn
    //   // 3-2. Update state to turnStarts and the entity who's turn it is
    //   // 3-3. Update state to turnProcess.
    //   // 3-4. Update state to turnEnds.
    //   // 4. Check if any player can continue
    //   // 4.1 If none can and state is not waitingForRoundStart then update state
    //   // to RoundEnds

    //   // End if none can start
    //   if (!player1.canContinue() && player2.canContinue()) return;

    //   // Begin the round
    //   emit(gameBloc.state.copyWith(status: GameStatus.roundStarts));

    //   // Find out which player or enemy should begin based on GameMode
    //   if (gameBloc.state.gameMode == GameMode.playerVSPlayer) {
    //     var nextEntity = gameBloc.state.currentEntity;
    //     if (gameBloc.state.currentEntity == Entity.player1 &&
    //         player2.canContinue()) {
    //       nextEntity = Entity.player2;
    //     } else if (gameBloc.state.currentEntity == Entity.player2 &&
    //         player1.canContinue()) {
    //       nextEntity = Entity.player1;
    //     }

    //     // TODO(tryy3): Check if we can actually do this many changes...
    //     // maybe move them into sequential events?
    //     emit(gameBloc.state.copyWith(
    //         status: GameStatus.turnStarts, currentEntity: nextEntity));
    //     emit(gameBloc.state.copyWith(
    //         status: GameStatus.turnProcess, currentEntity: nextEntity));
    //     emit(gameBloc.state
    //         .copyWith(status: GameStatus.turnEnds, currentEntity: nextEntity));
    //   } else if (gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
    //     // TODO(tryy3): Implement this...
    //   }
    // });

    // gameBloc.on<StartTurnEvent>((event, emit) {
    //   // Start with changing state to startTurn so that it's always correct
    //   // status when we begin.
    //   emit(gameBloc.state.copyWith(status: GameStatus.startTurn));

    //   // Attempt to find a player starting with lastPlayerId
    //   // doing it in this for loop allows more flexible of multiple players
    //   var playerId = gameBloc.state.lastPlayedId;
    //   for (var i = 0; i < players.length; i++) {
    //     playerId++;
    //     if (playerId >= players.length) playerId = 0;

    //     for (final player in players) {
    //       // If we found a player and the player can actually continue
    //       // Then send a PlayerTurnEvent and add a 2 second delay for next turn
    //       if (player.entity == playerId && player.canContinue()) {
    //         gameBloc.add(PlayerTurnEvent(playerId: player.entity));
    //         timerLimit = 2;
    //         return;
    //       }
    //     }
    //   }

    //     // If we were unable to find any player, then end the turn by sending
    //     // DrawingCards event
    //     gameBloc.add(const DrawingCardsEvent());
    //   });
  }

  final GameBloc gameBloc;
  final PlayerBloc playerBloc;
  bool gameOver = false;

  @override
  bool get debugMode => false;

  // Card settings
  static const double cardGap = 30;
  static const double cardWidth = 63;
  static const double cardHeight = 105;
  static const double cardRadius = 5;
  static final Vector2 cardSize = Vector2(cardHeight, cardWidth);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardHeight, cardWidth),
    const Radius.circular(cardRadius),
  );

  // Unicorn settings
  static const double unicornGap = 100;
  static const double unicornWidth = 100;
  static const double unicornHeight = 100;
  static final Vector2 unicornSize = Vector2(unicornWidth, unicornHeight);

  // Heart settings
  static const double heartWidthGap = 10;
  static const double heartHeightGap = 30;
  static const double heartWidth = 32;
  static const double heartHeight = 32;
  static final Vector2 heartSize = Vector2(heartWidth, heartHeight);
  static const double statsBarsWidth = 32;
  static const double statsBarsLength = 400;

  // Margin padding settings
  static const double margin = 20;
  static const double padding = 20;
  static const double radius = 5;

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
    await add(FpsTextComponent(position: Vector2(0, size.y - 24)));

    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<PlayerBloc, PlayerState>.value(
            value: playerBloc,
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
    // if (status == GameStatus.waitForTurn) {
    //   timerCounter += dt;
    //   if (timerCounter >= timerLimit) {
    //     gameBloc.add(const BeginRoundEvent());
    //     timerCounter = 0;
    //   }
    // }

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

    // TODO(tryy3): Implement here to reset "round", if no player can continue
    // then reset status to waitForTurn
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
