import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/app_theme.dart';
import '../../data/catalog.dart';
import '../../widgets/ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Glow(
      enabled: tab != 2,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: tab == 2
                    ? const SearchContent()
                    : SingleChildScrollView(
                        key: ValueKey(tab),
                        padding: const EdgeInsets.only(top: 18, bottom: 20),
                        child: Column(
                          children: [
                            const UserHeader(),
                            const SizedBox(height: 38),
                            if (tab == 0)
                              const BillboardContent()
                            else
                              const ExploreContent(),
                          ],
                        ),
                      ),
              ),
            ),
            if (tab != 2)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: MiniPlayer(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: List.generate(3, (i) {
                    final labels = ['Billboard', 'Explore', 'Search'];
                    final icons = [
                      Icons.star_border_rounded,
                      Icons.favorite_border,
                      Icons.search,
                    ];
                    return Expanded(
                      flex: tab == i ? 2 : 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Material(
                          color: tab == i ? Palette.pink : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() => tab = i);
                            },
                            child: SizedBox(
                              height: 52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icons[i],
                                    size: 20,
                                    color: tab == i
                                        ? Palette.ink
                                        : context.isDark
                                        ? Colors.white
                                        : Palette.ink,
                                  ),
                                  if (tab == i) ...[
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        labels[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Palette.ink,
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
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .36),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                s.username == 'James Smith' ? 'J.Smith' : s.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
            IconButton(
              tooltip: 'Switch theme',
              onPressed: () => s.setTheme(!s.dark),
              icon: Icon(
                s.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 19,
                color: Colors.white70,
              ),
            ),
            IconButton(
              tooltip: 'Profile',
              onPressed: () => go(context, '/profile'),
              icon: const Art('avatar', width: 34, height: 34, radius: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.art,
    required this.title,
    required this.artist,
    this.width = 168,
    this.height = 168,
    this.onTap,
  });
  final String art, title, artist;
  final double width, height;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap ?? () => go(context, '/artist'),
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: Art(art, radius: 16)),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: const TextStyle(fontSize: 10, color: Palette.pink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class BillboardContent extends StatelessWidget {
  const BillboardContent({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 10),
        child: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => go(context, '/library', arguments: 'Album'),
            child: const Text(
              'View all',
              style: TextStyle(fontSize: 11, color: Palette.coral),
            ),
          ),
        ),
      ),
      SideSection(
        'New Albums',
        child: SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const AlbumCard(
                art: 'album-1',
                title: 'Nice For What',
                artist: 'Mother John',
              ),
              const SizedBox(width: 16),
              const Align(
                alignment: Alignment.bottomCenter,
                child: AlbumCard(
                  art: 'album-2',
                  title: 'Do it',
                  artist: 'Kang Luu',
                  width: 136,
                  height: 136,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
      SideSection(
        'Weekly',
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: InkWell(
            onTap: () => go(context, '/video'),
            child: AspectRatio(
              aspectRatio: 294 / 168,
              child: Stack(
                children: [
                  const Positioned.fill(child: Art('weekly')),
                  const Positioned(
                    left: 18,
                    top: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay for the love',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'One Blue',
                          style: TextStyle(fontSize: 10, color: Palette.pink),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        border: Border.all(color: Colors.white),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 18,
                    right: 18,
                    bottom: 14,
                    child: Row(
                      children: [
                        Text(
                          '3:12',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: LinearProgressIndicator(
                              value: .6,
                              color: Palette.coral,
                              backgroundColor: Colors.white54,
                              minHeight: 2,
                            ),
                          ),
                        ),
                        Text(
                          '5:43',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SideSection(
        'Recently Music',
        child: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            children: tracks
                .take(4)
                .toList()
                .asMap()
                .entries
                .map((e) => SongTile(e.value, rank: e.key + 1))
                .toList(),
          ),
        ),
      ),
    ],
  );
}

class ExploreContent extends StatelessWidget {
  const ExploreContent({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SideSection(
        'Topics',
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, i) => InkWell(
              onTap: () => go(context, '/genres', arguments: topicNames[i]),
              child: Stack(
                children: [
                  Positioned.fill(child: Art('topic-${i + 1}')),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Center(
                    child: Text(
                      topicNames[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SideSection(
        'Recent Music',
        child: SizedBox(
          height: 142,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const AlbumCard(
                art: 'album-2',
                title: 'Do it',
                artist: 'Kang Luu',
                width: 136,
                height: 136,
              ),
              const SizedBox(width: 18),
              AlbumCard(
                art: 'video',
                title: 'Love You To Love Me',
                artist: 'Maroon 5',
                width: 136,
                height: 136,
                onTap: () => go(context, '/video'),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
      SideSection(
        'All Song',
        child: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            children: tracks
                .take(6)
                .toList()
                .asMap()
                .entries
                .map((e) => SongTile(e.value, rank: e.key + 1, menu: true))
                .toList(),
          ),
        ),
      ),
    ],
  );
}

class SearchContent extends StatefulWidget {
  const SearchContent({super.key});
  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final query = TextEditingController();
  int category = 0;
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = query.text.trim().toLowerCase();
    final results = tracks
        .where((t) => '${t.title} ${t.artist}'.toLowerCase().contains(q))
        .toList();
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.panel,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Column(
            children: [
              TextField(
                key: const ValueKey('search-field'),
                controller: query,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, color: Palette.ink),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAA4BE),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(4),
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.pink,
                        foregroundColor: Palette.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      tooltip: q.isEmpty ? 'Search' : 'Clear search',
                      onPressed: () {
                        query.clear();
                        setState(() {});
                      },
                      icon: Icon(
                        q.isEmpty ? Icons.search : Icons.close,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
              if (q.isEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  children: ['Fall out boy', 'Good girl']
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            backgroundColor: Palette.coral,
                            side: BorderSide.none,
                            label: Text(
                              s,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              query.text = s;
                              setState(() {});
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        if (q.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 18),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: category == i,
                      onSelected: (_) => setState(() => category = i),
                      label: Text(
                        ['All', 'Artist', 'Video', 'EDM', 'Album'][i],
                        style: TextStyle(
                          fontSize: 12,
                          color: category == i ? Colors.white : null,
                        ),
                      ),
                      showCheckmark: false,
                      selectedColor: Palette.coral,
                      side: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              if (q.isEmpty) ...[
                SideSection(
                  'Trending',
                  child: Column(
                    children: tracks
                        .take(4)
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => SongTile(e.value, rank: e.key + 1))
                        .toList(),
                  ),
                ),
                SideSection(
                  'Recently',
                  child: Column(
                    children: tracks
                        .skip(4)
                        .take(4)
                        .toList()
                        .asMap()
                        .entries
                        .map((e) => SongTile(e.value, rank: e.key + 1))
                        .toList(),
                  ),
                ),
              ] else if (category == 1)
                SideSection(
                  'Top Artist',
                  child: Column(
                    children:
                        [
                              'Meghan Trainor',
                              'Little Mix',
                              'Mark Ronson',
                              'Arian Grande',
                            ]
                            .where(
                              (a) =>
                                  a.toLowerCase().contains(q) || q.length == 1,
                            )
                            .map(
                              (a) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Art(
                                  'avatar',
                                  width: 34,
                                  height: 34,
                                ),
                                title: Text(
                                  a,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: const Icon(
                                  Icons.more_horiz,
                                  color: Palette.coral,
                                ),
                                onTap: () => go(context, '/artist'),
                              ),
                            )
                            .toList(),
                  ),
                ),
              if (q.isNotEmpty && category == 2)
                SideSection(
                  'Top Video',
                  child: Column(
                    children: List.generate(
                      2,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 20, right: 16),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
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
                              fontSize: 10,
                              color: Palette.coral,
                            ),
                          ),
                          onTap: () => go(context, '/video'),
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Video actions',
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Palette.coral,
                            ),
                            onSelected: (v) {
                              if (v == 'play') {
                                go(context, '/video');
                              } else {
                                AppScope.of(context).download(tracks[2]);
                                toast(context, 'Preview saved to My Download');
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'play',
                                child: Text('Play preview'),
                              ),
                              PopupMenuItem(
                                value: 'save',
                                child: Text('Save offline preview'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (q.isNotEmpty && category != 1 && category != 2)
                results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 40,
                              color: Palette.pink,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results for “${query.text}”',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a song or artist name',
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SideSection(
                        category == 4 ? 'Top Album' : 'Top Searching',
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Column(
                            children: results
                                .map((t) => SongTile(t, menu: true))
                                .toList(),
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ],
    );
  }
}
