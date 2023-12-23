import 'package:equatable/equatable.dart';

abstract class PlayerEvents extends Equatable {
  const PlayerEvents();
}

class PlayerHealthUpdateEvent extends PlayerEvents {
  const PlayerHealthUpdateEvent({required this.playerId, required this.health});

  final int health;
  final int playerId;

  @override
  List<Object?> get props => [health];
}
