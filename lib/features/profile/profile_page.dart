import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/enter_motion.dart';
import '../../core/theme.dart';
import 'widgets/logout_button.dart';
import 'widgets/profile_identity.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return EnterMotion(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'Profile',
            style: GoogleFonts.fraunces(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: dark ? AppColors.warmPaper : AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          const ProfileIdentity(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navyClock,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.softBorder.withValues(alpha: 0.6),
              ),
              boxShadow: AppColors.softShadow(dark),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandBlueTint.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 20,
                    color: AppColors.saffron,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your photos stay private.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Used only for your profile and attendance proof. Need account help or want to remove data? Contact your school admin.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: AppColors.brandBlueTint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const LogoutButton(),
        ],
      ),
    );
  }
}
