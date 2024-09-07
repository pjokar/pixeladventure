import 'package:flame/components.dart';

class Obstacle extends PositionComponent {
  bool isPlatform;
  Obstacle({super.position, super.size, this.isPlatform = false});
}
