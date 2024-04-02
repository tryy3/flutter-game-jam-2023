import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/text.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/deck_pile/deck_pile_unit.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class DeckComponent extends PositionComponent
    with HasGameRef<StarshipShooterGame> {
  DeckComponent({required this.side, required this.player, super.position})
      : super(
          anchor: Anchor.center,
        ) {
    _units = List.generate(
      maxCards,
      (index) => DeckPileUnit(index, side: side, player: player),
    );
  }

  // Configuration
  final int maxColumns = 4;
  final int maxCards = 12;
  late RRect _rRect;

  // Properties
  List<DeckPileUnit> _units = [];
  SideView side;
  Player player;

  @override
  bool get debugMode => false;

  //#region Deck Component API
  // Attempt to add card to next unit that dont have active card
  // if unable to add to any (no empty units) then it will return false
  bool addCard(Card card) {
    for (final unit in _units) {
      if (!unit.hasActiveCard()) {
        unit.acquireCard(card);
        return true;
      }
    }
    return false;
  }

  bool hasActiveCards() {
    for (final unit in _units) {
      if (unit.hasActiveCard()) {
        return true;
      }
    }
    return false;
  }

  // sortCards will go through all the cards and sort them by order
  void sortCards() {
    // Create a temporary list of cards to store
    final cards = <Card>[];

    for (final unit in _units) {
      if (unit.hasActiveCard()) {
        final card = unit.getFirstCard()!; // Retrieve the card
        unit.removeCard(card); // Remove the card from the current unit
        cards.add(card);
      }
    }

    // Add them back to the units based on order
    for (var i = 0; i < cards.length; i++) {
      _units[i].acquireCard(cards[i]);
    }
  }
  //#endRegion

  //#region Rendering logic
  final title = TextComponent(
    text: 'DECK',
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
    final columns = maxColumns;
    final rows = (maxCards / maxColumns).floorToDouble();

    size = Vector2(
      gameRef.config.padding +
          rows * (gameRef.config.cardHeight + gameRef.config.padding),
      gameRef.config.padding +
          columns * (gameRef.config.cardWidth + gameRef.config.padding),
    );

    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(
        gameRef.config.radius,
      ),
    );

    final viewportSize = gameRef.camera.viewport.size;
    final parentPosition = (parent! as PositionComponent).position;
    await add(title);

    switch (side) {
      case SideView.left:
        position = Vector2(
          -parentPosition.x + (size.x / 2) + gameRef.config.margin,
          -parentPosition.y + (size.y / 2) + gameRef.config.margin,
        );

        title.angle = pi / 2;
        title.position = Vector2(
          size.x + gameRef.config.margin,
          size.y / 2,
        );
      case SideView.right:
        position = Vector2(
          viewportSize.x -
              parentPosition.x -
              (size.x / 2) -
              gameRef.config.margin,
          viewportSize.y -
              parentPosition.y -
              (size.y / 2) -
              gameRef.config.margin,
        );

        title.angle = (pi / 2) * 3;
        title.position = Vector2(
          -gameRef.config.margin,
          size.y / 2,
        );
      case SideView.bottom:
      // TODO(tryy3): Handle this case.
    }

    // Add the unit slots at the end of rendering for the logic above
    // to be completed before
    await addAll(_units);
  }

  @override
  void render(Canvas canvas) {
    // Draw the initial border around the area
    canvas.drawRRect(_rRect, StarshipShooterGame.borderPaint);

    // Draw border around each playable card area
    for (var i = 0; i < maxCards; i++) {
      final column = i % maxColumns;
      final row = (i / maxColumns).floorToDouble();

      canvas.drawRRect(
        gameRef.config.cardRRect.shift(
          Offset(
            gameRef.config.padding +
                row * (gameRef.config.cardHeight + gameRef.config.padding),
            gameRef.config.padding +
                column * (gameRef.config.cardWidth + gameRef.config.padding),
          ),
        ),
        StarshipShooterGame.borderPaint,
      );
    }
  }
  //#endregion
}
