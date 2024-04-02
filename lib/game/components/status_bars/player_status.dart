import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_state.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/components/status_bars/cold_status_bar.dart';
import 'package:starship_shooter/game/components/status_bars/health_status_bar.dart';
import 'package:starship_shooter/game/components/status_bars/heat_status_bar.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class PlayerStatus extends PositionComponent
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<EntityBloc, EntityState> {
  PlayerStatus({required this.side, required this.player, super.position})
      : super(anchor: Anchor.center);

  // Configuration
  final int maxHeat = GameConfig.maxHeat;
  final int maxCold = GameConfig.maxCold;
  final int maxHealth = GameConfig.maxHealth;

  // Rectangles
  late RRect _rRect;

  // Properties
  SideView side;
  Player player;

  @override
  bool get debugMode => false;

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
    size = (side == SideView.bottom)
        ? Vector2(
            gameRef.config.padding +
                (gameRef.config.rotatedStatsBarsWidth +
                        gameRef.config.padding) *
                    3,
            player.deck.size.y)
        : Vector2(
            player.deck.size.x,
            gameRef.config.padding +
                (gameRef.config.rotatedStatsBarsHeight +
                        gameRef.config.padding) *
                    3,
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

        await addAll([
          HealthStatusBar(
            entityID: player.id,
            position: Vector2(
              size.x / 2,
              gameRef.config.rotatedStatsBarsWidth / 2 + gameRef.config.padding,
            ),
            side: side,
          ),
          HeatStatusBar(
            entityID: player.id,
            position: Vector2(
              size.x / 2,
              gameRef.config.rotatedStatsBarsWidth / 2 +
                  gameRef.config.padding +
                  gameRef.config.rotatedStatsBarsWidth +
                  gameRef.config.padding,
            ),
            side: side,
          ),
          ColdStatusBar(
            entityID: player.id,
            position: Vector2(
              size.x / 2,
              gameRef.config.rotatedStatsBarsWidth / 2 +
                  gameRef.config.padding +
                  gameRef.config.rotatedStatsBarsWidth +
                  gameRef.config.padding +
                  gameRef.config.rotatedStatsBarsWidth +
                  gameRef.config.padding,
            ),
            side: side,
          ),
        ]);
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

        await addAll([
          HealthStatusBar(
            entityID: player.id,
            position: Vector2(
              size.x / 2,
              size.y -
                  (gameRef.config.rotatedStatsBarsWidth / 2) -
                  gameRef.config.padding,
            ),
            side: side,
          ),
          HeatStatusBar(
            entityID: player.id,
            position: Vector2(
              size.x / 2,
              size.y -
                  (gameRef.config.rotatedStatsBarsWidth / 2) -
                  gameRef.config.padding -
                  gameRef.config.rotatedStatsBarsWidth -
                  gameRef.config.padding,
            ),
            side: side,
          ),
          ColdStatusBar(
            entityID: player.id,
            position: Vector2(
              size.x / 2,
              size.y -
                  (gameRef.config.rotatedStatsBarsWidth / 2) -
                  gameRef.config.padding -
                  gameRef.config.rotatedStatsBarsWidth -
                  gameRef.config.padding -
                  gameRef.config.rotatedStatsBarsWidth -
                  gameRef.config.padding,
            ),
            side: side,
          ),
        ]);
      case SideView.bottom:
        final cardSlotsSize = player.cardSlots.size;
        position = Vector2(
          (cardSlotsSize.x / 2) + (size.x / 2) + gameRef.config.margin,
          -(size.y / 2) - gameRef.config.padding,
        );

        title.position = Vector2(
          size.x / 2,
          -gameRef.config.margin,
        );

        await addAll([
          HealthStatusBar(
            entityID: player.id,
            position: Vector2(
              gameRef.config.rotatedStatsBarsWidth / 2 + gameRef.config.padding,
              size.y / 2,
            ),
            side: side,
          ),
          HeatStatusBar(
            entityID: player.id,
            position: Vector2(
              gameRef.config.rotatedStatsBarsWidth / 2 +
                  gameRef.config.padding +
                  gameRef.config.rotatedStatsBarsWidth +
                  gameRef.config.padding,
              size.y / 2,
            ),
            side: side,
          ),
          ColdStatusBar(
            entityID: player.id,
            position: Vector2(
              gameRef.config.rotatedStatsBarsWidth / 2 +
                  gameRef.config.padding +
                  gameRef.config.rotatedStatsBarsWidth +
                  gameRef.config.padding +
                  gameRef.config.rotatedStatsBarsWidth +
                  gameRef.config.padding,
              size.y / 2,
            ),
            side: side,
          ),
        ]);
      case SideView.bossBottom:
    }
    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(
        gameRef.config.radius,
      ),
    );
  }

  final statsBarBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = StarshipShooterGame.lightBlack80;

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
    canvas.drawRRect(_rRect, StarshipShooterGame.borderPaint);

    // Reset canvas afterwards
    if (side == SideView.right) {
      canvas.restore();
    }
  }
  //#endregion
}
