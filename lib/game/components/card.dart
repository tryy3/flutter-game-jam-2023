import 'dart:async';
import 'dart:math' show pi;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
// import 'package:starship_shooter/game/bloc/entity/entity_events.dart';
import 'package:starship_shooter/game/components/pile.dart';
import 'package:starship_shooter/game/components/player.dart';
import 'package:starship_shooter/game/starship_shooter.dart';

class Card extends PositionComponent
    with DragCallbacks, HasGameRef<StarshipShooterGame>
    implements OpacityProvider {
  Card({
    required this.side,
  }) : super(anchor: Anchor.center);

  // Card Properties
  SideView side;
  Pile? pile;
  bool _isDragging = false;
  final List<Card> attachedCards = [];
  List<BlockNode> descriptionBlockNodes = [];
  int cold = 0;
  int heat = 0;
  Sprite? logoSprite;

  double _opacity = 1;
  @override
  bool get debugMode => false;

  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) => _opacity = value;

  //#region Card API
  @mustCallSuper
  void useCard(Player player) {
    player
      ..heat -= heat
      ..cold -= cold;
  }

  // Attempts to delete itself
  void deleteCard({double? opacityDuration, void Function()? onComplete}) {
    pile?.removeCard(this);

    if (opacityDuration != null) {
      add(
        OpacityEffect.fadeOut(
          EffectController(duration: .4),
          target: this,
          onComplete: () {
            removeFromParent();
            onComplete?.call();
          },
        ),
      );
    } else {
      removeFromParent();
    }
  }
  // #endregion

  //#region Dragging
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (pile?.canMoveCard(this) ?? false) {
      _isDragging = true;
      priority = 100;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) {
      return;
    }
    final delta = event.localDelta;
    position.add(delta);
    for (final card in attachedCards) {
      card.position.add(delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    final dropPiles = parent!
        // .componentsAtPoint(position + size / 2)
        .componentsAtPoint(position)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      if (dropPiles.first.canAcceptCard(this)) {
        pile!.removeCard(this);
        dropPiles.first.acquireCard(this);
        if (attachedCards.isNotEmpty) {
          for (final card in attachedCards) {
            dropPiles.first.acquireCard(card);
          }
          attachedCards.clear();
        }
        return;
      }
    }
    pile!.returnCard(this);
    if (attachedCards.isNotEmpty) {
      for (final card in attachedCards) {
        pile!.returnCard(card);
      }
      attachedCards.clear();
    }
  }
  // #endregion

  //#region Component API
  @override
  Future<void> onLoad() async {
    size = (side == SideView.bottom)
        ? gameRef.config.normalCardSize
        : gameRef.config.rotatedCardSize;

    final style = DocumentStyle(
      background: BackgroundStyle(),
      text: InlineTextStyle(
        fontSize: 8,
        fontFamily: '04B_03',
        color: Colors.white,
      ),
      header3: BlockStyle(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
        text: InlineTextStyle(
          fontScale: 0.9,
        ),
      ),
      header4: BlockStyle(
        padding: const EdgeInsets.fromLTRB(15, 2, 15, 0),
        text: InlineTextStyle(
          fontScale: 1.5,
        ),
      ),
    );
    final document = DocumentRoot(descriptionBlockNodes);
    final textElementComponent = TextElementComponent.fromDocument(
      document: document,
      style: style,
      size: (side == SideView.bottom)
          ? Vector2(size.x, size.y / 2)
          : Vector2(size.y, size.x / 2),
    );
    await add(textElementComponent);

    if (side == SideView.left) {
      textElementComponent
        ..position = Vector2(size.x / 2, 0)
        ..angle = pi / 2;
    } else if (side == SideView.right) {
      textElementComponent
        ..position = Vector2(size.x / 2, size.y)
        ..angle = -pi / 2;
    } else if (side == SideView.bottom) {
      textElementComponent.position = Vector2(0, size.y / 2);
    }
  }
  // #endregion

  //#region Rendering
  @override
  void render(Canvas canvas) {
    _renderFront(canvas);
  }

  void drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    final pos = (side == SideView.bottom)
        ? Vector2(relativeY * size.y, relativeX * size.x)
        : Vector2(relativeX * size.x, relativeY * size.y);

    sprite.render(
      canvas,
      position: pos,
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
      overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
    );
  }

  Sprite _findSpriteNumber(
    String number,
    double startPositionY,
    Vector2 size,
  ) {
    var spritePositionX = 0;
    switch (number) {
      case '1':
        spritePositionX = 32 * 0;
      case '2':
        spritePositionX = 32 * 1;
      case '3':
        spritePositionX = 32 * 2;
      case '4':
        spritePositionX = 32 * 3;
      case '5':
        spritePositionX = 32 * 4;
      case '6':
        spritePositionX = 32 * 5;
      case '7':
        spritePositionX = 32 * 6;
      case '8':
        spritePositionX = 32 * 7;
      case '9':
        spritePositionX = 32 * 8;
      case '10':
        spritePositionX = 32 * 9;
    }

    return spriteSheet(
      spritePositionX.toDouble(),
      startPositionY,
      size.x,
      size.y,
    );
  }

  Paint frontBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 53, 21, 21)
    ..style = PaintingStyle.fill;
  final Paint redBorderPaint = Paint()
    ..color = const Color.fromARGB(255, 129, 37, 37)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  void _renderFront(Canvas canvas) {
    frontBackgroundPaint.color =
        frontBackgroundPaint.color.withOpacity(opacity);
    redBorderPaint.color = redBorderPaint.color.withOpacity(opacity);

    final cardRRect = (side == SideView.bottom)
        ? gameRef.config.normalCardRRect
        : gameRef.config.rotatedCardRRect;

    canvas
      ..drawRRect(cardRRect, frontBackgroundPaint)
      ..drawRRect(
        cardRRect,
        redBorderPaint,
      );

    if (side == SideView.left) {
      canvas
        ..save()
        ..rotate(pi / 2);

      if (cold > 0) {
        final coldSpriteNumber = _findSpriteNumber(
          cold.toString(),
          1344,
          Vector2(32, 32),
        );
        final topLeftPosition = Vector2(
          gameRef.config.cardStatsIconWidth / 2,
          -size.x + (gameRef.config.cardStatsIconHeight / 2),
        );
        coldSpriteNumber.render(
          canvas,
          position: topLeftPosition,
          anchor: Anchor.center,
          size: gameRef.config.cardStatsIconSize,
          overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      if (heat > 0) {
        final heatSpriteNumber = _findSpriteNumber(
          heat.toString(),
          1056,
          Vector2(32, 32),
        );
        final topLeftPosition = Vector2(
          size.y - (gameRef.config.cardStatsIconWidth / 2),
          -size.x + (gameRef.config.cardStatsIconHeight / 2),
        );
        heatSpriteNumber.render(
          canvas,
          position: topLeftPosition,
          anchor: Anchor.center,
          size: gameRef.config.cardStatsIconSize,
          overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      if (logoSprite != null) {
        logoSprite!.render(
          canvas,
          size: gameRef.config.cardIconSize,
          position: Vector2(
            (size.y / 2) - (gameRef.config.cardIconSize.y / 2),
            -size.x + gameRef.config.cardStatsIconSize.x,
          ),
        );
      }

      canvas.restore();
    } else if (side == SideView.right) {
      canvas
        ..save()
        ..rotate(-pi / 2);

      if (cold > 0) {
        final coldSpriteNumber = _findSpriteNumber(
          cold.toString(),
          1344,
          Vector2(32, 32),
        );
        final topLeftPosition = Vector2(
          -size.y + gameRef.config.cardStatsIconWidth / 2,
          gameRef.config.cardStatsIconHeight / 2,
        );
        coldSpriteNumber.render(
          canvas,
          position: topLeftPosition,
          anchor: Anchor.center,
          size: gameRef.config.cardStatsIconSize,
          overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      if (heat > 0) {
        final heatSpriteNumber = _findSpriteNumber(
          heat.toString(),
          1056,
          Vector2(32, 32),
        );
        final topLeftPosition = Vector2(
          -(gameRef.config.cardStatsIconWidth / 2),
          gameRef.config.cardStatsIconHeight / 2,
        );
        heatSpriteNumber.render(
          canvas,
          position: topLeftPosition,
          anchor: Anchor.center,
          size: gameRef.config.cardStatsIconSize,
          overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      if (logoSprite != null) {
        logoSprite!.render(
          canvas,
          size: gameRef.config.cardIconSize,
          position: Vector2(
            (-size.y / 2) - (gameRef.config.cardIconSize.y / 2),
            gameRef.config.cardStatsIconSize.x,
          ),
        );
      }

      canvas.restore();
    } else if (side == SideView.bottom) {
      if (cold > 0) {
        final coldSpriteNumber = _findSpriteNumber(
          cold.toString(),
          1344,
          Vector2(32, 32),
        );
        final topLeftPosition = Vector2(
          gameRef.config.cardStatsIconWidth / 2,
          gameRef.config.cardStatsIconHeight / 2,
        );
        coldSpriteNumber.render(
          canvas,
          position: topLeftPosition,
          anchor: Anchor.center,
          size: gameRef.config.cardStatsIconSize,
          overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      if (heat > 0) {
        final heatSpriteNumber = _findSpriteNumber(
          heat.toString(),
          1056,
          Vector2(32, 32),
        );
        final topLeftPosition = Vector2(
          size.x - (gameRef.config.cardStatsIconWidth / 2),
          gameRef.config.cardStatsIconHeight / 2,
        );
        heatSpriteNumber.render(
          canvas,
          position: topLeftPosition,
          anchor: Anchor.center,
          size: gameRef.config.cardStatsIconSize,
          overridePaint: Paint()..color = Colors.white.withOpacity(opacity),
        );
      }

      if (logoSprite != null) {
        logoSprite!.render(
          canvas,
          size: gameRef.config.cardIconSize,
          position: Vector2(
            gameRef.config.cardIconSize.x / 2,
            gameRef.config.cardStatsIconSize.y,
          ),
        );
      }
    }
  }

  // #endregion
}
