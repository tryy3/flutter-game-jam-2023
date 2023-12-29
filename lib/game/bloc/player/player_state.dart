import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/models/player_model.dart';

class PlayerState extends Equatable {
  const PlayerState({required this.players});

  const PlayerState.initial()
      : this(
          players: const {
            Entity.player1: PlayerObject(health: 20),
            Entity.player2: PlayerObject(health: 20),
          },
        );

  final Map<Entity, PlayerObject> players;

  @override
  List<Object?> get props => [players];

  PlayerState copyWith({
    required Entity entity,
    required int health,
  }) {
    return PlayerState(
      players: {
        ...players,
        entity: players[entity]!.copyWith(health: health),
      },
    );
  }
}
