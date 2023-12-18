import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/cubit/audio/audio_cubit.dart';
import 'package:starship_shooter/game/cubit/game/game_stats_bloc.dart';
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
          BlocProvider<GameStatsBloc>(create: (_) => GameStatsBloc()),
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
          statsBloc: context.read<GameStatsBloc>(),
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
        Center(
          child: GameButton(
            game: _game,
          ),
        ),
        // Center(
        //   child: ElevatedButton(
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all(
        //         gameOver ? Colors.amber : Colors.blue,
        //       ),
        //     ),
        //     onPressed: () async {
        //       context.read<GameStatsBloc>().add(const GameOver());
        //       // if (gameOver) {
        //       //   final navigator = Navigator.of(context);
        //       //   await navigator.pushReplacement<void, void>(GamePage.route());
        //       //   return;
        //       // }
        //       // final fGame = _game! as StarshipShooterGame;

        //       // // if (fGame.isOver()) {
        //       // //   setState(() => gameOver = true);
        //       // // } else {
        //       // fGame.endTurn();
        //       // }
        //     },
        //     child: const Text(
        //       'End Turn',
        //       style: TextStyle(
        //         color: Colors.black,
        //         fontSize: 18,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
