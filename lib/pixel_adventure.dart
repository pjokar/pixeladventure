import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components//level.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/utils.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  Player player = Player(characterName: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = !Utils.isWebPlatform();

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    final level = Level(player: player, levelName: "Level_01");

    camera = CameraComponent.withFixedResolution(
        world: level, width: 640, height: 360);

    camera.viewfinder.anchor = Anchor.topLeft;

    addAll([camera, level]);

    if (showJoystick) {
      addJoyStick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoyStick() {
    joystick = JoystickComponent(
      margin: const EdgeInsets.only(left: 32, bottom: 16),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }
}
