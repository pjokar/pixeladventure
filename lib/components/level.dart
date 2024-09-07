import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/obstacle.dart';
import 'package:pixel_adventure/components/player.dart';

class Level extends World {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<Obstacle> obstacles = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _addSpawnPoints();
    _addObstacles();
    return super.onLoad();
  }

  void _addSpawnPoints() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = spawnPoint.position;
            add(player);
            break;
        }
      }
    }
  }

  void _addObstacles() {
    final obstacleLayer = level.tileMap.getLayer<ObjectGroup>('Obstacles');
    if (obstacleLayer != null) {
      for (final obstacleLayerItem in obstacleLayer.objects) {
        switch (obstacleLayerItem.class_) {
          case 'Platform':
            final platform = Obstacle(
              isPlatform: true,
              position: obstacleLayerItem.position,
              size: obstacleLayerItem.size,
            );
            obstacles.add(platform);
            add(platform);
            break;
          default:
            final block = Obstacle(
              position: obstacleLayerItem.position,
              size: obstacleLayerItem.size,
            );
            obstacles.add(block);
            add(block);
        }
      }
    }
    player.obstacles = obstacles;
  }
}
