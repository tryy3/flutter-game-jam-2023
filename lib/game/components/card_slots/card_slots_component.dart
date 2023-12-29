import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:starship_shooter/game/components/card_slots/card_slots_unit.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class CardSlotsComponent extends PositionComponent
    with HasGameRef<StarshipShooterGame> {
  CardSlotsComponent({required this.side, required this.player, super.position})
      : super(
          anchor: Anchor.center,
        ) {
    size = Vector2(
      StarshipShooterGame.padding +
          StarshipShooterGame.cardHeight +
          StarshipShooterGame.padding,
      StarshipShooterGame.padding +
          ((StarshipShooterGame.cardWidth + StarshipShooterGame.padding) *
              maxCards),
    );

    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(
        StarshipShooterGame.radius,
      ),
    );

    _units = List.generate(
      maxCards,
      (i) => CardSlotsUnit(
        i,
        player: player,
        side: side,
      ),
    );
  }

  // Configuration
  final int maxCards = 5;
  late RRect _rRect;

  // Properties
  List<CardSlotsUnit> _units = [];
  SideView side;
  Player player;

  bool hasActiveCards() {
    for (final unit in _units) {
      if (unit.hasActiveCard()) {
        return true;
      }
    }
    return false;
  }

  CardSlotsUnit firstActiveUnit() {
    return _units.firstWhere((element) => element.hasActiveCard());
  }

  @override
  bool get debugMode => false;

  final title = TextComponent(
    text: 'CARD SLOTS',
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 24,
        color: StarshipShooterGame.lightGrey50,
        fontFamily: '04B_03',
      ),
    ),
  );

  //#region Rendering logic
  @override
  Future<void> onLoad() async {
    final parentPosition = (parent! as PositionComponent).position;
    final viewportSize = gameRef.camera.viewport.size;

    // Render the title text
    await add(title);

    // Set positions based on the side view
    switch (side) {
      case SideView.left:
        final deckPileSize = player.deck.size;
        position = Vector2(
          -parentPosition.x + (size.x / 2) + StarshipShooterGame.margin,
          -parentPosition.y +
              (size.y / 2) +
              StarshipShooterGame.margin +
              deckPileSize.y +
              StarshipShooterGame.margin,
        );

        title
          ..angle = pi / 2
          ..position = Vector2(
            size.x + StarshipShooterGame.margin,
            size.y / 2,
          );
      case SideView.right:
        final deckPileSize = player.deck.size;
        position = Vector2(
          viewportSize.x -
              parentPosition.x -
              (size.x / 2) -
              StarshipShooterGame.margin,
          viewportSize.y -
              parentPosition.y -
              (size.y / 2) -
              StarshipShooterGame.margin -
              deckPileSize.y -
              StarshipShooterGame.margin,
        );

        title
          ..angle = (pi / 2) * 3
          ..position = Vector2(
            -StarshipShooterGame.margin,
            size.y / 2,
          );
    }

    // Add the unit slots at the end of rendering for the logic above
    // to be completed before
    await addAll(_units);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw the initial border around the area
    canvas.drawRRect(_rRect, StarshipShooterGame.borderPaint);

    // Draw border around each playable card area
    for (var i = 0; i < maxCards; i++) {
      canvas.drawRRect(
        StarshipShooterGame.cardRRect.shift(
          Offset(
            StarshipShooterGame.padding,
            StarshipShooterGame.padding +
                i *
                    (StarshipShooterGame.cardWidth +
                        StarshipShooterGame.padding),
          ),
        ),
        StarshipShooterGame.borderPaint,
      );
    }
  }
  //#endregion
}
