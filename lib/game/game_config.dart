import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameConfig {
  GameConfig({required this.camera});
  final CameraComponent camera;

  // Calculate numbers by taking (base number / y * 100), this will result
  // in the number needed for using in the percentage below.
  // for example with cardWidth, based on y height of 1080 we want the cardwidth
  // to be 63 pixels. So we divide (63 / 1080) * 100, which results in roughly
  // 5.83

  // Card settings
  double get cardWidth => (camera.viewport.size.y * 5.83) / 100;
  double get cardHeight => (camera.viewport.size.x * 5.46) / 100;
  double get cardRadius => 5;
  Vector2 get rotatedCardSize => Vector2(cardHeight, cardWidth);
  Vector2 get normalCardSize => Vector2(cardWidth, cardHeight);
  RRect get rotatedCardRRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, cardHeight, cardWidth),
        Radius.circular(cardRadius),
      );
  RRect get normalCardRRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, cardWidth, cardHeight),
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
  double get rotatedStatsBarsWidth => (camera.viewport.size.y * 2.96) / 100;
  double get rotatedStatsBarsHeight => (camera.viewport.size.x * 20.83) / 100;

  // Margin padding settings
  double get margin => (camera.viewport.size.x * 1.04) / 100;
  double get padding => (camera.viewport.size.x * 1.04) / 100;
  double get radius => 5;

  // Attribute values
  static const int maxHealth = 20;
  static const int maxCold = 20;
  static const int maxHeat = 20;
  static const int minHealth = 0;
  static const int minCold = 0;
  static const int minHeat = 0;

  // Game static configs
  static const double delayBetweenRounds = 1;

  // Simple boss settings
  double get simpleBossWidth => (camera.viewport.size.y * 9.25) / 100;
  double get simpleBossHeight => (camera.viewport.size.y * 9.25) / 100;
  Vector2 get simpleBossSize => Vector2(simpleBossWidth, simpleBossHeight);
}
