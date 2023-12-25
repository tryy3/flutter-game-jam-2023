import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/cubit/game/game_bloc.dart';
import 'package:starship_shooter/game/cubit/game/game_events.dart';
import 'package:starship_shooter/game/cubit/game/game_state.dart';
import 'package:starship_shooter/game/cubit/player/player_bloc.dart';
import 'package:starship_shooter/game/cubit/player/player_state.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/side_view.dart';
import 'package:starship_shooter/l10n/l10n.dart';

// enum GameState {
//   drawingCards,
//   endDrawingTurn,
//   player1Draws,
//   player2Draws,
//   endPlayerTurn,
// }

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.gameBloc,
    required this.playerBloc,
  }) {
    images.prefix = '';

    gameBloc.on<StartTurnEvent>((event, emit) {
      // Start with changing state to startTurn so that it's always correct
      // status when we begin.
      emit(gameBloc.state.copyWith(status: GameStatus.startTurn));

      // Attempt to find a player starting with lastPlayerId
      // doing it in this for loop allows more flexible of multiple players
      var playerId = gameBloc.state.lastPlayedId;
      for (var i = 0; i < players.length; i++) {
        playerId++;
        if (playerId >= players.length) playerId = 0;

        for (final player in players) {
          // If we found a player and the player can actually continue
          // Then send a PlayerTurnEvent and add a 2 second delay for next turn
          if (player.id == playerId && player.canContinue()) {
            gameBloc.add(PlayerTurnEvent(playerId: player.id));
            timerLimit = 2;
            return;
          }
        }
      }

      // If we were unable to find any player, then end the turn by sending
      // DrawingCards event
      gameBloc.add(const DrawingCardsEvent());
    });
  }

  final GameBloc gameBloc;
  final PlayerBloc playerBloc;
  bool gameOver = false;

  @override
  // TODO: implement debugMode
  bool get debugMode => false;

  static const double cardGap = 30;
  static const double cardWidth = 63;
  static const double cardHeight = 105;
  static const double cardRadius = 5;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  static const double unicornGap = 100;
  static const double unicornWidth = 100;
  static const double unicornHeight = 100;
  static final Vector2 unicornSize = Vector2(unicornWidth, unicornHeight);

  static const double heartWidthGap = 10;
  static const double heartHeightGap = 30;
  static const double heartWidth = 32;
  static const double heartHeight = 32;
  static final Vector2 heartSize = Vector2(heartWidth, heartHeight);

  final AppLocalizations l10n;
  final audio_player.AudioPlayer effectPlayer;
  final TextStyle textStyle;

  double timerCounter = 0;
  double timerLimit = 0;

  int counter = 0;
  // GameState gameState =
  //     GameState.drawingCards; // 0 = placing cards, 1 = end turn
  Timer countdown = Timer(.2);

  List<Player> players = [
    Player(id: 0, side: SideView.left, playerType: PlayerType.hot),
    Player(id: 1, side: SideView.right, playerType: PlayerType.cold),
  ];
  int lastPlayedId = -1;

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
        children: players,
      ),
    );

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);

    final status = gameBloc.state.status;
    if (status == GameStatus.startTurn || status == GameStatus.processTurn) {
      timerCounter += dt;
      if (timerCounter >= timerLimit) {
        gameBloc.add(const StartTurnEvent());
        timerCounter = 0;
      }
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
