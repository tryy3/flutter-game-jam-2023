import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:starship_shooter/game/entities/unicorn/unicorn.dart';
import 'package:starship_shooter/game/starship_shooter.dart';
import 'package:starship_shooter/gen/assets.gen.dart';

class TappingBehavior extends Behavior<Unicorn>
    with TapCallbacks, HasGameRef<StarshipShooterGame> {
  @override
  bool containsLocalPoint(Vector2 point) {
    return parent.containsLocalPoint(point);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (parent.isAnimationPlaying()) {
      return;
    }
    gameRef.counter++;
    parent.playAnimation();

    gameRef.effectPlayer.play(AssetSource(Assets.audio.effect));
  }
}
