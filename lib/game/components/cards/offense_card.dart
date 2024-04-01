import 'dart:math';

import 'package:flame/text.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class OffenseCard extends Card {
  OffenseCard({required super.side}) {
    super.logoSprite = spriteSheet(128, 2720, 32, 32);
  }

  late int damage;

  //#region Card API
  @override
  String toString() {
    return 'Offense card - damage: $damage';
  }

  @override
  void useCard(Player player) {
    super.useCard(player);

    final enemyID =
        player.gameRef.entityComponentManager.findFirstEnemyID(player.id);

    gameRef.entityBloc.add(
      DamageEvent(
        id: enemyID,
        damage: damage,
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

      // Debug mode
      maxRandomValue = 20;
    }

    // Randomize if it's gonna be cold or heat card
    final typeOfCard = Random().nextInt(100);
    final cardMultiplier = Random().nextInt(maxRandomValue) + 1;
    final cardBaseOutput = Random().nextInt(maxRandomValue) + 1;
    if (typeOfCard < 50) {
      // Heat
      cold = cardMultiplier;
      damage = cardMultiplier * cardBaseOutput;
    } else {
      // Cold
      heat = cardMultiplier;
      damage = cardMultiplier * cardBaseOutput;
    }

    super.descriptionBlockNodes = [
      HeaderNode.simple('Damage Card', level: 3),
      HeaderNode.simple('$damage', level: 4),
    ];

    await super.onLoad();
  }
  //#endregion
}
