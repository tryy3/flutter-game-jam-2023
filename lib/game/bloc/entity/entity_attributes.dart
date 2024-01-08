import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/game_config.dart';

enum EntityStatus {
  none, // Default value, status is not set yet
  alive,
  dead,
}

class EntityAttributes extends Equatable {
  const EntityAttributes({
    required this.health,
    required this.heat,
    required this.cold,
    this.status = EntityStatus.none,
  });
  final int health;
  final int heat;
  final int cold;
  final EntityStatus status;

  @override
  List<Object?> get props => [health, heat, cold, status];

  EntityAttributes copyWith({
    int? health,
    int? heat,
    int? cold,
    EntityStatus? status,
  }) {
    return EntityAttributes(
      health: max(
        min(
          health ?? this.health,
          GameConfig.maxHealth,
        ),
        GameConfig.minHealth,
      ),
      heat: max(
        min(
          heat ?? this.heat,
          GameConfig.maxCold,
        ),
        GameConfig.minCold,
      ),
      cold: max(
        min(
          cold ?? this.cold,
          GameConfig.maxHeat,
        ),
        GameConfig.minHeat,
      ),
      status: status ?? this.status,
    );
  }
}
