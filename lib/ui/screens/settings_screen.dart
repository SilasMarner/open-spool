import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../services/unit_converter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Units', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioGroup<UnitSystem>(
            groupValue: settings.units,
            onChanged: (v) => settings.setUnits(v!),
            child: const Column(
              children: [
                RadioListTile<UnitSystem>(
                  title: Text('US (yd / lb / in)'),
                  subtitle: Text('Yards, pounds, inches'),
                  value: UnitSystem.us,
                ),
                RadioListTile<UnitSystem>(
                  title: Text('Metric (m / kg / mm)'),
                  subtitle: Text('Meters, kilograms, millimeters'),
                  value: UnitSystem.metric,
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'How it works',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Each reel is anchored to one published capacity. Any line is then '
              'converted by the diameter-squared rule: a spool holds yards '
              'proportional to 1 / diameter². Topshot mixes subtract the fixed '
              'line\'s volume and fill the rest with the other line.\n\n'
              'Results are estimates — actual fill depends on how evenly the line '
              'is laid and how tightly it is packed. Specs tagged VERIFY in the '
              'catalog are approximate and should be confirmed against the '
              'manufacturer before you trust the numbers.',
            ),
          ),
        ],
      ),
    );
  }
}
