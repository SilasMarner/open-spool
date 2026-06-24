import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_state.dart';
import '../../models/loadout.dart';
import '../../services/loadout_result.dart';

/// Lists saved favorites. Tapping one returns it to the calculator; swipe to
/// delete; the share icon hands its result to the system share sheet.
class LoadoutsScreen extends StatefulWidget {
  const LoadoutsScreen({super.key});

  @override
  State<LoadoutsScreen> createState() => _LoadoutsScreenState();
}

class _LoadoutsScreenState extends State<LoadoutsScreen> {
  late Future<List<Loadout>> _future;

  @override
  void initState() {
    super.initState();
    _future = loadoutRepo.all();
  }

  void _refresh() => setState(() => _future = loadoutRepo.all());

  Future<void> _shareLoadout(Loadout l) async {
    final r = computeLoadout(l);
    if (r == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not compute this favorite.')),
        );
      }
      return;
    }
    await Share.share(
      shareSummary(r, settings.units, title: l.name),
      subject: 'Reel line plan — ${l.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved favorites')),
      body: FutureBuilder<List<Loadout>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No saved favorites yet.\nBuild a setup on the calculator and tap Save favorite.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final l = items[i];
              final reel = catalog.reel(l.reelId);
              final lineNames = l.segments
                  .map((s) => catalog.line(s.lineId)?.displayName ?? '?')
                  .join(' over ');
              return Dismissible(
                key: ValueKey(l.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (_) async {
                  await loadoutRepo.delete(l.id!);
                  _refresh();
                },
                child: ListTile(
                  leading: Icon(
                    l.mode == LoadoutMode.topshot ? Icons.layers : Icons.linear_scale,
                  ),
                  title: Text(l.name),
                  subtitle: Text('${reel?.displayName ?? l.reelId}\n$lineNames'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.ios_share),
                    tooltip: 'Share',
                    onPressed: () => _shareLoadout(l),
                  ),
                  onTap: () => Navigator.pop(context, l),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
