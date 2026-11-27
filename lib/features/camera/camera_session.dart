import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'front_lens.dart';
import 'photo_codec.dart';

class CameraSession extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  String? error;
  bool busy = false;
  bool _opening = false;
  bool _closed = false;
  bool _active = true;

  CameraSession() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> open() async {
    if (_opening || _closed || !_active) return;
    if (controller != null) {
      error = null;
      notifyListeners();
      return;
    }
    _opening = true;
    error = null;
    notifyListeners();
    CameraController? next;
    try {
      final cameras = await availableCameras();
      if (_closed || !_active) return;
      next = CameraController(
        FrontLens.select(cameras),
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await next.initialize();
      if (_closed || !_active) {
        await next.dispose();
        return;
      }
      controller = next;
    } on CameraException catch (e) {
      await next?.dispose();
      error = e.code.contains('Access')
          ? "Camera permission denied. Allow Camera access in Settings for Punchd'in, then retry."
          : 'Could not open front camera. Please try again.';
    } catch (e) {
      await next?.dispose();
      error = e is StateError ? e.message.toString() : 'Camera error. Please try again.';
    } finally {
      _opening = false;
      if (!_closed) {
        notifyListeners();
        if (_active && controller == null && error == null) open();
      }
    }
  }

  Future<Uint8List?> take() async {
    final camera = controller;
    if (busy || camera == null || !camera.value.isInitialized) return null;
    busy = true;
    notifyListeners();
    try {
      final file = await camera.takePicture();
      return await PhotoCodec.compress(await file.readAsBytes());
    } catch (_) {
      error = 'Could not save photo. Please try again.';
      return null;
    } finally {
      busy = false;
      if (!_closed) notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active) {
      final old = controller;
      controller = null;
      old?.dispose();
    } else if (!_opening) {
      open();
    }
    if (!_closed) notifyListeners();
  }

  @override
  void dispose() {
    _closed = true;
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}
