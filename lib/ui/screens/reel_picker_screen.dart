import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/reel.dart';
import '../../services/unit_converter.dart';

/// Searchable reel list; returns the chosen [Reel] via Navigator.pop.
class ReelPickerScreen extends StatefulWidget {
  const ReelPickerScreen({super.key});

  @override
  State<ReelPickerScreen> createState() => _ReelPickerScreenState();
}

class _ReelPickerScreenState extends State<ReelPickerScreen> {
  String _query = '';
  ReelType? _typeFilter;

  List<Reel> get _filtered {
    final q = _query.toLowerCase();
    return catalog.reels.where((r) {
      if (_typeFilter != null && r.type != _typeFilter) return false;
      if (q.isEmpty) return true;
      return r.displayName.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final u = settings.units;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select reel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add custom reel',
            onPressed: _addCustom,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              autofocus: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search reels',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filterChip('All', null),
                _filterChip('Conventional', ReelType.conventional),
                _filterChip('Spinning', ReelType.spinning),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final r = _filtered[i];
                return ListTile(
                  leading: Icon(r.type == ReelType.spinning
                      ? Icons.cyclone
                      : Icons.settings_input_component),
                  title: Row(
                    children: [
                      Flexible(child: Text(r.displayName)),
                      if (r.custom) const _Tag('custom'),
                      if (r.unverified) const _Tag('VERIFY', warn: true),
                    ],
                  ),
                  subtitle: Text(
                      '${r.type.label} · anchor ${u.length(r.anchorYards)} of ${r.anchorLabel}'),
                  onTap: () => Navigator.pop(context, r),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, ReelType? type) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _typeFilter == type,
          onSelected: (_) => setState(() => _typeFilter = type),
        ),
      );

  Future<void> _addCustom() async {
    final reel = await showDialog<Reel>(
      context: context,
      builder: (_) => const _CustomReelDialog(),
    );
    if (reel != null) {
      await catalog.addCustomReel(reel);
      if (mounted) setState(() {});
    }
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool warn;
  const _Tag(this.text, {this.warn = false});
  @override
  Widget build(BuildContext context) {
    final c = warn ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: c),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, color: c)),
      ),
    );
  }
}

class _CustomReelDialog extends StatefulWidget {
  const _CustomReelDialog();
  @override
  State<_CustomReelDialog> createState() => _CustomReelDialogState();
}

class _CustomReelDialogState extends State<_CustomReelDialog> {
  final _form = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _anchorDia = TextEditingController();
  final _anchorYards = TextEditingController();
  final _anchorLabel = TextEditingController(text: '50 lb mono');
  ReelType _type = ReelType.conventional;

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _anchorDia.dispose();
    _anchorYards.dispose();
    _anchorLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add custom reel'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_brand, 'Brand'),
              _field(_model, 'Model'),
              SegmentedButton<ReelType>(
                segments: const [
                  ButtonSegment(value: ReelType.conventional, label: Text('Conv.')),
                  ButtonSegment(value: ReelType.spinning, label: Text('Spin')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              _field(_anchorLabel, 'Anchor label (e.g. 50 lb mono)'),
              _field(_anchorYards, 'Anchor yards', number: true),
              _field(_anchorDia, 'Anchor line diameter (inches)', number: true),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'The anchor is one known capacity. Everything else is derived '
                  'from it via diameter².',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextFormField(
          controller: c,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(labelText: label),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (number && double.tryParse(v.trim()) == null) return 'Number';
            return null;
          },
        ),
      );

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final id = 'custom-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.pop(
      context,
      Reel(
        id: id,
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        type: _type,
        anchorDiameterIn: double.parse(_anchorDia.text.trim()),
        anchorYards: double.parse(_anchorYards.text.trim()),
        anchorLabel: _anchorLabel.text.trim(),
        source: 'user-entered',
        custom: true,
      ),
    );
  }
}
