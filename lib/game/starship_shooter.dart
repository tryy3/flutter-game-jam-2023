import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/foundation_pile.dart';
import 'package:starship_shooter/game/components/stock_pile.dart';
import 'package:starship_shooter/game/components/tableau_pile.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/side_view.dart';
import 'package:starship_shooter/gen/assets.gen.dart';
import 'package:starship_shooter/l10n/l10n.dart';

class StarshipShooterGame extends FlameGame {
  StarshipShooterGame({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
  }) {
    images.prefix = '';
  }

  static const double cardGap = 40;
  static const double cardWidth = 70;
  static const double cardHeight = 110;
  static const double cardRadius = 5;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  static const double unicornGap = 100;
  static const double unicornWidth = 100;
  static const double unicornHeight = 100;
  static final Vector2 unicornSize = Vector2(unicornWidth, unicornHeight);

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  int counter = 0;

  final Player player1 = Player(id: 1, side: SideView.left);
  final Player player2 = Player(id: 1, side: SideView.right);

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    await images.load('images/klondike_sprites.png');

    final world = World(
      children: [
        Unicorn(
          position: Vector2(cardGap + cardWidth + unicornGap, size.y / 2),
        ),
        CounterComponent(
          position: (size / 2)
            ..sub(
              Vector2(0, 16),
            ),
        ),
      ],
    );

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    await player1.generatePlayer(world, camera);
    await player2.generatePlayer(world, camera);
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('images/klondike_sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
