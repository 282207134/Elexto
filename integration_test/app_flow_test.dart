import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:elexto/app.dart';
import 'package:elexto/core/app_controller.dart';
import 'package:elexto/data/catalog.dart';
import 'package:elexto/data/preference_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Pixso screens, library interactions and native audio preview', (
    tester,
  ) async {
    for (final dark in [true, false]) {
      final state = AppController(store: PreferenceStore.memory())..dark = dark;
      final nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ElextoApp(
          controller: state,
          navigatorKey: nav,
          initialRoute: '/welcome',
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        if (!name.startsWith('23-')) {
          ScaffoldMessenger.of(nav.currentContext!).clearSnackBars();
        }
        await tester.pump(const Duration(milliseconds: 300));
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Runtime error on $name',
        );
        final themedName = name.replaceAll(
          '-dark',
          state.dark ? '-dark' : '-light',
        );
        debugPrint('CAPTURE:$themedName');
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      }

      Future<void> page(String route, {Object? arguments}) async {
        FocusManager.instance.primaryFocus?.unfocus();
        nav.currentState!.pushNamedAndRemoveUntil(
          route,
          (_) => false,
          arguments: arguments,
        );
        await tester.pumpAndSettle();
      }

      for (int i = 1; i <= 4; i++) {
        await capture('${i.toString().padLeft(2, '0')}-welcome-dark');
        await tester.tap(find.text('NEXT').last);
        await tester.pumpAndSettle();
      }
      await capture('05-login-dark');
      await tester.enterText(
        find.byKey(const ValueKey('Your password')),
        'demo123',
      );
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();
      expect(state.signedIn, true);
      await page('/signup');
      await tester.enterText(
        find.byKey(const ValueKey('Your password')),
        'demo123',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();
      expect(find.text('Email account is already in use'), findsOneWidget);
      await capture('06-signup-dark');
      await page('/phone');
      await capture('07-phone-empty-dark');
      await tester.enterText(
        find.byKey(const ValueKey('Phone number')),
        '123 456 789',
      );
      await capture('08-phone-filled-dark');
      await page('/forgot');
      await capture('09-forgot-dark');
      await tester.tap(find.text('START VERIFY'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('digit-0')), '2');
      await tester.enterText(find.byKey(const ValueKey('digit-1')), '8');
      await capture('10-verification-dark');
      await tester.enterText(find.byKey(const ValueKey('digit-2')), '2');
      await tester.enterText(find.byKey(const ValueKey('digit-3')), '8');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.text('VERIFY'));
      await tester.pump(const Duration(milliseconds: 400));
      await capture('11-loading-dark');
      await tester.pumpAndSettle();
      await capture('12-success-dark');
      await tester.tap(find.text('LET START'));
      await tester.pumpAndSettle();
      await capture('13-home-dark');
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -230),
      );
      await tester.pumpAndSettle();
      await capture('14-home-scrolled-dark');
      await page('/search');
      await capture('15-search-dark');
      await tester.tap(find.byKey(const ValueKey('search-field')));
      await tester.pumpAndSettle();
      await capture('16-search-focused-dark');
      await tester.enterText(find.byKey(const ValueKey('search-field')), 'M');
      await tester.pumpAndSettle();
      await capture('17-search-all-dark');
      await tester.enterText(find.byKey(const ValueKey('search-field')), 'C');
      await tester.tap(find.text('Artist').last);
      await tester.pumpAndSettle();
      await capture('18-search-artist-dark');
      await tester.enterText(find.byKey(const ValueKey('search-field')), 'Pay');
      await tester.tap(find.text('Video').last);
      await tester.pumpAndSettle();
      await capture('19-search-video-dark');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Video actions').first);
      await tester.pumpAndSettle();
      await capture('20-video-actions-dark');
      await page('/home');
      await state.play(tracks[1]);
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();
      expect(state.playing, true);
      expect(state.position.inMilliseconds, greaterThan(0));
      expect(state.audioError, isNull);
      await state.toggle();
      await tester.pumpAndSettle();
      nav.currentState!.pushNamed('/player');
      await tester.pumpAndSettle();
      await capture('21-player-dark');
      await tester.tap(find.byTooltip('Show queue'));
      await tester.pumpAndSettle();
      await capture('22-player-queue-dark');
      await tester.tap(find.byTooltip('Show record'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add to playlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Love Album'));
      await tester.pumpAndSettle();
      expect(state.playlists['Love Album'], contains(state.current.id));
      await capture('23-added-to-playlist-dark');
      await tester.tap(find.byTooltip('Lyrics'));
      await tester.pumpAndSettle();
      await capture('24-lyrics-dark');
      await tester.tap(find.byTooltip('Show record'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add to playlist'));
      await tester.pumpAndSettle();
      await capture('25-playlists-dark');
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();
      await capture('26-share-dark');
      await tester.tap(find.text('Copy link'));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Favorite'));
      await tester.pumpAndSettle();
      expect(state.favorites, contains(state.current.id));
      await tester.tap(find.byTooltip('Save offline'));
      await tester.pumpAndSettle();
      expect(state.downloads, contains(state.current.id));
      await tester.tap(find.byTooltip('Next track'));
      await tester.pumpAndSettle();
      expect(state.current, tracks[2]);
      await state.toggle();
      await tester.pumpAndSettle();
      await page('/artist');
      await tester.tap(find.text('Follow +'));
      await tester.pumpAndSettle();
      expect(state.following, true);
      await capture('27-artist-dark');
      await page('/video');
      await capture('28-video-dark');
      await page('/explore');
      await capture('29-explore-dark');
      await page('/genres');
      await capture('30-genres-dark');
      await page('/folder', arguments: 'Baroque');
      await capture('31-folder-dark');
      await tester.tap(find.byTooltip('Folder settings'));
      await tester.pumpAndSettle();
      await capture('32-folder-settings-dark');
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(state.playlists.containsKey('Baroque copy'), true);
      await page('/profile');
      await capture('33-profile-dark');
      await page('/settings');
      await capture('34-settings-dark');
      await page('/password');
      await capture('35-password-dark');
      await page('/equalizer');
      await capture('36-equalizer-dark');
      await page('/library', arguments: 'My playlist');
      await capture('37-library-dark');
      await page('/library', arguments: 'My Download');
      expect(find.text('Someone You Live'), findsOneWidget);
      await capture('38-downloads-dark');
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    }
  });
}
