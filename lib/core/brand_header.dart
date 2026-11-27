import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'punchdin_mark.dart';
import 'theme.dart';
import 'theme_picker.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 10,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const PunchdinMark(size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Punchd'in",
                style: GoogleFonts.fraunces(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const ThemePicker(inHeader: true),
        ],
      ),
    );
  }
}
