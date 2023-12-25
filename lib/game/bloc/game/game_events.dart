import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
}

class GameStartEvent extends GameEvent {
  const GameStartEvent();

  @override
  List<Object?> get props => [];
}

class GameOverEvent extends GameEvent {
  const GameOverEvent();

  @override
  List<Object?> get props => [];
}

class DrawingCardsEvent extends GameEvent {
  const DrawingCardsEvent();

  @override
  List<Object?> get props => [];
}

class StartTurnEvent extends GameEvent {
  const StartTurnEvent();

  @override
  List<Object?> get props => [];
}

class PlayerTurnEvent extends GameEvent {
  const PlayerTurnEvent({required this.playerId});

  final int playerId;

  @override
  List<Object?> get props => [playerId];
}
