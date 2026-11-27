import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../domain/attendance.dart';
import '../../domain/attendance_policy.dart';
import '../capture_page.dart';
import '../providers.dart';
import 'scan_emblem.dart';

class CheckInCard extends ConsumerWidget {
  const CheckInCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final asyncRecords = ref.watch(attendanceProvider);
    final records = asyncRecords.asData?.value ?? const <Attendance>[];
    final loaded = asyncRecords.hasValue;
    final hasError = asyncRecords.hasError;

    final now = DateTime.now();
    Attendance? today;
    for (final rec in records) {
      if (rec.createdAt != null && AttendancePolicy.isSameWibDay(rec.createdAt!, now)) {
        today = rec;
        break;
      }
    }
    final todayStatus = today?.resolvedStatus;
    final todayExcused = todayStatus == AttendanceStatus.excused;

    var onTimeCount = 0;
    var lateCount = 0;
    var absentCount = 0;
    var excusedCount = 0;
    for (final rec in records) {
      switch (rec.resolvedStatus) {
        case AttendanceStatus.onTime:
          onTimeCount++;
        case AttendanceStatus.late:
          lateCount++;
        case AttendanceStatus.absent:
          absentCount++;
        case AttendanceStatus.excused:
          excusedCount++;
      }
    }

    final pills = <(AttendanceStatus, String, int, Color, Color)>[
      (AttendanceStatus.onTime, 'On Time', onTimeCount, AppColors.onTime, AppColors.ink),
      (AttendanceStatus.late, 'Late', lateCount, AppColors.late, AppColors.ink),
      (AttendanceStatus.absent, 'Absent', absentCount, AppColors.absent, Colors.white),
      (AttendanceStatus.excused, 'Excused', excusedCount, AppColors.excused, AppColors.ink),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Punch in now!',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: dark ? AppColors.warmPaper : AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left column: 4 status counter pills
              Expanded(
                flex: 95,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < pills.length; i++) ...[
                      _StatusCounterPill(
                        label: pills[i].$2,
                        count: pills[i].$3,
                        bg: pills[i].$4,
                        fg: pills[i].$5,
                        dark: dark,
                        onTap: () {
                          ref.read(historyFilterProvider.notifier).setFilter(pills[i].$1);
                          ref.read(navIndexProvider.notifier).setIndex(1);
                        },
                      ),
                      if (i < pills.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right column: Clock in now! Bento action card
              Expanded(
                flex: 115,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder(dark)),
                    boxShadow: AppColors.softShadow(dark),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Clock in now!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ScanEmblem(
                        punched: today != null,
                        excused: todayExcused,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todayExcused
                            ? 'Excused today · Streak safe!'
                            : today != null
                                ? "You've punched in today!"
                                : "You haven't punched in today!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.3,
                          color: AppColors.brandBlueTint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: today != null || !loaded
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const CapturePage(),
                                    ),
                                  ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.ink,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
                            disabledForegroundColor: AppColors.ink.withValues(alpha: 0.65),
                            minimumSize: const Size(double.infinity, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                            ),
                          ),
                          icon: Icon(
                            today != null ? Icons.check_rounded : Icons.camera_alt_outlined,
                            size: 14,
                          ),
                          label: Text(
                            todayExcused
                                ? 'Excused'
                                : today != null
                                    ? 'Punched in'
                                    : 'Take a photo',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (hasError)
                        GestureDetector(
                          onTap: () => ref.invalidate(attendanceProvider),
                          child: const Text(
                            'Retry sync',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.saffron,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Get your streak!',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brandBlueTint,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Request Excuse button
        Material(
          color: dark
              ? AppColors.darkSurface
              : AppColors.brandBlueTint.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: today != null || !loaded
                ? null
                : () => _showExcuseSheet(context, ref),
            child: Opacity(
              opacity: today != null || !loaded ? 0.55 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder(dark)),
                  boxShadow: AppColors.softShadow(dark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 15,
                      color: dark ? AppColors.excused : AppColors.brandBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      todayExcused
                          ? 'Excused logged for today'
                          : today != null
                              ? 'Already checked in today'
                              : 'Request Excuse',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: dark ? AppColors.warmPaper : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showExcuseSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ExcuseBottomSheet(),
    );
  }
}

class _StatusCounterPill extends StatelessWidget {
  const _StatusCounterPill({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color bg;
  final Color fg;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: bg,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
          ),
          boxShadow: AppColors.softShadow(dark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 26, minHeight: 24),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ExcuseBottomSheet extends ConsumerStatefulWidget {
  const _ExcuseBottomSheet();

  @override
  ConsumerState<_ExcuseBottomSheet> createState() => _ExcuseBottomSheetState();
}

class _ExcuseBottomSheetState extends ConsumerState<_ExcuseBottomSheet> {
  static const reasons = ['Sick', 'Family / Personal', 'School / Official Duty'];
  String selectedReason = reasons.first;
  final noteController = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(repositoryProvider)
          .submitExcuse(selectedReason, note: noteController.text);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excuse logged! Your weekly streak is preserved.')),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not submit excuse request. Ensure you have not checked in today.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.warmPaper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.cardBorder(dark))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: 0.2) : AppColors.softBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.excused.withValues(alpha: dark ? 0.2 : 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: dark ? AppColors.excused : AppColors.brandBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Excuse',
                      style: GoogleFonts.fraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Logs today as Excused and keeps your weekly streak safe.',
                      style: TextStyle(
                        fontSize: 11,
                        color: dark ? AppColors.excused : AppColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final item in reasons) ...[
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => selectedReason = item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: selectedReason == item
                      ? (dark
                          ? AppColors.brandBlue.withValues(alpha: 0.35)
                          : AppColors.brandBlueTint)
                      : (dark ? AppColors.darkCanvas : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedReason == item
                        ? (dark ? AppColors.excused : AppColors.brandBlue)
                        : AppColors.cardBorder(dark),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedReason == item
                            ? (dark ? Colors.white : AppColors.ink)
                            : (dark ? AppColors.excused : AppColors.mutedInk),
                      ),
                    ),
                    Icon(
                      selectedReason == item
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 16,
                      color: selectedReason == item
                          ? (dark ? AppColors.saffron : AppColors.brandBlue)
                          : (dark ? Colors.white30 : const Color(0xFFB8C4DC)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          const Text(
            'Short note (optional)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: noteController,
            maxLength: 120,
            decoration: const InputDecoration(
              counterText: '',
              hintText: "e.g., Doctor's note sent to homeroom teacher",
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.absent,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: busy ? null : submit,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: Text(
                    busy ? 'Submitting…' : 'Submit Excuse',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
