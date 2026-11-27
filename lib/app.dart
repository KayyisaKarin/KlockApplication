import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/atmosphere.dart';
import 'core/punchdin_mark.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'features/attendance/presentation/shell.dart';
import 'features/auth/auth_providers.dart';
import 'features/auth/login_page.dart';

class PunchdinApp extends ConsumerWidget {
  const PunchdinApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: "Punchd'in",
    builder: (_, child) => Atmosphere(child: child!),
    debugShowCheckedModeBanner: false,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    themeMode: ref.watch(themeProvider).asData?.value ?? ThemeMode.light,
    home: startupError != null
        ? const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Firebase is not connected yet. Check google-services.json or firebase_options.dart.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        : ref
              .watch(sessionProvider)
              .when(
                loading: () => const _LaunchSplash(),
                error: (_, _) => const Scaffold(
                  body: Center(child: Text('Failed to read session. Please restart the app.')),
                ),
                data: (signedIn) => signedIn ? const AppShell() : const LoginPage(),
              ),
  );
}

class _LaunchSplash extends StatelessWidget {
  const _LaunchSplash();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PunchdinMark(size: 88),
            const SizedBox(height: 16),
            Text(
              "Punchd'in",
              style: GoogleFonts.fraunces(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: dark ? AppColors.warmPaper : AppColors.ink,
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.brandBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
