import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class StatsBars extends PositionComponent with HasGameRef<StarshipShooterGame> {
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
  int get health => game.entityBloc.state.entities[player.entity]!.health;
  int get cold => game.entityBloc.state.entities[player.entity]!.cold;
  int get heat => game.entityBloc.state.entities[player.entity]!.heat;

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
    size = Vector2(
      player.deck.size.x,
      StarshipShooterGame.padding +
          (StarshipShooterGame.statsBarsWidth + StarshipShooterGame.padding) *
              3,
    );

    switch (side) {
      case SideView.left:
        position = Vector2(
          -parentPosition.x + (size.x / 2) + StarshipShooterGame.margin,
          -parentPosition.y +
              (size.y / 2) +
              StarshipShooterGame.margin +
              player.deck.size.y +
              StarshipShooterGame.margin +
              player.cardSlots.size.y +
              StarshipShooterGame.margin,
        );

        title.angle = pi / 2;
        title.position = Vector2(
          size.x + StarshipShooterGame.margin,
          size.y / 2,
        );
      case SideView.right:
        position = Vector2(
          viewportSize.x -
              parentPosition.x -
              (size.x / 2) -
              StarshipShooterGame.margin,
          viewportSize.y -
              parentPosition.y -
              (size.y / 2) -
              StarshipShooterGame.margin -
              player.deck.size.y -
              StarshipShooterGame.margin -
              player.cardSlots.size.y -
              StarshipShooterGame.margin,
        );

        title.angle = (pi / 2) * 3;
        title.position = Vector2(
          -StarshipShooterGame.margin,
          size.y / 2,
        );
    }
    _rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(
        StarshipShooterGame.radius,
      ),
    );
    _healthBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        StarshipShooterGame.padding,
        StarshipShooterGame.padding,
        size.x - (StarshipShooterGame.padding * 2),
        StarshipShooterGame.statsBarsWidth,
      ),
      const Radius.circular(
        StarshipShooterGame.radius,
      ),
    );
    _heatBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        StarshipShooterGame.padding,
        StarshipShooterGame.padding +
            StarshipShooterGame.statsBarsWidth +
            StarshipShooterGame.padding,
        size.x - (StarshipShooterGame.padding * 2),
        StarshipShooterGame.statsBarsWidth,
      ),
      const Radius.circular(
        StarshipShooterGame.radius,
      ),
    );
    _coldBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        StarshipShooterGame.padding,
        StarshipShooterGame.padding +
            StarshipShooterGame.statsBarsWidth +
            StarshipShooterGame.padding +
            StarshipShooterGame.statsBarsWidth +
            StarshipShooterGame.padding,
        size.x - (StarshipShooterGame.padding * 2),
        StarshipShooterGame.statsBarsWidth,
      ),
      const Radius.circular(
        StarshipShooterGame.radius,
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
          const Radius.circular(
            StarshipShooterGame.radius,
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
          const Radius.circular(
            StarshipShooterGame.radius,
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
          const Radius.circular(
            StarshipShooterGame.radius,
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
