import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:punchdin_app/app.dart';
import 'package:punchdin_app/core/brand_header.dart';
import 'package:punchdin_app/core/orbit_clock.dart';
import 'package:punchdin_app/core/punchdin_mark.dart';
import 'package:punchdin_app/core/theme.dart';
import 'package:punchdin_app/core/theme_picker.dart';
import 'package:punchdin_app/core/theme_provider.dart';
import 'package:punchdin_app/features/attendance/domain/attendance.dart';
import 'package:punchdin_app/features/attendance/domain/attendance_policy.dart';
import 'package:punchdin_app/features/attendance/presentation/providers.dart';
import 'package:punchdin_app/features/attendance/presentation/widgets/check_in_card.dart';
import 'package:punchdin_app/features/attendance/presentation/widgets/history_tile.dart';
import 'package:punchdin_app/features/attendance/presentation/widgets/month_summary.dart';
import 'package:punchdin_app/features/auth/auth_providers.dart';

class _FakeThemePreference extends ThemePreference {
  _FakeThemePreference(this._initial);

  final ThemeMode _initial;

  @override
  Future<ThemeMode> build() async => _initial;

  @override
  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
  }
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('en');
  });

  testWidgets('PunchdinApp renders login-only screen with no registration or demo shortcuts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemePreference(ThemeMode.light)),
          sessionProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const PunchdinApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Punchd'in"), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Ask your school admin for access.'), findsOneWidget);

    // No sign-up / registration or demo user shortcuts
    expect(find.text('Sign up'), findsNothing);
    expect(find.text('Register'), findsNothing);
    expect(find.textContaining('demo', findRichText: true), findsNothing);
  });

  testWidgets('BrandHeader and ThemePicker display Light/Dark label and toggle theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith(() => _FakeThemePreference(ThemeMode.light)),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final mode = ref.watch(themeProvider).asData?.value ?? ThemeMode.light;
            return MaterialApp(
              theme: buildTheme(Brightness.light),
              darkTheme: buildTheme(Brightness.dark),
              themeMode: mode,
              home: const Scaffold(
                body: Column(
                  children: [
                    BrandHeader(),
                    ThemePicker(inHeader: false),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PunchdinMark), findsOneWidget);
    expect(find.text("Punchd'in"), findsOneWidget);
    expect(find.text('Light'), findsNWidgets(2));

    await tester.tap(find.byType(ThemePicker).first);
    await tester.pumpAndSettle();

    expect(find.text('Dark'), findsNWidgets(2));
  });

  testWidgets('CheckInCard, MonthSummary, OrbitClock, and HistoryTile render Punchd\'in widgets', (
    tester,
  ) async {
    final now = DateTime.now();
    final sampleRecords = [
      Attendance(
        id: 'rec-1',
        createdAt: now,
        status: AttendanceStatus.excused,
        note: 'Sick — Doctor note',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          attendanceProvider.overrideWith((ref) => Stream.value(sampleRecords)),
        ],
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  OrbitClock(size: 62, date: now),
                  const CheckInCard(),
                  MonthSummary(items: sampleRecords),
                  HistoryTile(record: sampleRecords.first),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Punch in now!'), findsOneWidget);
    expect(find.text('Clock in now!'), findsOneWidget);
    expect(find.text('Excused'), findsWidgets);
    expect(find.text('Your Streak'), findsOneWidget);
    expect(find.text('Excused logged for today'), findsOneWidget);
  });
}
