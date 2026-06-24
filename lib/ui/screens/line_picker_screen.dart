import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/line.dart';
import '../../services/unit_converter.dart';

/// Searchable line list with type filter; returns the chosen [Line].
class LinePickerScreen extends StatefulWidget {
  /// Optional heading, e.g. "Select topshot".
  final String title;
  const LinePickerScreen({super.key, this.title = 'Select line'});

  @override
  State<LinePickerScreen> createState() => _LinePickerScreenState();
}

class _LinePickerScreenState extends State<LinePickerScreen> {
  String _query = '';
  LineType? _typeFilter;

  List<Line> get _filtered {
    final q = _query.toLowerCase();
    return catalog.lines.where((l) {
      if (_typeFilter != null && l.type != _typeFilter) return false;
      if (q.isEmpty) return true;
      return l.displayName.toLowerCase().contains(q) ||
          l.lbTest.toStringAsFixed(0).contains(q);
    }).toList()
      ..sort((a, b) {
        final n = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
        return n != 0 ? n : a.lbTest.compareTo(b.lbTest);
      });
  }

  @override
  Widget build(BuildContext context) {
    final u = settings.units;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add custom line',
            onPressed: _addCustom,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search lines (brand or test)',
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
                _filterChip('Mono', LineType.mono),
                _filterChip('Solid braid', LineType.braidSolid),
                _filterChip('Hollow braid', LineType.braidHollow),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final l = _filtered[i];
                return ListTile(
                  leading: const Icon(Icons.timeline),
                  title: Row(
                    children: [
                      Flexible(child: Text('${l.displayName} · ${u.test(l.lbTest)}')),
                      if (l.custom) const _Tag('custom'),
                      if (l.unverified) const _Tag('VERIFY', warn: true),
                    ],
                  ),
                  subtitle: Text('${l.type.shortLabel} · ${u.diameter(l.diameterIn)}'),
                  onTap: () => Navigator.pop(context, l),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, LineType? type) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _typeFilter == type,
          onSelected: (_) => setState(() => _typeFilter = type),
        ),
      );

  Future<void> _addCustom() async {
    final line = await showDialog<Line>(
      context: context,
      builder: (_) => const _CustomLineDialog(),
    );
    if (line != null) {
      await catalog.addCustomLine(line);
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

class _CustomLineDialog extends StatefulWidget {
  const _CustomLineDialog();
  @override
  State<_CustomLineDialog> createState() => _CustomLineDialogState();
}

class _CustomLineDialogState extends State<_CustomLineDialog> {
  final _form = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _product = TextEditingController();
  final _test = TextEditingController();
  final _dia = TextEditingController();
  LineType _type = LineType.braidSolid;

  @override
  void dispose() {
    _brand.dispose();
    _product.dispose();
    _test.dispose();
    _dia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add custom line'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_brand, 'Brand'),
              _field(_product, 'Product'),
              DropdownButtonFormField<LineType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: LineType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (t) => setState(() => _type = t ?? _type),
              ),
              _field(_test, 'Test (lb)', number: true),
              _field(_dia, 'Diameter (inches)', number: true),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Diameter drives the whole calculation — use the manufacturer '
                  'spec for best accuracy.',
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
    final id = 'customline-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.pop(
      context,
      Line(
        id: id,
        brand: _brand.text.trim(),
        product: _product.text.trim(),
        type: _type,
        lbTest: double.parse(_test.text.trim()),
        diameterIn: double.parse(_dia.text.trim()),
        source: 'user-entered',
        custom: true,
      ),
    );
  }
}
