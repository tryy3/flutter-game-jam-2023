import 'dart:async';

import 'package:flame/components.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/player/player.dart';

enum HeartState {
  available,
  unavailable,
}

class HealthComponent extends SpriteGroupComponent<HeartState>
    with HasGameRef<StarshipShooterGame> {
  HealthComponent({
    required this.heartNumber,
    required this.player,
    required super.position,
  }) : super(size: StarshipShooterGame.heartSize);

  final int heartNumber;
  final Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final availableSprite = await game.loadSprite(
      'images/heart.png',
      srcSize: Vector2.all(32),
    );

    final unavailableSprite = await game.loadSprite(
      'images/heart_half.png',
      srcSize: Vector2.all(32),
    );

    sprites = {
      HeartState.available: availableSprite,
      HeartState.unavailable: unavailableSprite,
    };

    current = HeartState.available;
  }

  @override
  void update(double dt) {
    if (player.health < heartNumber) {
      current = HeartState.unavailable;
    } else {
      current = HeartState.available;
    }
    super.update(dt);
  }
}
