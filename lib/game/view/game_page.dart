import 'dart:io';

import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/bloc/audio/audio_cubit.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/bloc/entity/entity_bloc.dart';
import 'package:starship_shooter/game/starship_shooter.dart';
import 'package:starship_shooter/game/view/game_button.dart';
import 'package:starship_shooter/l10n/l10n.dart';
import 'package:starship_shooter/loading/cubit/cubit.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GamePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<AudioCubit>(
            create: (context) =>
                AudioCubit(audioCache: context.read<PreloadCubit>().audio),
          ),
          BlocProvider<GameBloc>(create: (_) => GameBloc()),
          BlocProvider<EntityBloc>(create: (_) => EntityBloc()),
        ],
        child: const Scaffold(
          body: SafeArea(child: GameView()),
        ),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, this.game});

  final FlameGame? game;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  FlameGame? _game;
  bool gameOver = false;

  // late final Bgm bgm;

  @override
  void initState() {
    super.initState();
    // bgm = context.read<AudioCubit>().bgm;
    // bgm.play(Assets.audio.background);
  }

  @override
  void dispose() {
    // bgm.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.white,
          fontSize: 4,
        );

    _game ??= widget.game ??
        StarshipShooterGame(
          l10n: context.l10n,
          effectPlayer: context.read<AudioCubit>().effectPlayer,
          textStyle: textStyle,
          gameBloc: context.read<GameBloc>(),
          entityBloc: context.read<EntityBloc>(),
        );

    return Stack(
      children: [
        Positioned.fill(child: GameWidget(game: _game!)),
        Align(
          alignment: Alignment.topRight,
          child: BlocBuilder<AudioCubit, AudioState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.volume == 0 ? Icons.volume_off : Icons.volume_up,
                ),
                onPressed: () => context.read<AudioCubit>().toggleVolume(),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.white,
                ),
                padding: MaterialStateProperty.all(
                  const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 10,
                  ),
                ),
              ),
              onPressed: () {
                exit(0);
              },
              child: const Text(
                'Quit',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 70),
          child: Align(
            alignment: Alignment.topCenter,
            child: GameButton(
              game: _game,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return Text(
                'Status: ${state.status}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
