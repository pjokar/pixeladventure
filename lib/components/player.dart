import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils.dart';

enum PlayerState { idle, run, jump, hit, fall }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  final double stepTime = 0.05;

  String characterName;

  Player({super.position, required this.characterName});

  @override
  FutureOr<void> onLoad() {
    _loadAnimations();
    return super.onLoad();
  }

  void _loadAnimations() {
    idleAnimation = _getSpriteAnimation(PlayerState.idle, 11);
    runAnimation = _getSpriteAnimation(PlayerState.run, 12);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _getSpriteAnimation(
      PlayerState playerState, int sequencesAmount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Main Characters/$characterName/${Utils.capitalizeFirstLetter(playerState.name)} (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: sequencesAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
