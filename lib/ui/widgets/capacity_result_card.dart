import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../services/unit_converter.dart';

/// A single labelled line in the result (e.g. "Topshot — 300 yd").
class ResultRow {
  final String label;
  final double yards;
  final String sub;

  /// Line test rating (lb); when set, shown as "· 80 lb" (kg in metric) after
  /// the label so the result names the line's strength, not just its product.
  final double? lbTest;
  const ResultRow(this.label, this.yards, {this.sub = '', this.lbTest});
}

/// Shows the computed capacity. Big headline number(s) plus an estimate note.
class CapacityResultCard extends StatelessWidget {
  final List<ResultRow> rows;
  final double? fillFraction;
  final bool overflow;

  /// Overrides the default overflow message when provided.
  final String? overflowText;
  final bool unverifiedInputs;

  /// When provided, a Share button is shown that hands the result to the system
  /// share sheet (email, text, messaging, etc.).
  final VoidCallback? onShare;

  /// When provided, a "Save favorite" button is shown so the user can persist
  /// the current setup without hunting for the AppBar star.
  final VoidCallback? onSave;

  const CapacityResultCard({
    super.key,
    required this.rows,
    this.fillFraction,
    this.overflow = false,
    this.overflowText,
    this.unverifiedInputs = false,
    this.onShare,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final u = settings.units;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capacity',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                )),
            const SizedBox(height: 12),
            for (final r in rows) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                        r.lbTest != null
                            ? '${r.label} · ${u.test(r.lbTest!)}'
                            : r.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        )),
                  ),
                  Text(
                    u.length(r.yards),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              if (r.sub.isNotEmpty)
                Text(r.sub,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    )),
              const SizedBox(height: 8),
            ],
            const Divider(height: 16),
            if (overflow)
              _Note(
                icon: Icons.error_outline,
                color: theme.colorScheme.error,
                text: overflowText ??
                    'The fixed line alone overfills this spool. Reduce its '
                        'length or pick a thinner line.',
              )
            else if (fillFraction != null)
              _Note(
                icon: Icons.donut_large,
                color: theme.colorScheme.onPrimaryContainer,
                text: 'Spool filled to ~${(fillFraction! * 100).toStringAsFixed(0)}% '
                    'of its rated volume.',
              ),
            _Note(
              icon: Icons.straighten,
              color: theme.colorScheme.onPrimaryContainer,
              text: 'Estimate from the diameter² model — verify on the spool; '
                  'real fill varies with line lay and tension.',
            ),
            if (unverifiedInputs)
              _Note(
                icon: Icons.warning_amber,
                color: theme.colorScheme.error,
                text: 'Uses an unverified catalog spec (tagged VERIFY). '
                    'Confirm the diameter / anchor before trusting this.',
              ),
            if (onSave != null || onShare != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onSave != null)
                    TextButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Save favorite'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  if (onShare != null)
                    TextButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('Share'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Note({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
