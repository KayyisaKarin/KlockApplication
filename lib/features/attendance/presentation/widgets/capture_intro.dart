import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class CaptureIntro extends StatelessWidget {
  const CaptureIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      'Attendance timestamp is stamped by the server upon submission (07:00 WIB cutoff).',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        height: 1.45,
        color: dark ? AppColors.excused : AppColors.mutedInk,
      ),
    );
  }
}
