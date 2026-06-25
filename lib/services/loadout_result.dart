import '../app_state.dart';
import '../models/line.dart';
import '../models/line_segment.dart';
import '../models/loadout.dart';
import '../models/reel.dart';
import 'capacity_calculator.dart';
import 'unit_converter.dart';

/// One labelled line in a computed result (reel + segment yardage), decoupled
/// from any widget so it can feed both the result card and the share text.
class ResultLine {
  final String label;
  final double yards;
  final String sub;
  const ResultLine(this.label, this.yards, {this.sub = ''});
}

/// A fully computed capacity result. Built once, then rendered as a card and/or
/// turned into a shareable summary.
class ComputedResult {
  final Reel reel;
  final List<ResultLine> rows;
  final double? fillFraction;
  final bool overflow;

  /// Custom message shown when [overflow] is true; null falls back to the
  /// card's default ("the fixed line alone overfills").
  final String? overflowText;
  final bool unverified;
  const ComputedResult({
    required this.reel,
    required this.rows,
    this.fillFraction,
    this.overflow = false,
    this.overflowText,
    this.unverified = false,
  });
}

/// Fraction of the spool's rated volume a [yards] run of [line] occupies. Lets
/// the result card explain *why* a fat topshot leaves little room for backing.
double _spoolShare(double yards, Line line, Reel reel) {
  if (reel.spoolK <= 0) return 0;
  return yards * volPerYard(line.diameterIn, packingFactor: line.packingFactor) /
      reel.spoolK;
}

String _pct(double fraction) => '~${(fraction * 100).round()}% of spool';

/// Straight (single-line) fill.
ComputedResult computeStraight({required Reel reel, required Line line}) {
  final yards = straightYards(
    spoolK: reel.spoolK,
    diameterIn: line.diameterIn,
    packingFactor: line.packingFactor,
  );
  return ComputedResult(
    reel: reel,
    rows: [ResultLine(line.displayName, yards, sub: line.type.shortLabel)],
    fillFraction: 1.0,
    unverified: reel.unverified || line.unverified,
  );
}

/// Topshot mix. [fixedYards] is in engine units (yards).
ComputedResult computeMix({
  required Reel reel,
  required Line topshot,
  required Line backing,
  required FixedSegment fixed,
  required double fixedYards,
}) {
  final r = mixFill(
    spoolK: reel.spoolK,
    topDiameterIn: topshot.diameterIn,
    topPackingFactor: topshot.packingFactor,
    backDiameterIn: backing.diameterIn,
    backPackingFactor: backing.packingFactor,
    fixed: fixed,
    fixedYards: fixedYards,
  );
  final topFixed = fixed == FixedSegment.topshot;
  final topShare = _spoolShare(r.topshotYards, topshot, reel);
  final backShare = _spoolShare(r.backingYards, backing, reel);
  return ComputedResult(
    reel: reel,
    rows: [
      ResultLine('Topshot — ${topshot.displayName}', r.topshotYards,
          sub: '${topFixed ? 'fixed' : 'computed fill'} · ${_pct(topShare)}'),
      ResultLine('Backing — ${backing.displayName}', r.backingYards,
          sub: '${topFixed ? 'computed fill' : 'fixed'} · ${_pct(backShare)}'),
    ],
    fillFraction: r.fillFraction,
    overflow: r.overflow,
    unverified: reel.unverified || topshot.unverified || backing.unverified,
  );
}

