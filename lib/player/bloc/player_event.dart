import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();
}

class PlayerHealthUpdate extends PlayerEvent {
  const PlayerHealthUpdate({
    required this.playerId,
    required this.playerHealth,
  });

  final int playerId;
  final int playerHealth;

  @override
  List<Object?> get props => [playerId, playerHealth];
}
