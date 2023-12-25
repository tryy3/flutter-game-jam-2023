import 'dart:ui';

import 'package:flame/components.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/pile.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class FoundationPile extends PositionComponent implements Pile {
  FoundationPile(this.intSuit, {required this.player, super.position})
      : super(size: StarshipShooterGame.cardSize, anchor: Anchor.center);

  final List<Card> _cards = [];
  Player player;
  int intSuit;

  //#region Pile API
  @override
  // TODO: implement debugMode
  bool get debugMode => false;

  @override
  bool canMoveCard(Card card) {
    return _cards.isNotEmpty && card == _cards.last;
  }

  @override
  bool canAcceptCard(Card card) {
    if (_cards.isNotEmpty) return false;
    if (!player.ownsCard(card)) return false;
    return true;
  }

  @override
  void removeCard(Card card) {
    if (!canMoveCard(card)) return;
    _cards.removeLast();
  }

  @override
  void returnCard(Card card) {
    card
      ..position = position
      ..priority = _cards.indexOf(card);
  }

  @override
  void acquireCard(Card card) {
    if (card.isFaceDown) return;
    card
      ..pile = this
      ..position = position
      ..priority = _cards.length;
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

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(StarshipShooterGame.cardRRect, _borderPaint);
  }
  //#endregion
}
