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
    on<RoundStartsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.roundStarts,
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
          currentEntityID: event.currentEntityID,
        ),
      ),
    );
    on<TurnProcessEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.turnProcess,
          currentEntityID: event.currentEntityID,
        ),
      ),
    );
    on<TurnEndsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.turnEnds,
          currentEntityID: event.currentEntityID,
        ),
      ),
    );
    on<RoundEndsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.roundEnds,
          currentEntityID: -1,
        ),
      ),
    );
    on<ChangeGameSettings>(
      (event, emit) => emit(
        state.copyWith(
          gameMode: event.gameMode ?? state.gameMode,
          playerMode: event.playerMode ?? state.playerMode,
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
    on<GameRestartEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.gameRestarts,
        ),
      ),
    );
  }
}
