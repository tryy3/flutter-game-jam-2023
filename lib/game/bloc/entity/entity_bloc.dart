import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  EntityBloc() : super(const EntityState.initial()) {
    on<BoostAttributeEvent>(
      (event, emit) => emit(
        state.copyWith(
          id: event.id,
          health: (event.health != null)
              ? state.entities[event.id]!.health + event.health!
              : null,
          cold: (event.cold != null)
              ? state.entities[event.id]!.cold + event.cold!
              : null,
          heat: (event.heat != null)
              ? state.entities[event.id]!.heat + event.heat!
              : null,
        ),
      ),
    );
    on<EntitySpawn>(
      (event, emit) => emit(
        state.addNewEntity(
          id: event.id,
          health: event.health ?? 0,
          cold: event.cold ?? 0,
          heat: event.heat ?? 0,
        ),
      ),
    );
    on<RespawnEntity>(
      (event, emit) => emit(
        state.copyWith(
          id: event.id,
          status: EntityStatus.alive,
          health: event.health,
          cold: event.cold,
          heat: event.heat,
        ),
      ),
    );
    on<EntityDeath>(
      (event, emit) => emit(
        state.copyWith(
          id: event.id,
          status: EntityStatus.dead,
        ),
      ),
    );
    on<CardUsedEvent>((event, emit) {
      // Get the heat/cold and subtract by the event depending on which one
      // was used at the time
      final heat = event.heat != null
          ? state.entities[event.id]!.heat - event.heat!
          : null;
      final cold = event.cold != null
          ? state.entities[event.id]!.cold - event.cold!
          : null;
      emit(
        state.copyWith(
          id: event.id,
          heat: heat,
          cold: cold,
        ),
      );
    });
    on<HealingEvent>((event, emit) {
      final newHealth = state.entities[event.id]!.health + event.health;

      emit(
        state.copyWith(
          id: event.id,
          health: newHealth,
        ),
      );
    });
    on<DamageEvent>((event, emit) {
      final newHealth = state.entities[event.id]!.health - event.damage;

      emit(
        state.copyWith(
          id: event.id,
          health: newHealth,
        ),
      );
    });
  }
}
