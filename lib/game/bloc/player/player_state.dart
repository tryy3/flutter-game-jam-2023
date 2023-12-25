import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/models/player_model.dart';

class PlayerState extends Equatable {
  const PlayerState({required this.players});

  const PlayerState.initial()
      : this(
          players: const {
            0: PlayerObject(health: 20),
            1: PlayerObject(health: 20),
          },
        );

  final Map<int, PlayerObject> players;

  @override
  List<Object?> get props => [players];

  PlayerState copyWith({
    required int playerId,
    required int health,
  }) {
    return PlayerState(
      players: {
        ...players,
        playerId: players[playerId]!.copyWith(health: health),
      },
    );
  }
}
