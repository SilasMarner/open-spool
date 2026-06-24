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
  final bool unverified;
  const ComputedResult({
    required this.reel,
    required this.rows,
    this.fillFraction,
    this.overflow = false,
    this.unverified = false,
  });
}

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
  return ComputedResult(
    reel: reel,
    rows: [
      ResultLine('Topshot — ${topshot.displayName}', r.topshotYards,
          sub: topFixed ? 'fixed' : 'computed fill'),
      ResultLine('Backing — ${backing.displayName}', r.backingYards,
          sub: topFixed ? 'computed fill' : 'fixed'),
    ],
    fillFraction: r.fillFraction,
    overflow: r.overflow,
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

  // Whichever segment carries a fixedYards is the pinned one.
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
    b.writeln('Note: the fixed line alone overfills this spool.');
  } else if (r.fillFraction != null) {
    b.writeln('Spool fill: ~${(r.fillFraction! * 100).toStringAsFixed(0)}%');
  }
  b.writeln();
  b.writeln('Estimate from the diameter-squared model — verify on the spool.');
  if (r.unverified) {
    b.writeln('Heads up: uses an unverified catalog spec (tagged VERIFY).');
  }
  b.writeln('Shared from Reel Capacity Planner');
  return b.toString().trimRight();
}
