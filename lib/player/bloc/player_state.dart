import 'package:equatable/equatable.dart';

class PlayerState extends Equatable {
  const PlayerState({
    required this.playerHealth1,
    required this.playerHealth2,
  });

  const PlayerState.initial() : this(playerHealth1: 20, playerHealth2: 20);

  final int playerHealth1;
  final int playerHealth2;

  PlayerState copyWith({
    int? playerHealth1,
    int? playerHealth2,
  }) {
    return PlayerState(
      playerHealth1: playerHealth1 ?? this.playerHealth1,
      playerHealth2: playerHealth2 ?? this.playerHealth2,
    );
  }

  @override
  List<Object?> get props => [playerHealth1, playerHealth2];
}
