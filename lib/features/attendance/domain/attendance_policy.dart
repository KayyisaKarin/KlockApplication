import 'attendance.dart';

enum AttendanceStatus { onTime, late, absent, excused }

class WeekdayPunch {
  const WeekdayPunch({
    required this.label,
    required this.dayIndex,
    required this.punched,
    required this.excused,
    required this.status,
    required this.isToday,
  });

  final String label;
  final int dayIndex; // 1 = Mon ... 5 = Fri
  final bool punched;
  final bool excused;
  final AttendanceStatus? status;
  final bool isToday;
}

class WeeklyStreakSummary {
  const WeeklyStreakSummary({required this.days, required this.punchedCount});

  final List<WeekdayPunch> days;
  final int punchedCount;
}

abstract final class AttendancePolicy {
  static const Duration _wibOffset = Duration(hours: 7);

  static DateTime wib(DateTime instant) => instant.toUtc().add(_wibOffset);

  static int wibDayNumber(DateTime instant) =>
      (instant.toUtc().millisecondsSinceEpoch + _wibOffset.inMilliseconds) ~/
      Duration.millisecondsPerDay;

  static bool isSameWibDay(DateTime a, DateTime b) =>
      wibDayNumber(a) == wibDayNumber(b);

  static AttendanceStatus status(DateTime instant) {
    final date = wib(instant);
    final deadline = DateTime.utc(date.year, date.month, date.day, 7);
    return date.isAfter(deadline) ? AttendanceStatus.late : AttendanceStatus.onTime;
  }

  static AttendanceStatus resolveStatus(Attendance record) {
    if (record.status != null) return record.status!;
    if (record.createdAt == null) return AttendanceStatus.onTime;
    return status(record.createdAt!);
  }

  static String labelFor(AttendanceStatus? s) => switch (s) {
    AttendanceStatus.onTime => 'On Time',
    AttendanceStatus.late => 'Late',
    AttendanceStatus.absent => 'Absent',
    AttendanceStatus.excused => 'Excused',
    null => 'Saving…',
  };

  static String label(DateTime? instant, [AttendanceStatus? explicitStatus]) {
    if (explicitStatus != null) return labelFor(explicitStatus);
    if (instant == null) return 'Saving…';
    return labelFor(status(instant));
  }

  static WeeklyStreakSummary computeWeeklyStreak(
    List<Attendance> records, [
    DateTime? now,
  ]) {
    final activeNow = now ?? DateTime.now();
    final wibNow = wib(activeNow);
    final daysSinceMonday = wibNow.weekday - DateTime.monday;
    final mondayDayNum = wibDayNumber(activeNow) - daysSinceMonday;
    final todayDayNum = wibDayNumber(activeNow);

    const labels = ['M', 'T', 'W', 'T', 'F'];
    final days = List<WeekdayPunch>.generate(5, (idx) {
      final targetDayNum = mondayDayNum + idx;
      Attendance? match;
      for (final rec in records) {
        if (rec.createdAt == null) continue;
        final recStatus = resolveStatus(rec);
        if (recStatus == AttendanceStatus.absent) continue;
        if (wibDayNumber(rec.createdAt!) == targetDayNum) {
          match = rec;
          break;
        }
      }
      final resolved = match != null ? resolveStatus(match) : null;
      final excused = resolved == AttendanceStatus.excused;
      final punched = match != null && !excused;
      return WeekdayPunch(
        label: labels[idx],
        dayIndex: idx + 1,
        punched: punched,
        excused: excused,
        status: resolved,
        isToday: targetDayNum == todayDayNum,
      );
    });

    final punchedCount = days.where((d) => d.punched || d.excused).length;
    return WeeklyStreakSummary(days: days, punchedCount: punchedCount);
  }
}
