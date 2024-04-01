import 'dart:math';

import 'package:flutter/material.dart';
import 'package:starship_shooter/game/components/status_bars/status_bar.dart';

class ColdStatusBar extends StatusBar {
  ColdStatusBar({
    required super.entityID,
    required super.position,
    super.side,
  }) : super(paintColor: Colors.blue);

  @override
  int get currentStatus => max(
        gameRef.entityBloc.state.entities[entityID]!.cold,
        0,
      );
}
