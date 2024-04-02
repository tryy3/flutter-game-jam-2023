import 'dart:async';

import 'package:flame/components.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/pile.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class DeckPileUnit extends PositionComponent
    with HasGameRef<StarshipShooterGame>
    implements Pile {
  DeckPileUnit(
    this.unitSlot, {
    required this.side,
    required this.player,
    super.position,
  }) : super(
          anchor: Anchor.center,
        );

  // Properties
  Card? _card;
  int unitSlot;
  SideView side;
  Player player;

  @override
  bool get debugMode => false;

  bool hasActiveCard() {
    return _card != null;
  }

  //#region Pile API
  @override
  void acquireCard(Card card) {
    card
      ..pile = this
      ..priority = 0
      ..position = absolutePosition;
    _card = card;
  }

  @override
  bool canAcceptCard(Card card) {
    if (!player.ownsCard(card)) return false;
    if (_card != null) return false;
    return true;
  }

  @override
  bool canMoveCard(Card card) => _card != null;

  @override
  void removeCard(Card card) {
    if (!canMoveCard(card)) return;
    _card = null;
  }

  @override
  void returnCard(Card card) {
    card
      ..position = absolutePosition
      ..priority = 0;
  }

  @override
  Card? getFirstCard() {
    return _card;
  }
  //#endregion

  //#region Rendering logic
  @override
  Future<void> onLoad() async {
    size = (side == SideView.bottom)
        ? gameRef.config.normalCardSize
        : gameRef.config.rotatedCardSize;

    // Set positions based on the side view
    final column = unitSlot % player.deck.maxColumns;
    final row = (unitSlot / player.deck.maxColumns).floorToDouble();

    switch (side) {
      case SideView.left:
        final parentSize = (parent! as PositionComponent).size;
        position = Vector2(
          (size.x / 2) +
              gameRef.config.padding +
              (row * (gameRef.config.cardHeight + gameRef.config.padding)),
          parentSize.y -
              (size.y / 2) -
              gameRef.config.padding -
              (column * (gameRef.config.padding + gameRef.config.cardWidth)),
        );
      case SideView.right:
        final parentSize = (parent! as PositionComponent).size;
        position = Vector2(
          parentSize.x -
              (size.x / 2) -
              gameRef.config.padding -
              (row * (gameRef.config.cardHeight + gameRef.config.padding)),
          (size.y / 2) +
              gameRef.config.padding +
              (column * (gameRef.config.padding + gameRef.config.cardWidth)),
        );
      case SideView.bottom:
        final parentSize = (parent! as PositionComponent).size;
        position = Vector2(
          parentSize.x -
              (size.x / 2) -
              gameRef.config.padding -
              (column * (gameRef.config.padding + gameRef.config.cardWidth)),
          parentSize.y -
              (size.y / 2) -
              gameRef.config.padding -
              (row * (gameRef.config.cardHeight + gameRef.config.padding)),
        );
      case SideView.bossBottom:
    }
  }
  //#endregion
}
