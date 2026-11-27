import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'camera_session.dart';

class FrontCameraPage extends StatefulWidget {
  const FrontCameraPage({super.key});

  @override
  State<FrontCameraPage> createState() => _FrontCameraPageState();
}

class _FrontCameraPageState extends State<FrontCameraPage> {
  final session = CameraSession();

  @override
  void initState() {
    super.initState();
    session.open();
  }

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => PopScope(
        canPop: !session.busy,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
            foregroundColor: Colors.white,
            title: const Text(
              'Front camera',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Center your face in good lighting, then tap Capture.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dark ? AppColors.excused : AppColors.mutedInk,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: dark ? AppColors.darkSurface : const Color(0xFFDCDCE0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder(dark)),
                          boxShadow: AppColors.softShadow(dark),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: session.controller?.value.isInitialized == true
                            ? AspectRatio(
                                aspectRatio: MediaQuery.orientationOf(context) ==
                                        Orientation.portrait
                                    ? 1 / session.controller!.value.aspectRatio
                                    : session.controller!.value.aspectRatio,
                                child: CameraPreview(session.controller!),
                              )
                            : AspectRatio(
                                aspectRatio: 3 / 4,
                                child: Center(
                                  child: session.error != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            session.error!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        )
                                      : const CircularProgressIndicator(
                                          color: AppColors.brandBlue,
                                        ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (session.error != null)
                    OutlinedButton.icon(
                      onPressed: session.open,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry camera'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: session.busy || session.controller == null
                          ? null
                          : () async {
                              final Uint8List? bytes = await session.take();
                              if (context.mounted && bytes != null) {
                                Navigator.pop(context, bytes);
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: AppColors.ink,
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: Text(
                        session.busy ? 'Processing…' : 'Capture photo',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
