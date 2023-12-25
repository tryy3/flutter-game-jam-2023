import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/bloc/player/player_events.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/cards/heal_card.dart';
import 'package:starship_shooter/game/components/cards/offense_card.dart';
import 'package:starship_shooter/game/components/dynamic_health_component.dart';
import 'package:starship_shooter/game/components/foundation_pile.dart';
import 'package:starship_shooter/game/components/stock_pile.dart';
import 'package:starship_shooter/game/components/waste_pile.dart';
import 'package:starship_shooter/game/entities/unicorn/unicorn.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

enum PlayerType {
  cold,
  hot,
}

class Player extends PositionComponent
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<GameBloc, GameState> {
  Player({
    required this.id,
    required this.side,
    required this.playerType,
  }) : super(anchor: Anchor.center);

  SideView side;

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

  int get health => game.playerBloc.state.players[id]!.health;
  set health(int value) {
    game.playerBloc.add(PlayerHealthUpdateEvent(playerId: id, health: value));
  }

  @override
  // TODO: implement debugMode
  bool get debugMode => false;

  @override
  void onNewState(GameState state) {
    if (state.status == GameStatus.processTurn && state.lastPlayedId == id) {
      startTurn();
    }

    if (state.status == GameStatus.drawingCards &&
        game.playerBloc.state.players[id]!.health <= 0) {
      game.gameBloc.add(const GameOverEvent());
    }
  }

  // Attempt to go through cards and use them if there is one
  Future<bool> useCard(int card) async {
    return true;
  }

  bool isGameOver() {
    return health <= 0 || (stock.isLoaded && stock.cardCount() <= 0);
  }

  bool ownsCard(Card card) {
    return _cards.contains(card);
  }

  bool startTurn() {
    final enemy = gameRef.players.firstWhere((element) => element.id != id);

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

  @override
  Future<void> onLoad() async {
    // TODO(tryy3): Add a check for SideView so that unicorn sprite looks
    // to the left

    // Position the player
    final viewportSize = gameRef.camera.viewport.size;

    // Add Health HUD
    healthComponent = DynamicHealthComponent(
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

    foundations = List.generate(
      4,
      (i) => FoundationPile(
        i,
        player: this,
      ),
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
              (waste.size.y / 2) +
              StarshipShooterGame.cardGap +
              stock.size.y +
              StarshipShooterGame.cardGap,
        );

        for (final (index, element) in foundations.indexed) {
          element.position = Vector2(
            -position.x + (waste.size.x / 2) + StarshipShooterGame.cardGap,
            -position.y +
                (element.size.y / 2) +
                StarshipShooterGame.cardGap +
                stock.size.y +
                StarshipShooterGame.cardGap +
                waste.size.y +
                StarshipShooterGame.cardGap +
                (index * (element.size.y + StarshipShooterGame.cardGap)),
          );
        }

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

        for (final (index, element) in foundations.indexed) {
          element.position = Vector2(
            viewportSize.x -
                position.x -
                (element.size.x / 2) -
                StarshipShooterGame.cardGap,
            viewportSize.y -
                position.y -
                (element.size.y / 2) -
                StarshipShooterGame.cardGap -
                stock.size.y -
                StarshipShooterGame.cardGap -
                waste.size.y -
                StarshipShooterGame.cardGap -
                (index * (element.size.y + StarshipShooterGame.cardGap)),
          );
        }
    }

    // Add components to the world
    await addAll([
      Unicorn(),
      healthComponent,
      stock,
      waste,
    ]);
    await addAll(foundations);

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
