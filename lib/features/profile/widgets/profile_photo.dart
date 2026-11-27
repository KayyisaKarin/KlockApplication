import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../attendance/data/camera_service.dart';
import '../profile_repository.dart';

class ProfilePhoto extends ConsumerStatefulWidget {
  const ProfilePhoto({super.key, this.initials = 'PP'});

  final String initials;

  @override
  ConsumerState<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends ConsumerState<ProfilePhoto> {
  bool busy = false;

  Future<void> change() async {
    setState(() => busy = true);
    try {
      final photo = await CameraService.capture(context);
      if (photo == null || !mounted) return;
      final save = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Use this photo?',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w700),
          ),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(photo, fit: BoxFit.cover),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.saffron,
                foregroundColor: AppColors.ink,
                minimumSize: const Size(88, 42),
              ),
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (save != true || !mounted) return;
      final repo = ref.read(profileRepositoryProvider);
      if (repo == null) throw StateError('Please log in first.');
      await repo.save(photo);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo failed to save. Check your connection and try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider);
    final bytes = avatar.asData?.value;

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover)
              : Center(
                  child: Text(
                    widget.initials,
                    style: GoogleFonts.fraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: busy || avatar.isLoading ? null : change,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 15, color: AppColors.ink),
                  const SizedBox(width: 6),
                  Text(
                    busy ? 'Saving…' : 'Change photo',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (avatar.hasError)
          TextButton(
            onPressed: () => ref.invalidate(avatarProvider),
            child: const Text(
              'Failed to load photo · Retry',
              style: TextStyle(fontSize: 12, color: AppColors.saffron),
            ),
          ),
      ],
    );
  }
}
