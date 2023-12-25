// ignore_for_file: no_default_cases

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/view/game_page.dart';

class GameButton extends StatelessWidget {
  const GameButton({required this.game, super.key});

  final FlameGame? game;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        switch (state.status) {
          case GameStatus.gameOver:
            return ElevatedButton(
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
          case GameStatus.processTurn || GameStatus.startTurn:
            return ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
              ),
              child: const Text(
                'Proccessing turn...',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          default:
            return ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(const StartTurnEvent());
                // (game! as StarshipShooterGame).endTurn();
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
            );
        }
      },
    );
  }
}
