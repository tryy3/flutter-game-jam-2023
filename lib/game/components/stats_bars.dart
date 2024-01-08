import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/entity/entity_attributes.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class StatsBars extends PositionComponent
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<EntityBloc, EntityState> {
  StatsBars({required this.side, required this.player, super.position})
      : super(anchor: Anchor.center);

  // Configuration
  final int maxHeat = 20;
  final int maxCold = 20;
  final int maxHealth = 20;

  // Rectangles
  late RRect _rRect;
  late RRect _healthBarRRect;
  late RRect _heatBarRRect;
  late RRect _coldBarRRect;

  // Stats
  int get health => max(game.entityBloc.state.entities[player.id]!.health, 0);
  int get cold => max(game.entityBloc.state.entities[player.id]!.cold, 0);
  int get heat => max(game.entityBloc.state.entities[player.id]!.heat, 0);

  // Properties
  SideView side;
  Player player;

  @override
  bool get debugMode => false;

  //#region State Changes
  @override
  void onNewState(EntityState state) {
    // Check if player is dead
    var entity = state.entities[player.id]!;
    if (entity.status == EntityStatus.alive && entity.health <= 0) {
      gameRef.entityBloc.add(EntityDeath(id: player.id));
    }
  }
  //#endregion

  //#region Rendering
  @override
  Future<void> onLoad() async {
    final viewportSize = gameRef.camera.viewport.size;
    final parentPosition = (parent! as PositionComponent).position;

    final title = TextComponent(
      text: 'Stats',
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: StarshipShooterGame.lightGrey50,
          fontFamily: '04B_03',
        ),
      ),
    );
    await add(title);

    // Resize based on deck size which is the largest element so far
    size = Vector2(
      player.deck.size.x,
      gameRef.config.padding +
          (gameRef.config.statsBarsWidth + gameRef.config.padding) * 3,
    );

    switch (side) {
      case SideView.left:
        position = Vector2(
          -parentPosition.x + (size.x / 2) + gameRef.config.margin,
          -parentPosition.y +
              (size.y / 2) +
              gameRef.config.margin +
              player.deck.size.y +
              gameRef.config.margin +
              player.cardSlots.size.y +
              gameRef.config.margin,
        );

        title.angle = pi / 2;
        title.position = Vector2(
          size.x + gameRef.config.margin,
          size.y / 2,
        );
      case SideView.right:
        position = Vector2(
          viewportSize.x -
              parentPosition.x -
              (size.x / 2) -
              gameRef.config.margin,
          viewportSize.y -
              parentPosition.y -
              (size.y / 2) -
              gameRef.config.margin -
              player.deck.size.y -
              gameRef.config.margin -
              player.cardSlots.size.y -
              gameRef.config.margin,
        );

        title.angle = (pi / 2) * 3;
        title.position = Vector2(
          -gameRef.config.margin,
          size.y / 2,
        );
      case SideView.bottom:
      // TODO: Handle this case.
    }
    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(
        gameRef.config.radius,
      ),
    );
    _healthBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        gameRef.config.padding,
        gameRef.config.padding,
        size.x - (gameRef.config.padding * 2),
        gameRef.config.statsBarsWidth,
      ),
      Radius.circular(
        gameRef.config.radius,
      ),
    );
    _heatBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        gameRef.config.padding,
        gameRef.config.padding +
            gameRef.config.statsBarsWidth +
            gameRef.config.padding,
        size.x - (gameRef.config.padding * 2),
        gameRef.config.statsBarsWidth,
      ),
      Radius.circular(
        gameRef.config.radius,
      ),
    );
    _coldBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        gameRef.config.padding,
        gameRef.config.padding +
            gameRef.config.statsBarsWidth +
            gameRef.config.padding +
            gameRef.config.statsBarsWidth +
            gameRef.config.padding,
        size.x - (gameRef.config.padding * 2),
        gameRef.config.statsBarsWidth,
      ),
      Radius.circular(
        gameRef.config.radius,
      ),
    );
  }

  final statsBarBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = StarshipShooterGame.lightBlack80;
  final healthBarPaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 3
    ..color = Colors.red;
  final heatBarPaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 3
    ..color = Colors.orange;
  final coldBarPaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 3
    ..color = Colors.blue;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Rotate canvas while rendering
    if (side == SideView.right) {
      canvas
        ..save()
        ..rotate(pi)
        ..translate(-size.x, -size.y);
    }

    // Draw the initial border around the area
    canvas
      ..drawRRect(_rRect, StarshipShooterGame.borderPaint)

      // Render the health bar
      ..drawRRect(_healthBarRRect, statsBarBorder)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            _healthBarRRect.left,
            _healthBarRRect.top,
            (_healthBarRRect.width / maxHealth) * health,
            _healthBarRRect.height,
          ),
          Radius.circular(
            gameRef.config.radius,
          ),
        ),
        healthBarPaint,
      )

      // Render the heat bar
      ..drawRRect(_heatBarRRect, statsBarBorder)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            _heatBarRRect.left,
            _heatBarRRect.top,
            (_heatBarRRect.width / maxHeat) * heat,
            _heatBarRRect.height,
          ),
          Radius.circular(
            gameRef.config.radius,
          ),
        ),
        heatBarPaint,
      )

      // Render the cold bar
      ..drawRRect(_coldBarRRect, statsBarBorder)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            _coldBarRRect.left,
            _coldBarRRect.top,
            (_coldBarRRect.width / maxCold) * cold,
            _coldBarRRect.height,
          ),
          Radius.circular(
            gameRef.config.radius,
          ),
        ),
        coldBarPaint,
      );

    // Reset canvas afterwards
    if (side == SideView.right) {
      canvas.restore();
    }
  }
  //#endregion
}
