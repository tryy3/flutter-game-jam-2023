import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

abstract class EntityEvent extends Equatable {
  const EntityEvent();
}

/// When a card has been used.
///
/// Mainly used to subtract heat/cold for the card that has been used
class CardUsedEvent extends EntityEvent {
  const CardUsedEvent({
    required this.entity,
    this.heat,
    this.cold,
  });

  // Entity that used the card
  final Entity entity;

  /// The cost of the damage
  final int? heat;
  final int? cold;

  @override
  List<Object?> get props => [entity, heat, cold];
}

/// Event whenever someone deal damage.
///
/// The entity in this case will be the initiator.
class DamageEvent extends EntityEvent {
  const DamageEvent({
    required this.entity,
    required this.damage,
  });

  final int damage;
  final Entity entity;

  @override
  List<Object?> get props => [entity, damage];
}

/// Event whenever someone deal damage.
///
/// The entity in this case will be the initiator.
class HealingEvent extends EntityEvent {
  const HealingEvent({
    required this.entity,
    required this.health,
  });

  final int health;
  final Entity entity;

  @override
  List<Object?> get props => [entity, health];
}

/// Event to give an entity more heat/cold stats.
///
/// Used in situations like at the end of a round to give player extra heat/cold
class BoostAttributeEvent extends EntityEvent {
  const BoostAttributeEvent({
    required this.entity,
    this.cold,
    this.heat,
  });

  final Entity entity;
  final int? cold;
  final int? heat;

  @override
  List<Object?> get props => [entity, cold, heat];
}

/// Whenever an entity dies. Could be a player, mob or a boss.
class EntityDeath extends EntityEvent {
  const EntityDeath({
    required this.entity,
  });

  final Entity entity;

  @override
  List<Object?> get props => [entity];
}
