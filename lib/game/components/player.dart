import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
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
    required this.entity,
    required this.side,
    required this.playerType,
  }) : super(anchor: Anchor.center);

  // Properties
  SideView side;
  final Entity entity;
  final PlayerType playerType;

  late Unicorn unicorn;
  late DeckComponent deck;
  late CardSlotsComponent cardSlots;
  late StatsBars statsBars;
  late InformationSection informationSection;
  late List<Card> _cards;
  late SpriteAnimationComponent _animationComponent;

  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  @override
  bool get debugMode => false;

  // Helper get for player stats
  int get health => gameRef.entityBloc.state.entities[entity]!.health;
  int get heat => gameRef.entityBloc.state.entities[entity]!.heat;
  int get cold => gameRef.entityBloc.state.entities[entity]!.cold;

  // #region State changes
  @override
  void onNewState(GameState state) {
    if (state.status == GameStatus.turnProcess &&
        state.currentEntity == entity) {
      startTurn();
    }

    if (state.status == GameStatus.roundEnds) {
      // Shuffle the cards and add 2 new cards to the pile
      deck.sortCards();

      // Generate new random cards
      final newCards = generateNewCards(2)..shuffle();
      for (final card in newCards) {
        // Only add card to the player if the deck can accept it
        if (deck.addCard(card)) {
          // card.flip();
          gameRef.add(card);
          _cards.add(card);
        }
      }

      // Add back 2 cold/heat status to the player
      gameRef.entityBloc.add(
        BoostAttributeEvent(
          entity: entity,
          heat: 2,
          cold: 2,
        ),
      );
    }
  }
  // #endregion

  List<Card> generateNewCards(int count) {
    return List.generate(count, (index) {
      final cardType = Random().nextInt(100);
      if (cardType < 50) {
        return OffenseCard(side: side);
      } else {
        return HealCard(side: side);
      }
    });
  }

  // Attempt to go through cards and use them if there is one
  Future<bool> useCard(int card) async {
    return true;
  }

  bool ownsCard(Card card) {
    return _cards.contains(card);
  }

  void startTurn() {
    final unit = cardSlots.firstPlayableCardSlot();
    if (unit == null) return;

    final card = unit.getFirstCard()!
      // Use the card's ability
      ..useCard(this);

    // Discard the card
    unit.removeCard(card);
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
  }

  // Check if there is any foundation cards left to draw
  bool canContinue() {
    return cardSlots.hasPlayableCards();
  }

  bool canNotContinue() {
    return !canContinue();
  }

  @override
  Future<void> onLoad() async {
    // Position the player
    final viewportSize = gameRef.camera.viewport.size;

    // Create player related components
    deck = DeckComponent(side: side, player: this);
    cardSlots = CardSlotsComponent(side: side, player: this);
    statsBars = StatsBars(side: side, player: this);
    informationSection = InformationSection(side: side, player: this);
    unicorn = Unicorn(side: side, player: this);

    // Set Player position based on SideView
    switch (side) {
      case SideView.left:
        // Player position
        position = Vector2(
          0,
          viewportSize.y / 2,
        );

      case SideView.right:
        // Player position
        position = Vector2(
          viewportSize.x,
          viewportSize.y / 2,
        );
    }

    // Add components to the world
    await addAll([
      unicorn,
      deck,
      cardSlots,
    ]);
    await add(statsBars);
    await add(informationSection);

    // Generate a pile of random cards
    _cards = generateNewCards(10)..shuffle();

    await gameRef.addAll(_cards.cast());
    for (final card in _cards) {
      // card.flip();
      deck.addCard(card);
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
