import 'dart:async';

import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/enemies/boss_enemy.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/entity_component.dart';
import 'package:starship_shooter/game/game_config.dart';

class EntityComponentManager {
  EntityComponentManager({
    required EntityBloc entityBloc,
    required GameBloc gameBloc,
  })  : _entityBloc = entityBloc,
        _gameBloc = gameBloc {
    entityBlocStream = entityBloc.stream.listen((state) {
      if (gameBloc.state.status != GameStatus.gameOver &&
          gameBloc.state.gameMode == GameMode.playerVSEnvironment) {
        // First check if boss is dead
        final deadBoss = _entities.where(
          (element) =>
              (element is BossEnemy) && element.status == EntityStatus.dead,
        );
        if (deadBoss.isNotEmpty) {
          gameBloc.add(const GameOverEvent());
          return;
        }

        // Next check if there is still any players alive
        // TODO: Can we do anything about the none status?
        final alivePlayers = _entities.where(
          (element) =>
              (element is Player) &&
              (element.status == EntityStatus.alive ||
                  element.status == EntityStatus.none),
        );
        if (alivePlayers.isEmpty) {
          gameBloc.add(const GameOverEvent());
          return;
        }
      }
    });
  }

  // Internal usage
  int _lastID = -1;
  final EntityBloc _entityBloc;
  final GameBloc _gameBloc;

  StreamSubscription<EntityState>? entityBlocStream;

  void onDispose() {
    entityBlocStream?.cancel();
  }

  final List<EntityComponent> _entities = [];
  Iterable<Player> get players => _entities.whereType<Player>();

  /// Add a new entity and also set it's id
  void addEntity(EntityComponent entity) {
    // TODO(Tryy3): Should we use UUID here? could be useful for debugging
    _lastID++;
    final id = _lastID;
    // final id = Random().nextInt(1000000);
    entity.id = id;
    _entities.add(entity);
    // entity.spawnEntity();
    _entityBloc.add(SpawnEntityEvent(id: id));
  }

  /// Will return next ID of the entity that is able to play
  int nextPlayableEntityID(int currentID) {
    return nextPlayableEntity(currentID).id;
  }

  /// Will return next entity that is able to play
  EntityComponent nextPlayableEntity(int currentID) {
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
  EntityComponent findEntity(int id) {
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

  List<EntityComponent> findAlivePlayerEntities() {
    return _entities
        .where(
          (element) =>
              (element is Player) && (element.health > GameConfig.minHealth),
        )
        .toList();
  }

  /// Tries to find the ID of a enemy, if it's PvP it will go based on
  /// the player that is next in line, if it's PvE then it will go for
  /// whoever the enemy is.
  int findFirstEnemyID(int currentID) {
    if (_gameBloc.state.gameMode == GameMode.playerVSPlayer) {
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
    } else {
      final boss = _entities.whereType<BossEnemy>().firstOrNull;
      return boss != null ? boss.id : -1;
    }
    return -1;
  }

  /// Initialize the players health and stats in the entity bloc
  void spawnEntities() {
    for (final entity in _entities) {
      entity.respawnEntity();
    }
  }
}
