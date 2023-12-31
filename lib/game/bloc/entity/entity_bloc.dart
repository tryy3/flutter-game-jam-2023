import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  EntityBloc() : super(const EntityState.initial());
}
