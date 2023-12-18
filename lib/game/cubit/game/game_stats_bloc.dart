import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GameStatsEvent extends Equatable {
  const GameStatsEvent();
}

class GameOver extends GameStatsEvent {
  const GameOver();

  @override
  List<Object?> get props => [];
}

enum GameStatus {
  running,
  gameOver,
}

class GameStatsState extends Equatable {
  const GameStatsState({required this.status});
  const GameStatsState.empty() : this(status: GameStatus.running);

  final GameStatus status;

  GameStatsState copyWith({
    int? score,
    int? lives,
    GameStatus? status,
  }) {
    return GameStatsState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}

class GameStatsBloc extends Bloc<GameStatsEvent, GameStatsState> {
  GameStatsBloc()
      : super(
          const GameStatsState.empty(),
        ) {
    on<GameOver>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.gameOver,
        ),
      ),
    );
  }
}
