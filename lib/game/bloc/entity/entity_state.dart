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

  EntityAttributes findEntityOrCreateNew(int id) {
    return entities[id] ??
        const EntityAttributes(
          health: 0,
          cold: 0,
          heat: 0,
        );
  }

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
    final entity = findEntityOrCreateNew(id);

    return EntityState(
      entities: {
        ...entities,
        id: entity.copyWith(
          health: health,
          cold: cold,
          heat: heat,
          status: status,
        ),
      },
    );
  }
}
