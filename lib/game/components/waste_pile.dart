import 'package:flame/components.dart';
import 'package:starship_shooter/game/card.dart';
import 'package:starship_shooter/game/pile.dart';
import 'package:starship_shooter/game/player/player.dart';
import 'package:starship_shooter/game/side_view.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class WastePile extends PositionComponent implements Pile {
  WastePile({required super.position, required this.side, required this.player})
      : super(anchor: Anchor.topLeft, size: StarshipShooterGame.cardSize);

  final List<Card> _cards = [];
  final Vector2 _fanOffset = Vector2(StarshipShooterGame.cardWidth * 0.3, 0);
  SideView side;
  Player player;

  //#region Pile API

  @override
  bool canMoveCard(Card card) => _cards.isNotEmpty && _cards.contains(card);

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card) {
    if (canMoveCard(card)) return;
    final cardIndex = _cards.indexOf(card);
    _cards.removeAt(cardIndex);
    _fanOutTopCards();
  }

  @override
  void returnCard(Card card) {
    card.priority = _cards.indexOf(card);
    _fanOutTopCards();
  }

  @override
  void acquireCard(Card card) {
    if (card.isFaceUp) return;
    card
      ..pile = this
      ..position = position
      ..priority = _cards.length;
    _cards.add(card);
    _fanOutTopCards();
  }

  //#endregion

  List<Card> removeAllCards() {
    final cards = _cards.toList();
    _cards.clear();
    return cards;
  }

  void _fanOutTopCards() {
    final n = _cards.length;
    for (var i = 0; i < n; i++) {
      _cards[i].position = position;
    }
    if (n == 2) {
      _cards[1]
          .position
          .add((side == SideView.left) ? _fanOffset : -_fanOffset);
    } else if (n >= 3) {
      _cards[n - 2]
          .position
          .add((side == SideView.left) ? _fanOffset : -_fanOffset);
      _cards[n - 1]
          .position
          .addScaled((side == SideView.left) ? _fanOffset : -_fanOffset, 2);
    }
  }
}
