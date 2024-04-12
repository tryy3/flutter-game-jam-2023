import 'dart:math';

import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/status_bars/status_bar.dart';

class HeatStatusBar extends StatusBar {
  HeatStatusBar({
    required super.entity,
    required super.position,
    super.side,
  }) : super(paintColor: Colors.orange);

  @override
  int get currentStatus => max(entity.heat, 0);
}
