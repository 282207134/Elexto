import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui.dart';

enum AuthMode { login, signup, phone, forgot, verify, password }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.mode});
  final AuthMode mode;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(text: 'Hello@deeper.one'),
      name = TextEditingController(text: 'James Smith'),
      password = TextEditingController(),
      oldPassword = TextEditingController(),
      phone = TextEditingController();
  final invite = TextEditingController();
  final digits = List.generate(4, (_) => TextEditingController());
  final focus = List.generate(4, (_) => FocusNode());
  bool show = false, busy = false;
  String? error;
  int seconds = 30;
  Timer? timer;
  AuthMode get mode => widget.mode;
  @override
  void initState() {
    super.initState();
    if (mode == AuthMode.verify) {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (seconds > 0) {
          setState(() => seconds--);
        } else {
          t.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final c in [
      email,
      name,
      password,
      oldPassword,
      phone,
      invite,
      ...digits,
    ]) {
      c.dispose();
    }
    for (final f in focus) {
      f.dispose();
    }
    super.dispose();
  }

  String? requiredText(String? s) =>
      s == null || s.trim().isEmpty ? 'Please fill in this field' : null;
  String? validateEmail(String? s) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s ?? '')
      ? null
      : 'Enter a valid email address';
  String? validatePassword(String? s) =>
      (s?.length ?? 0) >= 6 ? null : 'Use at least 6 characters';
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final state = AppScope.of(context);
    if (mode == AuthMode.signup &&
        email.text.toLowerCase() == 'hello@deeper.one') {
      setState(() => error = 'Email account is already in use');
      return;
    }
    if (mode == AuthMode.verify) {
      if (seconds == 0) {
        setState(() => error = 'Code expired. Tap Resend code.');
        return;
      }
      if (digits.map((c) => c.text).join() != '2828') {
        setState(() => error = 'Use demo verification code 2828');
        return;
      }
    }
    setState(() => busy = true);
    if (mode == AuthMode.login) {
      await state.login(account: email.text);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } else if (mode == AuthMode.signup) {
      await state.login(name: name.text, account: email.text);
      if (mounted) go(context, '/phone');
    } else if (mode == AuthMode.phone || mode == AuthMode.forgot) {
      if (mounted) go(context, '/verify');
    } else if (mode == AuthMode.verify) {
      if (mounted) Navigator.pushReplacementNamed(context, '/loading');
    } else {
      if (mounted) {
        toast(context, 'Demo password updated for this session');
        Navigator.pop(context);
      }
    }
    if (mounted) setState(() => busy = false);
  }

  Widget field(
    String hint,
    TextEditingController controller, {
    bool secret = false,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    Widget? suffix,
  }) => TextFormField(
    key: ValueKey(hint),
    controller: controller,
    obscureText: secret && !show,
    keyboardType: keyboard,
    textInputAction: TextInputAction.next,
    validator: validator ?? requiredText,
    style: const TextStyle(fontSize: 13, color: Palette.ink),
    cursorColor: Palette.coral,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB3AFC5), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 23),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Palette.pink, width: 2),
      ),
      suffixIcon:
          suffix ??
          (secret
              ? TextButton(
                  onPressed: () => setState(() => show = !show),
                  child: Text(
                    show ? 'Hide' : 'Show',
                    style: const TextStyle(fontSize: 11, color: Palette.purple),
                  ),
                )
              : null),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final compact = mode != AuthMode.login && mode != AuthMode.signup;
    final title = switch (mode) {
      AuthMode.login => 'Let’s Gooooo!',
      AuthMode.signup => 'Create Account',
      AuthMode.phone => 'You did very well!\nOne last step',
      AuthMode.forgot => 'Forgot password?',
      AuthMode.verify => 'Verify account',
      AuthMode.password => 'Change Password?',
    };
    final subtitle = switch (mode) {
      AuthMode.login => 'One small step to reach the huge music store',
      AuthMode.signup =>
        'Create one now to keep up with the world music trends',
      AuthMode.phone =>
        'Enter your phone number to activate\n2-step verification.',
      AuthMode.forgot =>
        "Don’t worry, start the password reset process by filling in the field below",
      AuthMode.verify =>
        'Please enter the 4 numbers we sent to your phone to verify your account',
      AuthMode.password => '',
    };
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: compact ? 440 : (box.maxHeight - 32).clamp(600, 900),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (compact)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: BackControl(),
                          )
                        else
                          const SizedBox(height: 22),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: -.6,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: context.muted,
                            ),
                          ),
                        ],
                        SizedBox(height: compact ? 32 : 46),
                        if (mode == AuthMode.signup) ...[
                          field('Your name', name),
                          const SizedBox(height: 10),
                        ],
                        if (mode == AuthMode.login ||
                            mode == AuthMode.signup ||
                            mode == AuthMode.forgot) ...[
                          field(
                            'Email address',
                            email,
                            keyboard: TextInputType.emailAddress,
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (mode == AuthMode.password) ...[
                          field('Old Password', oldPassword, secret: true),
                          const SizedBox(height: 16),
                        ],
                        if (mode == AuthMode.login ||
                            mode == AuthMode.signup ||
                            mode == AuthMode.password) ...[
                          field(
                            mode == AuthMode.password
                                ? 'New Password'
                                : 'Your password',
                            password,
                            secret: true,
                            validator: validatePassword,
                            suffix: mode == AuthMode.login
                                ? TextButton(
                                    onPressed: () => go(context, '/forgot'),
                                    child: const Text(
                                      'Forgot',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Palette.purple,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          if (mode == AuthMode.signup) ...[
                            const SizedBox(height: 16),
                            field(
                              'Invite code (optional)',
                              invite,
                              validator: (_) => null,
                            ),
                          ],
                        ],
                        if (mode == AuthMode.phone)
                          field(
                            'Phone number',
                            phone,
                            keyboard: TextInputType.phone,
                            validator: (s) =>
                                RegExp(r'^\+?[\d\s-]{7,16}$').hasMatch(s ?? '')
                                ? null
                                : 'Enter a valid phone number',
                            suffix: const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                '+1',
                                style: TextStyle(color: Palette.ink),
                              ),
                            ),
                          ),
                        if (mode == AuthMode.verify) ...[
                          Row(
                            children: List.generate(
                              4,
                              (i) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i == 3 ? 0 : 12,
                                  ),
                                  child: TextFormField(
                                    key: ValueKey('digit-$i'),
                                    controller: digits[i],
                                    focusNode: focus[i],
                                    maxLength: 1,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: Palette.ink,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (s) =>
                                        RegExp(r'^\d$').hasMatch(s ?? '')
                                        ? null
                                        : '•',
                                    onChanged: (v) {
                                      if (v.isNotEmpty && i < 3) {
                                        focus[i + 1].requestFocus();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Demo code: 2828 · Expires in ${seconds}s',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.muted,
                              ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: seconds == 0
                                  ? () {
                                      setState(() {
                                        seconds = 30;
                                        error = null;
                                      });
                                      timer = Timer.periodic(
                                        const Duration(seconds: 1),
                                        (t) {
                                          if (seconds > 0) {
                                            setState(() => seconds--);
                                          } else {
                                            t.cancel();
                                          }
                                        },
                                      );
                                    }
                                  : null,
                              child: const Text('Resend code'),
                            ),
                          ),
                        ],
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            error!,
                            style: const TextStyle(
                              color: Palette.coral,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (!compact)
                          const Spacer()
                        else
                          const SizedBox(height: 32),
                        if (mode == AuthMode.login)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Demo · any valid email and 6+ character password',
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        PrimaryButton(
                          busy
                              ? 'PLEASE WAIT…'
                              : switch (mode) {
                                  AuthMode.login => 'LOGIN',
                                  AuthMode.signup => 'CREATE ACCOUNT',
                                  AuthMode.phone ||
                                  AuthMode.forgot => 'START VERIFY',
                                  AuthMode.verify => 'VERIFY',
                                  AuthMode.password => 'SAVE',
                                },
                          onPressed: busy ? null : submit,
                        ),
                        if (!compact) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => go(
                                context,
                                mode == AuthMode.login ? '/signup' : '/login',
                              ),
                              child: Text(
                                mode == AuthMode.login
                                    ? 'Create new account'
                                    : 'Already have an account?',
                                style: TextStyle(
                                  color: context.isDark
                                      ? Colors.white
                                      : Palette.ink,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
