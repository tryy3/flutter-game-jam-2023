import 'package:equatable/equatable.dart';

class PlayerObject extends Equatable {
  const PlayerObject({required this.health});
  final int health;

  @override
  List<Object?> get props => [health];

  PlayerObject copyWith({
    int? health,
  }) {
    return PlayerObject(
      health: health ?? this.health,
    );
  }
}
