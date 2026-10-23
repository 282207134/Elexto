import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int index = 0;
  final pager = PageController();
  @override
  void dispose() {
    pager.dispose();
    super.dispose();
  }

  void next() {
    if (index < 3) {
      pager.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      AppScope.of(context).finishOnboarding();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => PageView.builder(
          controller: pager,
          itemCount: 4,
          onPageChanged: (v) => setState(() => index = v),
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: LayoutBuilder(
              builder: (context, size) {
                final first = i == 0;
                final panelHeight = first ? 330.0 : size.maxHeight * .63;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.cream,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    if (first)
                      Positioned(
                        top: 4,
                        left: 0,
                        right: 80,
                        height: 280,
                        child: const Art(
                          'onboarding-shape',
                          radius: 0,
                          fit: BoxFit.fill,
                        ),
                      ),
                    Positioned(
                      top: first ? -15 : -20,
                      left: 0,
                      right: -10,
                      height: first
                          ? size.maxHeight * .7
                          : size.maxHeight * .46,
                      child: Art(
                        'onboarding-${i + 1}',
                        fit: BoxFit.contain,
                        radius: 0,
                      ),
                    ),
                    if (i == 3) ...[
                      Positioned(
                        top: -15,
                        right: 24,
                        width: 127,
                        height: 101,
                        child: const Art(
                          'onboarding-note-1',
                          radius: 0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 55,
                        left: 125,
                        width: 23,
                        height: 38,
                        child: const Art(
                          'onboarding-note-2',
                          radius: 0,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 140,
                        left: 160,
                        width: 23,
                        height: 38,
                        child: const Art(
                          'onboarding-note-3',
                          radius: 0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: panelHeight,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          first ? 46 : 70,
                          20,
                          24,
                        ),
                        decoration: BoxDecoration(
                          color: context.panel,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: LayoutBuilder(
                          builder: (context, panel) => SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: panel.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: first
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'DEEPER UI KIT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Palette.coral,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      'Welcome to\nElexto App',
                                      textAlign: first
                                          ? TextAlign.left
                                          : TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        height: 1.2,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -.8,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Make life better with music and endless inspiration',
                                      textAlign: first
                                          ? TextAlign.left
                                          : TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: context.muted,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (!first)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          4,
                                          (n) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: n == i
                                                  ? Palette.coral
                                                  : context.isDark
                                                  ? Colors.white
                                                  : Palette.ink,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (!first) const Spacer(),
                                    Row(
                                      children: [
                                        if (!first) ...[
                                          SizedBox(
                                            width: 70,
                                            height: 66,
                                            child: FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Palette.ink,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  pager.previousPage(
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    curve: Curves.easeOut,
                                                  ),
                                              child: const Icon(
                                                Icons.arrow_back,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                        SizedBox(
                                          width: first
                                              ? size.maxWidth - 40
                                              : 148,
                                          child: PrimaryButton(
                                            'NEXT',
                                            onPressed: next,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({super.key, this.loading = false});
  final bool loading;
  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (widget.loading) {
      timer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/success');
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Art(
                  widget.loading ? 'loading' : 'unicorn',
                  width: widget.loading ? 310 : 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (widget.loading) ...[
              const CircularProgressIndicator(color: Palette.coral),
              const SizedBox(height: 28),
              Text('Loading…', style: TextStyle(color: context.muted)),
              const SizedBox(height: 65),
            ] else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'So Awesome!!!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "You are faster than a unicorn. Let's start the journey of emotions",
                      style: TextStyle(color: context.muted, height: 1.6),
                    ),
                    const SizedBox(height: 64),
                    PrimaryButton(
                      'LET START',
                      onPressed: () {
                        AppScope.of(context).login();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (_) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
