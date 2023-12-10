import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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
  }) {
    images.prefix = '';
  }

  static const double cardGap = 40;
  static const double cardWidth = 70;
  static const double cardHeight = 110;
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
  static const double heartHeightGap = 20;
  static const double heartWidth = 20;
  static const double heartHeight = 20;
  static final Vector2 heartSize = Vector2(heartWidth, heartHeight);

  final AppLocalizations l10n;
  final AudioPlayer effectPlayer;
  final TextStyle textStyle;

  int counter = 0;
  GameState gameState =
      GameState.drawingCards; // 0 = placing cards, 1 = end turn
  Timer countdown = Timer(.2);

  final Player player1 = Player(id: 1, side: SideView.left);
  final Player player2 = Player(id: 1, side: SideView.right);

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  void endTurn() {
    gameState = GameState.endDrawingTurn;
  }

  @override
  Future<void> onLoad() async {
    await images.load('images/klondike_sprites.png');

    final world = World(
      children: [],
    );

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    await player1.generatePlayer(world, camera);
    await player2.generatePlayer(world, camera);
  }

  @override
  void update(double dt) {
    super.update(dt);
    countdown.update(dt);

    if (gameState != GameState.drawingCards) {
      if (countdown.finished) {
        // Probably... not the best way to make a "delay"
        countdown = Timer(.2);

        // Different game states of the current turn
        if (gameState == GameState.endDrawingTurn) {
          gameState = GameState.player1Draws;
        } else if (gameState == GameState.player1Draws) {
          player1.startTurn(player2);
          gameState = GameState.player2Draws;
        } else if (gameState == GameState.player2Draws) {
          player2.startTurn(player1);
          gameState = GameState.player1Draws;
        } else if (gameState == GameState.endPlayerTurn) {
          gameState = GameState.drawingCards;
          return;
        }
        // Check if neither player 1 or player 2 can continue
        if (player1.canNotContinue() && player2.canNotContinue()) {
          gameState = GameState.endPlayerTurn;
          return;
        }
      }
    }
  }

  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );

  // @override
  // void render(Canvas canvas) {
  //   textPaint.render(
  //     canvas,
  //     "Countdown: ${countdown.current.toString()}",
  //     Vector2(10, 100),
  //   );
  // }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('images/klondike_sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
