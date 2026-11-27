import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../domain/attendance.dart';
import '../../domain/attendance_policy.dart';
import '../providers.dart';

class HistoryTile extends ConsumerWidget {
  const HistoryTile({super.key, required this.record});

  final Attendance record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final date = record.createdAt == null ? null : AttendancePolicy.wib(record.createdAt!);
    final status = record.resolvedStatus;

    final (bg, fg) = switch (status) {
      AttendanceStatus.onTime => (AppColors.onTime, AppColors.ink),
      AttendanceStatus.late => (AppColors.late, AppColors.ink),
      AttendanceStatus.absent => (AppColors.absent, Colors.white),
      AttendanceStatus.excused => (AppColors.excused, AppColors.ink),
    };

    final subtitle = switch (status) {
      AttendanceStatus.absent || AttendanceStatus.excused =>
        (record.note != null && record.note!.isNotEmpty) ? record.note! : record.statusLabel,
      _ => date == null ? 'Saving…' : '${DateFormat('HH:mm:ss').format(date)} WIB',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => PhotoDialog(record: record),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: AppColors.softShadow(dark),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(Icons.star_rounded, size: 15, color: AppColors.ink),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date == null
                            ? 'Pending'
                            : DateFormat('EEE, d MMM', 'en').format(date),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: fg.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    record.statusLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoDialog extends ConsumerWidget {
  const PhotoDialog({super.key, required this.record});

  final Attendance record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final status = record.resolvedStatus;
    final wib = record.createdAt == null ? null : AttendancePolicy.wib(record.createdAt!);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Attendance Proof',
            style: GoogleFonts.fraunces(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Text(
              record.statusLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wib != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${DateFormat('EEE, d MMM', 'en').format(wib)} · ${DateFormat('HH:mm:ss').format(wib)} WIB',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: dark ? AppColors.excused : AppColors.mutedInk,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCanvas : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder(dark)),
            ),
            clipBehavior: Clip.antiAlias,
            child: status == AttendanceStatus.absent || status == AttendanceStatus.excused
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      record.note ??
                          (status == AttendanceStatus.excused
                              ? 'Excused absence recorded.'
                              : 'No photo check-in recorded for this date.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: dark ? AppColors.excused : AppColors.mutedInk,
                      ),
                    ),
                  )
                : ref.watch(photoProvider(record.id)).when(
                      data: (bytes) => Image.memory(bytes, fit: BoxFit.contain),
                      loading: () => const SizedBox(
                        height: 160,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.brandBlue),
                        ),
                      ),
                      error: (_, _) => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Photo proof is not available.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(minimumSize: const Size(88, 42)),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
