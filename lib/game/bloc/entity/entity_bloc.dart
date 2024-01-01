import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  EntityBloc() : super(const EntityState.initial()) {
    on<BoostAttributeEvent>(
      (event, emit) => emit(
        state.copyWith(
          entity: event.entity,
          cold: (event.cold != null)
              ? min(state.entities[event.entity]!.cold + event.cold!, 20)
              : null,
          heat: (event.heat != null)
              ? min(state.entities[event.entity]!.heat + event.heat!, 20)
              : null,
        ),
      ),
    );
  }
}
