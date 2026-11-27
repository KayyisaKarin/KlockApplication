import 'package:camera/camera.dart';

abstract final class FrontLens {
  static CameraDescription select(List<CameraDescription> cameras) {
    final front = cameras.where((camera) => camera.lensDirection == CameraLensDirection.front);
    if (front.isEmpty) throw StateError('No front camera detected on this device.');
    return front.first;
  }
}
