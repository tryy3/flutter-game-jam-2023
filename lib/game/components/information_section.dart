import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class InformationSection extends PositionComponent
    with HasGameRef<StarshipShooterGame> {
  InformationSection({required this.side, required this.player, super.position})
      : super(anchor: Anchor.center);

  // Properties
  SideView side;
  Player player;
  late RRect _rRect;

  @override
  bool get debugMode => false;

  final title = TextComponent(
    text: 'INFORMATION',
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 24,
        color: StarshipShooterGame.lightGrey50,
        fontFamily: '04B_03',
      ),
    ),
  );

  //#region Rendering
  @override
  Future<void> onLoad() async {
    // Render the title text
    await add(title);

    // Then position it so it's above cardSlot
    switch (side) {
      case SideView.left:
        // Create the size so that it takes up whatever is left between the deck
        // and stats bar
        size = Vector2(
          player.deck.absolutePositionOfAnchor(Anchor.centerRight).x -
              player.cardSlots.absolutePositionOfAnchor(Anchor.centerRight).x -
              (gameRef.config.margin * 2),
          player.statsBars.absolutePositionOfAnchor(Anchor.topCenter).y -
              player.deck.absolutePositionOfAnchor(Anchor.bottomCenter).y -
              (gameRef.config.margin * 2),
        );

        position = absoluteToLocal(
          player.cardSlots.absolutePositionOfAnchor(Anchor.topRight),
        )..add(
            Vector2(
              gameRef.config.margin * 2,
              0,
            ),
          );

        title
          ..angle = pi / 2
          ..position = Vector2(
            size.x + gameRef.config.margin,
            size.y / 2,
          );
      case SideView.right:
        // Create the size so that it takes up whatever is left between the deck
        // and stats bar
        size = Vector2(
          player.cardSlots.absolutePositionOfAnchor(Anchor.centerLeft).x -
              player.deck.absolutePositionOfAnchor(Anchor.centerLeft).x -
              (gameRef.config.margin * 2),
          player.deck.absolutePositionOfAnchor(Anchor.topCenter).y -
              player.statsBars.absolutePositionOfAnchor(Anchor.bottomCenter).y -
              (gameRef.config.margin * 2),
        );

        position = absoluteToLocal(
          player.cardSlots.absolutePositionOfAnchor(Anchor.topLeft),
        )..add(
            Vector2(
              -size.x - (gameRef.config.margin * 2),
              0,
            ),
          );

        title
          ..angle = (pi / 2) * 3
          ..position = Vector2(
            -gameRef.config.margin,
            size.y / 2,
          );
      case SideView.bottom:
      // TODO: Handle this case.
    }

    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(
        gameRef.config.radius,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw the initial border around the area
    canvas.drawRRect(_rRect, StarshipShooterGame.borderPaint);
  }
  //#endregion
}
