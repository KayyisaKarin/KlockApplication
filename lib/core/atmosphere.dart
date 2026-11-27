import 'package:flutter/material.dart';
import 'theme.dart';

class Atmosphere extends StatelessWidget {
  const Atmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      color: dark ? AppColors.darkCanvas : AppColors.warmPaper,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _PaperGrain(dark))),
          ),
          child,
        ],
      ),
    );
  }
}

class _PaperGrain extends CustomPainter {
  _PaperGrain(this.dark);

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (dark ? Colors.white : AppColors.ink).withValues(alpha: 0.045);
    for (double x = 10; x < size.width; x += 20) {
      for (double y = 10; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 0.75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PaperGrain old) => dark != old.dark;
}
