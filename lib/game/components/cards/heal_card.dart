import 'dart:math';

import 'package:flame/text.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class HealCard extends Card {
  HealCard({required super.side}) {
    super.logoSprite = spriteSheet(0, 160, 32, 32);
  }

  late int health;

  //#region Card API
  @override
  String toString() {
    return 'Healing card - health: $health';
  }

  @override
  void useCard(Player player) {
    super.useCard(player);
    gameRef.entityBloc.add(
      HealingEvent(
        id: player.id,
        health: health,
      ),
    );
  }
  //#endregion

  //#region Component API
  @override
  Future<void> onLoad() async {
    size = gameRef.config.cardSize;
    var maxRandomValue = 3;

    // Different maxRandomValue depending on GameMode due to health issue
    if (gameRef.gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
      maxRandomValue = 5;
    } else if (gameRef.gameBloc.state.gameMode == GameMode.playerVSPlayer) {
      maxRandomValue = 3;
    }

    // Randomize if it's gonna be cold or heat card
    final typeOfCard = Random().nextInt(100);
    final cardMultiplier = Random().nextInt(maxRandomValue) + 1;
    final cardBaseOutput = Random().nextInt(maxRandomValue) + 1;
    if (typeOfCard < 50) {
      // Heat
      cold = cardMultiplier;
      health = cardMultiplier * cardBaseOutput;
    } else {
      // Cold
      heat = cardMultiplier;
      health = cardMultiplier * cardBaseOutput;
    }

    descriptionBlockNodes = [
      HeaderNode.simple('Healing Card', level: 3),
      HeaderNode.simple('$health', level: 4),
    ];

    await super.onLoad();
  }
  //#endregion
}
