import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/card.dart';
import 'package:starship_shooter/game/components/cards/heal_card.dart';
import 'package:starship_shooter/game/components/cards/offense_card.dart';
import 'package:starship_shooter/game/components/dynamic_health_component.dart';
import 'package:starship_shooter/game/components/foundation_pile.dart';
import 'package:starship_shooter/game/components/stock_pile.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/cubit/player/player_bloc.dart';
import 'package:starship_shooter/game/cubit/player/player_events.dart';
import 'package:starship_shooter/game/cubit/player/player_state.dart';
import 'package:starship_shooter/game/entities/unicorn/behaviors/tapping_behavior.dart';
import 'package:starship_shooter/game/game.dart';
import 'package:starship_shooter/game/side_view.dart';
import 'package:starship_shooter/gen/assets.gen.dart';

enum PlayerType {
  cold,
  hot,
}

class Player extends PositionComponent with HasGameRef<StarshipShooterGame> {
  Player({
    required this.id,
    required this.side,
    required this.playerType,
    int health = 20,
  }) : super(anchor: Anchor.center) {
    _health = health;
  }

  SideView side;
  late int _health;

  final int id;
  final PlayerType playerType;

  late StockPile stock;
  late WastePile waste;
  late List<FoundationPile> foundations;
  // late Unicorn unicorn;
  late List<Card> _cards;
  late DynamicHealthComponent healthComponent;

  late SpriteAnimationComponent _animationComponent;

  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  int get health => _health;
  set health(int value) {
    final v = max(value, 0);
    _health = v;

    game.playerBloc.add(PlayerHealthUpdateEvent(playerId: id, health: v));
  }

  @override
  // TODO: implement debugMode
  bool get debugMode => true;

  // Attempt to go through cards and use them if there is one
  Future<bool> useCard(int card) async {
    return true;
  }

  bool isGameOver() {
    return _health <= 0 || stock.cardCount() <= 0;
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
      return baseWidth -
          StarshipShooterGame.cardWidth -
          StarshipShooterGame.cardGap;
    }
  }

  bool ownsCard(Card card) {
    return _cards.contains(card);
  }

  bool startTurn(Player enemy) {
    for (final foundation in foundations) {
      if (foundation.isNotEmpty()) {
        // Retrieve the top card of the foundation
        final card = foundation.getTopCard()
          // Use the card's ability
          ..useCard(this, enemy);

        // Discard the card
        foundation.removeCard(card);
        card.add(
          OpacityEffect.fadeOut(
            EffectController(duration: .4),
            target: card,
            onComplete: () {
              card.removeFromParent();
              _cards.remove(card);
            },
          ),
        );

        return true;
      }
    }
    return false;
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

    await world.addAll(foundations);
  }

  @override
  Future<void> onLoad() async {
    // TODO(tryy3): Add a check for SideView so that unicorn sprite looks
    // to the left

    // Position the player
    final viewportSize = gameRef.camera.viewport.size;

    // Add Health HUD
    healthComponent = DynamicHealthComponent(
      startHealth: _health,
      side: side,
      size: StarshipShooterGame.heartSize,
    );

    // Create the StockPile component
    stock = StockPile(
      player: this,
    );

    // Create the waste pile component
    waste = WastePile(
      side: side,
      player: this,
    );

    // TODO(tryy3): Think about placing this in each component instead?
    // Generating position based on side is so different it's better to simply
    // make a switch case based on it and add them after initization
    switch (side) {
      case SideView.left:
        // Player position
        position = Vector2(
          (StarshipShooterGame.unicornWidth / 2) +
              StarshipShooterGame.cardGap +
              StarshipShooterGame.cardWidth +
              StarshipShooterGame.cardGap,
          viewportSize.y / 2,
        );

        // Component positions
        stock.position = Vector2(
          -position.x + (stock.size.x / 2) + StarshipShooterGame.cardGap,
          -position.y + (stock.size.y / 2) + StarshipShooterGame.cardGap,
        );

        healthComponent.position = Vector2(
          -position.x +
              (healthComponent.size.x / 2) +
              StarshipShooterGame.heartWidthGap,
          viewportSize.y -
              position.y -
              (healthComponent.size.y / 2) -
              StarshipShooterGame.heartHeightGap,
        );

        waste.position = Vector2(
          -position.x + (waste.size.x / 2) + StarshipShooterGame.cardGap,
          -position.y +
              (stock.size.y / 2) +
              StarshipShooterGame.cardGap +
              stock.size.y +
              StarshipShooterGame.cardGap,
        );

      case SideView.right:
        // Player position
        position = Vector2(
          viewportSize.x -
              (StarshipShooterGame.unicornWidth / 2) -
              StarshipShooterGame.cardGap -
              StarshipShooterGame.cardWidth -
              StarshipShooterGame.cardGap,
          viewportSize.y / 2,
        );

        // Component positions
        stock.position = Vector2(
          viewportSize.x -
              position.x -
              (stock.size.x / 2) -
              StarshipShooterGame.cardGap,
          viewportSize.y -
              position.y -
              (stock.size.y / 2) -
              StarshipShooterGame.cardGap,
        );

        healthComponent.position = Vector2(
          viewportSize.x -
              position.x -
              (healthComponent.size.x / 2) -
              StarshipShooterGame.heartWidthGap,
          -position.y +
              (healthComponent.size.y / 2) +
              StarshipShooterGame.heartHeightGap,
        );

        waste.position = Vector2(
          viewportSize.x -
              position.x -
              (waste.size.x / 2) -
              StarshipShooterGame.cardGap,
          viewportSize.y -
              position.y -
              (waste.size.y / 2) -
              StarshipShooterGame.cardGap -
              stock.size.y -
              StarshipShooterGame.cardGap,
        );
    }

    // Add components to the world
    await addAll([
      Unicorn(),
      healthComponent,
      stock,
      waste,
    ]);

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

    await addAll(_cards.cast());

    // Add cards to the stock pile
    final cardToDeal = _cards.length - 1;
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(_cards[n]);
    }
  }

  void resetAnimation() {
    animationTicker
      ..currentIndex = animationTicker.spriteAnimation.frames.length - 1
      ..update(0.1)
      ..currentIndex = 0;
  }

  /// Plays the animation.
  void playAnimation() => animationTicker.reset();

  /// Returns whether the animation is playing or not.
  bool isAnimationPlaying() => !animationTicker.done();
}
