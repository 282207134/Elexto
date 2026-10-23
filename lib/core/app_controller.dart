import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../data/preference_store.dart';
import '../data/catalog.dart';

/// Local application state. Passwords and verification codes are never stored.
class AppController extends ChangeNotifier {
  AppController({this.enableAudio = true, PreferenceStore? store})
    : _prefs = store ?? PreferenceStore();
  final bool enableAudio;
  final PreferenceStore _prefs;
  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool dark = true, onboarded = false, signedIn = false;
  bool playing = false, shuffle = false, repeat = false, following = false;
  String username = 'James Smith', email = 'Hello@deeper.one';
  String? audioError;
  Track current = tracks[1];
  Duration position = Duration.zero, duration = const Duration(seconds: 24);
  Set<String> favorites = {}, downloads = {};
  Map<String, List<String>> playlists = {
    'Love Album': ['1', '2'],
    'Amazing List': ['3', '4'],
  };
  List<double> equalizer = [0.62, 0.42, 0.52, 0.72, 0.54];
  Future<void> load() async {
    dark = await _prefs.getBool('dark') ?? true;
    onboarded = await _prefs.getBool('onboarded') ?? false;
    signedIn = await _prefs.getBool('signedIn') ?? false;
    username = await _prefs.getString('username') ?? username;
    email = await _prefs.getString('email') ?? email;
    following = await _prefs.getBool('following') ?? false;
    favorites = (await _prefs.getStringList('favorites') ?? []).toSet();
    downloads = (await _prefs.getStringList('downloads') ?? []).toSet();
    final saved = await _prefs.getString('playlists');
    if (saved != null) {
      try {
        playlists = (jsonDecode(saved) as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        );
      } on FormatException {
        /* Fall back to the bundled library. */
      }
    }
    final eq = await _prefs.getStringList('equalizer');
    if (eq?.length == 5) {
      equalizer = eq!
          .map((s) => (double.tryParse(s) ?? .5).clamp(0.0, 1.0))
          .toList();
    }
  }

  Future<void> setTheme(bool value) async {
    dark = value;
    notifyListeners();
    await _prefs.setBool('dark', value);
  }

  Future<void> login({String? name, String? account}) async {
    if (name != null && name.isNotEmpty) username = name;
    if (account != null) email = account;
    signedIn = true;
    onboarded = true;
    notifyListeners();
    await Future.wait([
      _prefs.setBool('signedIn', true),
      _prefs.setBool('onboarded', true),
      _prefs.setString('username', username),
      _prefs.setString('email', email),
    ]);
  }

  Future<void> logout() async {
    await _player?.pause();
    playing = false;
    signedIn = false;
    notifyListeners();
    await _prefs.setBool('signedIn', false);
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    notifyListeners();
    await _prefs.setBool('onboarded', true);
  }

  Future<void> favorite(Track track) async {
    favorites.contains(track.id)
        ? favorites.remove(track.id)
        : favorites.add(track.id);
    notifyListeners();
    await _prefs.setStringList('favorites', favorites.toList());
  }

  Future<void> download(Track track) async {
    downloads.add(track.id);
    notifyListeners();
    await _prefs.setStringList('downloads', downloads.toList());
  }

  Future<void> follow() async {
    following = !following;
    notifyListeners();
    await _prefs.setBool('following', following);
  }

  Future<void> saveLibrary() async {
    notifyListeners();
    await _prefs.setString('playlists', jsonEncode(playlists));
  }

  Future<void> addToPlaylist(String name, Track track) async {
    final list = playlists.putIfAbsent(name, () => []);
    if (!list.contains(track.id)) list.add(track.id);
    await saveLibrary();
  }

  Future<void> saveEqualizer() async {
    await _prefs.setStringList(
      'equalizer',
      equalizer.map((v) => v.toString()).toList(),
    );
  }

  AudioPlayer get _audio {
    if (_player == null) {
      _player = AudioPlayer();
      _player!.positionUpdater = TimerPositionUpdater(
        interval: const Duration(milliseconds: 250),
        getPosition: _player!.getCurrentPosition,
      );
      _subscriptions.add(
        _player!.onPositionChanged.listen((p) {
          position = p;
          notifyListeners();
        }),
      );
      _subscriptions.add(
        _player!.onDurationChanged.listen((d) {
          duration = d;
          notifyListeners();
        }),
      );
      _subscriptions.add(
        _player!.onPlayerStateChanged.listen((s) {
          playing = s == PlayerState.playing;
          notifyListeners();
        }),
      );
      _subscriptions.add(
        _player!.onPlayerComplete.listen((_) {
          if (repeat) {
            play(current);
          } else {
            next();
          }
        }),
      );
    }
    return _player!;
  }

  Future<void> play(Track track) async {
    current = track;
    position = Duration.zero;
    audioError = null;
    if (!enableAudio) {
      playing = true;
      notifyListeners();
      return;
    }
    try {
      await _audio.play(AssetSource('audio/${track.audio}.wav'));
    } catch (_) {
      audioError = 'Preview could not play. Please try again.';
      playing = false;
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    if (!enableAudio) {
      playing = !playing;
      notifyListeners();
      return;
    }
    try {
      if (playing) {
        await _audio.pause();
      } else if (position > Duration.zero) {
        await _audio.resume();
      } else {
        await play(current);
      }
    } catch (_) {
      audioError = 'Preview could not play. Please try again.';
      playing = false;
      notifyListeners();
    }
  }

  Future<void> seek(double fraction) async {
    position = Duration(
      milliseconds: (duration.inMilliseconds * fraction).round(),
    );
    if (enableAudio) await _audio.seek(position);
    notifyListeners();
  }

  Future<void> next([int step = 1]) async {
    final i = tracks.indexOf(current);
    await play(
      tracks[shuffle
          ? Random().nextInt(tracks.length)
          : (i + step) % tracks.length],
    );
  }

  void toggleShuffle() {
    shuffle = !shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    repeat = !repeat;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
