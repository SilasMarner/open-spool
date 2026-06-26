/// Pure line-capacity math. **No Flutter / IO dependencies** so it stays unit
/// testable on the Dart VM.
///
/// ## Model
/// A wound line occupies volume proportional to (length × diameter²). A reel's
/// usable spool volume is captured as a single constant:
///
///     K = anchorYards × anchorDiameter²        (anchorDiameter in inches)
///
/// derived from ONE published capacity for that reel. Any other line of
/// diameter `d` then fills:
///
///     yards = K / d²
///
/// Each line carries a [packingFactor] that scales its effective cross-section.
/// Published braid diameters understate the volume the line really occupies on
/// a packed spool (hollow core most of all), so braid types use a factor > 1 to
/// pull capacity down to real-world numbers. A factor of 1.0 means the stated
/// diameter is taken at face value (mono / fluoro). The spool constant uses the
/// anchor line's factor too — see [spoolConstant] — so a reel anchored on braid
/// resolves to the same true spool volume a mono anchor would.
library;

/// Which segment in a topshot mix the user pinned to a fixed length.
enum FixedSegment { topshot, backing }

/// Effective volume-per-yard for a line: diameter² scaled by [packingFactor].
double volPerYard(double diameterIn, {double packingFactor = 1.0}) =>
    diameterIn * diameterIn * packingFactor;

/// The spool constant K for a reel from one known capacity anchor.
///
/// [anchorPackingFactor] is the packing factor of the line the capacity was
/// published for (1.0 for mono/fluoro, >1 for braid). Including it keeps a
/// braid-anchored reel's true spool volume consistent with a mono anchor;
/// without it, braid's optimistic stated diameter would understate K and skew
/// every conversion off that reel.
double spoolConstant({
  required double anchorYards,
  required double anchorDiameterIn,
  double anchorPackingFactor = 1.0,
}) =>
    anchorYards * anchorDiameterIn * anchorDiameterIn * anchorPackingFactor;

/// Yards of a single line that fills the whole spool (straight braid or mono).
double straightYards({
  required double spoolK,
  required double diameterIn,
  double packingFactor = 1.0,
}) =>
    spoolK / volPerYard(diameterIn, packingFactor: packingFactor);

/// Result of a two-segment (backing + topshot) fill.
class MixResult {
  /// Yards of topshot on the spool.
  final double topshotYards;

  /// Yards of backing on the spool.
  final double backingYards;

  /// True when the pinned segment alone meets or exceeds spool volume, leaving
  /// no room for the other line.
  final bool overflow;

  /// Total used volume / K. ≈1.0 for a normal computed fill; >1.0 signals the
  /// fixed segment alone overflows the spool.
  final double fillFraction;

  const MixResult({
    required this.topshotYards,
    required this.backingYards,
    required this.overflow,
    required this.fillFraction,
  });
}

/// Solve a backing + topshot mix. Pin one segment to [fixedYards]; the other is
/// filled with whatever spool volume remains.
MixResult mixFill({
  required double spoolK,
  required double topDiameterIn,
  double topPackingFactor = 1.0,
  required double backDiameterIn,
  double backPackingFactor = 1.0,
  required FixedSegment fixed,
  required double fixedYards,
}) {
  final topVpy = volPerYard(topDiameterIn, packingFactor: topPackingFactor);
  final backVpy = volPerYard(backDiameterIn, packingFactor: backPackingFactor);

  if (fixed == FixedSegment.topshot) {
    final topVol = fixedYards * topVpy;
    final remaining = spoolK - topVol;
    if (remaining <= 0) {
      return MixResult(
        topshotYards: fixedYards,
        backingYards: 0,
        overflow: true,
        fillFraction: topVol / spoolK,
      );
    }
    final backingYards = remaining / backVpy;
    return MixResult(
      topshotYards: fixedYards,
      backingYards: backingYards,
      overflow: false,
      fillFraction: (topVol + backingYards * backVpy) / spoolK,
    );
  } else {
    final backVol = fixedYards * backVpy;
    final remaining = spoolK - backVol;
    if (remaining <= 0) {
      return MixResult(
        topshotYards: 0,
        backingYards: fixedYards,
        overflow: true,
        fillFraction: backVol / spoolK,
      );
    }
    final topshotYards = remaining / topVpy;
    return MixResult(
      topshotYards: topshotYards,
      backingYards: fixedYards,
      overflow: false,
      fillFraction: (topshotYards * topVpy + backVol) / spoolK,
    );
  }
}

/// Both segment lengths set explicitly (no auto-fill). Reports total fill and
/// flags [overflow] when the two together need more than the spool holds.
MixResult mixBoth({
  required double spoolK,
  required double topDiameterIn,
  double topPackingFactor = 1.0,
  required double backDiameterIn,
  double backPackingFactor = 1.0,
  required double topYards,
  required double backYards,
}) {
  final topVol = topYards * volPerYard(topDiameterIn, packingFactor: topPackingFactor);
  final backVol = backYards * volPerYard(backDiameterIn, packingFactor: backPackingFactor);
  final fill = (topVol + backVol) / spoolK;
  // Allow a 1% slop so a whole-yard rounding on an auto-filled segment doesn't
  // tip a "just full" spool into a false overflow warning. A real overflow (one
  // length alone exceeding the spool) clears this easily.
  return MixResult(
    topshotYards: topYards,
    backingYards: backYards,
    overflow: fill > 1.01,
    fillFraction: fill,
  );
}
