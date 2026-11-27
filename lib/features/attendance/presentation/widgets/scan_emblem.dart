import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class ScanEmblem extends StatelessWidget {
  const ScanEmblem({super.key, this.punched = false, this.excused = false});

  final bool punched;
  final bool excused;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
    ),
    child: Icon(
      excused
          ? Icons.shield_outlined
          : punched
              ? Icons.check_rounded
              : Icons.face_retouching_natural_rounded,
      size: 24,
      color: excused
          ? AppColors.excused
          : punched
              ? AppColors.onTime
              : Colors.white,
    ),
  );
}
