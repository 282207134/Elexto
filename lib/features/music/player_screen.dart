import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_controller.dart';
import '../../core/app_theme.dart';
import '../../data/catalog.dart';
import '../../widgets/ui.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int view = 0;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: Glow(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: context.isDark ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 24),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: -60,
                          child: Container(
                            width: 250,
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Palette.coral.withValues(alpha: .2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    tooltip: 'Close player',
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 24,
                                    ),
                                  ),
                                  Text(
                                    'NOW PLAYING',
                                    style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 2,
                                      color: context.muted,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: view == 0
                                        ? 'Show queue'
                                        : 'Show record',
                                    onPressed: () => setState(
                                      () => view = view == 0 ? 1 : 0,
                                    ),
                                    icon: const Icon(
                                      Icons.open_in_full,
                                      size: 17,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (view == 0) ...[
                                        const SizedBox(height: 16),
                                        Center(
                                          child: ClipOval(
                                            child: Art(
                                              'record',
                                              width: 230,
                                              height: 230,
                                              radius: 0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 26),
                                      ] else
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            child: Art(
                                              'record',
                                              width: 72,
                                              height: 72,
                                              radius: 50,
                                            ),
                                          ),
                                        ),
                                      GestureDetector(
                                        onTap: () => go(context, '/artist'),
                                        child: Text(
                                          s.current.title,
                                          textAlign: view == 0
                                              ? TextAlign.center
                                              : TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: () => go(context, '/artist'),
                                        child: Text(
                                          s.current.artist,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Palette.coral,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      if (view == 0)
                                        Text(
                                          'Every sound has a story. Find yours.',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: context.muted,
                                          ),
                                        )
                                      else if (view == 1) ...[
                                        Text(
                                          'Discover music that moves with you. A collection of voices, memories and new beginnings.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.8,
                                            color: context.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        const Divider(
                                          color: Palette.coral,
                                          thickness: .5,
                                        ),
                                        SideSection(
                                          'Same playlist',
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: Column(
                                            children: tracks
                                                .skip(8)
                                                .map(
                                                  (t) =>
                                                      SongTile(t, menu: true),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ] else ...[
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Lyrics',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'In every rhythm, find a place to start\nA little light inside a beating heart\n\nWe follow sounds into the open sky\nAnd let the quiet moments pass us by\n\nOriginal instrumental preview\nLyrics shown for layout demonstration.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 2.2,
                                            color: context.muted,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (view == 0) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      tooltip: 'Share',
                                      onPressed: () => showShare(context),
                                      icon: const Icon(
                                        Icons.share_outlined,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Add to playlist',
                                      onPressed: () => showPlaylists(context),
                                      icon: const Icon(
                                        Icons.playlist_add,
                                        size: 23,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Lyrics',
                                      onPressed: () => setState(() => view = 2),
                                      icon: const Icon(
                                        Icons.music_note_outlined,
                                        size: 22,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Save offline',
                                      onPressed: () {
                                        s.download(s.current);
                                        toast(
                                          context,
                                          'Preview saved to My Download',
                                        );
                                      },
                                      icon: Icon(
                                        s.downloads.contains(s.current.id)
                                            ? Icons.download_done
                                            : Icons.file_download_outlined,
                                        size: 20,
                                        color:
                                            s.downloads.contains(s.current.id)
                                            ? Palette.coral
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const PlaybackProgress(),
                              const SizedBox(height: 18),
                              const Transport(),
                              if (s.audioError != null)
                                Text(
                                  s.audioError!,
                                  style: const TextStyle(
                                    color: Palette.coral,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 60,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Palette.pink,
                            foregroundColor: Palette.ink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.star_border, size: 18),
                          label: const Text(
                            'Billboard',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: 'Favorite',
                          onPressed: () => s.favorite(s.current),
                          icon: Icon(
                            s.favorites.contains(s.current.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: s.favorites.contains(s.current.id)
                                ? Palette.coral
                                : null,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: 'Search',
                          onPressed: () => go(context, '/search'),
                          icon: const Icon(Icons.search, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showPlaylists(BuildContext context) => showDialog(
  context: context,
  builder: (ctx) {
    final state = AppScope.of(ctx);
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Text('Playlists', style: TextStyle(fontSize: 18, color: Palette.ink)),
          Spacer(),
          Icon(Icons.playlist_add, color: Palette.ink),
        ],
      ),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: state.playlists.entries
              .map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Palette.pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    e.key,
                    style: const TextStyle(fontSize: 13, color: Palette.ink),
                  ),
                  subtitle: Text(
                    '${e.value.length} Songs',
                    style: const TextStyle(color: Palette.coral, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.add, color: Palette.pink),
                  onTap: () {
                    state.addToPlaylist(e.key, state.current);
                    Navigator.pop(ctx);
                    toast(
                      context,
                      '${state.current.title} · Added to ${e.key}',
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    );
  },
);
Future<void> showShare(BuildContext context) => showModalBottomSheet(
  context: context,
  backgroundColor: Colors.white,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
  ),
  builder: (ctx) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share',
            style: TextStyle(color: Palette.ink, fontSize: 18),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                [Icons.music_note, Icons.headphones, Icons.link, Icons.qr_code]
                    .asMap()
                    .entries
                    .map(
                      (e) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: [
                            Palette.purple,
                            Palette.coral,
                            Colors.black,
                            Palette.pink,
                          ][e.key],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(e.value, color: Colors.white, size: 28),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Copy a local demo track link',
            style: TextStyle(color: Palette.ink, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Palette.pink,
                foregroundColor: Palette.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: 'elexto://track/${AppScope.of(context).current.id}',
                  ),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (context.mounted) toast(context, 'Track link copied');
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy link'),
            ),
          ),
        ],
      ),
    ),
  ),
);
