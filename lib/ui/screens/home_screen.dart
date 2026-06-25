import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_state.dart';
import '../../models/line.dart';
import '../../models/line_segment.dart';
import '../../models/loadout.dart';
import '../../models/reel.dart';
import '../../services/capacity_calculator.dart';
import '../../services/loadout_result.dart';
import '../../services/unit_converter.dart';
import '../widgets/capacity_result_card.dart';
import '../widgets/wave_header.dart';
import 'line_picker_screen.dart';
import 'loadouts_screen.dart';
import 'manual_screen.dart';
import 'reel_picker_screen.dart';
import 'settings_screen.dart';

/// Front-screen fill type: one straight line, a topshot (set the topshot length,
/// backing auto-fills), or backing + topshot with both lengths set explicitly.
enum _FillType { straight, topshot, both }

/// How the user dials in a topshot/backing mix: by typed lengths, or by a
/// percentage split of the spool (each segment's yardage is computed for them).
enum _MixInput { length, percent }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Reel? _reel;
  _FillType _fill = _FillType.straight;

  Line? _straightLine;

  Line? _topshotLine;
  Line? _backingLine;
  final _topYards = TextEditingController(text: '50');
  final _backYards = TextEditingController(text: '300');

  /// Mix input style and the topshot's share of the spool (%) for percent mode.
  _MixInput _mixInput = _MixInput.length;
  double _topPercent = 30;

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

  /// True when there's an in-progress plan worth clearing (a reel or any line
  /// picked). Drives whether the "Start over" action is enabled.
  bool get _hasSelections =>
      _reel != null ||
      _straightLine != null ||
      _topshotLine != null ||
      _backingLine != null;

  /// Clear the calculator back to a fresh state. Only touches the in-progress
  /// selections — saved favorites are untouched.
  void _reset() {
    setState(() {
      _reel = null;
      _fill = _FillType.straight;
      _straightLine = null;
      _topshotLine = null;
      _backingLine = null;
      _topYards.text = '50';
      _backYards.text = '300';
      _mixInput = _MixInput.length;
      _topPercent = 30;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Started a new plan')));
  }

  @override
  void dispose() {
    settings.removeListener(_onSettingsChanged);
    _topYards.dispose();
    _backYards.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenSpool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Start over',
            onPressed: _hasSelections ? _reset : null,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Favorites',
            onPressed: _openLoadouts,
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'User Guide',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManualScreen()),
            ),
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
      // SafeArea keeps the (often non-scrolling) page above the system nav bar
      // so the result card's Share button isn't hidden behind a Samsung-style
      // 3-button bar under Android's forced edge-to-edge.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Animated wave band matching OpenTides, so the two apps read as one
            // family. Shows the picked reel as its subtitle once chosen.
            WaveHeader(subtitle: _reel?.displayName),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                children: [
                  const _StepHeader(1, 'Pick your reel'),
            _reelSelector(),
            const SizedBox(height: 16),
            const _StepHeader(2, 'How are you filling it?'),
            _modeToggle(),
            const SizedBox(height: 8),
            _modeHelp(),
            const SizedBox(height: 16),
            _StepHeader(3, _stepThreeTitle()),
            if (_fill == _FillType.straight)
              _straightSection()
            else
              _mixSection(),
            const SizedBox(height: 16),
            _result(),
                ],
              ),
            ),
          ],
        ),
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

  Widget _modeToggle() => SegmentedButton<_FillType>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 6),
          ),
        ),
        segments: const [
          ButtonSegment(value: _FillType.straight, label: Text('Straight')),
          ButtonSegment(value: _FillType.topshot, label: Text('Topshot')),
          ButtonSegment(
            value: _FillType.both,
            label: Text('Backing/\nTopshot', textAlign: TextAlign.center),
          ),
        ],
        selected: {_fill},
        onSelectionChanged: (s) {
          setState(() => _fill = s.first);
          // Entering Backing/Topshot: top off the backing from the topshot so
          // both fields start showing a full-spool pair.
          if (_fill == _FillType.both) _syncMix(FixedSegment.topshot);
        },
      );

  Widget _modeHelp() {
    final String msg;
    switch (_fill) {
      case _FillType.straight:
        msg = 'One line fills the whole spool.';
      case _FillType.topshot:
        msg = 'Set your topshot length — the backing auto-fills the rest of '
            'the spool.';
      case _FillType.both:
        msg = 'Set either length — the other auto-fills so the two together '
            'fill the spool.';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        msg,
        style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
      ),
    );
  }

  String _stepThreeTitle() {
    switch (_fill) {
      case _FillType.straight:
        return 'Pick your line';
      case _FillType.topshot:
        return 'Pick lines & set your topshot';
      case _FillType.both:
        return 'Pick lines & set both lengths';
    }
  }

  // ---- Straight ------------------------------------------------------------

  Widget _straightSection() => _lineTile(
        label: 'Your line',
        line: _straightLine,
        onPick: (l) => setState(() => _straightLine = l),
      );

  // ---- Backing + topshot ---------------------------------------------------

  Widget _mixSection() {
    final unit = settings.units.lengthUnit;
    final both = _fill == _FillType.both;
    return Column(
      children: [
        _lineTile(
          label: 'Topshot — line on top',
          line: _topshotLine,
          title: 'Select topshot',
          onPick: (l) => _pickMixLine(topshot: true, line: l),
        ),
        _lineTile(
          label: 'Backing — fills underneath',
          line: _backingLine,
          title: 'Select backing',
          onPick: (l) => _pickMixLine(topshot: false, line: l),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mixInputToggle(),
                const SizedBox(height: 14),
                if (_mixInput == _MixInput.percent)
                  _percentBody()
                else ...[
                  _yardsField(
                    controller: _topYards,
                    label: 'Topshot length',
                    unit: unit,
                    onChanged: both
                        ? (_) {
                            _syncMix(FixedSegment.topshot);
                            setState(() {});
                          }
                        : null,
                  ),
                  if (both) ...[
                    const SizedBox(height: 12),
                    _yardsField(
                      controller: _backYards,
                      label: 'Backing length',
                      unit: unit,
                      onChanged: (_) {
                        _syncMix(FixedSegment.backing);
                        setState(() {});
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 2),
                      child: Text(
                        'Edit either length — the other auto-adjusts to fill the '
                        'rest of the spool.',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 2),
                      child: Text(
                        'Backing fills the rest of the spool automatically.',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mixInputToggle() => SegmentedButton<_MixInput>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12.5)),
        ),
        segments: const [
          ButtonSegment(
            value: _MixInput.length,
            label: Text('By length'),
            icon: Icon(Icons.straighten, size: 18),
          ),
          ButtonSegment(
            value: _MixInput.percent,
            label: Text('By %'),
            icon: Icon(Icons.percent, size: 18),
          ),
        ],
        selected: {_mixInput},
        onSelectionChanged: (s) => setState(() => _mixInput = s.first),
      );

  /// Percent-split body: a slider sets the topshot's share of the spool; the
  /// backing takes the rest. The result card shows the yardage each works out to.
  Widget _percentBody() {
    final top = _topPercent.round();
    final back = 100 - top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Topshot share', style: TextStyle(fontSize: 14)),
            const Spacer(),
            Text('$top%  ·  backing $back%',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: _topPercent,
          min: 0,
          max: 100,
          divisions: 100,
          label: '$top%',
          onChanged: (v) => setState(() => _topPercent = v),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Text(
            'Split the spool by volume — each line’s yardage is computed '
            'below.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        ),
      ],
    );
  }

  Widget _yardsField({
    required TextEditingController controller,
    required String label,
    required String unit,
    ValueChanged<String>? onChanged,
  }) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged ?? (_) => setState(() {}),
      );

  /// Parse a length field in the active unit → yards, or null if blank/invalid.
  double? _yards(TextEditingController c) {
    final v = double.tryParse(c.text.trim());
    if (v == null || v <= 0) return null;
    return settings.units == UnitSystem.metric ? metersToYards(v) : v;
  }

  /// Backing/Topshot mode: after the [edited] segment changes, recompute the
  /// other segment to whatever fills the rest of the spool (diameter² model) and
  /// write it back into its field. Setting a controller's text programmatically
  /// doesn't fire its onChanged, so this can't loop.
  void _syncMix(FixedSegment edited) {
    final reel = _reel;
    final top = _topshotLine;
    final back = _backingLine;
    if (reel == null || top == null || back == null) return;
    final src = edited == FixedSegment.topshot ? _topYards : _backYards;
    final fixedYd = _yards(src);
    if (fixedYd == null) return;
    final r = computeMix(
      reel: reel,
      topshot: top,
      backing: back,
      fixed: edited,
      fixedYards: fixedYd,
    );
    // rows[0] = topshot, rows[1] = backing.
    final otherYards =
        edited == FixedSegment.topshot ? r.rows[1].yards : r.rows[0].yards;
    final dst = edited == FixedSegment.topshot ? _backYards : _topYards;
    dst.text = _formatFixed(otherYards);
  }

  void _pickMixLine({required bool topshot, required Line line}) {
    if (topshot) {
      _topshotLine = line;
    } else {
      _backingLine = line;
    }
    if (_fill == _FillType.both) _syncMix(FixedSegment.topshot);
    setState(() {});
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
            ? const Text('Tap to choose')
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

    if (_fill == _FillType.straight) {
      final line = _straightLine;
      if (line == null) return const _Hint('Pick a line to see capacity.');
      return _card(computeStraight(reel: reel, line: line));
    }

    final top = _topshotLine;
    final back = _backingLine;
    if (top == null || back == null) {
      return const _Hint('Pick both a topshot and a backing line.');
    }

    // Percent split applies to either mix mode — set the topshot's share of the
    // spool and both yardages are computed.
    if (_mixInput == _MixInput.percent) {
      return _card(computeMixSplit(
        reel: reel,
        topshot: top,
        backing: back,
        topPercent: _topPercent,
      ));
    }

    if (_fill == _FillType.topshot) {
      final y = _yards(_topYards);
      if (y == null) return const _Hint('Enter a topshot length greater than zero.');
      return _card(computeMix(
        reel: reel,
        topshot: top,
        backing: back,
        fixed: FixedSegment.topshot,
        fixedYards: y,
      ));
    }

    // Backing/Topshot: editing one length auto-fills the other (a length of 0
    // means the other segment alone overflows the spool — keep it so the card
    // can show the overflow warning rather than hiding behind a hint).
    final ty = _yards(_topYards) ?? 0;
    final by = _yards(_backYards) ?? 0;
    if (ty <= 0 && by <= 0) {
      return const _Hint('Enter a topshot or backing length.');
    }
    return _card(computeMixBoth(
      reel: reel,
      topshot: top,
      backing: back,
      topYards: ty,
      backYards: by,
    ));
  }

  Widget _card(ComputedResult r) => CapacityResultCard(
        rows: [
          for (final row in r.rows)
            ResultRow(row.label, row.yards, sub: row.sub, lbTest: row.lbTest)
        ],
        fillFraction: r.fillFraction,
        overflow: r.overflow,
        overflowText: r.overflowText,
        unverifiedInputs: r.unverified,
        onShare: () => _shareResult(r),
        onSave: _saveLoadout,
      );

  Future<void> _shareResult(ComputedResult r) async {
    await Share.share(
      shareSummary(r, settings.units),
      subject: 'Reel line plan — ${r.reel.displayName}',
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
      if (l.mode == LoadoutMode.straight) {
        _fill = _FillType.straight;
        _straightLine = l.segments.isNotEmpty ? catalog.line(l.segments.first.lineId) : null;
      } else {
        double? topF;
        double? backF;
        for (final seg in l.segments) {
          final line = catalog.line(seg.lineId);
          if (seg.role == SegmentRole.topshot) {
            _topshotLine = line;
            topF = seg.fixedYards;
          } else {
            _backingLine = line;
            backF = seg.fixedYards;
          }
        }
        if (topF != null && backF != null) {
          // Both lengths pinned → Backing/Topshot.
          _fill = _FillType.both;
          _topYards.text = _formatFixed(topF);
          _backYards.text = _formatFixed(backF);
        } else {
          // Topshot pinned, backing auto-filled.
          _fill = _FillType.topshot;
          if (topF != null) _topYards.text = _formatFixed(topF);
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
    if (_fill == _FillType.straight) {
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
      double? topFixed;
      double? backFixed;
      if (_mixInput == _MixInput.percent) {
        // Resolve the split to concrete pinned yards so it persists like any
        // both-lengths plan (the percentage is just an input convenience).
        final r = computeMixSplit(
          reel: reel,
          topshot: _topshotLine!,
          backing: _backingLine!,
          topPercent: _topPercent,
        );
        topFixed = r.rows[0].yards;
        backFixed = r.rows[1].yards;
      } else {
        topFixed = _yards(_topYards);
        if (topFixed == null) {
          _toast('Enter a valid topshot length.');
          return;
        }
        // Backing/Topshot pins both; Topshot leaves the backing to auto-fill.
        if (_fill == _FillType.both) {
          backFixed = _yards(_backYards);
          if (backFixed == null) {
            _toast('Enter a valid backing length.');
            return;
          }
        }
      }
      segments = [
        LineSegment(
          lineId: _topshotLine!.id,
          role: SegmentRole.topshot,
          fixedYards: topFixed,
        ),
        LineSegment(
          lineId: _backingLine!.id,
          role: SegmentRole.backing,
          fixedYards: backFixed,
        ),
      ];
    }

    final candidate = Loadout(
      name: '',
      reelId: reel.id,
      mode: _fill == _FillType.straight ? LoadoutMode.straight : LoadoutMode.topshot,
      segments: segments,
    );

    // Don't let the same reel + lines + lengths be saved twice.
    final existing = await loadoutRepo.findDuplicate(candidate);
    if (existing != null) {
      _toast('Already saved as "${existing.name}".');
      return;
    }

    final name = await _askName(reel);
    if (name == null || name.trim().isEmpty) return;

    await loadoutRepo.save(candidate.copyWith(name: name.trim()));
    _toast('Saved "${name.trim()}".');
  }

  Future<String?> _askName(Reel reel) {
    final c = TextEditingController(text: '${reel.model} setup');
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save favorite'),
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

/// A numbered step heading (circular badge + bold title) for the calculator's
/// stepped flow.
class _StepHeader extends StatelessWidget {
  final int number;
  final String title;
  const _StepHeader(this.number, this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
