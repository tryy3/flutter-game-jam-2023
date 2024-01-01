import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/entities/unicorn/behaviors/tapping_behavior.dart';
import 'package:starship_shooter/game/starship_shooter.dart';
import 'package:starship_shooter/gen/assets.gen.dart';

class Unicorn extends PositionedEntity with HasGameRef<StarshipShooterGame> {
  Unicorn({required this.side, required this.player})
      : super(
          anchor: Anchor.center,
          behaviors: [
            TappingBehavior(),
          ],
        );

  SideView side;
  Player player;
  late SpriteAnimationComponent _animationComponent;

  @override
  bool get debugMode => false;

  @visibleForTesting
  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  @override
  Future<void> onLoad() async {
    size = gameRef.config.unicornSize;

    final animation = await gameRef.loadSpriteAnimation(
      Assets.images.unicornAnimation.path,
      SpriteAnimationData.sequenced(
        amount: 16,
        stepTime: 0.1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );

    await add(
      _animationComponent = SpriteAnimationComponent(
        animation: animation,
        size: size,
      ),
    );

    switch (side) {
      case SideView.left:
        position = Vector2(
          (size.x / 2) +
              gameRef.config.padding +
              player.deck.size.x +
              gameRef.config.padding,
          0,
        );
        _animationComponent
          ..angle = pi / 2
          ..position = Vector2(_animationComponent.size.x, y);
      case SideView.right:
        position = Vector2(
          -(size.x / 2) -
              gameRef.config.padding -
              player.deck.size.x -
              gameRef.config.padding,
          0,
        );
        _animationComponent
          ..angle = -pi / 2
          ..position = Vector2(0, _animationComponent.size.y);
    }

    resetAnimation();
  }

  void resetAnimation() {
    animationTicker
      ..currentIndex = animationTicker.spriteAnimation.frames.length - 1
      ..update(0.1)
      ..currentIndex = 0;
  }

  /// Plays the animation.
  void playAnimation() => animationTicker.reset();

  /// Returns whether the animation is playing or not.
  bool isAnimationPlaying() => !animationTicker.done();
}
