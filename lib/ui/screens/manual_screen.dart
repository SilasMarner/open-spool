import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A quick, scrollable user guide: what the app does, how the capacity math
/// works, and how to drive each screen. Styled to match the OpenTides user
/// guide so the two apps read as one family.
class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('User Guide'),
          backgroundColor: AppTheme.navyLight,
          foregroundColor: AppTheme.cyan,
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 28 + MediaQuery.of(context).viewPadding.bottom),
          children: [
            const Text('How OpenSpool works',
                style: TextStyle(
                    color: AppTheme.cyan,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Pick a reel and a line and the app tells you how many yards the '
              'spool holds — for straight fills or backing-plus-topshot mixes. '
              'Everything is computed on your phone from a built-in catalog of '
              'manufacturer specs. No account, no tracking, no ads.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            ..._sections.map(_buildSection),
          ],
        ),
      );

  Widget _buildSection(_Section s) => Card(
        color: AppTheme.cardBg,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(s.icon, color: AppTheme.cyan, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.title,
                        style: const TextStyle(
                            color: AppTheme.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...s.body.map((b) => b.startsWith('• ')
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ',
                              style:
                                  TextStyle(color: AppTheme.cyan, fontSize: 13)),
                          Expanded(
                            child: Text(b.substring(2),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.45)),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(b,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.45)),
                    )),
            ],
          ),
        ),
      );

  static const _sections = <_Section>[
    _Section(
      Icons.calculate,
      'How the math works',
      [
        'Line takes up spool space in proportion to its length times the square '
            'of its diameter. So if you know one capacity for a reel, you can '
            'convert it to any other line by the ratio of the diameters squared.',
        'Each reel in the catalog is pinned to one manufacturer-published '
            'capacity — an “anchor” (for example 50 lb braid / 290 yd). From '
            'that the app derives a spool constant and computes the yardage for '
            'whatever line you choose.',
        'Because real fill depends on how evenly and tightly line is packed, '
            'treat every number as a close estimate, not a guarantee.',
      ],
    ),
    _Section(
      Icons.phishing,
      'Picking a reel',
      [
        'Tap the reel tile at the top of the home screen to open the reel '
            'picker. Reels are grouped by type — spinning and conventional — '
            'and you can search by brand or model.',
        'The tile shows the reel’s anchor capacity so you can see what the '
            'estimate is built from.',
        '• Don’t see your reel? Add it as a custom reel with one known '
            'capacity (line test, diameter, and yards) and the app handles the '
            'rest.',
      ],
    ),
    _Section(
      Icons.timeline,
      'Picking a line',
      [
        'Open a line picker and filter by type or brand. Diameter is the '
            'number that drives the result, so the catalog stores a real '
            'published diameter for each line and test.',
        'Four line types are supported:',
        '• Mono — monofilament.',
        '• Fluorocarbon — 100% fluoro leader/topshot material.',
        '• Braid (solid) — standard round/solid braided superline.',
        '• Braid (hollow) — hollow-core braid you can splice for wind-on '
            'leaders and topshots.',
        '• Add a custom line with its diameter if a product isn’t listed.',
      ],
    ),
    _Section(
      Icons.layers,
      'Straight, Topshot, Backing/Topshot',
      [
        'Step 2 picks how you’re filling the spool — three options:',
        '• Straight — one line fills the whole spool. The result is simply how '
            'many yards of that line the reel holds.',
        '• Topshot — set your topshot length and the backing auto-fills the '
            'rest of the spool. Best for a leader/topshot over backing when you '
            'only care about the topshot.',
        '• Backing/Topshot — set either length and the other auto-adjusts so '
            'the two together fill the spool. Type the backing you have on hand '
            'and it tells you the topshot that tops it off (or vice versa).',
        'If a length is larger than the spool can hold, the result card flags '
            'an overflow so you can shorten it.',
      ],
    ),
    _Section(
      Icons.straighten,
      'Reading the result',
      [
        'The result card shows the yardage for each segment, plus how full the '
            'spool is versus its anchor capacity.',
        'A “computed fill” label marks the segment the app solved for; “fixed” '
            'marks the length you entered.',
        '• An “unverified inputs” note appears when the reel or a line you '
            'picked is tagged VERIFY — its spec wasn’t confirmed against a '
            'primary manufacturer chart, so the number is a best estimate.',
      ],
    ),
    _Section(
      Icons.star_outline,
      'Favorites & sharing',
      [
        'Built a setup you like? Tap Save favorite (the button appears once a '
            'reel is selected) and give it a name. It’s stored on your phone.',
        'Reopen favorites from the bookmark icon in the top bar — tap one to '
            'load the reel, mode, lines, and fixed length back into the '
            'calculator.',
        '• Share a result anytime: tap Share on the result card for the setup '
            'you’re looking at, or the share icon next to any saved favorite. '
            'The summary goes out through your phone’s share sheet — email, '
            'text, or any messaging app.',
      ],
    ),
    _Section(
      Icons.tune,
      'Units & tips',
      [
        '• Switch between Standard (yd / lb / in) and Metric (m / kg / mm) in '
            'Settings — every figure reformats instantly.',
        '• Catalog entries are manufacturer-published specs; ones tagged '
            'VERIFY are commonly-cited figures awaiting confirmation.',
        '• Numbers are estimates — confirm the real fill the first time you '
            'spool up and adjust your topshot length if needed.',
      ],
    ),
    _Section(
      Icons.alternate_email,
      'Contact & contribute',
      [
        'This catalog is a work in progress. If you spot a wrong number, know a '
            'line’s real published diameter, or want a reel or line added, send '
            'it over and it’ll go into a future update.',
        '• Email the author: openspool.sandbar377@passmail.com',
        '• Especially helpful: confirmed line diameters for entries tagged '
            'VERIFY — the author is collecting these from the manufacturers.',
        '• Questions about the math or a result are welcome too.',
        'Settings has an “Email the author” button that opens your email app '
            'with the address filled in.',
      ],
    ),
  ];
}

class _Section {
  final IconData icon;
  final String title;
  final List<String> body;
  const _Section(this.icon, this.title, this.body);
}
