import 'dart:math';

import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/status_bars/status_bar.dart';

class HeatStatusBar extends StatusBar {
  HeatStatusBar({
    required super.entityID,
    required super.position,
    super.side,
  }) : super(paintColor: Colors.orange);

  @override
  int get currentStatus => max(
        gameRef.entityBloc.state.entities[entityID]?.heat ?? 0,
        0,
      );
}
