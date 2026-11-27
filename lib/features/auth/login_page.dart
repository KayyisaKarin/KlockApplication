import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enter_motion.dart';
import '../../core/theme.dart';
import '../../core/theme_picker.dart';
import 'auth_repository.dart';
import 'login_fields.dart';
import 'login_header.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(email.text.trim(), password.text);
    } on FirebaseAuthException {
      if (mounted) setState(() => error = 'Login failed. Check your credentials and try again.');
    } catch (_) {
      if (mounted) setState(() => error = 'Unable to sign in right now. Please try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: EnterMotion(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: ThemePicker(inHeader: false),
                    ),
                    const SizedBox(height: 18),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Tilted Cobalt Cardstock Backing Folder
                        Positioned.fill(
                          child: Transform.rotate(
                            angle: -0.052,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.brandBlue,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: dark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : AppColors.brandBlueHover.withValues(alpha: 0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandBlue.withValues(alpha: 0.22),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Main Physical Punch-Card Ticket
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF232738) : AppColors.ticketCream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE5D7A3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandBlue.withValues(alpha: 0.14),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const LoginHeader(),
                              const SizedBox(height: 20),
                              LoginFields(email: email, password: password),
                              if (error != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.absent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.absent),
                                  ),
                                  child: Text(
                                    error!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.absent,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: busy ? null : login,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.brandBlue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  busy ? 'Connecting…' : 'Log in',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Don't have an account?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: dark ? const Color(0xFFCBD5E1) : AppColors.mutedInk,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ask your school admin for access.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: (dark ? const Color(0xFFCBD5E1) : AppColors.mutedInk)
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Decorative punch-hole notches
                        Positioned(
                          top: 48,
                          right: -7,
                          child: _PunchNotch(dark: dark),
                        ),
                        Positioned(
                          bottom: 56,
                          left: -7,
                          child: _PunchNotch(dark: dark),
                        ),

                        // Yellow Starburst Badge
                        Positioned(
                          top: -20,
                          left: -14,
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: CustomPaint(painter: _StarburstPainter()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Punchd'in helps you track daily streaks with photo capture.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: dark ? AppColors.excused : AppColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PunchNotch extends StatelessWidget {
  const _PunchNotch({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      color: AppColors.brandBlue,
      shape: BoxShape.circle,
      border: Border.all(
        color: dark
            ? Colors.white.withValues(alpha: 0.15)
            : AppColors.brandBlueHover.withValues(alpha: 0.4),
      ),
    ),
  );
}

class _StarburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width * 0.48;
    final inner = size.width * 0.24;
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + (i * math.pi / points);
      final pt = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();

    canvas.drawShadow(path, AppColors.brandBlue.withValues(alpha: 0.25), 4, false);
    canvas.drawPath(path, Paint()..color = AppColors.saffron);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFD9A81E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
