import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/foundation_pile.dart';
import 'package:starship_shooter/game/components/stock_pile.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/side_view.dart';

class Player {
  Player({required this.id, required this.side, this.health = 100});

  SideView side;
  double health;
  final int id;

  late StockPile stock;
  late WastePile waste;
  late List<FoundationPile> foundations;
  late Unicorn unicorn;

  // Attempt to go through cards and use them if there is one
  Future<bool> useCard(int card) async {
    return true;
  }

  // Based on card input, try to take damage from it but also checking game rules
  // (defense cards)
  Future<int> takeDamage(Card card) async {
    return 0;
  }

  double _calculateBaseWidthPosition(CameraComponent camera) {
    if (side == SideView.left) {
      return StarshipShooterGame.cardGap;
    } else {
      return camera.viewport.size.x -
          StarshipShooterGame.cardWidth -
          StarshipShooterGame.cardGap;
    }
  }

  double _calculateUnicornWidthPosition(double baseWidth) {
    if (side == SideView.left) {
      return baseWidth +
          StarshipShooterGame.cardWidth +
          StarshipShooterGame.unicornGap;
    } else {
      return baseWidth - StarshipShooterGame.cardWidth;
    }
  }

  Future<void> generatePlayer(World world, CameraComponent camera) async {
    final baseWidth = _calculateBaseWidthPosition(camera);

    stock = StockPile(
      position: Vector2(
        baseWidth,
        StarshipShooterGame.cardGap,
      ),
      player: this,
    );
    waste = WastePile(
      position: Vector2(
        baseWidth,
        StarshipShooterGame.cardGap +
            StarshipShooterGame.cardHeight +
            StarshipShooterGame.cardGap,
      ),
      side: side,
    );
    foundations = List.generate(
      4,
      (i) => FoundationPile(
        i,
        position: Vector2(
          baseWidth,
          ((StarshipShooterGame.cardGap + StarshipShooterGame.cardHeight) * 2 +
                  StarshipShooterGame.cardGap) +
              (i *
                  (StarshipShooterGame.cardHeight +
                      StarshipShooterGame.cardGap)),
        ),
      ),
    );
    unicorn = Unicorn(
      position: Vector2(
        _calculateUnicornWidthPosition(baseWidth),
        camera.viewport.size.y / 2,
      ),
      side: side,
    );

    world
      ..add(stock)
      ..add(waste)
      ..add(unicorn);

    final cards = [
      for (var rank = 1; rank <= 13; rank++)
        for (var suit = 0; suit < 4; suit++) Card(rank, suit),
    ]..shuffle();

    await world.addAll(cards);
    await world.addAll(foundations);

    final cardToDeal = cards.length - 1;
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }
}
