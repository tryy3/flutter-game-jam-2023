import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStartsEvent extends GameEvent {
  const GameStartsEvent();
}

class WaitingForRoundStartsEvent extends GameEvent {
  const WaitingForRoundStartsEvent();
}

class RoundStartsEvent extends GameEvent {
  const RoundStartsEvent();
}

class InBetweenTurnsEvent extends GameEvent {
  const InBetweenTurnsEvent();
}

class TurnStartsEvent extends GameEvent {
  const TurnStartsEvent({required this.currentEntity});

  final Entity currentEntity;

  @override
  List<Object?> get props => [currentEntity];
}

class TurnProcessEvent extends GameEvent {
  const TurnProcessEvent({required this.currentEntity});

  final Entity currentEntity;

  @override
  List<Object?> get props => [currentEntity];
}

class TurnEndsEvent extends GameEvent {
  const TurnEndsEvent({required this.currentEntity});

  final Entity currentEntity;

  @override
  List<Object?> get props => [currentEntity];
}

class RoundEndsEvent extends GameEvent {
  const RoundEndsEvent();
}

class GameOverEvent extends GameEvent {
  const GameOverEvent();
}
