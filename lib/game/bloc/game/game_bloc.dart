import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc()
      : super(
          const GameState.empty(),
        ) {
    on<GameStartEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.gameStart,
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
    on<DrawingCardsEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.drawingCards,
        ),
      ),
    );
    on<PlayerTurnEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: GameStatus.processTurn,
          lastPlayedId: event.playerId,
        ),
      ),
    );
  }
}
