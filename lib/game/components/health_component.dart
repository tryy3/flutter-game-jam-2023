import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/player/bloc/player_bloc.dart';
import 'package:starship_shooter/player/bloc/player_state.dart';

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

    final availableSprite = spriteSheet(288, 4224, 32, 32);
    final unavailableSprite = spriteSheet(192, 4224, 32, 32);

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
