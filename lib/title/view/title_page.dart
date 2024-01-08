import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/view/game_page.dart';
import 'package:starship_shooter/l10n/l10n.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const TitlePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.titleAppBarTitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: const SafeArea(child: TitleView()),
    );
  }
}

class TitleView extends StatelessWidget {
  const TitleView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 64,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.red,
                ),
              ),
              onPressed: () {
                context.read<GameBloc>().add(
                      const ChangeGameSettings(
                        gameMode: GameMode.playerVSPlayer,
                        playerMode: PlayerMode.twoPlayers,
                      ),
                    );
                Navigator.of(context)
                    .pushReplacement<void, void>(GamePage.route());
              },
              child: const Center(
                child: Text(
                  'Player VS Player',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 64,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.green,
                ),
              ),
              onPressed: () {
                context.read<GameBloc>().add(
                      const ChangeGameSettings(
                        gameMode: GameMode.playerVSEnvironment,
                        playerMode: PlayerMode.twoPlayers,
                      ),
                    );
                Navigator.of(context)
                    .pushReplacement<void, void>(GamePage.route());
              },
              child: const Center(
                  child: Text(
                'Multiplayer Boss Fight',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 64,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.blue,
                ),
              ),
              onPressed: () {
                context.read<GameBloc>().add(
                      const ChangeGameSettings(
                        gameMode: GameMode.playerVSEnvironment,
                        playerMode: PlayerMode.onePlayer,
                      ),
                    );
                Navigator.of(context)
                    .pushReplacement<void, void>(GamePage.route());
              },
              child: const Center(
                child: Text(
                  'Singleplayer',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 64,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.yellow,
                ),
              ),
              onPressed: () {
                exit(0);
              },
              child: const Center(
                child: Text(
                  'Quit Game',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
