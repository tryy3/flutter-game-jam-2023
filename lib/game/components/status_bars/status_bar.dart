import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class StatusBar extends PositionComponent with HasGameRef<StarshipShooterGame> {
  StatusBar({
    required this.entityID,
    required super.position,
    this.side = SideView.bottom,
    this.maxStatus = 20,
    this.paintColor = Colors.white,
  }) : super(
          anchor: Anchor.center,
        ) {
    statusBarPaint.color = paintColor;
  }

  int entityID;
  int maxStatus;
  SideView side;
  Color paintColor;

  // Rectangless
  late RRect _statusBarRRect;

  // Auto generated stats
  int get currentStatus => 0;
  // int get health => 10;

  // Title component
  late TextComponent title;

  @override
  bool get debugMode => false;

  //#region Rendering
  @override
  Future<void> onLoad() async {
    size = (side == SideView.bottom)
        ? Vector2(
            gameRef.config.rotatedStatsBarsWidth,
            gameRef.config.rotatedStatsBarsHeight -
                (gameRef.config.padding * 2),
          )
        : Vector2(
            gameRef.config.rotatedStatsBarsHeight -
                (gameRef.config.padding * 2),
            gameRef.config.rotatedStatsBarsWidth,
          );

    _statusBarRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        0,
        size.x,
        size.y,
      ),
      Radius.circular(
        gameRef.config.radius,
      ),
    );

    var angle = 0.0;
    switch (side) {
      case SideView.left:
        angle = pi / 2;
      case SideView.right:
        angle = -pi / 2;
      case SideView.bottom:
      case SideView.bossBottom:
        angle = 0;
    }

    title = TextComponent(
      text: currentStatus.toString(),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontFamily: '04B_03',
        ),
      ),
      angle: angle,
    );
    await add(title);
  }

  final statsBarBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = StarshipShooterGame.lightBlack80;
  final statusBarPaint = Paint()
    ..style = PaintingStyle.fill
    ..strokeWidth = 3;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw the initial border around the area
    if (side == SideView.bottom) {
      canvas
        // Render the health bar
        ..drawRRect(_statusBarRRect, statsBarBorder)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              0,
              (_statusBarRRect.height / maxStatus) *
                  (maxStatus - currentStatus),
              _statusBarRRect.width,
              (_statusBarRRect.height / maxStatus) * currentStatus,
            ),
            Radius.circular(
              gameRef.config.radius,
            ),
          ),
          statusBarPaint,
        );
    } else {
      canvas
        // Render the health bar
        ..drawRRect(_statusBarRRect, statsBarBorder)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              0,
              0,
              (_statusBarRRect.width / maxStatus) * currentStatus,
              _statusBarRRect.height,
            ),
            Radius.circular(
              gameRef.config.radius,
            ),
          ),
          statusBarPaint,
        );
    }
  }

  @override
  void update(double dt) {
    title.text = currentStatus.toString();
  }
  //#endregion
}
