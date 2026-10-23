import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../core/app_theme.dart';
import '../data/catalog.dart';

void go(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
String timeLabel(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

class Art extends StatelessWidget {
  const Art(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 12,
    this.fit = BoxFit.cover,
  });
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
      excludeFromSemantics: true,
    ),
  );
}

class Glow extends StatelessWidget {
  final bool enabled;
  const Glow({super.key, required this.child, this.enabled = true});
  final Widget child;
  @override
  Widget build(BuildContext context) => !enabled
      ? child
      : Stack(
          children: [
            Positioned(
              top: -190,
              left: -240,
              child: Container(
                width: 650,
                height: 620,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Palette.coral,
                      Palette.coral,
                      Palette.coral.withValues(alpha: 0),
                    ],
                    stops: const [0, .45, 1],
                  ),
                ),
              ),
            ),
            child,
          ],
        );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.height = 66,
  });
  final String label;
  final VoidCallback? onPressed;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: height,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Palette.coral,
        foregroundColor: Colors.white,
        disabledBackgroundColor: context.isDark
            ? const Color(0xFF4A4584)
            : Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class BackControl extends StatelessWidget {
  const BackControl({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Back',
    onPressed: () => Navigator.maybePop(context),
    icon: const Icon(Icons.arrow_back_rounded, size: 21),
  );
}

class SideSection extends StatelessWidget {
  const SideSection(
    this.title, {
    super.key,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: 28),
  });
  final String title;
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          child: Center(
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: context.isDark
                      ? Colors.white.withValues(alpha: .85)
                      : Palette.ink,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

class SongTile extends StatelessWidget {
  const SongTile(
    this.track, {
    super.key,
    this.rank,
    this.onTap,
    this.menu = false,
  });
  final Track track;
  final int? rank;
  final VoidCallback? onTap;
  final bool menu;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return InkWell(
      onTap:
          onTap ??
          () {
            state.play(track);
            go(context, '/player');
          },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            if (rank != null)
              SizedBox(
                width: 24,
                child: Text(
                  '#$rank',
                  style: TextStyle(fontSize: 10, color: context.muted),
                ),
              ),
            Art(track.artwork, width: 34, height: 34, radius: 3),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    track.artist,
                    style: const TextStyle(fontSize: 10, color: Palette.coral),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: menu ? 'Song actions' : 'Favorite ${track.title}',
              icon: Icon(
                menu
                    ? Icons.more_horiz
                    : state.favorites.contains(track.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 17,
                color: Palette.coral,
              ),
              onPressed: () => menu
                  ? showSongActions(context, track)
                  : state.favorite(track),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showSongActions(BuildContext context, Track track) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(track.title), subtitle: Text(track.artist)),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play preview'),
              onTap: () {
                Navigator.pop(ctx);
                AppScope.of(context).play(track);
                go(context, '/player');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Save to favorites'),
              onTap: () {
                AppScope.of(context).favorite(track);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View artist'),
              onTap: () {
                Navigator.pop(ctx);
                go(context, '/artist');
              },
            ),
          ],
        ),
      ),
    );

class PlaybackProgress extends StatelessWidget {
  const PlaybackProgress({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final max = s.duration.inMilliseconds;
    return Column(
      children: [
        Slider(
          semanticFormatterCallback: (v) =>
              timeLabel(Duration(milliseconds: (v * max).round())),
          value: max == 0 ? 0 : (s.position.inMilliseconds / max).clamp(0, 1),
          onChanged: s.seek,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeLabel(s.position), style: const TextStyle(fontSize: 10)),
              Text(timeLabel(s.duration), style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

class Transport extends StatelessWidget {
  const Transport({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: !compact && constraints.maxWidth < 280
              ? 280
              : constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!compact)
                IconButton(
                  tooltip: 'Shuffle',
                  onPressed: s.toggleShuffle,
                  icon: Icon(
                    Icons.shuffle,
                    size: 20,
                    color: s.shuffle ? Palette.coral : null,
                  ),
                ),
              IconButton(
                tooltip: 'Previous track',
                onPressed: () => s.next(-1),
                icon: const Icon(Icons.skip_previous_rounded, size: 26),
              ),
              SizedBox(
                width: compact ? 46 : 72,
                height: compact ? 46 : 72,
                child: FilledButton(
                  onPressed: s.toggle,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Palette.coral,
                    shape: const CircleBorder(),
                  ),
                  child: Icon(
                    s.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: compact ? 24 : 34,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next track',
                onPressed: s.next,
                icon: const Icon(Icons.skip_next_rounded, size: 26),
              ),
              if (!compact)
                IconButton(
                  tooltip: 'Repeat',
                  onPressed: s.toggleRepeat,
                  icon: Icon(
                    Icons.repeat,
                    size: 20,
                    color: s.repeat ? Palette.coral : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Material(
      color: context.isDark ? const Color(0xFF211E3A) : Palette.cream,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => go(context, '/player'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 8, 8),
          child: Row(
            children: [
              Art('record', width: 42, height: 42, radius: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.current.title,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: s.duration.inMilliseconds == 0
                          ? 0
                          : (s.position.inMilliseconds /
                                    s.duration.inMilliseconds)
                                .clamp(0, 1),
                      minHeight: 2,
                      backgroundColor: context.muted,
                      color: Palette.coral,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Open player',
                onPressed: () => go(context, '/player'),
                icon: const Icon(Icons.open_in_full, size: 15),
              ),
              IconButton.filled(
                onPressed: s.toggle,
                tooltip: s.playing ? 'Pause' : 'Play',
                style: IconButton.styleFrom(
                  backgroundColor: Palette.coral,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  s.playing ? Icons.pause : Icons.play_arrow,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
