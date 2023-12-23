import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/pile.dart';
import 'package:starship_shooter/game/player/player.dart';

class Card extends PositionComponent
    with DragCallbacks
    implements OpacityProvider {
  Card() : super(anchor: Anchor.center);

  bool _faceUp = false;
  Pile? pile;

  bool get isFaceUp => _faceUp;
  bool get isFaceDown => !_faceUp;
  void flip() => _faceUp = !_faceUp;

  bool _isDragging = false;
  final List<Card> attachedCards = [];

  void useCard(Player player, Player enemy) {}

  double _opacity = 1;

  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) => _opacity = value;

  void drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas
        ..save()
        ..translate(size.x / 2, size.y / 2)
        ..rotate(pi)
        ..translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
      overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
    );
    if (rotate) {
      canvas.restore();
    }
  }

  //#region Dragging
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (pile?.canMoveCard(this) ?? false) {
      _isDragging = true;
      priority = 100;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) {
      return;
    }
    final delta = event.localDelta;
    position.add(delta);
    for (final card in attachedCards) {
      card.position.add(delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    final dropPiles = parent!
        .componentsAtPoint(position + size / 2)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      if (dropPiles.first.canAcceptCard(this)) {
        pile!.removeCard(this);
        dropPiles.first.acquireCard(this);
        if (attachedCards.isNotEmpty) {
          for (final card in attachedCards) {
            dropPiles.first.acquireCard(card);
          }
          attachedCards.clear();
        }
        return;
      }
    }
    pile!.returnCard(this);
    if (attachedCards.isNotEmpty) {
      for (final card in attachedCards) {
        pile!.returnCard(card);
      }
      attachedCards.clear();
    }
  }

  //#endregion
}
