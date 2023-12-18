import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/side_view.dart';

class HealthSprite extends OpacityProvider {
  HealthSprite({
    required this.sprite,
    required this.position,
    required this.effect,
  }) {
    effect.target = this;
  }
  Sprite sprite;
  Vector2 position;

  @override
  double opacity = 0;

  OpacityEffect effect;
  bool removing = false;
  // double remove
}

class DynamicHealthComponent extends PositionComponent
    with HasGameRef<StarshipShooterGame> {
  DynamicHealthComponent({
    required this.startHealth,
    this.side = SideView.left,
  }) {
    currentHealth = startHealth;
  }

  SideView side;

  int startHealth;
  late int currentHealth;
  List<HealthSprite> renderSprites = List.empty(growable: true);

  final availableSprite = spriteSheet(288, 4224, 32, 32);
  final unavailableSprite = spriteSheet(192, 4224, 32, 32);
  final extraHealthSprite = spriteSheet(320, 4224, 32, 32);

  @override
  void update(double dt) {
    super.update(dt);

    if (renderSprites.length < currentHealth) {
      for (var i = renderSprites.length; i < currentHealth; i++) {
        final column = i % startHealth;
        final row = (i / startHealth).floorToDouble();

        var x = 0 +
            ((StarshipShooterGame.heartWidth + StarshipShooterGame.heartGap) *
                column);
        if (side == SideView.right) x = -x;

        var y = row *
            (StarshipShooterGame.heartHeight +
                StarshipShooterGame.heartHeightGap);
        if (side == SideView.left) y = -y;

        var sprite = availableSprite;
        if (row > 0) sprite = extraHealthSprite;

        final effect = OpacityEffect.fadeIn(
          EffectController(duration: 1.25),
        );

        final healthSprite = HealthSprite(
          sprite: sprite,
          position: Vector2(x, y),
          effect: effect,
        );

        renderSprites.add(healthSprite);
      }
    } else if (renderSprites.length > currentHealth) {
      for (var i = renderSprites.length; i > currentHealth; i--) {
        final rSprite = renderSprites[i - 1];
        if (rSprite.removing) continue;

        rSprite
          ..removing = true
          ..effect = OpacityEffect.fadeOut(
            EffectController(duration: 1.25),
            target: rSprite,
            onComplete: () {
              renderSprites.remove(rSprite);
            },
          );
      }
    }

    for (final rSprite in renderSprites) {
      rSprite.effect.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final rSprite in renderSprites) {
      drawSprite(
        canvas,
        rSprite.sprite,
        rSprite.position.x,
        rSprite.position.y,
        opacity: rSprite.opacity,
      );
    }
  }

  void drawSprite(
    Canvas canvas,
    Sprite sprite,
    double positionX,
    double positionY, {
    double scale = 1,
    bool rotate = false,
    double opacity = 1,
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
      position: Vector2(positionX, positionY),
      size: sprite.srcSize.scaled(scale),
      overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
    );
    if (rotate) {
      canvas.restore();
    }
  }
}
