import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/enemies/boss_enemy.dart';
import 'package:starship_shooter/game/components/status_bars/health_status_bar.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

const simpleBossMaxHealth = 200;
const minDamageDone = 5;
const maxDamageDone = 15;

class SimpleBoss extends PositionComponent
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<GameBloc, GameState>
    implements BossEnemy {
  SimpleBoss({this.id = -1}) : super(anchor: Anchor.center);

  //#region EntityComponent API
  @override
  int id;
  @override
  int get health => gameRef.entityBloc.state.entities[id]!.health;
  @override
  int get cold => -1;
  @override
  int get heat => -1;
  @override
  bool canContinue() => true;
  //#endregion

  @override
  bool get debugMode => true;

  @override
  Future<void> onLoad() async {
    // Position the boss
    final viewportSize = gameRef.camera.viewport.size;

    position = Vector2(
      viewportSize.x / 2,
      viewportSize.y / 2,
    );
    size = gameRef.config.simpleBossSize;

    await add(
      FlameBlocListener<EntityBloc, EntityState>(
        onNewState: (EntityState state) {
          final entity = state.entities[id]!;
          // Check for health correction, so that the boss health is within
          // normal range
          final checkNewHealth = max(
            min(
              entity.health,
              simpleBossMaxHealth,
            ),
            GameConfig.minHealth,
          );
          if (checkNewHealth != entity.health) {
            gameRef.entityBloc.add(
              CorrectEntityAttributeEvent(id: id, health: checkNewHealth),
            );
            return;
          }

          // Check if boss is dead
          if (entity.status == EntityStatus.alive && entity.health <= 0) {
            gameRef.entityBloc.add(EntityDeathEvent(id: id));
            return;
          }
          if (entity.status == EntityStatus.dead) {}
        },
      ),
    );

    await add(
      FlameBlocListener<GameBloc, GameState>(
        onNewState: (GameState state) {
          if (state.status == GameStatus.turnProcess &&
              state.currentEntityID == id) {
            startTurn();
          }
        },
      ),
    );

    await add(
      SpriteComponent(
        sprite: spriteSheet(480, 4128, 32, 32),
        size: size,
      ),
    );

    await add(
      HealthStatusBar(
        entityID: id,
        position: Vector2(
          size.x / 2,
          size.y + gameRef.config.statsBarsWidth / 2 + gameRef.config.padding,
        ),
        maxStatus: simpleBossMaxHealth,
      ),
    );
  }

  @override
  SpawnEntityEvent spawnEntity() {
    return SpawnEntityEvent(
      id: id,
      health: simpleBossMaxHealth,
      status: EntityStatus.alive,
    );
  }

  void startTurn() {
// generates a new Random object
    final _random = Random();
    final playerEntities = gameRef.entityComponentManager.getPlayerEntities();
    final randomPlayer = playerEntities[_random.nextInt(playerEntities.length)];

    // Get a random damage between min and max
    final randomDamage =
        _random.nextInt(maxDamageDone - minDamageDone) + minDamageDone;

    // Apply the damage to the player
    gameRef.entityBloc.add(
      DamageEvent(
        id: randomPlayer.id,
        damage: randomDamage,
      ),
    );
  }
}
