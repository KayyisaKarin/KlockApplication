import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = AsyncNotifierProvider<ThemePreference, ThemeMode>(ThemePreference.new);

class ThemePreference extends AsyncNotifier<ThemeMode> {
  late final storage = SharedPreferencesAsync();

  @override
  Future<ThemeMode> build() async {
    final value = await storage.getString('theme');
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    await storage.setString('theme', mode.name);
    state = AsyncData(mode);
  }

  Future<void> toggle(Brightness platformBrightness) async {
    final current = state.asData?.value ?? ThemeMode.light;
    final currentlyDark = current == ThemeMode.dark ||
        (current == ThemeMode.system && platformBrightness == Brightness.dark);
    await setMode(currentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
