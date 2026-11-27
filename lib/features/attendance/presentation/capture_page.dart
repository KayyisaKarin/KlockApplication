import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../data/camera_service.dart';
import 'providers.dart';
import 'widgets/capture_intro.dart';
import 'widgets/photo_preview.dart';

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage> {
  Uint8List? photo;
  bool busy = false;
  String? error;

  Future<void> capture() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final bytes = await CameraService.capture(context);
      if (bytes == null) return;
      if (mounted) setState(() => photo = bytes);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Camera failed or photo exceeded 100 KB. Check permissions and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref.read(repositoryProvider).submit(photo!);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Punched in! Your streak has been updated.')),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Failed to submit. Make sure you have not punched in today.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
          foregroundColor: Colors.white,
          title: const Text(
            'Go back',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              PhotoPreview(photo: photo),
              const SizedBox(height: 12),
              const CaptureIntro(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: busy ? null : capture,
                style: OutlinedButton.styleFrom(
                  backgroundColor: dark ? AppColors.darkSurface : Colors.white,
                  foregroundColor: dark ? AppColors.brandBlueTint : AppColors.brandBlue,
                  side: BorderSide(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.brandBlue.withValues(alpha: 0.65),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(
                  photo == null ? 'Take a photo' : 'Retake photo',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: busy || photo == null ? null : submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: AppColors.ink,
                ),
                child: Text(
                  busy ? 'Submitting…' : 'Submit',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.absent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.absent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.absent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
