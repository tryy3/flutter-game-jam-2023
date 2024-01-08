import 'package:equatable/equatable.dart';

enum GameStatus {
  gameLoading, // Whenever the game loads for first time
  gameStarts, // Game begins
  waitingForRoundStart, // Players draw cards
  roundStarts, // Player clicked Button and round starts
  inBetweenTurns, // Inbetween round and turn start, waiting for game delay
  turnStarts, // Comes directly after just to initiate that a turn starts
  turnProcess, // Either a player or entity processing it's turn
  turnEnds, // Event for when a turn ends
  roundEnds, // Event for when a full round ends
  gameOver, // Game is over, someone lost
  gameRestarts, // The game restarts
}

enum GameMode {
  playerVSPlayer, // PvP
  playerVSEnvironment, // PvE - Bosses
}

enum PlayerMode {
  onePlayer,
  twoPlayers,
}

class GameState extends Equatable {
  const GameState({
    required this.status,
    required this.currentEntityID,
    required this.gameMode,
    required this.playerMode,
  });
  const GameState.empty()
      : this(
          status: GameStatus.gameLoading,
          currentEntityID: -1,
          playerMode: PlayerMode.twoPlayers,
          gameMode: GameMode.playerVSPlayer,
        );

  final GameStatus status;
  final GameMode gameMode;
  final PlayerMode playerMode;
  final int currentEntityID;

  GameState copyWith({
    int? currentEntityID,
    GameStatus? status,
    GameMode? gameMode,
    PlayerMode? playerMode,
  }) {
    return GameState(
      status: status ?? this.status,
      currentEntityID: currentEntityID ?? this.currentEntityID,
      gameMode: gameMode ?? this.gameMode,
      playerMode: playerMode ?? this.playerMode,
    );
  }

  @override
  List<Object?> get props => [status, currentEntityID, gameMode, playerMode];
}
