import 'package:equatable/equatable.dart';

enum GameStatus {
  gameStarts, // Game begins
  waitingForRoundStart, // Players draw cards
  roundStarts, // Player clicked Button and round starts
  inBetweenTurns, // Inbetween round and turn start, waiting for game delay
  turnStarts, // Comes directly after just to initiate that a turn starts
  turnProcess, // Either a player or entity processing it's turn
  turnEnds, // Event for when a turn ends
  roundEnds, // Event for when a full round ends
  gameOver, // Game is over, someone lost
}

enum GameMode {
  playerVSPlayer, // PvP
  playerVSEnvironment, // PvE - Bosses
}

enum PlayerMode {
  onePlayer,
  twoPlayers,
}

enum Entity {
  player1,
  player2,
  environment,
  none,
}

class GameState extends Equatable {
  const GameState({
    required this.status,
    required this.currentEntity,
    required this.gameMode,
    required this.playerMode,
  });
  const GameState.empty()
      : this(
          status: GameStatus.gameStarts,
          currentEntity: Entity.none,
          playerMode: PlayerMode.twoPlayers,
          gameMode: GameMode.playerVSPlayer,
        );

  final GameStatus status;
  final GameMode gameMode;
  final PlayerMode playerMode;
  final Entity currentEntity;

  GameState copyWith({
    Entity? currentEntity,
    GameStatus? status,
    GameMode? gameMode,
    PlayerMode? playerMode,
  }) {
    return GameState(
      status: status ?? this.status,
      currentEntity: currentEntity ?? this.currentEntity,
      gameMode: gameMode ?? this.gameMode,
      playerMode: playerMode ?? this.playerMode,
    );
  }

  @override
  List<Object?> get props => [status, currentEntity, gameMode, playerMode];
}
