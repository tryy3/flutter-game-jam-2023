import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/enemies/boss_enemy.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/components/status_bars/health_status_bar.dart';
import 'package:starship_shooter/game/entity.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

const simpleBossMaxHealth = 50;
const minDamageDone = 3;
const maxDamageDone = 10;

class SimpleBoss extends PositionComponent
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<GameBloc, GameState>
    implements BossEnemy {
  SimpleBoss({this.id = -1}) : super(anchor: Anchor.center);

  //#region EntityComponent API
  @override
  int id;

  int _health = GameConfig.minHealth;
  @override
  int get health => _health;
  set health(int value) {
    _health = max(min(value, simpleBossMaxHealth), GameConfig.minHealth);
    if (_health <= GameConfig.minHealth && status == EntityStatus.alive) {
      status = EntityStatus.dead;
    }
  }

  @override
  int get heat => -1;
  @override
  int get cold => -1;

  @override
  EntityStatus status = EntityStatus.none;

  @override
  bool canContinue() => true;

  @override
  void healEntity(int healing) {
    health += healing;
  }

  @override
  void damageEntity(int damage) {
    health -= damage;
  }

  //#endregion
  @override
  void onDispose() {}

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
        entity: this,
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
  Future<bool> respawnEntity() async {
    health = simpleBossMaxHealth;
    status = EntityStatus.alive;
    return true;
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
    // final randomDamage = 200;

    // Apply the damage to entity
    randomPlayer.damageEntity(randomDamage);
    (randomPlayer as Player).addNewLogMessage('Took $randomDamage from enemy');
  }
}
