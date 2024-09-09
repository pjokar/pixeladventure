import 'package:flutter/foundation.dart';
import 'package:pixel_adventure/components/obstacle.dart';

import 'components/player.dart';

class Utils {
  static String capitalizeFirstLetter(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }

  static String convertToTitleCase(String input) {
    final RegExp exp = RegExp(r'([a-z])([A-Z])');
    String result =
        input.replaceAllMapped(exp, (Match m) => '${m.group(1)} ${m.group(2)}');
    return result[0].toUpperCase() + result.substring(1);
  }

  static bool isWebPlatform() {
    return kIsWeb;
  }

  static bool checkIsCollision(Player player, Obstacle obstacle) {
    final playerX = player.position.x;
    final playerY = player.position.y;
    final playerWidth = player.width;
    final playerHeight = player.height;

    final obstacleX = obstacle.position.x;
    final obstacleY = obstacle.position.y;
    final obstacleWidth = obstacle.width;
    final obstacleHeight = obstacle.height;

    // depending on player's direction the coordinates of x and y flip!
    final fixedPlayerX = player.scale.x < 0 ? playerX - playerWidth : playerX;
    final fixedPlayerY = obstacle.isPlatform ? playerY + playerHeight : playerY;

    return (fixedPlayerY < obstacleY + obstacleHeight &&
        fixedPlayerY + playerHeight > obstacleY &&
        fixedPlayerX < obstacleX + obstacleWidth &&
        fixedPlayerX + playerWidth > obstacleX);
  }
}
