import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../camera/front_camera_page.dart';

abstract final class CameraService {
  static Future<Uint8List?> capture(BuildContext context) async {
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use front camera?'),
        content: const Text(
          "Punchd'in needs camera access to snap your check-in selfie. Photos are only sent "
          'when you tap Submit—no gallery or microphone access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (consent != true || !context.mounted) return null;
    return Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const FrontCameraPage()),
    );
  }
}
