import 'package:equatable/equatable.dart';

enum GameStatus {
  drawingCards,
  startTurn,
  processTurn,

  gameStart,
  gameOver,
}

class GameState extends Equatable {
  const GameState({required this.status, required this.lastPlayedId});
  const GameState.empty()
      : this(
          status: GameStatus.gameStart,
          lastPlayedId: -1,
        );

  final GameStatus status;
  final int lastPlayedId;

  GameState copyWith({
    int? lastPlayedId,
    GameStatus? status,
  }) {
    return GameState(
      status: status ?? this.status,
      lastPlayedId: lastPlayedId ?? this.lastPlayedId,
    );
  }

  @override
  List<Object?> get props => [status, lastPlayedId];
}
