import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? const Color(0xFFCBD5E1) : AppColors.mutedInk;

    return Column(
      children: [
        Text(
          'LOGIN',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: dark ? AppColors.excused : AppColors.mutedInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Punchd'in",
          textAlign: TextAlign.center,
          style: GoogleFonts.fraunces(
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: dark ? AppColors.warmPaper : AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Punch in your absence in a streak!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
      ],
    );
  }
}
