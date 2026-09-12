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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _Tab {
  final String label;
  final IconData icon;
  final Widget child;
  const _Tab(this.label, this.icon, this.child);
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    _Tab('Accueil', Icons.home, HomeTab()),
    _Tab('Direct', Icons.live_tv, LiveTab()),
    _Tab('Programme', Icons.calendar_month, ProgramTab()),
    _Tab('À propos', Icons.info, AboutTab()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.jpg', height: 32),
            const SizedBox(width: 10),
            Text(_tabs[_index].label),
          ],
        ),
      ),
      body: _tabs[_index].child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.jpg', width: 160),
            const SizedBox(height: 16),
            const Text('Bienvenue sur D3 TV'),
          ],
        ),
      );
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'D3TV est une chaîne de télévision malienne basée à Bamako.',
            textAlign: TextAlign.center,
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
        final items = snap.data!;
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final item = items[i] as Map<String, dynamic>;
            return ListTile(
              title: Text(item['titre'] as String),
              subtitle: Text(item['horaire'] as String),
            );
          },
        );
      },
    );
  }
}
