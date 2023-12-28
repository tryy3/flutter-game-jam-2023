import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_events.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/bloc/player/player_events.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/card_slots/card_slots_component.dart';
import 'package:starship_shooter/game/components/cards/heal_card.dart';
import 'package:starship_shooter/game/components/cards/offense_card.dart';
import 'package:starship_shooter/game/components/deck_pile/deck_component.dart';
import 'package:starship_shooter/game/components/information_section.dart';
import 'package:starship_shooter/game/components/stats_bars.dart';
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

  // Properties
  SideView side;
  final int id;
  final PlayerType playerType;

  late DeckComponent deck;
  late CardSlotsComponent cardSlots;
  late StatsBars statsBars;
  late InformationSection informationSection;
  late List<Card> _cards;
  late SpriteAnimationComponent _animationComponent;

  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  int get health => game.playerBloc.state.players[id]!.health;
  set health(int value) {
    game.playerBloc.add(PlayerHealthUpdateEvent(playerId: id, health: value));
  }

  @override
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
    return health <= 0;
  }

  bool ownsCard(Card card) {
    return _cards.contains(card);
  }

  bool startTurn() {
    final enemy = gameRef.players.firstWhere((element) => element.id != id);
    return false;
  }

  // Check if there is any foundation cards left to draw
  bool canContinue() {
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
    // healthComponent = DynamicHealthComponent(
    //   side: side,
    //   size: StarshipShooterGame.heartSize,
    // );

    // Create player related components
    deck = DeckComponent(side: side, player: this);
    cardSlots = CardSlotsComponent(side: side, player: this);
    statsBars = StatsBars(side: side, player: this);
    informationSection = InformationSection(side: side, player: this);

    // Set Player position based on SideView
    switch (side) {
      case SideView.left:
        // Player position
        position = Vector2(
          (StarshipShooterGame.unicornWidth / 2) +
              StarshipShooterGame.padding +
              deck.size.x +
              StarshipShooterGame.padding,
          viewportSize.y / 2,
        );

      case SideView.right:
        // Player position
        position = Vector2(
          viewportSize.x -
              (StarshipShooterGame.unicornWidth / 2) -
              StarshipShooterGame.padding -
              deck.size.x -
              StarshipShooterGame.padding,
          viewportSize.y / 2,
        );
    }

    // Add components to the world
    await addAll([
      Unicorn(),
      deck,
      cardSlots,
    ]);
    await add(statsBars);
    await add(informationSection);

    // Generate a pile of random cards
    _cards = List.generate(10, (index) {
      final cardType = Random().nextInt(100);
      if (cardType < 50) {
        return OffenseCard(playerType: playerType);
      } else {
        return HealCard(playerType: playerType);
      }
    })
      ..shuffle();

    await gameRef.addAll(_cards.cast());
    var i = 0;
    for (final card in _cards) {
      card.flip();
      deck.addCard(i, card);
      i++;
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
