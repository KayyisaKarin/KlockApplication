import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../features/attendance/domain/attendance_policy.dart';
import 'theme.dart';

class OrbitClock extends StatelessWidget {
  const OrbitClock({super.key, this.size = 64, this.date});

  final double size;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final wib = AttendancePolicy.wib(date ?? DateTime.now());
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ClockArt(wib)),
    );
  }
}

class _ClockArt extends CustomPainter {
  _ClockArt(this.wib);

  final DateTime wib;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.36;

    // Outer orbital ring
    canvas.drawCircle(
      c,
      r * 1.24,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.brandBlueTint.withValues(alpha: 0.28),
    );

    // Dial body
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF1D2951));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.brandBlueTint.withValues(alpha: 0.65),
    );

    // 12 hour markers
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final point = c + Offset(math.sin(angle), -math.cos(angle)) * r * 0.78;
      canvas.drawCircle(
        point,
        i % 3 == 0 ? 1.7 : 0.95,
        Paint()..color = AppColors.brandBlueTint.withValues(alpha: 0.7),
      );
    }

    final seconds = wib.second;
    final minutes = wib.minute;
    final hours = wib.hour % 12;

    final secondAngle = (seconds / 60) * math.pi * 2;
    final minuteAngle = ((minutes + seconds / 60) / 60) * math.pi * 2;
    final hourAngle = ((hours + minutes / 60 + seconds / 3600) / 12) * math.pi * 2;

    Offset pointAt(double angle, double length) =>
        c + Offset(math.sin(angle) * length, -math.cos(angle) * length);

    // Hour hand
    canvas.drawLine(
      c,
      pointAt(hourAngle, r * 0.46),
      Paint()
        ..color = AppColors.warmPaper
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );

    // Minute hand
    canvas.drawLine(
      c,
      pointAt(minuteAngle, r * 0.68),
      Paint()
        ..color = AppColors.saffron
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // Second hand with counterweight tail
    canvas.drawLine(
      pointAt(secondAngle + math.pi, r * 0.18),
      pointAt(secondAngle, r * 0.78),
      Paint()
        ..color = AppColors.coral
        ..strokeWidth = 1.25
        ..strokeCap = StrokeCap.round,
    );

    // Center pivot cap
    canvas.drawCircle(c, 2.5, Paint()..color = AppColors.saffron);
    canvas.drawCircle(c, 1.1, Paint()..color = AppColors.coral);

    // Teal check stamp badge
    final badge = c + Offset(r * 0.76, r * 0.76);
    canvas.drawCircle(badge, r * 0.32, Paint()..color = AppColors.onTime);
    canvas.drawCircle(
      badge,
      r * 0.32,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.ink.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      Path()
        ..moveTo(badge.dx - 4, badge.dy)
        ..lineTo(badge.dx - 1, badge.dy + 3.5)
        ..lineTo(badge.dx + 5, badge.dy - 3.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockArt old) =>
      old.wib.second != wib.second ||
      old.wib.minute != wib.minute ||
      old.wib.hour != wib.hour;
}
