import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/cubit/game/game_stats_bloc.dart';
import 'package:starship_shooter/game/starship_shooter.dart';
import 'package:starship_shooter/game/view/game_page.dart';

class GameButton extends StatelessWidget {
  const GameButton({required this.game, super.key});

  final FlameGame? game;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameStatsBloc, GameStatsState>(
      builder: (context, state) {
        return state.status == GameStatus.running
            ? ElevatedButton(
                onPressed: () {
                  (game! as StarshipShooterGame).endTurn();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                ),
                child: const Text(
                  'End Turn',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await navigator.pushReplacement<void, void>(GamePage.route());
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                child: const Text(
                  'Restart Game',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
      },
    );
  }
}
