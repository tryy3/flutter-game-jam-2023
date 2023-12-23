import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/cubit/player/player_bloc.dart';
import 'package:starship_shooter/game/cubit/player/player_state.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/player/player.dart';
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
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<PlayerBloc, PlayerState> {
  DynamicHealthComponent({
    required super.position,
    required super.size,
    required this.startHealth,
    this.side = SideView.left,
  }) : super(anchor: Anchor.center) {
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
  void onNewState(PlayerState state) {
    currentHealth = state.players[(parent! as Player).id]!.health;
  }

  @override
  // TODO: implement debugMode
  bool get debugMode => true;

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

    for (var i = 0; i < renderSprites.length; i++) {
      final rSprite = renderSprites[i];
      rSprite.effect.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final rSprite in renderSprites) {
      // canvas
      //   ..save()
      //   ..translate(-)
      rSprite.sprite.render(
        canvas,
        size: size,
        position: rSprite.position,
        overridePaint: Paint()
          ..color = Colors.white.withOpacity(rSprite.opacity),
      );
      // drawSprite(
      //   canvas,
      //   rSprite.sprite,
      //   rSprite.position.x,
      //   rSprite.position.y,
      //   opacity: rSprite.opacity,
      // );
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
    final spriteSize = sprite.srcSize.scaled(scale);
    canvas
      ..save()
      ..translate(-spriteSize.x / 2, -spriteSize.y / 2);
    sprite.render(
      canvas,
      position: Vector2(positionX, positionY),
      size: spriteSize,
      overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
    );
    canvas.restore();
  }
}
