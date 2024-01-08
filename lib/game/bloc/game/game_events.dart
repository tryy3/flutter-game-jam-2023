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

class GameRestartEvent extends GameEvent {
  const GameRestartEvent();
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
  const TurnStartsEvent({required this.currentEntityID});

  final int currentEntityID;

  @override
  List<Object?> get props => [currentEntityID];
}

class TurnProcessEvent extends GameEvent {
  const TurnProcessEvent({required this.currentEntityID});

  final int currentEntityID;

  @override
  List<Object?> get props => [currentEntityID];
}

class TurnEndsEvent extends GameEvent {
  const TurnEndsEvent({required this.currentEntityID});

  final int currentEntityID;

  @override
  List<Object?> get props => [currentEntityID];
}

class RoundEndsEvent extends GameEvent {
  const RoundEndsEvent();
}

class GameOverEvent extends GameEvent {
  const GameOverEvent();
}

class ChangeGameSettings extends GameEvent {
  const ChangeGameSettings({this.gameMode, this.playerMode});

  final GameMode? gameMode;
  final PlayerMode? playerMode;

  @override
  List<Object?> get props => [gameMode, playerMode];
}
