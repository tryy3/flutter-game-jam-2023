import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/player/player_bloc.dart';
import 'package:starship_shooter/game/bloc/player/player_state.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

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
    required super.size,
    super.position,
    this.side = SideView.left,
  }) : super(anchor: Anchor.center) {
    currentHealth = startHealth;
    startHealth =
        gameRef.playerBloc.state.players[(parent! as Player).id]!.health;
  }

  SideView side;

  late int startHealth;
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
  bool get debugMode => false;

  @override
  void update(double dt) {
    super.update(dt);

    final health = max(0, currentHealth);

    if (renderSprites.length < health) {
      for (var i = renderSprites.length; i < health; i++) {
        final column = i % startHealth;
        final row = (i / startHealth).floorToDouble();

        var x = 0 +
            ((StarshipShooterGame.heartWidth +
                    StarshipShooterGame.heartWidthGap) *
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
    } else if (renderSprites.length > health) {
      for (var i = renderSprites.length; i > health; i--) {
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
      rSprite.sprite.render(
        canvas,
        size: size,
        position: rSprite.position,
        overridePaint: Paint()
          ..color = Colors.white.withOpacity(rSprite.opacity),
      );
    }
  }
}
