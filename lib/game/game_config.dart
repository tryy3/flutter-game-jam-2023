import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameConfig {
  GameConfig({required this.camera});
  final CameraComponent camera;

  // Card settings
  double get cardWidth => (camera.viewport.size.y * 5.83) / 100;
  double get cardHeight => (camera.viewport.size.x * 5.46) / 100;
  double get cardRadius => 5;
  Vector2 get cardSize => Vector2(cardHeight, cardWidth);
  RRect get cardRRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, cardHeight, cardWidth),
        Radius.circular(cardRadius),
      );
  double get cardStatsIconWidth => (cardWidth * 37.5) / 100;
  double get cardStatsIconHeight => cardStatsIconWidth;
  Vector2 get cardStatsIconSize =>
      Vector2(cardStatsIconWidth, cardStatsIconHeight);
  double get cardIconWidth => (cardWidth * 50) / 100;
  double get cardIconHeight => cardIconWidth;
  Vector2 get cardIconSize => Vector2(cardIconWidth, cardIconHeight);

  // Unicorn settings
  double get unicornWidth => (camera.viewport.size.y * 9.25) / 100;
  double get unicornHeight => (camera.viewport.size.y * 9.25) / 100;
  Vector2 get unicornSize => Vector2(unicornWidth, unicornHeight);

  // Stats settings
  double get statsBarsWidth => (camera.viewport.size.y * 2.96) / 100;
  double get statsBarsLength => (camera.viewport.size.x * 20.83) / 100;

  // Margin padding settings
  double get margin => (camera.viewport.size.x * 1.04) / 100;
  double get padding => (camera.viewport.size.x * 1.04) / 100;
  double get radius => 5;
}
