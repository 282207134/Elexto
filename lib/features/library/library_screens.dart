import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_controller.dart';
import '../../core/app_theme.dart';
import '../../data/catalog.dart';
import '../../widgets/ui.dart';
import '../music/home_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key, required this.name});
  final String name;
  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late String name = widget.name;
  Future<void> options() async {
    final state = AppScope.of(context);
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: context.isDark ? const Color(0xFF19191A) : Palette.cream,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Folder Setting', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Duplicate'),
                trailing: const Icon(Icons.copy_outlined, size: 18),
                onTap: () {
                  var copy = '$name copy';
                  while (state.playlists.containsKey(copy)) {
                    copy = '$copy 2';
                  }
                  state.playlists[copy] = List.of(
                    state.playlists[name] ??
                        tracks.take(6).map((t) => t.id).toList(),
                  );
                  state.saveLibrary();
                  Navigator.pop(ctx);
                  toast(context, 'Created $copy');
                },
              ),
              ListTile(
                title: const Text('Rename'),
                trailing: const Icon(Icons.edit_outlined, size: 18),
                onTap: () async {
                  Navigator.pop(ctx);
                  final value = await askName(
                    context,
                    'Rename folder',
                    initial: name,
                  );
                  if (value != null && mounted) {
                    if (value != name && state.playlists.containsKey(value)) {
                      toast(
                        context,
                        'A playlist with that name already exists',
                      );
                      return;
                    }
                    final songs =
                        state.playlists.remove(name) ??
                        tracks.take(6).map((t) => t.id).toList();
                    state.playlists[value] = songs;
                    await state.saveLibrary();
                    setState(() => name = value);
                  }
                },
              ),
              ListTile(
                tileColor: Palette.coral,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textColor: Colors.white,
                iconColor: Colors.white,
                title: const Text('Remove Folder'),
                trailing: const Icon(Icons.delete_outline, size: 18),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: Text('Remove $name?'),
                      content: const Text(
                        'This removes the local playlist. The bundled music stays available.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(d, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(d, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    state.playlists.remove(name);
                    await state.saveLibrary();
                    if (mounted) {
                      Navigator.pop(context);
                      toast(context, 'Folder removed');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final ids = s.playlists[name];
    final songs = ids == null
        ? tracks.take(6).toList()
        : tracks.where((t) => ids.contains(t.id)).toList();
    return Scaffold(
      body: Stack(
        children: [
          const Art('genre-2', width: double.infinity, height: 440, radius: 0),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0, .65],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BackControl(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.panel,
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Folder settings',
                                onPressed: options,
                                icon: const Icon(Icons.more_horiz),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Baroque music is a period or style of Western art music composed from approximately 1600 to 1750.',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.6,
                              color: context.muted,
                            ),
                          ),
                          const SizedBox(height: 28),
                          AlbumCard(
                            art: 'baroque',
                            title: 'Love You To Love Me',
                            artist: 'Maroon 5',
                            width: MediaQuery.sizeOf(context).width - 80,
                            height: 167,
                            onTap: () {
                              s.play(tracks[3]);
                              go(context, '/player');
                            },
                          ),
                          const SizedBox(height: 20),
                          if (songs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No songs yet. Add music from the player.',
                              ),
                            )
                          else
                            ...songs.asMap().entries.map(
                              (e) => SongTile(
                                e.value,
                                rank: e.key + 1,
                                menu: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> askName(
  BuildContext context,
  String title, {
  String initial = '',
}) async {
  final input = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: input,
        autofocus: true,
        maxLength: 40,
        decoration: const InputDecoration(labelText: 'Name'),
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (input.text.trim().isNotEmpty) {
              Navigator.pop(ctx, input.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  // Dialog route can still be animating after its result completes.
  Future<void>.delayed(const Duration(milliseconds: 400), input.dispose);
  return result;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.settings = false});
  final bool settings;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.isDark ? Colors.black : Colors.white,
        body: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: settings ? 12 : 0,
                sigmaY: settings ? 12 : 0,
              ),
              child: const Art(
                'profile',
                width: double.infinity,
                height: 520,
                radius: 0,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      context.isDark ? Colors.black : Colors.white,
                    ],
                    stops: const [0, .67],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackControl(),
                  ),
                  SizedBox(height: settings ? 172 : 160),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.username,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: settings && !context.isDark
                                ? Palette.ink
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '02 Jan 1992',
                          style: TextStyle(color: Palette.coral, fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: () => go(context, '/settings'),
                              style: FilledButton.styleFrom(
                                backgroundColor: settings
                                    ? Palette.coral
                                    : Colors.white24,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Setting'),
                            ),
                            const Spacer(),
                            if (settings)
                              TextButton(
                                onPressed: () async {
                                  await s.logout();
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (_) => false,
                                    );
                                  }
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Palette.coral),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (settings)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? Colors.black
                                  : Palette.cream,
                              border: Border.all(
                                color: Palette.coral.withValues(alpha: .18),
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'User Info',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 14),
                                ...{
                                  'Username': s.username,
                                  'Email': s.email,
                                  'Phone': '+ 123 456 789',
                                  'Password': '********',
                                }.entries.map(
                                  (e) => InkWell(
                                    onTap: () => e.key == 'Password'
                                        ? go(context, '/password')
                                        : showDialog<void>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(e.key),
                                              content: Text(e.value),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            e.key,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              e.value,
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Palette.coral,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Dark appearance',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: s.dark,
                                  onChanged: s.setTheme,
                                  activeThumbColor: Palette.coral,
                                ),
                                Center(
                                  child: TextButton(
                                    onPressed: () => go(context, '/equalizer'),
                                    child: const Text(
                                      'Sound Equalizer',
                                      style: TextStyle(color: Palette.coral),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Palette.cream,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Library',
                                  style: TextStyle(
                                    color: Palette.ink,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...[
                                  'My playlist',
                                  'Album',
                                  'Videos',
                                  'Following',
                                  'My Download',
                                ].asMap().entries.map(
                                  (e) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    leading: Icon(
                                      [
                                        Icons.music_note_outlined,
                                        Icons.album_outlined,
                                        Icons.play_arrow_outlined,
                                        Icons.person_outline,
                                        Icons.file_download_outlined,
                                      ][e.key],
                                      size: 19,
                                      color: Palette.coral,
                                    ),
                                    title: Text(
                                      e.value,
                                      style: const TextStyle(
                                        color: Palette.ink,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.more_horiz,
                                      size: 18,
                                      color: Palette.coral,
                                    ),
                                    onTap: () => go(
                                      context,
                                      '/library',
                                      arguments: e.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SideSection(
                    'Recent Music',
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        children: tracks
                            .take(4)
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (e) => SongTile(
                                e.value,
                                rank: e.key + 1,
                                menu: true,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.kind});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final songs = kind == 'My Download'
        ? tracks.where((t) => s.downloads.contains(t.id)).toList()
        : tracks.where((t) => s.favorites.contains(t.id)).toList();
    return Scaffold(
      appBar: AppBar(
        leading: const BackControl(),
        title: Text(kind, style: const TextStyle(fontSize: 22)),
        actions: [
          if (kind == 'My playlist')
            IconButton(
              tooltip: 'New playlist',
              onPressed: () async {
                final name = await askName(context, 'New playlist');
                if (name != null && context.mounted) {
                  if (s.playlists.containsKey(name)) {
                    toast(context, 'A playlist with that name already exists');
                  } else {
                    s.playlists[name] = [];
                    await s.saveLibrary();
                  }
                }
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (kind == 'My playlist')
            ListTile(
              leading: const Icon(Icons.favorite, color: Palette.coral),
              title: const Text('Liked songs'),
              subtitle: Text('${s.favorites.length} Songs'),
              onTap: () => go(context, '/library', arguments: 'Favorites'),
            ),
          if (kind == 'My playlist')
            ...s.playlists.entries.map(
              (e) => ListTile(
                leading: const Icon(Icons.queue_music, color: Palette.pink),
                title: Text(e.key),
                subtitle: Text(
                  '${e.value.length} Songs',
                  style: const TextStyle(color: Palette.coral, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(context, '/folder', arguments: e.key),
              ),
            )
          else if (kind == 'Album')
            ...List.generate(
              2,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: AlbumCard(
                  art: 'album-${i + 1}',
                  title: i == 0 ? 'Nice For What' : 'Do it',
                  artist: i == 0 ? 'Mother John' : 'Kang Luu',
                  width: double.infinity,
                  height: 240,
                  onTap: () => go(
                    context,
                    '/folder',
                    arguments: i == 0 ? 'Nice For What' : 'Do it',
                  ),
                ),
              ),
            )
          else if (kind == 'Videos')
            ListTile(
              leading: const Art('video', width: 112, height: 66),
              title: const Text('In My Feelings'),
              subtitle: const Text('Alan Walker'),
              onTap: () => go(context, '/video'),
            )
          else if (kind == 'Following')
            s.following
                ? ListTile(
                    leading: const Art(
                      'avatar',
                      width: 44,
                      height: 44,
                      radius: 30,
                    ),
                    title: const Text('Arian Grande'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => go(context, '/artist'),
                  )
                : const EmptyLibrary('Follow an artist to find them here.')
          else if (songs.isEmpty)
            EmptyLibrary(
              kind == 'My Download'
                  ? 'Save a preview from the player to listen offline.'
                  : 'Favorite a song to keep it in your library.',
            )
          else
            ...songs.map((t) => SongTile(t, menu: true)),
        ],
      ),
    );
  }
}

class EmptyLibrary extends StatelessWidget {
  const EmptyLibrary(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
    child: Column(
      children: [
        const Icon(Icons.library_music_outlined, color: Palette.pink, size: 48),
        const SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.muted, height: 1.6),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => go(context, '/home'),
          child: const Text('Discover music'),
        ),
      ],
    ),
  );
}

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});
  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  late List<double> values;
  bool initialized = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      values = List.of(AppScope.of(context).equalizer);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: context.isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        leading: const BackControl(),
        title: const Text(
          'Sound Equalizer',
          style: TextStyle(fontSize: 17, color: Palette.coral),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (i) => Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: 36,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  semanticFormatterCallback: (v) =>
                                      '${((v - .5) * 24).round()} dB',
                                  value: values[i],
                                  onChanged: (v) =>
                                      setState(() => values[i] = v),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FittedBox(
                            child: Text(
                              [
                                '50 HZ',
                                '170 HZ',
                                '400 HZ',
                                '1 KHZ',
                                '2.5 KHZ',
                              ][i],
                              style: const TextStyle(
                                color: Palette.coral,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Test Sound',
                style: TextStyle(color: context.muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              const PlaybackProgress(),
              const SizedBox(height: 16),
              const Transport(compact: true),
              const SizedBox(height: 18),
              Text(
                'Preview preset · saved on this device',
                style: TextStyle(color: context.muted, fontSize: 10),
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                'SAVE',
                onPressed: () async {
                  s.equalizer = List.of(values);
                  await s.saveEqualizer();
                  if (context.mounted) {
                    toast(context, 'Equalizer preset saved');
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
