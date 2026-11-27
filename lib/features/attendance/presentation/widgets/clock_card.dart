import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/clock_provider.dart';
import '../../../../core/orbit_clock.dart';
import '../../../../core/theme.dart';
import '../../domain/attendance_policy.dart';

class ClockCard extends ConsumerWidget {
  const ClockCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rawNow = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final now = AttendancePolicy.wib(rawNow);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder(dark)),
        boxShadow: AppColors.softShadow(dark),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.navyClock,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 15, color: AppColors.saffron),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEE, d MMM', 'en').format(now),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandBlueTint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(now),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 38,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.5,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat(':ss').format(now),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.excused,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                OrbitClock(size: 62, date: rawNow),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Check-in 07:00 WIB',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.excused,
                  ),
                ),
                Text(
                  'WIB',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.saffron,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
