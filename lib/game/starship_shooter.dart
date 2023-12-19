import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/cubit/game/game_stats_bloc.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/side_view.dart';
import 'package:starship_shooter/l10n/l10n.dart';

enum GameState {
  drawingCards,
  endDrawingTurn,
  player1Draws,
  player2Draws,
  endPlayerTurn,
}

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.statsBloc,
  }) {
    images.prefix = '';
  }

  final GameStatsBloc statsBloc;
  bool gameOver = false;

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

  static const double heartGap = 10;
  static const double heartHeightGap = 10;
  static const double heartWidth = 32;
  static const double heartHeight = 32;
  static final Vector2 heartSize = Vector2(heartWidth, heartHeight);

  final AppLocalizations l10n;
  final AudioPlayer effectPlayer;
  final TextStyle textStyle;

  double timerCounter = 0;
  double timerLimit = 0;

  int counter = 0;
  GameState gameState =
      GameState.drawingCards; // 0 = placing cards, 1 = end turn
  Timer countdown = Timer(.2);

  final Player player1 =
      Player(id: 1, side: SideView.left, playerType: PlayerType.hot);
  final Player player2 =
      Player(id: 1, side: SideView.right, playerType: PlayerType.cold);

  @override
  Color backgroundColor() => Colors.grey[900]!;

  void endTurn() {
    gameState = GameState.endDrawingTurn;
  }

  @override
  Future<void> onLoad() async {
    await images.load('assets/images/sprite_sheet.png');

    final world = World(
      children: [],
    );

    // final camera = CameraComponent.withFixedResolution(
    //   world: world,
    //   width: 1920,
    //   height: 1080,
    // );
    final camera = CameraComponent(
      world: world,
    );

    await addAll([world, camera]);
    await add(FpsTextComponent(position: Vector2(0, size.y - 24)));

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    await player1.generatePlayer(world, camera);
    await player2.generatePlayer(world, camera);
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);

    if (gameState != GameState.drawingCards) timerCounter += dt;

    if (gameState != GameState.drawingCards) {
      if (timerCounter >= timerLimit) {
        timerCounter = 0;

        // Check if neither player 1 or player 2 can continue
        if (player1.canNotContinue() && player2.canNotContinue()) {
          gameState = GameState.drawingCards;
          return;
        } else if (gameState == GameState.player1Draws &&
            player1.canNotContinue()) {
          gameState = GameState.player2Draws;
        } else if (gameState == GameState.player2Draws &&
            player2.canNotContinue()) {
          gameState = GameState.player1Draws;
        }

        // Different game states of the current turn
        if (gameState == GameState.endDrawingTurn) {
          gameState = GameState.player1Draws;
        } else if (gameState == GameState.player1Draws) {
          player1.startTurn(player2);
          gameState = GameState.player2Draws;
          timerLimit = 2;
        } else if (gameState == GameState.player2Draws) {
          player2.startTurn(player1);
          gameState = GameState.player1Draws;
          timerLimit = 2;
        } else if (gameState == GameState.endPlayerTurn) {
          gameState = GameState.drawingCards;
          timerLimit = 0;
          return;
        }
      }
    } else if (!gameOver) {
      if (player1.isGameOver() || player2.isGameOver()) {
        gameOver = true;
        statsBloc.add(const GameOver());
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
