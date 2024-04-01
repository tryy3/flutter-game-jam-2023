import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';

class EntityState extends Equatable {
  const EntityState({required this.entities});

  const EntityState.initial()
      : this(
          entities: const {},
        );

  final Map<int, EntityAttributes> entities;

  @override
  List<Object?> get props => [entities];

  EntityState addNewEntity({
    required int id,
    required int health,
    required int cold,
    required int heat,
    required EntityStatus status,
  }) {
    return EntityState(
      entities: {
        ...entities,
        id: EntityAttributes(
          health: health,
          cold: cold,
          heat: heat,
          status: status,
        ),
      },
    );
  }

  EntityState copyWith({
    required int id,
    int? health,
    int? cold,
    int? heat,
    EntityStatus? status,
  }) {
    return EntityState(
      entities: {
        ...entities,
        id: entities[id]!.copyWith(
          health: health,
          cold: cold,
          heat: heat,
          status: status,
        ),
      },
    );
  }
}
