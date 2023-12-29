import 'package:equatable/equatable.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';

abstract class PlayerEvents extends Equatable {
  const PlayerEvents();
}

class PlayerHealthUpdateEvent extends PlayerEvents {
  const PlayerHealthUpdateEvent({required this.player, required this.health});

  final int health;
  final Entity player;

  @override
  List<Object?> get props => [health];
}
