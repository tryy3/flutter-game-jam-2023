import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import 'package:starship_shooter/game/card.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/pile.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class StockPile extends PositionComponent with TapCallbacks implements Pile {
  StockPile({required super.position, required this.player})
      : super(anchor: Anchor.topLeft, size: StarshipShooterGame.cardSize);

  /// Which cards are currently placed onto this pile. The first card in the
  /// list is at the bottom, the last card is on top.
  final List<Card> _cards = [];
  final Player player;

  //#region Pile API

  @override
  bool canMoveCard(Card card) => false;

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card) => throw StateError('cannot remove cards');

  @override
  void returnCard(Card card) => throw StateError('cannot remove cards');

  @override
  void acquireCard(Card card) {
    assert(card.isFaceDown);
    card
      ..updatePile(this)
      ..position = position;
    (card as Component).priority = _cards.length;
    _cards.add(card);
  }

  //#endregion

  @override
  void onTapUp(TapUpEvent event) {
    final wastePile = player.waste;
    if (_cards.isEmpty) {
      wastePile.removeAllCards().reversed.forEach((card) {
        card.flip();
        acquireCard(card);
      });
    } else {
      for (var i = 0; i < 3; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          wastePile.acquireCard(card);
        }
      }
    }
  }

  //#region Rendering

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..color = const Color(0x883F5B5D);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(StarshipShooterGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      StarshipShooterGame.cardWidth * 0.3,
      _circlePaint,
    );
  }

  //#endregion
}
