import 'package:flutter/material.dart';
import 'theme.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = 16,
    this.color,
    this.borderRadius = 16,
  });

  final Widget child;
  final double padding;
  final Color? color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color ?? (dark ? AppColors.darkSurface : AppColors.cardSurface),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.cardBorder(dark)),
        boxShadow: AppColors.softShadow(dark),
      ),
      child: child,
    );
  }
}
