import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_state.dart';
import '../../services/unit_converter.dart';
import 'manual_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Units', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // settings is a ChangeNotifier; this screen is a pushed route the root
          // listener can't rebuild, so listen here or the radio won't move when
          // tapped (it stays on whatever value the route opened with).
          ListenableBuilder(
            listenable: settings,
            builder: (context, _) => RadioGroup<UnitSystem>(
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
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('User Guide'),
            subtitle: const Text('How the planner works, step by step'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManualScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email the author'),
            subtitle: const Text(
              'openspool.sandbar377@passmail.com\n'
              'Line corrections, verified diameters, reel/line requests, '
              'or questions',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(
              Uri(
                scheme: 'mailto',
                path: 'openspool.sandbar377@passmail.com',
                query: 'subject=OpenSpool feedback',
              ),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sailing_outlined),
            title: const Text('Also from the author: OpenTides'),
            subtitle: const Text(
              'Tide & current predictions and marine weather — free on Google Play',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(
              Uri.parse(
                'https://play.google.com/store/apps/details?id=com.mattbettinger.tides',
              ),
              mode: LaunchMode.externalApplication,
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                final label = info == null
                    ? 'OpenSpool'
                    : 'OpenSpool v${info.version} (${info.buildNumber})';
                return Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
