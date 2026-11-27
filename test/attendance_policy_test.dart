import 'package:flutter_test/flutter_test.dart';
import 'package:punchdin_app/features/attendance/domain/attendance.dart';
import 'package:punchdin_app/features/attendance/domain/attendance_policy.dart';

void main() {
  group('AttendancePolicy', () {
    test('marks timestamps at or before 07:00 WIB as onTime and after as late', () {
      // 07:00:00 WIB == 00:00:00 UTC
      final exactDeadline = DateTime.utc(2026, 11, 23, 0, 0, 0);
      final oneSecondLate = DateTime.utc(2026, 11, 23, 0, 0, 1);

      expect(AttendancePolicy.status(exactDeadline), AttendanceStatus.onTime);
      expect(AttendancePolicy.label(exactDeadline), 'On Time');
      expect(AttendancePolicy.status(oneSecondLate), AttendanceStatus.late);
      expect(AttendancePolicy.label(oneSecondLate), 'Late');
    });

    test('computes same WIB calendar day across UTC midnight boundary', () {
      // 2026-11-23 23:30 UTC == 2026-11-24 06:30 WIB
      final morningWib = DateTime.utc(2026, 11, 23, 23, 30);
      // 2026-11-24 14:00 UTC == 2026-11-24 21:00 WIB
      final nightWib = DateTime.utc(2026, 11, 24, 14, 0);

      expect(AttendancePolicy.isSameWibDay(morningWib, nightWib), isTrue);
    });

    test('weekly streak includes punched days and excused days while skipping absent', () {
      // Wednesday 2026-11-25 10:00 WIB (03:00 UTC)
      final now = DateTime.utc(2026, 11, 25, 3, 0);

      final records = [
        // Monday: On Time (06:45 WIB -> 2026-11-22 23:45 UTC)
        Attendance(
          id: 'mon',
          createdAt: DateTime.utc(2026, 11, 22, 23, 45),
        ),
        // Tuesday: Excused (shields streak)
        Attendance(
          id: 'tue',
          createdAt: DateTime.utc(2026, 11, 24, 1, 0),
          status: AttendanceStatus.excused,
          note: 'Sick',
        ),
        // Wednesday: Absent (does not count toward streak)
        Attendance(
          id: 'wed',
          createdAt: DateTime.utc(2026, 11, 25, 2, 0),
          status: AttendanceStatus.absent,
        ),
      ];

      final summary = AttendancePolicy.computeWeeklyStreak(records, now);

      expect(summary.days.length, 5);
      expect(summary.days[0].punched, isTrue);
      expect(summary.days[0].excused, isFalse);
      expect(summary.days[1].punched, isFalse);
      expect(summary.days[1].excused, isTrue);
      expect(summary.days[2].punched, isFalse);
      expect(summary.days[2].excused, isFalse);
      expect(summary.days[2].isToday, isTrue);
      expect(summary.punchedCount, 2);
    });
  });
}
