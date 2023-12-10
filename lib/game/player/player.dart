import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:starship_shooter/game/card.dart';
import 'package:starship_shooter/game/components/cards/heal_card.dart';
import 'package:starship_shooter/game/components/cards/offense_card.dart';
import 'package:starship_shooter/game/components/foundation_pile.dart';
import 'package:starship_shooter/game/components/health_component.dart';
import 'package:starship_shooter/game/components/stock_pile.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/side_view.dart';

enum PlayerType {
  Cold,
  Hot,
}

class Player {
  Player({
    required this.id,
    required this.side,
    required this.playerType,
    this.health = 20,
  });

  SideView side;
  double health;
  final int id;
  final PlayerType playerType;

  late StockPile stock;
  late WastePile waste;
  late List<FoundationPile> foundations;
  late Unicorn unicorn;
  late List<Card> _cards;

  // Attempt to go through cards and use them if there is one
  Future<bool> useCard(int card) async {
    return true;
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

  double _calculateHealthHeightPosition(CameraComponent camera) {
    if (side == SideView.left) {
      return camera.viewport.size.y -
          StarshipShooterGame.heartHeight -
          StarshipShooterGame.heartHeightGap;
    } else {
      return StarshipShooterGame.heartHeightGap;
    }
  }

  double _calculateHealthWidthPosition(CameraComponent camera) {
    if (side == SideView.left) {
      return StarshipShooterGame.cardGap + StarshipShooterGame.cardWidth;
    } else {
      return camera.viewport.size.x -
          StarshipShooterGame.heartWidth -
          StarshipShooterGame.cardWidth -
          StarshipShooterGame.cardGap;
    }
  }

  bool ownsCard(Card card) {
    return _cards.contains(card);
  }

  void startTurn(Player enemy) {
    // Go through the foundation cards until a foundation is found with a card
    // then start to use it
    for (final foundation in foundations) {
      if (foundation.isNotEmpty()) {
        // Retrieve the top card of the foundation
        final card = foundation.getTopCard();

        // Use the card's ability
        card.useCard(this, enemy);

        // Discard the card
        foundation.removeCard(card);
        _cards.remove(card);
        (card as PositionComponent).removeFromParent();
        return;
      }
    }
  }

  // Check if there is any foundation cards left to draw
  bool canContinue() {
    for (final foundation in foundations) {
      if (foundation.isNotEmpty()) return true;
    }
    return false;
  }

  bool canNotContinue() {
    return !canContinue();
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
      player: this,
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
        player: this,
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

    // Generate a pile of random cards
    _cards = List.generate(20, (index) {
      final cardType = Random().nextInt(100);
      if (cardType < 50) {
        return OffenseCard(playerType: playerType);
      } else {
        return HealCard(playerType: playerType);
      }
    })
      ..shuffle();

    await world.addAll(_cards.cast());
    await world.addAll(foundations);

    final cardToDeal = _cards.length - 1;
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(_cards[n]);
    }

    // Add Health HUD
    final healthStartPositionX = _calculateHealthWidthPosition(camera);
    final healthStartPositionY = _calculateHealthHeightPosition(camera);
    for (var i = 1; i <= health; i++) {
      final positionX = (side == SideView.left)
          ? healthStartPositionX +
              ((StarshipShooterGame.heartWidth + StarshipShooterGame.heartGap) *
                  i)
          : healthStartPositionX -
              ((StarshipShooterGame.heartWidth + StarshipShooterGame.heartGap) *
                  i);
      await world.add(
        HealthComponent(
          heartNumber: i,
          player: this,
          position: Vector2(
            positionX,
            healthStartPositionY,
          ),
        ),
      );
    }
  }
}
