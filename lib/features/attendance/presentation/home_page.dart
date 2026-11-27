import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enter_motion.dart';
import '../../../core/surface_card.dart';
import '../../../core/theme.dart';
import '../../auth/auth_providers.dart';
import 'providers.dart';
import 'widgets/check_in_card.dart';
import 'widgets/clock_card.dart';
import 'widgets/month_summary.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final firstName = ref.watch(studentNameProvider).split(' ').first;
    final attendance = ref.watch(attendanceProvider);

    return EnterMotion(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'Hello, ${firstName.isEmpty ? 'Student' : firstName}',
            style: GoogleFonts.fraunces(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: dark ? AppColors.warmPaper : AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          const ClockCard(),
          const SizedBox(height: 16),
          const CheckInCard(),
          const SizedBox(height: 16),
          attendance.when(
            data: (items) => MonthSummary(items: items),
            loading: () => SurfaceCard(
              child: Text(
                'Loading punch-card streak…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark ? AppColors.excused : AppColors.mutedInk,
                ),
              ),
            ),
            error: (_, _) => MonthSummary(items: const []),
          ),
        ],
      ),
    );
  }
}
