import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_controller.dart';
import 'core/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/music/home_screen.dart';
import 'features/music/player_screen.dart';
import 'features/music/detail_screens.dart';
import 'features/library/library_screens.dart';

class ElextoApp extends StatelessWidget {
  const ElextoApp({
    super.key,
    required this.controller,
    this.initialRoute,
    this.navigatorKey,
  });
  final AppController controller;
  final String? initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        title: 'Elexto',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: Palette.theme(false),
        darkTheme: Palette.theme(true),
        themeMode: controller.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: context.isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: child!,
        ),
        initialRoute:
            initialRoute ??
            (controller.signedIn
                ? '/home'
                : controller.onboarded
                ? '/login'
                : '/welcome'),
        onGenerateRoute: (settings) {
          final page = switch (settings.name) {
            '/welcome' => const WelcomeScreen(),
            '/login' => const AuthScreen(mode: AuthMode.login),
            '/signup' => const AuthScreen(mode: AuthMode.signup),
            '/phone' => const AuthScreen(mode: AuthMode.phone),
            '/forgot' => const AuthScreen(mode: AuthMode.forgot),
            '/verify' => const AuthScreen(mode: AuthMode.verify),
            '/password' => const AuthScreen(mode: AuthMode.password),
            '/loading' => const CompletionScreen(loading: true),
            '/success' => const CompletionScreen(),
            '/home' => const HomeScreen(),
            '/explore' => const HomeScreen(initialTab: 1),
            '/search' => const HomeScreen(initialTab: 2),
            '/player' => const PlayerScreen(),
            '/artist' => const ArtistScreen(),
            '/video' => const VideoScreen(),
            '/genres' => const GenresScreen(),
            '/folder' => FolderScreen(
              name: settings.arguments as String? ?? 'Baroque',
            ),
            '/profile' => const ProfileScreen(),
            '/settings' => const ProfileScreen(settings: true),
            '/equalizer' => const EqualizerScreen(),
            '/library' => LibraryScreen(
              kind: settings.arguments as String? ?? 'My playlist',
            ),
            _ => const HomeScreen(),
          };
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => page,
          );
        },
      ),
    ),
  );
}
