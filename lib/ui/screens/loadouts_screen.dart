import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/loadout.dart';

/// Lists saved loadouts. Tapping one returns it to the calculator; swipe/long
/// press to delete.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved loadouts')),
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
                  'No saved loadouts yet.\nBuild a setup on the calculator and tap Save.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
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
