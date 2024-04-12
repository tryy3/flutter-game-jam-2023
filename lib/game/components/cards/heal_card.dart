import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
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
    // ignore_for_file: no_runtimeType_toString
    return '''
$runtimeType(
  health: $health,
  cold: $cold,
  heat: $cold,
  position: ${position.toStringWithMaxPrecision(4)},
  size: ${size.toStringWithMaxPrecision(4)},
  angle: $angle,
  scale: $scale,
)''';
  }

  @override
  void useCard(Player player) {
    super.useCard(player);
    player
      ..healEntity(health)
      ..addNewLogMessage('Healed yourself with $health HP');
  }
  //#endregion

  //#region Component API
  @override
  Future<void> onLoad() async {
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
