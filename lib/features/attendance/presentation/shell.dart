import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/brand_header.dart';
import '../../profile/profile_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'providers.dart';
import 'widgets/floating_nav.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    return Scaffold(
      body: Column(
        children: [
          const BrandHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: IndexedStack(
                  index: index,
                  children: const [HomePage(), HistoryPage(), ProfilePage()],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNav(
        index: index,
        onChanged: (value) {
          if (value == 1) {
            ref.read(historyFilterProvider.notifier).setFilter(null);
          }
          ref.read(navIndexProvider.notifier).setIndex(value);
        },
      ),
    );
  }
}
