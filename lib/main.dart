import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:video_player/video_player.dart';

const liveStreamUrl =
    'https://live20.bozztv.com/akamaissh101/ssh101/d3tvnet/playlist.m3u8';

void main() => runApp(const D3tvApp());

class D3tvApp extends StatelessWidget {
  const D3tvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D3 TV',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeShell(),
    );
  }
}

/// Groups programme/actualité-style JSON items by their "categorie" field,
/// preserving first-seen order. Shared by HomeTab (horizontal rows) and
/// ProgramTab (vertical list) so the grouping logic lives in one place.
Map<String, List<Map<String, dynamic>>> _groupByCategorie(
    List<dynamic> raw) {
  final map = <String, List<Map<String, dynamic>>>{};
  for (final r in raw) {
    final item = r as Map<String, dynamic>;
    (map[item['categorie'] as String] ??= []).add(item);
  }
  return map;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _labels = ['Accueil', 'Direct', 'Actualités', 'Programmes'];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
    NavigationDestination(icon: Icon(Icons.live_tv), label: 'Direct'),
    NavigationDestination(icon: Icon(Icons.article), label: 'Actualités'),
    NavigationDestination(
        icon: Icon(Icons.calendar_month), label: 'Programmes'),
  ];

  void _goTo(int i) => setState(() => _index = i);

  Widget _body() {
    switch (_index) {
      case 0:
        return HomeTab(onVoirDirect: () => _goTo(1));
      case 1:
        return const LiveTab();
      case 2:
        return const ActualitesTab();
      default:
        return const ProgramTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.jpg', height: 32),
            const SizedBox(width: 10),
            Text(_labels[_index]),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Image.asset('assets/logo.jpg', height: 60),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendrier des programmes'),
              onTap: () {
                Navigator.pop(context);
                _goTo(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Présentation & contact'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('À propos')),
                      body: const AboutTab(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _body(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: _destinations,
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final VoidCallback onVoirDirect;
  const HomeTab({super.key, required this.onVoirDirect});

  Future<List<dynamic>> _load() async {
    final raw = await rootBundle.loadString('assets/programme.json');
    return jsonDecode(raw) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              Image.asset('assets/logo.jpg', width: 140),
              const SizedBox(height: 12),
              const Text(
                'La chaîne malienne du cœur',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onVoirDirect,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Voir le Direct'),
              ),
            ],
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: _load(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final grouped = _groupByCategorie(snap.data!);
            return Column(
              children: [
                for (final entry in grouped.entries)
                  _CategoryRow(title: entry.key, items: entry.value),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  const _CategoryRow({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final item = items[i];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['titre'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item['horaire'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'D3TV est une chaîne de télévision malienne basée à Bamako, '
                'dédiée aux cultures et langues du Mali (Bambara, Peulh...).',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text('contact@d3tv.net', textAlign: TextAlign.center),
              SizedBox(height: 4),
              Text(
                'Facebook · Instagram · TikTok · YouTube',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class LiveTab extends StatefulWidget {
  const LiveTab({super.key});

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(liveStreamUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _error = 'Flux indisponible pour le moment');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Center(child: Text(_error!));
    if (!_ready) return const Center(child: CircularProgressIndicator());
    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

class ProgramTab extends StatelessWidget {
  const ProgramTab({super.key});

  Future<List<dynamic>> _load() async {
    final raw = await rootBundle.loadString('assets/programme.json');
    return jsonDecode(raw) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final grouped = _groupByCategorie(snap.data!);
        return ListView(
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final item in entry.value)
                ListTile(
                  title: Text(item['titre'] as String),
                  subtitle: Text(item['horaire'] as String),
                ),
              const Divider(height: 1),
            ],
          ],
        );
      },
    );
  }
}

class ActualitesTab extends StatelessWidget {
  const ActualitesTab({super.key});

  Future<List<dynamic>> _load() async {
    final raw = await rootBundle.loadString('assets/actualites.json');
    return jsonDecode(raw) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final item = items[i] as Map<String, dynamic>;
            return ListTile(
              title: Text(item['titre'] as String),
              subtitle: Text('${item['categorie']} · ${item['date']}'),
            );
          },
        );
      },
    );
  }
}
