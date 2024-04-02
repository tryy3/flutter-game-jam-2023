import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';

abstract class EntityComponent {
  /// The entity ID
  int get id;
  set id(int id);

  /// Entity attributes, not all entities will use all of them but they are
  /// available if needed.
  int get health;
  int get heat;
  int get cold;
  EntityStatus get status;

  /// Checks if the entity can continue playing or not
  ///
  /// Will differ between the type of entity, in the case of player it can be
  /// determined by if they have a card in their hand if that card is playable or
  /// not
  bool canContinue();

  void respawnEntity();
}
