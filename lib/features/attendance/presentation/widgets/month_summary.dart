import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/punchdin_mark.dart';
import '../../../../core/theme.dart';
import '../../domain/attendance.dart';
import '../../domain/attendance_policy.dart';

class MonthSummary extends StatelessWidget {
  const MonthSummary({super.key, required this.items});

  final List<Attendance> items;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final summary = AttendancePolicy.computeWeeklyStreak(items);
    final milestoneReached = summary.punchedCount >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Streak',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: dark ? AppColors.warmPaper : AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder(dark)),
            boxShadow: AppColors.softShadow(dark),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Cobalt Brand Panel
                Expanded(
                  flex: 100,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
                      border: Border(
                        right: BorderSide(color: AppColors.cardBorder(dark)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Punchd'in",
                              style: GoogleFonts.fraunces(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'My Week\nStreak',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.25,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brandBlueTint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${summary.punchedCount}/5 days',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.saffron,
                              ),
                            ),
                            const PunchdinMark(size: 26),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Warm Cardstock Punch Holes
                Expanded(
                  flex: 135,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: dark ? AppColors.darkSurface : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (var i = 0; i < 3; i++)
                              _PunchCircle(day: summary.days[i], dark: dark),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _PunchCircle(day: summary.days[3], dark: dark),
                            _PunchCircle(day: summary.days[4], dark: dark),
                            Transform.rotate(
                              angle: -0.14,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: milestoneReached
                                      ? AppColors.saffron
                                      : AppColors.brandBlueTint,
                                  border: Border.all(
                                    color: milestoneReached
                                        ? const Color(0xFFD1A317)
                                        : AppColors.softBorder,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      milestoneReached ? 'STREAK' : 'GOAL',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w800,
                                        color: milestoneReached
                                            ? AppColors.ink
                                            : AppColors.mutedInk,
                                      ),
                                    ),
                                    Text(
                                      milestoneReached
                                          ? '${summary.punchedCount}D!'
                                          : '3+ D',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: milestoneReached
                                            ? AppColors.ink
                                            : AppColors.mutedInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PunchCircle extends StatelessWidget {
  const _PunchCircle({required this.day, required this.dark});

  final WeekdayPunch day;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    if (day.excused) {
      fill = AppColors.excused;
      border = const Color(0xFF7E94C4);
    } else if (day.punched) {
      final isLate = day.status == AttendanceStatus.late;
      fill = isLate ? AppColors.saffron : AppColors.onTime;
      border = isLate ? const Color(0xFFD1A317) : const Color(0xFF239B8F);
    } else if (day.isToday) {
      fill = dark ? const Color(0xFF2A334D) : AppColors.brandBlueTint.withValues(alpha: 0.6);
      border = dark ? AppColors.excused : AppColors.brandBlue;
    } else {
      fill = dark ? AppColors.darkCanvas : AppColors.warmPaper;
      border = AppColors.cardBorder(dark);
    }

    return Column(
      children: [
        Text(
          day.label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: dark ? AppColors.warmPaper : AppColors.ink,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(color: border),
          ),
          child: day.excused
              ? const Icon(Icons.shield_outlined, size: 14, color: AppColors.ink)
              : day.punched
                  ? const Icon(Icons.check_rounded, size: 15, color: AppColors.ink)
                  : day.isToday
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.brandBlue,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
        ),
      ],
    );
  }
}
