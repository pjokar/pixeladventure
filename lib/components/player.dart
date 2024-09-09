import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/obstacle.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/utils.dart';

enum PlayerState { idle, run, jump, doubleJump, wallJump, hit, fall }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation wallJumpAnimation;

  final double stepTime = 0.05;
  List<Obstacle> obstacles = [];

  double horizontalMovement = 0;
  Vector2 velocity = Vector2.zero();
  final double _moveSpeed = 100;
  final double _gravityForce = 50;
  final double _jumpingForce = 560;
  final double _terminalVelocity = 300;
  final double _maxJumps = 2; // Maximal 2 Sprünge (ein Doppelsprung)
  double _jumpCount = 0;
  bool _isJumping = false;
  bool _isOnGround = false;

  String characterName;

  Player({
    super.position,
    this.characterName = 'Ninja Frog',
  });

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollision(dt);
    _applyGravity(dt);
    _checkVerticalCollision(dt);
  }

  void _checkHorizontalCollision(dt) {
    for (final obstacle in obstacles) {
      if (!obstacle.isPlatform) {
        if (Utils.checkIsCollision(this, obstacle)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = obstacle.position.x - width;
            break;
          }

          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = obstacle.position.x + obstacle.width + width;
            break;
          }
        }
      }
    }
  }

  void _checkVerticalCollision(dt) {
    for (final obstacle in obstacles) {
      if (obstacle.isPlatform) {
        if (Utils.checkIsCollision(this, obstacle)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = obstacle.position.y - height;
            _isOnGround = true;
            _jumpCount = 0; // Zähler zurücksetzen, wenn auf dem Boden
            break;
          }
        }
      } else {
        if (Utils.checkIsCollision(this, obstacle)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = obstacle.position.y - height;
            _isOnGround = true;
            _jumpCount = 0; // Zähler zurücksetzen, wenn auf dem Boden
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = obstacle.position.y + obstacle.height;
            _isOnGround = false;
            break;
          }
        }
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    _isJumping = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    horizontalMovement = 0;
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAnimations() {
    idleAnimation = _getSpriteAnimation(PlayerState.idle, 11);
    runAnimation = _getSpriteAnimation(PlayerState.run, 12);
    jumpAnimation = _getSpriteAnimation(PlayerState.jump, 1);
    fallAnimation = _getSpriteAnimation(PlayerState.fall, 1);
    doubleJumpAnimation = _getSpriteAnimation(PlayerState.doubleJump, 6);
    wallJumpAnimation = _getSpriteAnimation(PlayerState.wallJump, 5);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.doubleJump: doubleJumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _getSpriteAnimation(
      PlayerState playerState, int sequencesAmount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Main Characters/$characterName/${Utils.convertToTitleCase(playerState.name)} (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: sequencesAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Check if running
    if (velocity.x != 0) {
      playerState = PlayerState.run;
    }

    // Check if falling
    if (velocity.y > 0) {
      playerState = PlayerState.fall;
    }

    // Check if jumping
    if (velocity.y < 0 && _jumpCount == 1) {
      playerState = PlayerState.jump;
    }

    // Check if double jumping
    if (velocity.y < 0 && _jumpCount == 2) {
      playerState = PlayerState.doubleJump;
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (_isJumping && (_isOnGround || _jumpCount < _maxJumps)) {
      _jump(dt);
    }

    velocity.x = horizontalMovement * _moveSpeed;
    position.x += velocity.x * dt;
  }

  void _jump(double dt) {
    if (_jumpCount < _maxJumps) {
      velocity.y = -_jumpingForce;
      position.y += velocity.y * dt;
      _jumpCount++;
      _isJumping = false;
      _isOnGround = false;
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravityForce; // Gravity
    velocity.y = velocity.y.clamp(-_jumpingForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
}
