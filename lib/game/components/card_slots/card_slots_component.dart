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

  @override
  bool get debugMode => false;

  //#region Card Slot API
  /// Tries to find the first playable card slot.
  ///
  /// It will be based on the players heat/cold source to check for
  /// any cards that can be used with current value
  CardSlotsUnit? firstPlayableCardSlot() {
    for (final unit in _units) {
      final card = unit.getFirstCard();

      // Check if player stats source is enough to use this card
      if (card != null &&
          (card.heat <= 0 || player.heat >= card.heat) &&
          (card.cold <= 0 || player.cold >= card.cold)) {
        return unit;
      }
    }
    return null;
  }

  bool hasPlayableCards() {
    return firstPlayableCardSlot() != null;
  }
  //#endregion

  //#region Rendering logic
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

  @override
  Future<void> onLoad() async {
    size = Vector2(
      gameRef.config.padding +
          gameRef.config.cardHeight +
          gameRef.config.padding,
      gameRef.config.padding +
          ((gameRef.config.cardWidth + gameRef.config.padding) * maxCards),
    );

    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(
        gameRef.config.radius,
      ),
    );

    final parentPosition = (parent! as PositionComponent).position;
    final viewportSize = gameRef.camera.viewport.size;

    // Render the title text
    await add(title);

    // Set positions based on the side view
    switch (side) {
      case SideView.left:
        final deckPileSize = player.deck.size;
        position = Vector2(
          -parentPosition.x + (size.x / 2) + gameRef.config.margin,
          -parentPosition.y +
              (size.y / 2) +
              gameRef.config.margin +
              deckPileSize.y +
              gameRef.config.margin,
        );

        title
          ..angle = pi / 2
          ..position = Vector2(
            size.x + gameRef.config.margin,
            size.y / 2,
          );
      case SideView.right:
        final deckPileSize = player.deck.size;
        position = Vector2(
          viewportSize.x -
              parentPosition.x -
              (size.x / 2) -
              gameRef.config.margin,
          viewportSize.y -
              parentPosition.y -
              (size.y / 2) -
              gameRef.config.margin -
              deckPileSize.y -
              gameRef.config.margin,
        );

        title
          ..angle = (pi / 2) * 3
          ..position = Vector2(
            -gameRef.config.margin,
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
        gameRef.config.cardRRect.shift(
          Offset(
            gameRef.config.padding,
            gameRef.config.padding +
                i * (gameRef.config.cardWidth + gameRef.config.padding),
          ),
        ),
        StarshipShooterGame.borderPaint,
      );
    }
  }
  //#endregion
}
