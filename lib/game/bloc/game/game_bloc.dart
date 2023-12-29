import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc()
      : super(
          const GameState.empty(),
        ) {
    on<GameStartsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.gameStarts,
        ),
      ),
    );
    on<WaitingForRoundStartsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.waitingForRoundStart,
        ),
      ),
    );
    on<InBetweenTurnsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.inBetweenTurns,
        ),
      ),
    );
    on<TurnStartsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.turnStarts,
          currentEntity: event.currentEntity,
        ),
      ),
    );
    on<TurnProcessEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.turnProcess,
          currentEntity: event.currentEntity,
        ),
      ),
    );
    on<TurnEndsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.turnEnds,
          currentEntity: event.currentEntity,
        ),
      ),
    );
    on<RoundEndsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.roundEnds,
          currentEntity: Entity.none,
        ),
      ),
    );
    on<GameOverEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.gameOver,
        ),
      ),
    );
  }
}
