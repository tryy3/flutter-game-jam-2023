import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class HealCard extends Card with HasGameRef<StarshipShooterGame> {
  HealCard({required super.side}) {
    super.size = StarshipShooterGame.cardSize;
    super.logoSprite = spriteSheet(128, 2720, 32, 32);

    // Randomize if it's gonna be cold or heat card
    final typeOfCard = Random().nextInt(100);
    final cardMultiplier = Random().nextInt(5) + 1;
    final cardBaseOutput = Random().nextInt(5) + 1;
    if (typeOfCard < 50) {
      // Heat
      cold = cardMultiplier;
      health = cardMultiplier * cardBaseOutput;
    } else {
      // Cold
      heat = cardMultiplier;
      health = cardMultiplier * cardBaseOutput;
    }

    super.descriptionBlockNodes = [
      HeaderNode.simple('Healing Card', level: 3),
      HeaderNode.simple('$health', level: 4),
    ];
  }

  late int health;

  @override
  String toString() {
    return 'Healing card - health: $health';
  }

  @override
  void useCard(Player player) {
    super.useCard(player);
    gameRef.entityBloc.add(HealingEvent(entity: player.entity, health: health));
  }

  //#region Rendering

  //#endregion
}
