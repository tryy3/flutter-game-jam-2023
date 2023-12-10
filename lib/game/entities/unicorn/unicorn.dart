import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/entities/unicorn/behaviors/tapping_behavior.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/side_view.dart';
import 'package:starship_shooter/gen/assets.gen.dart';

class Unicorn extends PositionedEntity with HasGameRef {
  Unicorn({
    required super.position,
    required this.side,
  }) : super(
          anchor: Anchor.center,
          size: StarshipShooterGame.unicornSize,
          behaviors: [
            TappingBehavior(),
          ],
        );

  @visibleForTesting
  Unicorn.test({
    required super.position,
    required this.side,
    super.behaviors,
  }) : super(size: Vector2.all(32));

  late SpriteAnimationComponent _animationComponent;
  SideView side;

  @visibleForTesting
  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  @override
  Future<void> onLoad() async {
    // TODO(tryy3): Add a check for SideView so that unicorn sprite looks
    // to the left
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
