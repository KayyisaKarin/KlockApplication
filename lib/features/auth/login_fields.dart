import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({super.key, required this.email, required this.password});

  final TextEditingController email;
  final TextEditingController password;

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: dark ? AppColors.warmPaper : AppColors.ink,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email:', style: labelStyle),
        const SizedBox(height: 5),
        TextField(
          controller: widget.email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(hintText: 'student@school.edu'),
        ),
        const SizedBox(height: 12),
        Text('Password:', style: labelStyle),
        const SizedBox(height: 5),
        TextField(
          controller: widget.password,
          obscureText: hidden,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              tooltip: hidden ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => hidden = !hidden),
              icon: Icon(
                hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
