import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/text.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/card_slots/card_slots_unit.dart';
import 'package:starship_shooter/game/components/deck_pile/deck_unit.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class DeckPile extends PositionComponent with HasGameRef<StarshipShooterGame> {
  DeckPile({required this.side, required this.player, super.position})
      : super(
          anchor: Anchor.center,
        ) {
    final columns = maxColumns;
    final rows = (maxCards / maxColumns).floorToDouble();

    size = Vector2(
      StarshipShooterGame.padding +
          rows * (StarshipShooterGame.cardHeight + StarshipShooterGame.padding),
      StarshipShooterGame.padding +
          columns *
              (StarshipShooterGame.cardWidth + StarshipShooterGame.padding),
    );

    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(
        StarshipShooterGame.radius,
      ),
    );

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

  void addCard(int index, Card card) => _units[index].acquireCard(card);

  @override
  bool get debugMode => false;

  //#region Rendering logic
  @override
  Future<void> onLoad() async {
    final viewportSize = gameRef.camera.viewport.size;
    final parentPosition = (parent! as PositionComponent).position;

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
    await add(title);

    switch (side) {
      case SideView.left:
        position = Vector2(
          -parentPosition.x + (size.x / 2) + StarshipShooterGame.margin,
          -parentPosition.y + (size.y / 2) + StarshipShooterGame.margin,
        );

        title.angle = pi / 2;
        title.position = Vector2(
          size.x + StarshipShooterGame.margin,
          size.y / 2,
        );
      case SideView.right:
        position = Vector2(
          viewportSize.x -
              parentPosition.x -
              (size.x / 2) -
              StarshipShooterGame.margin,
          viewportSize.y -
              parentPosition.y -
              (size.y / 2) -
              StarshipShooterGame.margin,
        );

        title.angle = (pi / 2) * 3;
        title.position = Vector2(
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
    // Draw the initial border around the area
    canvas.drawRRect(_rRect, StarshipShooterGame.borderPaint);

    // Draw border around each playable card area
    for (var i = 0; i < maxCards; i++) {
      final column = i % maxColumns;
      final row = (i / maxColumns).floorToDouble();

      canvas.drawRRect(
        StarshipShooterGame.cardRRect.shift(Offset(
          StarshipShooterGame.padding +
              row *
                  (StarshipShooterGame.cardHeight +
                      StarshipShooterGame.padding),
          StarshipShooterGame.padding +
              column *
                  (StarshipShooterGame.cardWidth + StarshipShooterGame.padding),
        )),
        StarshipShooterGame.borderPaint,
      );
    }
  }
  //#endregion
}
