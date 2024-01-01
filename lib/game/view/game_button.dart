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
                padding: MaterialStateProperty.all(
                  const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 15,
                    bottom: 15,
                  ),
                ),
              ),
              child: const Text(
                'Restart Game',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          case GameStatus.roundStarts ||
                GameStatus.turnStarts ||
                GameStatus.turnProcess ||
                GameStatus.turnEnds ||
                GameStatus.roundEnds ||
                GameStatus.inBetweenTurns:
            return ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 15,
                    bottom: 15,
                  ),
                ),
              ),
              child: const Text(
                'Waiting for round to end...',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          case GameStatus.waitingForRoundStart || GameStatus.gameStarts:
            return ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(const RoundStartsEvent());
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 15,
                    bottom: 15,
                  ),
                ),
              ),
              child: const Text(
                'Start Round',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
        }
      },
    );
  }
}
