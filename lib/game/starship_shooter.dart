import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/foundation_pile.dart';
import 'package:starship_shooter/game/components/stock_pile.dart';
import 'package:starship_shooter/game/components/tableau_pile.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/game.dart';
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

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  int counter = 0;

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    await images.load('images/klondike_sprites.png');

    final stock = StockPile(position: Vector2.all(cardGap));
    final waste =
        WastePile(position: Vector2(cardGap, cardGap + cardHeight + cardGap));
    final foundations = List.generate(
      4,
      (i) => FoundationPile(
        i,
        position: Vector2(
            cardGap,
            ((cardGap + cardHeight) * 2 + cardGap) +
                (i * (cardHeight + cardGap))),
      ),
    );

    final world = World(
      children: [
        Unicorn(position: size / 2),
        CounterComponent(
          position: (size / 2)
            ..sub(
              Vector2(0, 16),
            ),
        ),
        stock,
        waste,
      ],
    );

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;

    final cards = [
      for (var rank = 1; rank <= 13; rank++)
        for (var suit = 0; suit < 4; suit++) Card(rank, suit),
    ];
    cards.shuffle();
    await world.addAll(cards);
    await world.addAll(foundations);

    var cardToDeal = cards.length - 1;
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('images/klondike_sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
