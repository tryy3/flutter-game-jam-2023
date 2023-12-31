import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

class EntityState extends Equatable {
  const EntityState({required this.entities});

  const EntityState.initial()
      : this(
          entities: const {
            Entity.player1: EntityAttributes(
              health: 20,
              heat: 20,
              cold: 20,
            ),
            Entity.player2: EntityAttributes(
              health: 20,
              heat: 20,
              cold: 20,
            ),
          },
        );

  final Map<Entity, EntityAttributes> entities;

  @override
  List<Object?> get props => [entities];

  EntityState copyWith({
    required Entity entity,
    int? health,
    int? cold,
    int? heat,
  }) {
    return EntityState(
      entities: {
        ...entities,
        entity: entities[entity]!.copyWith(
          health: health,
          cold: cold,
          heat: heat,
        ),
      },
    );
  }
}
