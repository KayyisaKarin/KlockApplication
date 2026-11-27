import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'theme_provider.dart';

class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key, this.inHeader = false});

  final bool inHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final bgColor = inHeader
        ? Colors.white.withValues(alpha: 0.15)
        : (dark ? AppColors.darkSurface : AppColors.cardSurface);
    final borderColor = inHeader
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.cardBorder(dark);
    final fgColor = inHeader
        ? Colors.white
        : (dark ? AppColors.warmPaper : AppColors.ink);

    return Tooltip(
      message: dark ? 'Switch to light mode' : 'Switch to dark mode',
      child: Semantics(
        button: true,
        label: dark ? 'Dark mode, tap to switch to light mode' : 'Light mode, tap to switch to dark mode',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              try {
                await ref.read(themeProvider.notifier).toggle(platformBrightness);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not save theme preference. Please try again.')),
                  );
                }
              }
            },
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: inHeader
                        ? Colors.black.withValues(alpha: 0.12)
                        : AppColors.brandBlue.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    dark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                    size: 15,
                    color: dark ? AppColors.saffron : fgColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
