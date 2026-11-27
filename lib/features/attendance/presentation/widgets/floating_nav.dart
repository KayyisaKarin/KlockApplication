import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class FloatingNav extends StatelessWidget {
  const FloatingNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const icons = [Icons.home_outlined, Icons.history_rounded, Icons.person_outline_rounded];
    const labels = ['Home', 'History', 'Profile'];

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        6,
        12,
        MediaQuery.paddingOf(context).bottom + 10,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandBlueDark : AppColors.brandBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Semantics(
                  selected: index == i,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: index == i ? AppColors.saffron : Colors.transparent,
                        border: index == i
                            ? Border.all(color: Colors.black.withValues(alpha: 0.1))
                            : null,
                        boxShadow: index == i
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icons[i],
                            size: 18,
                            color: index == i ? AppColors.ink : Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: index == i ? AppColors.ink : Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
