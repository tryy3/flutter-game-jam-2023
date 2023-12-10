import 'dart:ui';

import 'package:flame/components.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/pile.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/suit.dart';

class FoundationPile extends PositionComponent implements Pile {
  FoundationPile(int intSuit, {required this.player, super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: StarshipShooterGame.cardSize);

  final Suit suit;
  final List<Card> _cards = [];
  Player player;

  //#region Pile API

  @override
  bool canMoveCard(Card card) {
    return _cards.isNotEmpty && card == _cards.last;
  }

  @override
  bool canAcceptCard(Card card) {
    if (_cards.isNotEmpty) return false;
    if (!player.ownsCard(card)) return false;
    return true;
    // final topCardRank = _cards.isEmpty ? 0 : _cards.last.rank.value;
    // return card.suit == suit &&
    //     card.rank.value == topCardRank + 1 &&
    //     card.attachedCards.isEmpty;
  }

  @override
  void removeCard(Card card) {
    assert(canMoveCard(card));
    _cards.removeLast();
  }

  @override
  void returnCard(Card card) {
    card.position = position;
    card.priority = _cards.indexOf(card);
  }

  @override
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    card.pile = this;
    _cards.add(card);
  }

  //#endregion

  //#region Foundation Logic
  bool isEmpty() {
    return _cards.isEmpty;
  }

  bool isNotEmpty() {
    return !isEmpty();
  }

  Card getTopCard() {
    return _cards.last;
  }
  //#endregion

  //#region Rendering

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed ? const Color(0x3a000000) : const Color(0x64000000)
    ..blendMode = BlendMode.luminosity;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(StarshipShooterGame.cardRRect, _borderPaint);
    suit.sprite.render(
      canvas,
      position: size / 2,
      anchor: Anchor.center,
      size: Vector2.all(StarshipShooterGame.cardWidth * 0.6),
      overridePaint: _suitPaint,
    );
  }

  //#endregion
}
