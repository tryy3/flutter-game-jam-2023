import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/components/card.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class OffenseCard extends Card with HasGameRef<StarshipShooterGame> {
  OffenseCard({required super.side}) {
    super.size = StarshipShooterGame.cardSize;
    super.logoSprite = spriteSheet(0, 160, 32, 32);

    // Randomize if it's gonna be cold or heat card
    final typeOfCard = Random().nextInt(100);
    final cardMultiplier = Random().nextInt(5) + 1;
    final cardBaseOutput = Random().nextInt(5) + 1;
    if (typeOfCard < 50) {
      // Heat
      cold = cardMultiplier;
      damage = cardMultiplier * cardBaseOutput;
    } else {
      // Cold
      heat = cardMultiplier;
      damage = cardMultiplier * cardBaseOutput;
    }

    super.descriptionBlockNodes = [
      HeaderNode.simple('Damage Card', level: 3),
      HeaderNode.simple('$damage', level: 4),
    ];
  }

  late int damage;

  @override
  String toString() {
    return 'Offense card - damage: $damage';
  }

  @override
  void useCard(Player player) {
    super.useCard(player);
    gameRef.entityBloc.add(DamageEvent(entity: player.entity, damage: damage));
  }

  //#region Rendering

  // @override
  // void render(Canvas canvas) {
  //   if (isFaceUp) {
  //     _renderFront(canvas);
  //   } else {
  //     _renderBack(canvas);
  //   }
  // }

  // static Paint backBackgroundPaint = Paint();
  // static final Paint backBorderPaint1 = Paint()
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 3;
  // static final Paint backBorderPaint2 = Paint()
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 35;
  // static final RRect cardRRect = RRect.fromRectAndRadius(
  //   StarshipShooterGame.cardSize.toRect(),
  //   const Radius.circular(StarshipShooterGame.cardRadius),
  // );
  // static final RRect backRRectInner = cardRRect.deflate(40);

  // void _renderBack(Canvas canvas) {
  //   Sprite backSprite;
  //   if (playerType == PlayerType.hot) {
  //     backBackgroundPaint.color = const Color(0xff380c02);
  //     backBorderPaint1.color = const Color(0xffdbaf58);
  //     backBorderPaint2.color = const Color(0x5CEF971B);
  //     backSprite = spriteSheet(160, 2016, 32, 32);
  //   } else {
  //     backBackgroundPaint.color = const Color.fromARGB(255, 2, 19, 56);
  //     backBorderPaint1.color = const Color.fromARGB(255, 88, 160, 219);
  //     backBorderPaint2.color = const Color.fromARGB(255, 88, 112, 219);
  //     backSprite = spriteSheet(224, 2016, 32, 32);
  //   }

  //   canvas
  //     ..drawRRect(cardRRect, backBackgroundPaint)
  //     ..drawRRect(cardRRect, backBorderPaint1)
  //     ..drawRRect(backRRectInner, backBorderPaint2);
  //   backSprite.render(
  //     canvas,
  //     position: size / 2,
  //     size: Vector2.all(size.x / 2),
  //     anchor: Anchor.center,
  //   );
  // }

  // static Paint frontBackgroundPaint = Paint();
  // static final Paint redBorderPaint = Paint()
  //   ..color = const Color(0xffece8a3)
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 3;
  // static final Paint blackBorderPaint = Paint()
  //   ..color = const Color(0xff7ab2e8)
  //   ..style = PaintingStyle.stroke
  //   ..strokeWidth = 3;
  // static final blueFilter = Paint()
  //   ..colorFilter = const ColorFilter.mode(
  //     Color(0x880d8bff),
  //     BlendMode.srcATop,
  //   );

  // void _renderFront(Canvas canvas) {
  //   Sprite damageSymbol;

  //   if (playerType == PlayerType.hot) {
  //     damageSymbol = spriteSheet(128, 2720, 32, 32);
  //     frontBackgroundPaint.color = const Color(0xff380c02);
  //   } else {
  //     damageSymbol = spriteSheet(160, 2720, 32, 32);
  //     frontBackgroundPaint.color = const Color.fromARGB(255, 2, 19, 56);
  //   }

  //   frontBackgroundPaint.color =
  //       frontBackgroundPaint.color.withOpacity(opacity);
  //   redBorderPaint.color = redBorderPaint.color.withOpacity(opacity);

  //   canvas
  //     ..drawRRect(cardRRect, frontBackgroundPaint)
  //     ..drawRRect(
  //       cardRRect,
  //       blackBorderPaint,
  //     );

  //   drawSprite(canvas, damageSymbol, 0.12, 0.12, scale: 0.4);
  //   drawSprite(canvas, damageSymbol, 0.12, 0.12, scale: 0.4, rotate: true);
  //   _drawNumber(canvas);

  //   drawSprite(canvas, damageSymbol, 0.5, 0.5);
  // }

  // void _drawNumber(Canvas canvas) {
  //   // int pos = 0;
  //   for (final ch in damage.toString().characters) {
  //     var spritePositionX = 0;
  //     switch (ch) {
  //       case '1':
  //         spritePositionX = 32 * 0;
  //       case '2':
  //         spritePositionX = 32 * 1;
  //       case '3':
  //         spritePositionX = 32 * 2;
  //       case '4':
  //         spritePositionX = 32 * 3;
  //       case '5':
  //         spritePositionX = 32 * 4;
  //       case '6':
  //         spritePositionX = 32 * 5;
  //       case '7':
  //         spritePositionX = 32 * 6;
  //       case '8':
  //         spritePositionX = 32 * 7;
  //       case '9':
  //         spritePositionX = 32 * 8;
  //       case '10':
  //         spritePositionX = 32 * 9;
  //     }
  //     final numberSprite =
  //         spriteSheet(spritePositionX.toDouble(), 1248, 32, 32);
  //     drawSprite(canvas, numberSprite, 0.14, 0.27, scale: 0.6);
  //     drawSprite(canvas, numberSprite, 0.14, 0.27, scale: 0.6, rotate: true);

  //     // pos++;
  //   }
  // }
  //#endregion
}
