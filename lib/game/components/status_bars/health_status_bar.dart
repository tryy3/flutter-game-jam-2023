import 'dart:math';

import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/status_bars/status_bar.dart';

class HealthStatusBar extends StatusBar {
  HealthStatusBar({
    required super.entityID,
    required super.position,
    super.side,
    super.maxStatus,
  }) : super(paintColor: Colors.red);

  @override
  int get currentStatus => max(
        gameRef.entityBloc.state.entities[entityID]?.health ?? 0,
        0,
      );
}
