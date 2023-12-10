import 'package:flame/effects.dart';
import 'package:starship_shooter/game/pile.dart';
import 'package:starship_shooter/game/player/player.dart';

abstract class Card extends PositionProvider {
  bool get isFaceUp;
  bool get isFaceDown;
  void flip();
  void useCard(Player player, Player enemy);
  void updatePile(Pile pile);
}
