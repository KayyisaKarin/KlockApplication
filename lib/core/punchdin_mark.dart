import 'package:flutter/material.dart';

class PunchdinMark extends StatelessWidget {
  const PunchdinMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Image.asset(
      'assets/brand/punchdin_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    ),
  );
}
