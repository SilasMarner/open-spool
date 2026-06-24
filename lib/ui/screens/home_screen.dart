import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/line.dart';
import '../../models/line_segment.dart';
import '../../models/loadout.dart';
import '../../models/reel.dart';
import '../../services/capacity_calculator.dart';
import '../../services/unit_converter.dart';
import '../widgets/capacity_result_card.dart';
import 'line_picker_screen.dart';
import 'loadouts_screen.dart';
import 'reel_picker_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Reel? _reel;
  LoadoutMode _mode = LoadoutMode.straight;

  Line? _straightLine;

  Line? _topshotLine;
  Line? _backingLine;
  FixedSegment _fixed = FixedSegment.topshot;
  final _fixedYards = TextEditingController(text: '300');

  @override
  void initState() {
    super.initState();
    // The root ListenableBuilder can't rebuild this screen (it's a const `home`
    // widget Flutter short-circuits), so listen to unit changes directly.
    settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    settings.removeListener(_onSettingsChanged);
    _fixedYards.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reel Capacity Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Loadouts',
            onPressed: _openLoadouts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _reelSelector(),
          const SizedBox(height: 8),
          _modeToggle(),
          const SizedBox(height: 8),
          if (_mode == LoadoutMode.straight) _straightSection() else _topshotSection(),
          const SizedBox(height: 12),
          _result(),
        ],
      ),
      floatingActionButton: _reel == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _saveLoadout,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
    );
  }

  // ---- Reel ----------------------------------------------------------------

  Widget _reelSelector() {
    final u = settings.units;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.phishing),
        title: Text(_reel?.displayName ?? 'Select a reel'),
        subtitle: _reel == null
            ? const Text('Tap to choose')
            : Text('${_reel!.type.label} · anchor '
                '${u.length(_reel!.anchorYards)} of ${_reel!.anchorLabel}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final r = await Navigator.push<Reel>(
            context,
            MaterialPageRoute(builder: (_) => const ReelPickerScreen()),
          );
          if (r != null) setState(() => _reel = r);
        },
      ),
    );
  }

  Widget _modeToggle() => SegmentedButton<LoadoutMode>(
        segments: const [
          ButtonSegment(
            value: LoadoutMode.straight,
            label: Text('Straight'),
            icon: Icon(Icons.linear_scale),
          ),
          ButtonSegment(
            value: LoadoutMode.topshot,
            label: Text('Topshot'),
            icon: Icon(Icons.layers),
          ),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() => _mode = s.first),
      );

  // ---- Straight ------------------------------------------------------------

  Widget _straightSection() => _lineTile(
        label: 'Line',
        line: _straightLine,
        onPick: (l) => setState(() => _straightLine = l),
      );

  // ---- Topshot -------------------------------------------------------------

  Widget _topshotSection() {
    return Column(
      children: [
        _lineTile(
          label: 'Topshot (top)',
          line: _topshotLine,
          title: 'Select topshot',
          onPick: (l) => setState(() => _topshotLine = l),
        ),
        _lineTile(
          label: 'Backing (bottom)',
          line: _backingLine,
          title: 'Select backing',
          onPick: (l) => setState(() => _backingLine = l),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fix the length of:'),
                const SizedBox(height: 8),
                SegmentedButton<FixedSegment>(
                  segments: const [
                    ButtonSegment(value: FixedSegment.topshot, label: Text('Topshot')),
                    ButtonSegment(value: FixedSegment.backing, label: Text('Backing')),
                  ],
                  selected: {_fixed},
                  onSelectionChanged: (s) => setState(() => _fixed = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fixedYards,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText:
                        'Fixed ${_fixed == FixedSegment.topshot ? "topshot" : "backing"} length (${settings.units.lengthUnit})',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineTile({
    required String label,
    required Line? line,
    required ValueChanged<Line> onPick,
    String title = 'Select line',
  }) {
    final u = settings.units;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(line == null ? label : '${line.displayName} · ${u.test(line.lbTest)}'),
        subtitle: line == null
            ? Text('Tap to choose · $label')
            : Text('${line.type.shortLabel} · ${u.diameter(line.diameterIn)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final l = await Navigator.push<Line>(
            context,
            MaterialPageRoute(builder: (_) => LinePickerScreen(title: title)),
          );
          if (l != null) onPick(l);
        },
      ),
    );
  }

  // ---- Result --------------------------------------------------------------

  Widget _result() {
    final reel = _reel;
    if (reel == null) {
      return const _Hint('Pick a reel to begin.');
    }

    if (_mode == LoadoutMode.straight) {
      final line = _straightLine;
      if (line == null) return const _Hint('Pick a line to see capacity.');
      final yards = straightYards(
        spoolK: reel.spoolK,
        diameterIn: line.diameterIn,
        packingFactor: line.packingFactor,
      );
      return CapacityResultCard(
        rows: [ResultRow(line.displayName, yards, sub: line.type.shortLabel)],
        fillFraction: 1.0,
        unverifiedInputs: reel.unverified || line.unverified,
      );
    }

    final top = _topshotLine;
    final back = _backingLine;
    if (top == null || back == null) {
      return const _Hint('Pick both a topshot and a backing line.');
    }
    final fixedYards = double.tryParse(_fixedYards.text.trim());
    if (fixedYards == null || fixedYards <= 0) {
      return const _Hint('Enter a fixed length greater than zero.');
    }
    // Input length is in the active unit; convert to yards for the engine.
    final fixedYd =
        settings.units == UnitSystem.metric ? metersToYards(fixedYards) : fixedYards;

    final r = mixFill(
      spoolK: reel.spoolK,
      topDiameterIn: top.diameterIn,
      topPackingFactor: top.packingFactor,
      backDiameterIn: back.diameterIn,
      backPackingFactor: back.packingFactor,
      fixed: _fixed,
      fixedYards: fixedYd,
    );

    final topFixed = _fixed == FixedSegment.topshot;
    return CapacityResultCard(
      rows: [
        ResultRow('Topshot — ${top.displayName}', r.topshotYards,
            sub: topFixed ? 'fixed' : 'computed fill'),
        ResultRow('Backing — ${back.displayName}', r.backingYards,
            sub: topFixed ? 'computed fill' : 'fixed'),
      ],
      fillFraction: r.fillFraction,
      overflow: r.overflow,
      unverifiedInputs: reel.unverified || top.unverified || back.unverified,
    );
  }

  // ---- Loadouts ------------------------------------------------------------

  Future<void> _openLoadouts() async {
    final loadout = await Navigator.push<Loadout>(
      context,
      MaterialPageRoute(builder: (_) => const LoadoutsScreen()),
    );
    if (loadout != null) _applyLoadout(loadout);
  }

  void _applyLoadout(Loadout l) {
    final reel = catalog.reel(l.reelId);
    setState(() {
      _reel = reel;
      _mode = l.mode;
      if (l.mode == LoadoutMode.straight) {
        _straightLine = l.segments.isNotEmpty ? catalog.line(l.segments.first.lineId) : null;
      } else {
        for (final seg in l.segments) {
          final line = catalog.line(seg.lineId);
          if (seg.role == SegmentRole.topshot) {
            _topshotLine = line;
            if (seg.fixedYards != null) {
              _fixed = FixedSegment.topshot;
              _fixedYards.text = _formatFixed(seg.fixedYards!);
            }
          } else {
            _backingLine = line;
            if (seg.fixedYards != null) {
              _fixed = FixedSegment.backing;
              _fixedYards.text = _formatFixed(seg.fixedYards!);
            }
          }
        }
      }
    });
  }

  String _formatFixed(double yards) {
    final v = settings.units == UnitSystem.metric ? yardsToMeters(yards) : yards;
    return v.toStringAsFixed(0);
  }

  Future<void> _saveLoadout() async {
    final reel = _reel;
    if (reel == null) return;

    // Validate the current setup is complete enough to save.
    final List<LineSegment> segments;
    if (_mode == LoadoutMode.straight) {
      if (_straightLine == null) {
        _toast('Pick a line first.');
        return;
      }
      segments = [LineSegment(lineId: _straightLine!.id, role: SegmentRole.backing)];
    } else {
      if (_topshotLine == null || _backingLine == null) {
        _toast('Pick both lines first.');
        return;
      }
      final entered = double.tryParse(_fixedYards.text.trim());
      if (entered == null || entered <= 0) {
        _toast('Enter a valid fixed length.');
        return;
      }
      final fixedYd =
          settings.units == UnitSystem.metric ? metersToYards(entered) : entered;
      segments = [
        LineSegment(
          lineId: _topshotLine!.id,
          role: SegmentRole.topshot,
          fixedYards: _fixed == FixedSegment.topshot ? fixedYd : null,
        ),
        LineSegment(
          lineId: _backingLine!.id,
          role: SegmentRole.backing,
          fixedYards: _fixed == FixedSegment.backing ? fixedYd : null,
        ),
      ];
    }

    final name = await _askName(reel);
    if (name == null || name.trim().isEmpty) return;

    await loadoutRepo.save(Loadout(
      name: name.trim(),
      reelId: reel.id,
      mode: _mode,
      segments: segments,
    ));
    _toast('Saved "$name".');
  }

  Future<String?> _askName(Reel reel) {
    final c = TextEditingController(text: '${reel.model} setup');
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save loadout'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
