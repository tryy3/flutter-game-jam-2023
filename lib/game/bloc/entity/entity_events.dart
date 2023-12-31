import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

abstract class EntityEvent extends Equatable {
  const EntityEvent();
}

/// Event whenever someone deal damage.
///
/// The entity in this case will be the initiator.
class DamageEvent extends EntityEvent {
  const DamageEvent({
    required this.entity,
    required this.damage,
    this.heat,
    this.cold,
  });

  final int damage;
  final Entity entity;

  /// The cost of the damage
  final int? heat;
  final int? cold;

  @override
  List<Object?> get props => [entity, damage, heat, cold];
}

/// Event whenever someone deal damage.
///
/// The entity in this case will be the initiator.
class HealingEvent extends EntityEvent {
  const HealingEvent({
    required this.entity,
    required this.health,
    this.heat,
    this.cold,
  });

  final int health;
  final Entity entity;

  /// The cost of the damage
  final int? heat;
  final int? cold;

  @override
  List<Object?> get props => [entity, health, heat, cold];
}
