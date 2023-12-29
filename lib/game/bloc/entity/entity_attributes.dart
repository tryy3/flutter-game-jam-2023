import 'package:equatable/equatable.dart';

class EntityAttributes extends Equatable {
  const EntityAttributes({
    required this.health,
    required this.heat,
    required this.cold,
  });
  final int health;
  final int heat;
  final int cold;

  @override
  List<Object?> get props => [health, heat, cold];

  EntityAttributes copyWith({
    int? health,
    int? heat,
    int? cold,
  }) {
    return EntityAttributes(
      health: health ?? this.health,
      heat: heat ?? this.heat,
      cold: cold ?? this.cold,
    );
  }
}
