import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/player/bloc/player_event.dart';
import 'package:starship_shooter/player/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerState.initial()) {
    on<PlayerHealthUpdate>(_onPlayerHealthUpdate);
  }

  void _onPlayerHealthUpdate(
    PlayerHealthUpdate event,
    Emitter<PlayerState> emit,
  ) {
    var playerHealth1 = state.playerHealth1;
    var playerHealth2 = state.playerHealth2;

    if (event.playerId == 0) {
      playerHealth1 += event.playerHealth;
    } else {
      playerHealth2 += event.playerHealth;
    }
    emit(
      state.copyWith(
        playerHealth1: playerHealth1,
        playerHealth2: playerHealth2,
      ),
    );
  }
}
