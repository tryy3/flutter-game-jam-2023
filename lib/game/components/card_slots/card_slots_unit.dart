import 'dart:async';

import 'package:flame/components.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/pile.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class CardSlotsUnit extends PositionComponent
    with HasGameRef<StarshipShooterGame>
    implements Pile {
  CardSlotsUnit(
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
    size = gameRef.config.cardSize;

    // Set positions based on the side view
    switch (side) {
      case SideView.left:
        position = Vector2(
          (size.x / 2) + gameRef.config.padding,
          (size.y / 2) +
              gameRef.config.padding +
              (unitSlot * (gameRef.config.padding + gameRef.config.cardWidth)),
        );
      case SideView.right:
        final parentSize = (parent! as PositionComponent).size;
        position = Vector2(
          parentSize.x - (size.x / 2) - gameRef.config.padding,
          parentSize.y -
              (size.y / 2) -
              gameRef.config.padding -
              (unitSlot * (gameRef.config.padding + gameRef.config.cardWidth)),
        );
      case SideView.bottom:
      // TODO(tryy3): Handle this case.
    }
  }
  //#endregion
}
