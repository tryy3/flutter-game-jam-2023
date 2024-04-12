import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/enemies/boss_enemy.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/entity.dart';

class EntityComponentManager {
  EntityComponentManager({
    required GameBloc gameBloc,
  }) : _gameBloc = gameBloc;

  // Internal usage
  int _lastID = -1;
  final GameBloc _gameBloc;

  void onDispose() {
    for (final entity in _entities) {
      entity.onDispose();
    }
  }

  final List<Entity> _entities = [];
  Iterable<Player> get players => _entities.whereType<Player>();

  /// Add a new entity and also set it's id
  void addEntity(Entity entity) {
    // TODO(Tryy3): Should we use UUID here? could be useful for debugging
    _lastID++;
    final id = _lastID;
    // final id = Random().nextInt(1000000);
    entity.id = id;
    _entities.add(entity);
    // entity.spawnEntity();
    // _entityBloc.add(SpawnEntityEvent(id: id));
  }

  /// Will return next ID of the entity that is able to play
  int nextPlayableEntityID(int currentID) {
    return nextPlayableEntity(currentID).id;
  }

  /// Will return next entity that is able to play
  Entity nextPlayableEntity(int currentID) {
    final playableEntities =
        _entities.where((element) => element.canContinue());
    var foundEntity = false;
    for (final entity in playableEntities) {
      if (entity.id == currentID) {
        foundEntity = true;
        continue;
      }
      if (foundEntity) return entity;
    }
    return playableEntities.first;
  }

  /// Will return the entity of the last played
  Entity findEntity(int id) {
    return _entities.firstWhere((element) => element.id == id);
  }

  /// Checks if any player is able to continue
  bool playersCanContinue() {
    for (final entity in _entities) {
      if (entity is Player && entity.canContinue()) {
        return true;
      }
    }
    return false;
  }

  List<Entity> findAlivePlayerEntities() {
    // TODO(tryy3): Can we do anything about the none status?
    return _entities
        .where(
          (entity) =>
              (entity is Player) &&
              (entity.status == EntityStatus.alive ||
                  entity.status == EntityStatus.none),
        )
        .toList();
  }

  List<Entity> findDeadPlayerEntities() {
    return _entities
        .where(
          (entity) =>
              (entity is Player) && (entity.status == EntityStatus.dead),
        )
        .toList();
  }

  List<Entity> findDeadBosses() {
    return _entities
        .where(
          (entity) =>
              (entity is BossEnemy) && entity.status == EntityStatus.dead,
        )
        .toList();
  }

  /// Tries to find the ID of a enemy, if it's PvP it will go based on
  /// the player that is next in line, if it's PvE then it will go for
  /// whoever the enemy is.
  Entity? findFirstEnemy(int currentID) {
    if (_gameBloc.state.gameMode == GameMode.playerVSPlayer) {
      final players = _entities.whereType<Player>();
      var foundPlayer = false;

      // First attempt to find the next player
      for (final player in players) {
        if (player.id == currentID) {
          foundPlayer = true;
          continue;
        }

        // Return the next player in list if we previously found the player
        if (foundPlayer) {
          return player;
        }
      }

      // If we have found a player but it was last in list
      // then simply return the first player
      return foundPlayer ? players.first : null;
    } else {
      final boss = _entities.whereType<BossEnemy>().firstOrNull;
      return boss;
    }
  }

  /// Initialize the players health and stats in the entity bloc
  void spawnEntities() {
    for (final entity in _entities) {
      entity.respawnEntity();
      // _entityBloc.add(entity.respawnEntity());
    }
  }
}
