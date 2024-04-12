import 'dart:math';

import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/status_bars/status_bar.dart';

class ColdStatusBar extends StatusBar {
  ColdStatusBar({
    required super.entity,
    required super.position,
    super.side,
  }) : super(paintColor: Colors.blue);

  @override
  int get currentStatus => max(entity.cold, 0);
}
