import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_state.dart';
import '../../models/loadout.dart';
import '../../services/loadout_result.dart';

/// Lists saved favorites. Tap one to load it onto the calculator; drag the
/// handle to reorder; tap the trash icon to delete (with Undo); the share icon
/// hands its result to the system share sheet.
class LoadoutsScreen extends StatefulWidget {
  const LoadoutsScreen({super.key});

  @override
  State<LoadoutsScreen> createState() => _LoadoutsScreenState();
}

class _LoadoutsScreenState extends State<LoadoutsScreen> {
  List<Loadout> _items = [];
  bool _loading = true;
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // Don't let our "Deleted …" snackbar leak onto the previous screen — the
    // root messenger keeps it alive across navigation otherwise.
    _messenger?.clearSnackBars();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await loadoutRepo.all();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _persistOrder() =>
      loadoutRepo.reorder(_items.map((e) => e.id!).toList());

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    // onReorderItem already adjusts newIndex for the removed item.
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    await _persistOrder();
  }

  Future<void> _delete(Loadout l) async {
    final index = _items.indexWhere((e) => e.id == l.id);
    if (index < 0) return;
    setState(() => _items.removeAt(index));
    await loadoutRepo.delete(l.id!);
    await _persistOrder();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${l.name}".'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _restore(l, index),
          ),
        ),
      );
  }

  Future<void> _restore(Loadout l, int index) async {
    await loadoutRepo.restore(l);
    if (!mounted) return;
    setState(() => _items.insert(index.clamp(0, _items.length), l));
    await _persistOrder();
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No saved favorites yet.\nBuild a setup on the calculator and tap Save favorite.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom),
                  itemCount: _items.length,
                  onReorderItem: _onReorder,
                  itemBuilder: (context, i) => _row(_items[i], i),
                ),
    );
  }

  Widget _row(Loadout l, int index) {
    final reel = catalog.reel(l.reelId);
    final lineNames = l.segments
        .map((s) => catalog.line(s.lineId)?.displayName ?? '?')
        .join(' over ');
    return ListTile(
      key: ValueKey(l.id),
      leading: Icon(
        l.mode == LoadoutMode.topshot ? Icons.layers : Icons.linear_scale,
      ),
      title: Text(l.name),
      subtitle: Text('${reel?.displayName ?? l.reelId}\n$lineNames'),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share',
            onPressed: () => _shareLoadout(l),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _delete(l),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Icon(Icons.drag_handle),
            ),
          ),
        ],
      ),
      onTap: () => Navigator.pop(context, l),
    );
  }
}
