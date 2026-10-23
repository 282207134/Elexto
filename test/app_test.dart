import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elexto/app.dart';
import 'package:elexto/core/app_controller.dart';
import 'package:elexto/data/catalog.dart';
import 'package:elexto/data/preference_store.dart';

void main() {
  test('library, theme and profile survive controller recreation', () async {
    final store = PreferenceStore.memory();
    final state = AppController(enableAudio: false, store: store);
    await state.login(name: 'Test Listener', account: 'test@example.com');
    await state.setTheme(false);
    await state.favorite(tracks[2]);
    await state.download(tracks[1]);
    await state.addToPlaylist('Road Trip', tracks[3]);
    await state.follow();
    final restored = AppController(enableAudio: false, store: store);
    await restored.load();
    expect(restored.signedIn, true);
    expect(restored.dark, false);
    expect(restored.username, 'Test Listener');
    expect(restored.favorites, {'3'});
    expect(restored.downloads, {'2'});
    expect(restored.playlists['Road Trip'], ['4']);
    expect(restored.following, true);
    await state.logout();
    expect(state.signedIn, false);
    state.dispose();
    restored.dispose();
  });
  test(
    'playlist membership stays unique and previous wraps the queue',
    () async {
      final state = AppController(
        enableAudio: false,
        store: PreferenceStore.memory(),
      );
      await state.addToPlaylist('Mix', tracks.first);
      await state.addToPlaylist('Mix', tracks.first);
      expect(state.playlists['Mix'], ['1']);
      await state.play(tracks.first);
      await state.next(-1);
      expect(state.current, tracks.last);
      state.dispose();
    },
  );
  testWidgets('login validates fields before entering the app', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppController(
      enableAudio: false,
      store: PreferenceStore.memory(),
    );
    await tester.pumpWidget(
      ElextoApp(controller: state, initialRoute: '/login'),
    );
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 6 characters'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('Your password')),
      'demo123',
    );
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();
    expect(state.signedIn, true);
    expect(find.text('New Albums'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  for (final dark in [true, false]) {
    testWidgets(
      'all primary routes render in ${dark ? 'dark' : 'light'} without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final state = AppController(
          enableAudio: false,
          store: PreferenceStore.memory(),
        )..dark = dark;
        for (final route in [
          '/welcome',
          '/login',
          '/signup',
          '/phone',
          '/forgot',
          '/verify',
          '/password',
          '/success',
          '/home',
          '/explore',
          '/search',
          '/player',
          '/artist',
          '/video',
          '/genres',
          '/folder',
          '/profile',
          '/settings',
          '/equalizer',
          '/library',
        ]) {
          await tester.pumpWidget(
            ElextoApp(
              key: ValueKey('$route-$dark'),
              controller: state,
              initialRoute: route,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(
            tester.takeException(),
            isNull,
            reason: 'Layout failed on $route, dark=$dark',
          );
        }
        await tester.pumpWidget(const SizedBox());
        state.dispose();
      },
    );
  }
  testWidgets('search filters the real local catalog and has an empty state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppController(
      enableAudio: false,
      store: PreferenceStore.memory(),
    );
    await tester.pumpWidget(
      ElextoApp(controller: state, initialRoute: '/search'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'Someone',
    );
    await tester.pumpAndSettle();
    expect(find.text('Someone You Live'), findsOneWidget);
    expect(find.text('Girl Like You'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'zzzzzz',
    );
    await tester.pumpAndSettle();
    expect(find.text('No results for “zzzzzz”'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets('compact phone routes remain usable', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppController(
      enableAudio: false,
      store: PreferenceStore.memory(),
    );
    for (final route in [
      '/welcome',
      '/home',
      '/search',
      '/player',
      '/equalizer',
      '/settings',
    ]) {
      await tester.pumpWidget(
        ElextoApp(
          key: ValueKey('compact-$route'),
          controller: state,
          initialRoute: route,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets(
    'equalizer edits survive playback notifications and persist on save',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = PreferenceStore.memory();
      final state = AppController(enableAudio: false, store: store);
      final nav = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ElextoApp(controller: state, navigatorKey: nav, initialRoute: '/home'),
      );
      nav.currentState!.pushNamed('/equalizer');
      await tester.pumpAndSettle();
      final slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(0, -45));
      await tester.pumpAndSettle();
      final edited = tester.widget<Slider>(slider).value;
      state.toggleShuffle();
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(slider).value, edited);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      final restored = AppController(enableAudio: false, store: store);
      await restored.load();
      expect(restored.equalizer.first, edited);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
      restored.dispose();
    },
  );
}
