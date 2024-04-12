import 'dart:math';

import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/status_bars/status_bar.dart';

class HealthStatusBar extends StatusBar {
  HealthStatusBar({
    required super.entity,
    required super.position,
    super.side,
    super.maxStatus,
  }) : super(paintColor: Colors.red);

  @override
  int get currentStatus => max(entity.health, 0);
}
