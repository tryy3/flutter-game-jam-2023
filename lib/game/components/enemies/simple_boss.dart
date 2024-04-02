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
  int get health =>
      gameRef.entityBloc.state.entities[id]?.health ?? GameConfig.minHealth;
  @override
  int get cold => GameConfig.minHealth;
  @override
  int get heat => GameConfig.minHealth;
  @override
  EntityStatus get status =>
      gameRef.entityBloc.state.entities[id]?.status ?? EntityStatus.none;
  @override
  bool canContinue() => true;
  //#endregion

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    // Position the boss
    final viewportSize = gameRef.camera.viewport.size;

    position = Vector2(
      viewportSize.x / 2,
      viewportSize.y / 2,
    );
    size = gameRef.config.simpleBossSize;

    if (gameRef.gameBloc.state.playerMode == PlayerMode.onePlayer) {
      position.y = viewportSize.y / 2 / 2;
    }

    await add(
      FlameBlocListener<EntityBloc, EntityState>(
        onNewState: (EntityState state) {
          final entity = state.entities[id];
          if (entity == null) return;

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
          size.y +
              gameRef.config.rotatedStatsBarsWidth / 2 +
              gameRef.config.padding,
        ),
        maxStatus: simpleBossMaxHealth,
        side: SideView.bossBottom,
      ),
    );
  }

  @override
  EntityEvent respawnEntity() {
    return RespawnEntityEvent(
      id: id,
      health: simpleBossMaxHealth,
    );
  }

  void startTurn() {
    // generates a new Random object
    final rand = Random();
    final playerEntities =
        gameRef.entityComponentManager.findAlivePlayerEntities();
    final randomPlayer = playerEntities[rand.nextInt(playerEntities.length)];

    // Get a random damage between min and max
    final randomDamage =
        rand.nextInt(maxDamageDone - minDamageDone) + minDamageDone;

    // Apply the damage to the player
    gameRef.entityBloc.add(
      DamageEvent(
        id: randomPlayer.id,
        damage: randomDamage,
      ),
    );
  }
}
