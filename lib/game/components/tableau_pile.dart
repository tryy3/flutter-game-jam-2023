import 'dart:ui';

import 'package:flame/components.dart';
import 'package:starship_shooter/game/card.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/pile.dart';

class TableauPile extends PositionComponent implements Pile {
  TableauPile({super.position}) : super(size: StarshipShooterGame.cardSize);

  /// Which cards are currently placed onto this pile.
  final List<Card> _cards = [];
  final Vector2 _fanOffset1 = Vector2(0, StarshipShooterGame.cardHeight * 0.05);
  final Vector2 _fanOffset2 = Vector2(0, StarshipShooterGame.cardHeight * 0.20);

  @override
  // TODO: implement debugMode
  bool get debugMode => true;
  //#region Pile API

  @override
  bool canMoveCard(Card card) => card.isFaceUp;

  @override
  bool canAcceptCard(Card card) {
    return true;
    // if (_cards.isEmpty) {
    //   return card.rank.value == 13;
    // } else {
    //   final topCard = _cards.last;
    //   return card.suit.isRed == !topCard.suit.isRed &&
    //       card.rank.value == topCard.rank.value - 1;
    // }
  }

  @override
  void removeCard(Card card) {
    assert(_cards.contains(card) && card.isFaceUp);
    final index = _cards.indexOf(card);
    _cards.removeRange(index, _cards.length);
    if (_cards.isNotEmpty && _cards.last.isFaceDown) {
      flipTopCard();
    }
    layOutCards();
  }

  @override
  void returnCard(Card card) {
    // card.priority = _cards.indexOf(card);
    layOutCards();
  }

  @override
  void acquireCard(Card card) {
    card.updatePile(this);
    // card.priority = _cards.length;
    _cards.add(card);
    layOutCards();
  }

  //#endregion

  void flipTopCard() {
    assert(_cards.last.isFaceDown);
    _cards.last.flip();
  }

  void layOutCards() {
    if (_cards.isEmpty) {
      return;
    }
    _cards[0].position.setFrom(position);
    for (var i = 1; i < _cards.length; i++) {
      _cards[i].position
        ..setFrom(_cards[i - 1].position)
        ..add(_cards[i - 1].isFaceDown ? _fanOffset1 : _fanOffset2);
    }
    height = StarshipShooterGame.cardHeight * 1.5 +
        (_cards.last as PositionComponent).y -
        (_cards.first as PositionComponent).y;
  }

  List<Card> cardsOnTop(Card card) {
    assert(card.isFaceUp && _cards.contains(card));
    final index = _cards.indexOf(card);
    return _cards.getRange(index + 1, _cards.length).toList();
  }

  //#region Rendering

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(StarshipShooterGame.cardRRect, _borderPaint);
  }

  //#endregion
}
