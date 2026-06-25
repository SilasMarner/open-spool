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

  /// The chosen line type. Null *and* not-yet-chosen → show the type chooser.
  /// Null *and* chosen → "Show all" was tapped, so list every type.
  LineType? _type;
  bool _typeChosen = false;

  List<Line> get _filtered {
    final q = _query.toLowerCase();
    return catalog.lines.where((l) {
      if (_type != null && l.type != _type) return false;
      if (q.isEmpty) return true;
      return l.displayName.toLowerCase().contains(q) ||
          l.lbTest.toStringAsFixed(0).contains(q);
    }).toList()
      ..sort((a, b) {
        final n = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
        return n != 0 ? n : a.lbTest.compareTo(b.lbTest);
      });
  }

  /// Back arrow: from the list, step back to the type chooser; from the
  /// chooser, leave the picker entirely.
  void _back() {
    if (_typeChosen) {
      setState(() {
        _typeChosen = false;
        _query = '';
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _chooseType(LineType? type) =>
      setState(() {
        _type = type;
        _typeChosen = true;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
        title: Text(_typeChosen
            ? (_type == null ? 'All lines' : '${_type!.shortLabel} lines')
            : widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add custom line',
            onPressed: _addCustom,
          ),
        ],
      ),
      body: _typeChosen ? _listBody() : _typeChooser(),
    );
  }

  // ---- Stage 1: pick the line type ----------------------------------------

  Widget _typeChooser() => ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Text('What kind of line?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text('Pick a type and only those lines show up.',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
          ),
          _typeOption(LineType.mono, Icons.water_drop_outlined),
          _typeOption(LineType.fluoro, Icons.invert_colors_outlined),
          _typeOption(LineType.braidSolid, Icons.timeline),
          _typeOption(LineType.braidHollow, Icons.linear_scale),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => _chooseType(null),
              child: const Text('Show all lines instead'),
            ),
          ),
        ],
      );

  Widget _typeOption(LineType type, IconData icon) {
    final count = catalog.lines.where((l) => l.type == type).length;
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(type.label),
        subtitle: Text('$count lines'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _chooseType(type),
      ),
    );
  }

  // ---- Stage 2: the filtered list -----------------------------------------

  Widget _listBody() {
    final u = settings.units;
    final list = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search (brand or test)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 12, 6),
            child: TextButton.icon(
              onPressed: () => setState(() {
                _typeChosen = false;
                _query = '';
              }),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(_type == null
                  ? 'Showing all types · change'
                  : 'Showing ${_type!.shortLabel} · change type'),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? _EmptyState(
                  icon: Icons.search_off,
                  message: 'No lines match.',
                  hint: 'Try a different search, or tap + to add a custom line.',
                )
              : ListView.builder(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final l = list[i];
                    return ListTile(
                      leading: const Icon(Icons.timeline),
                      title: Row(
                        children: [
                          Flexible(
                              child: Text(
                                  '${l.displayName} · ${u.test(l.lbTest)}')),
                          if (l.custom) const _Tag('custom'),
                          if (l.unverified) const _Tag('VERIFY', warn: true),
                        ],
                      ),
                      subtitle: Text(
                          '${l.type.shortLabel} · ${u.diameter(l.diameterIn)}'),
                      onTap: () => Navigator.pop(context, l),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _addCustom() async {
    final line = await showDialog<Line>(
      context: context,
      builder: (_) => const _CustomLineDialog(),
    );
    if (line != null) {
      await catalog.addCustomLine(line);
      // Land in the new line's type list so it's right there to pick.
      if (mounted) {
        setState(() {
          _type = line.type;
          _typeChosen = true;
          _query = '';
        });
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String hint;
  const _EmptyState(
      {required this.icon, required this.message, required this.hint});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.white38),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(hint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ],
        ),
      ),
    );
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
