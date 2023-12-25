import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/player/player_events.dart';
import 'package:starship_shooter/game/bloc/player/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvents, PlayerState> {
  PlayerBloc() : super(const PlayerState.initial()) {
    on<PlayerHealthUpdateEvent>(
      (event, emit) => emit(
        state.copyWith(playerId: event.playerId, health: event.health),
      ),
    );
  }
}