/// Topshot mix with BOTH lengths set explicitly. [topYards]/[backYards] are in
/// engine units (yards). Flags an overflow when the two exceed the spool.
ComputedResult computeMixBoth({
  required Reel reel,
  required Line topshot,
  required Line backing,
  required double topYards,
  required double backYards,
}) {
  final r = mixBoth(
    spoolK: reel.spoolK,
    topDiameterIn: topshot.diameterIn,
    topPackingFactor: topshot.packingFactor,
    backDiameterIn: backing.diameterIn,
    backPackingFactor: backing.packingFactor,
    topYards: topYards,
    backYards: backYards,
  );
  final topShare = _spoolShare(topYards, topshot, reel);
  final backShare = _spoolShare(backYards, backing, reel);
  return ComputedResult(
    reel: reel,
    rows: [
      ResultLine('Topshot — ${topshot.displayName}', topYards,
          sub: 'you set · ${_pct(topShare)}'),
      ResultLine('Backing — ${backing.displayName}', backYards,
          sub: 'you set · ${_pct(backShare)}'),
    ],
    fillFraction: r.fillFraction,
    overflow: r.overflow,
    overflowText: r.overflow
        ? 'These two lengths need ~${(r.fillFraction * 100).toStringAsFixed(0)}% '
            'of the spool — more than it holds. Trim the topshot or backing.'
        : null,
    unverified: reel.unverified || topshot.unverified || backing.unverified,
  );
}

/// Compute a saved loadout, resolving its ids against the catalog. Returns null
/// if the reel or a referenced line can no longer be found.
ComputedResult? computeLoadout(Loadout l) {
  final reel = catalog.reel(l.reelId);
  if (reel == null) return null;

  if (l.mode == LoadoutMode.straight) {
    final seg = l.segments.isNotEmpty ? l.segments.first : null;
    final line = seg == null ? null : catalog.line(seg.lineId);
    if (line == null) return null;
    return computeStraight(reel: reel, line: line);
  }

  LineSegment? topSeg;
  LineSegment? backSeg;
  for (final s in l.segments) {
    if (s.role == SegmentRole.topshot) {
      topSeg = s;
    } else {
      backSeg = s;
    }
  }
  if (topSeg == null || backSeg == null) return null;
  final top = catalog.line(topSeg.lineId);
  final back = catalog.line(backSeg.lineId);
  if (top == null || back == null) return null;

  // Both segments pinned → both-lengths mode; otherwise the pinned one fills.
  if (topSeg.fixedYards != null && backSeg.fixedYards != null) {
    return computeMixBoth(
      reel: reel,
      topshot: top,
      backing: back,
      topYards: topSeg.fixedYards!,
      backYards: backSeg.fixedYards!,
    );
  }
  final fixed = topSeg.fixedYards != null
      ? FixedSegment.topshot
      : FixedSegment.backing;
  final fixedYards = topSeg.fixedYards ?? backSeg.fixedYards ?? 0;
  return computeMix(
    reel: reel,
    topshot: top,
    backing: back,
    fixed: fixed,
    fixedYards: fixedYards,
  );
}

/// Build a shareable plain-text summary in the active unit system, suitable for
/// the system share sheet (email subject/body, SMS, messaging apps, etc.).
String shareSummary(ComputedResult r, UnitSystem u, {String? title}) {
  final b = StringBuffer();
  b.writeln('Reel line plan${title != null ? ' — $title' : ''}');
  b.writeln();
  b.writeln('Reel: ${r.reel.displayName} (${r.reel.type.label})');
  for (final row in r.rows) {
    final sub = row.sub.isNotEmpty ? ' (${row.sub})' : '';
    b.writeln('${row.label}: ${u.length(row.yards)}$sub');
  }
  if (r.overflow) {
    b.writeln('Note: ${r.overflowText ?? 'the fixed line alone overfills this spool.'}');
  } else if (r.fillFraction != null) {
    b.writeln('Spool fill: ~${(r.fillFraction! * 100).toStringAsFixed(0)}%');
  }
  b.writeln();
  b.writeln('Estimate from the diameter-squared model — verify on the spool.');
  if (r.unverified) {
    b.writeln('Heads up: uses an unverified catalog spec (tagged VERIFY).');
  }
  b.writeln('Shared from OpenSpool');
  return b.toString().trimRight();
}
