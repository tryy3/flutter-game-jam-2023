import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/entity_component.dart';

class EntityComponentManager {
  EntityComponentManager({required EntityBloc entityBloc})
      : _entityBloc = entityBloc;

  // Internal usage
  int _lastID = -1;
  final EntityBloc _entityBloc;

  final List<EntityComponent> _entities = [];
  Iterable<Player> get players => _entities.whereType<Player>();

  /// Add a new entity and also set it's id
  void addEntity(EntityComponent entity) {
    _lastID++;
    entity.id = _lastID;
    _entities.add(entity);
    _entityBloc.add(EntitySpawn(id: _lastID));
  }

  /// Will return next ID of the entity that is able to play
  int nextPlayableEntityID(int currentID) {
    final playableEntities =
        _entities.where((element) => element.canContinue());
    var foundEntity = false;
    for (final entity in playableEntities) {
      if (entity.id == currentID) {
        foundEntity = true;
        continue;
      }
      if (foundEntity) return entity.id;
    }
    return playableEntities.first.id;
  }

  /// Checks if any player is able to continue
  bool playersCanContinue() {
    for (final entity in _entities) {
      if (entity is Player && entity.canContinue()) return true;
    }
    return false;
  }

  /// Tries to find the ID of the next player in line based on current ID.
  /// If unable to find current ID then it will return -1.
  int nextPlayerID(int currentID) {
    final players = _entities.whereType<Player>();
    var foundPlayer = false;

    // First attempt to find the next player
    for (final player in players) {
      if (player.id == currentID) {
        foundPlayer = true;
        continue;
      }
      if (foundPlayer) {
        return player.id;
      }
    }

    return foundPlayer ? players.first.id : -1;
  }

  /// Initialize the players health and stats in the entity bloc
  void initializePlayerAttributes() {
    for (final entity in _entities) {
      if (entity is Player) {
        _entityBloc.add(
          RespawnEntity(
            id: entity.id,
            health: 20,
            cold: 20,
            heat: 20,
          ),
        );
        entity.createCards();
      }
    }
  }
}
