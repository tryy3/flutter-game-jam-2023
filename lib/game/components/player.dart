import 'dart:async';
import 'dart:developer' show log;
import 'dart:math' show Random, max, min;

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_bloc.dart';
import 'package:starship_shooter/game/bloc/game/game_state.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/card_slots/card_slots_component.dart';
import 'package:starship_shooter/game/components/cards/heal_card.dart';
import 'package:starship_shooter/game/components/cards/offense_card.dart';
import 'package:starship_shooter/game/components/deck_pile/deck_component.dart';
import 'package:starship_shooter/game/components/information_section.dart';
import 'package:starship_shooter/game/components/status_bars/player_status.dart';
import 'package:starship_shooter/game/entities/unicorn/unicorn.dart';
import 'package:starship_shooter/game/entity.dart';
import 'package:starship_shooter/game/game_config.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

enum PlayerType {
  cold,
  hot,
}

class Player extends PositionComponent
    with
        HasGameRef<StarshipShooterGame>,
        FlameBlocListenable<GameBloc, GameState>
    implements Entity {
  Player({
    required this.side,
    this.id = -1,
  }) : super(anchor: Anchor.center);

  // Properties
  SideView side;
  @override
  int id;

  late Unicorn unicorn;
  late DeckComponent deck;
  late CardSlotsComponent cardSlots;
  late PlayerStatus statsBars;
  late InformationSection informationSection;
  late List<Card> _cards;
  late SpriteAnimationComponent _animationComponent;

  final List<String> _logMessages = List.empty(growable: true);
  // final List<String> _logMessages = new List.from([
  //   'abc',
  //   'def',
  // ]);

  List<String> getLatestLogMessages() {
    const maxRows = 7;
    if (_logMessages.length <= maxRows) return _logMessages;
    return _logMessages
        .getRange(_logMessages.length - maxRows, _logMessages.length)
        .toList();
  }

  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  @override
  bool get debugMode => false;

  @override
  void onDispose() {
    informationSection.onDispose();
  }

  void addNewLogMessage(String msg) {
    _logMessages.add(msg);
  }
  // #region Player API

  // Helper get for player stats
  int _health = GameConfig.minHealth;
  @override
  int get health => _health;
  set health(int value) {
    _health = max(min(value, GameConfig.maxHealth), GameConfig.minHealth);
    if (_health <= GameConfig.minHealth && status == EntityStatus.alive) {
      killTheEntity();
    }
  }

  int _heat = GameConfig.minHeat;
  @override
  int get heat => _heat;
  set heat(int value) {
    _heat = max(min(value, GameConfig.maxHeat), GameConfig.minHeat);
  }

  int _cold = GameConfig.minCold;
  @override
  int get cold => _cold;
  set cold(int value) {
    _cold = max(min(value, GameConfig.maxCold), GameConfig.minCold);
  }

  @override
  EntityStatus status = EntityStatus.none;

  @override
  void healEntity(int healing) {
    health += healing;
  }

  @override
  void damageEntity(int damage) {
    health -= damage;
  }

  void killTheEntity() {
    status = EntityStatus.dead;
    cold = 0;
    heat = 0;
    // This will trigger the set health method twice, but shouldn't be a
    // problem as long as we have set the status before...
    health = 0;
    clearCards();
  }

  // #endregion

  // #region State changes
  @override
  void onNewState(GameState state) {
    if (state.status == GameStatus.turnProcess && state.currentEntityID == id) {
      startTurn();
    }

    // At the end of the round, buff player and give them cards
    // only if they are still alive
    if (state.status == GameStatus.roundEnds) {
      if (status != EntityStatus.dead) {
        // Shuffle the cards and add 2 new cards to the pile
        deck.sortCards();

        // Generate new random cards
        final newCards = generateNewCards(2)..shuffle();
        for (final card in newCards) {
          // Only add card to the player if the deck can accept it
          if (deck.addCard(card)) {
            // card.flip();
            add(card);
            _cards.add(card);
          }
        }

        // Add back 2 cold/heat status to the player
        heat += 2;
        cold += 2;
      }
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
    card.deleteCard(
      opacityDuration: .4,
      onComplete: () {
        _cards.remove(card);
      },
    );
  }

  // Check if there is any foundation cards left to draw
  @override
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
    statsBars = PlayerStatus(side: side, player: this);
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
      case SideView.bottom:
        // Player position
        position = Vector2(
          viewportSize.x / 2,
          viewportSize.y,
        );
      case SideView.bossBottom:
    }

    // Add components to the world
    await addAll([
      unicorn,
      deck,
      cardSlots,
    ]);
    await add(statsBars);
    await add(informationSection);
  }

  Future<void> createCards() async {
    // Generate a pile of random cards
    _cards = generateNewCards(10)..shuffle();

    // await gameRef.addAll(_cards.cast());
    await addAll(_cards.cast());
    for (final card in _cards) {
      // card.flip();
      deck.addCard(card);
    }
  }

  Future<void> clearCards() async {
    for (final card in _cards) {
      card.deleteCard();
    }
    _cards.clear();
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

  @override
  Future<bool> respawnEntity() async {
    health = GameConfig.maxHealth;
    heat = GameConfig.maxHeat;
    cold = GameConfig.maxCold;
    status = EntityStatus.alive;
    _logMessages.clear();

    await createCards();

    return true;
  }
}
