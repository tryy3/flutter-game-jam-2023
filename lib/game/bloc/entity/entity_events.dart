import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';

abstract class EntityEvent extends Equatable {
  const EntityEvent();
}

/// When a card has been used.
///
/// Mainly used to subtract heat/cold for the card that has been used
class CardUsedEvent extends EntityEvent {
  const CardUsedEvent({
    required this.id,
    this.heat,
    this.cold,
  });

  // Entity that used the card
  final int id;

  /// The cost of the damage
  final int? heat;
  final int? cold;

  @override
  List<Object?> get props => [id, heat, cold];
}

/// Event whenever someone deal damage.
///
/// The entity in this case will be the initiator.
class DamageEvent extends EntityEvent {
  const DamageEvent({
    required this.id,
    required this.damage,
  });

  final int damage;
  final int id;

  @override
  List<Object?> get props => [id, damage];
}

/// Event whenever someone deal damage.
///
/// The entity in this case will be the initiator.
class HealingEvent extends EntityEvent {
  const HealingEvent({
    required this.id,
    required this.health,
  });

  final int health;
  final int id;

  @override
  List<Object?> get props => [id, health];
}

/// Event to give an entity more heat/cold stats.
///
/// Used in situations like at the end of a round to give player extra heat/cold
class BoostAttributeEvent extends EntityEvent {
  const BoostAttributeEvent({
    required this.id,
    this.health,
    this.cold,
    this.heat,
  });

  final int id;
  final int? health;
  final int? cold;
  final int? heat;

  @override
  List<Object?> get props => [id, health, cold, heat];
}

/// Whenever an entity dies. Could be a player, mob or a boss.
class EntityDeathEvent extends EntityEvent {
  const EntityDeathEvent({
    required this.id,
  });

  final int id;

  @override
  List<Object?> get props => [id];
}

/// Whenever an entity is spawned.
class SpawnEntityEvent extends EntityEvent {
  const SpawnEntityEvent({
    required this.id,
    this.health,
    this.cold,
    this.heat,
    this.status,
  });

  final int id;
  final int? health;
  final int? cold;
  final int? heat;
  final EntityStatus? status;

  @override
  List<Object?> get props => [id, health, cold, heat, status];
}

/// Whenever an entity is respawned. It will change the entity status to alive
/// and also add attributes if provided.
class RespawnEntityEvent extends EntityEvent {
  const RespawnEntityEvent({
    required this.id,
    this.health,
    this.cold,
    this.heat,
  });

  final int id;
  final int? health;
  final int? cold;
  final int? heat;

  @override
  List<Object?> get props => [id, health, cold, heat];
}

/// When any attributes get corrected, for example health went above max
class CorrectEntityAttributeEvent extends EntityEvent {
  const CorrectEntityAttributeEvent({
    required this.id,
    this.health,
    this.cold,
    this.heat,
  });

  final int id;
  final int? health;
  final int? cold;
  final int? heat;

  @override
  List<Object?> get props => [id, health, cold, heat];
}
