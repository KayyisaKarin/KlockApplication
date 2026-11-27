import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/enter_motion.dart';
import '../../../core/surface_card.dart';
import '../../../core/theme.dart';
import '../domain/attendance_policy.dart';
import 'providers.dart';
import 'widgets/history_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(historyFilterProvider);
    final attendance = ref.watch(attendanceProvider);

    final options = <(AttendanceStatus?, String)>[
      (null, 'All'),
      (AttendanceStatus.onTime, 'On Time'),
      (AttendanceStatus.late, 'Late'),
      (AttendanceStatus.absent, 'Absent'),
      (AttendanceStatus.excused, 'Excused'),
    ];

    return EnterMotion(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'History',
            style: GoogleFonts.fraunces(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: dark ? AppColors.warmPaper : AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (value, label) in options) ...[
                  _FilterChip(
                    label: label,
                    active: filter == value,
                    dark: dark,
                    onTap: () => ref.read(historyFilterProvider.notifier).setFilter(value),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...attendance.when(
            data: (items) {
              final filtered = filter == null
                  ? items
                  : items.where((rec) => rec.resolvedStatus == filter).toList();
              if (filtered.isEmpty) {
                return [
                  SurfaceCard(
                    padding: 28,
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 44,
                          color: dark ? AppColors.excused : AppColors.mutedInk,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No punch-card logs yet.',
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Head to Home and take a photo to punch in today.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: dark ? AppColors.excused : AppColors.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              }
              return filtered.map((item) => HistoryTile(record: item)).toList();
            },
            loading: () => const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brandBlue),
                ),
              ),
            ],
            error: (_, _) => [
              SurfaceCard(
                child: Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(attendanceProvider),
                    child: const Text('Failed to load history. Tap to retry.'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(999),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppColors.brandBlue
            : (dark ? AppColors.darkSurface : AppColors.cardSurface),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? AppColors.brandBlue : AppColors.cardBorder(dark),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : (dark ? AppColors.warmPaper : AppColors.ink),
        ),
      ),
    ),
  );
}
