import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/pile.dart';
import 'package:starship_shooter/game/player/player.dart';

class Card extends PositionComponent implements OpacityProvider {
  bool _faceUp = false;
  Pile? pile;

  bool get isFaceUp => _faceUp;
  bool get isFaceDown => !_faceUp;
  void flip() => _faceUp = !_faceUp;

  void useCard(Player player, Player enemy) {}

  void updatePile(Pile pile) {
    this.pile = pile;
  }

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
}
