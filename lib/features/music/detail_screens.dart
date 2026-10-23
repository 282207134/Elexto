import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_controller.dart';
import '../../core/app_theme.dart';
import '../../data/catalog.dart';
import '../../widgets/ui.dart';
import 'home_screen.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  const Art(
                    'artist',
                    width: double.infinity,
                    height: 565,
                    radius: 0,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(left: 8, top: 50, child: BackControl()),
                  Positioned(
                    right: 24,
                    top: 84,
                    child: Column(
                      children:
                          [
                                '22',
                                'Playlist',
                                s.following ? '360 K + 1' : '360 K',
                                'Follower',
                                '56',
                                'Following',
                              ]
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: t.contains(RegExp(r'\d'))
                                          ? 18
                                          : 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arian Grande',
                          style: TextStyle(fontSize: 26, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '26 Jan 1990',
                          style: TextStyle(color: Palette.pink, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'A singer, songwriter and actress whose unmistakable voice brings a world of feeling to every song. Explore the albums and songs in this demo artist collection.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: s.follow,
                          style: FilledButton.styleFrom(
                            backgroundColor: Palette.coral,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(s.following ? 'Following ✓' : 'Follow +'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SideSection(
                'Album',
                child: SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      4,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: AlbumCard(
                          art: i.isEven ? 'album-1' : 'album-2',
                          title: [
                            'That XX',
                            'Lost In',
                            'Studio 09',
                            'Fantastic',
                          ][i],
                          artist: '',
                          width: 88,
                          height: 100,
                          onTap: () => go(
                            context,
                            '/folder',
                            arguments: [
                              'That XX',
                              'Lost In',
                              'Studio 09',
                              'Fantastic',
                            ][i],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SideSection(
                'Songs',
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: tracks
                        .take(4)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => SongTile(e.value, rank: e.key + 1, menu: true),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              Stack(
                children: [
                  const Art(
                    'video',
                    width: double.infinity,
                    height: 246,
                    radius: 0,
                  ),
                  const Positioned(top: 0, left: 8, child: BackControl()),
                  Positioned.fill(
                    child: Center(
                      child: IconButton.filled(
                        tooltip: 'Play video audio preview',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        iconSize: 44,
                        onPressed: () {
                          if (s.current != tracks[2]) {
                            s.play(tracks[2]);
                          } else {
                            s.toggle();
                          }
                        },
                        icon: Icon(
                          s.playing
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: PlaybackProgress(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'In My Feelings',
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Like video',
                          onPressed: () => s.favorite(tracks[2]),
                          icon: Icon(
                            s.favorites.contains('3')
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Palette.coral,
                          ),
                        ),
                        const Text('350 K', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const Text(
                      'Alan Walker',
                      style: TextStyle(color: Palette.coral, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    ...{
                      'Album': 'Walking on 01',
                      'Artist': 'The Weekend',
                      'Musician': 'Howard Lawence',
                      'Category': 'R&B',
                    }.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                e.key,
                                style: TextStyle(
                                  color: context.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(e.value, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Artwork with an original audio preview',
                      style: TextStyle(fontSize: 10, color: context.muted),
                    ),
                  ],
                ),
              ),
              SideSection(
                'Suggestion',
                child: Column(
                  children: List.generate(
                    2,
                    (i) => ListTile(
                      leading: Art(
                        'suggestion-${i + 1}',
                        width: 112,
                        height: 66,
                      ),
                      title: Text(
                        i == 0 ? 'Pay for the love' : 'Classic life',
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        i == 0 ? 'One Blue' : 'Tom Jones',
                        style: const TextStyle(
                          color: Palette.coral,
                          fontSize: 10,
                        ),
                      ),
                      onTap: () => s.play(tracks[i + 1]),
                      trailing: const Icon(
                        Icons.more_horiz,
                        color: Palette.coral,
                      ),
                    ),
                  ),
                ),
              ),
              SideSection(
                'Comments',
                child: Column(
                  children:
                      ['Guillermo Raffaele', 'Iida Niskanen', 'Miyah Myles']
                          .asMap()
                          .entries
                          .map(
                            (e) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Art(
                                'avatar',
                                width: 44,
                                height: 44,
                                radius: 30,
                              ),
                              title: Text(
                                e.value,
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Text(
                                [
                                  'I like it so much!!!',
                                  'Very good!',
                                  'Niceeeeeee!',
                                ][e.key],
                                style: TextStyle(
                                  color: context.muted,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: Text(
                                ['2 mins', '2 days', 'November 9'][e.key],
                                style: TextStyle(
                                  color: context.muted,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenresScreen extends StatelessWidget {
  const GenresScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Glow(
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const BackControl(),
                const Spacer(),
                IconButton(
                  tooltip: 'My playlists',
                  onPressed: () => go(context, '/library'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                children: [
                  const Text('Classic', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int col = 0; col < 2; col++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: col == 0 ? 12 : 0,
                              left: col == 1 ? 12 : 0,
                              top: col == 0 ? 64 : 0,
                            ),
                            child: Column(
                              children: List.generate(4, (row) {
                                final i = (col == 0
                                    ? [0, 6, 7, 5]
                                    : [1, 3, 4, 2])[row];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 22),
                                  child: InkWell(
                                    onTap: () => go(
                                      context,
                                      '/folder',
                                      arguments: genreNames[i],
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Art(
                                              'genre-${i + 1}',
                                              radius: 18,
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              genreNames[i].replaceAll(
                                                ' ',
                                                '\n',
                                              ),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                height: 1.2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                    ],
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
