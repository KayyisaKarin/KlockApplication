import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../auth/auth_providers.dart';
import 'profile_photo.dart';

class ProfileIdentity extends ConsumerWidget {
  const ProfileIdentity({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'PP';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final name = ref.watch(studentNameProvider);
    final email = ref.watch(studentEmailProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder(dark)),
        boxShadow: AppColors.softShadow(dark),
      ),
      child: Column(
        children: [
          ProfilePhoto(initials: _initials(name)),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: AppColors.brandBlueTint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
