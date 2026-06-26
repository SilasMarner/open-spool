import 'package:flutter_test/flutter_test.dart';
import 'package:reel_planner/services/capacity_calculator.dart';
import 'package:reel_planner/models/line.dart';
import 'package:reel_planner/models/reel.dart';

void main() {
  group('spoolConstant + straightYards', () {
    test('K reproduces the anchor capacity', () {
      // Anchor: 700 yd of 0.037" mono.
      final k = spoolConstant(anchorYards: 700, anchorDiameterIn: 0.037);
      final yards = straightYards(spoolK: k, diameterIn: 0.037);
      expect(yards, closeTo(700, 1e-6));
    });

    test('thinner line fits more, by the diameter-squared ratio', () {
      // Same spool, switch from 0.037" mono to 0.019" braid.
      // Expected ratio = (0.037/0.019)^2.
      final k = spoolConstant(anchorYards: 700, anchorDiameterIn: 0.037);
      final braidYards = straightYards(spoolK: k, diameterIn: 0.019);
      final expected = 700 * (0.037 / 0.019) * (0.037 / 0.019);
      expect(braidYards, closeTo(expected, 1e-6));
      expect(braidYards, greaterThan(700));
    });

    test('packingFactor < 1 increases yards proportionally', () {
      final k = spoolConstant(anchorYards: 500, anchorDiameterIn: 0.030);
      final base = straightYards(spoolK: k, diameterIn: 0.030);
      final packed = straightYards(spoolK: k, diameterIn: 0.030, packingFactor: 0.9);
      expect(packed, closeTo(base / 0.9, 1e-6));
    });
  });

  group('mixFill (topshot over backing)', () {
    // Spool sized to 1000 yd of 0.030" line for round numbers.
    final k = spoolConstant(anchorYards: 1000, anchorDiameterIn: 0.030);

    test('fixed topshot leaves the rest for backing, fill ≈ 100%', () {
      final r = mixFill(
        spoolK: k,
        topDiameterIn: 0.030,
        backDiameterIn: 0.030,
        fixed: FixedSegment.topshot,
        fixedYards: 300,
      );
      expect(r.overflow, isFalse);
      // Equal diameters: backing = 1000 - 300 = 700.
      expect(r.backingYards, closeTo(700, 1e-6));
      expect(r.topshotYards, 300);
      expect(r.fillFraction, closeTo(1.0, 1e-9));
    });

    test('thinner backing under a thicker topshot fits more yards', () {
      final r = mixFill(
        spoolK: k,
        topDiameterIn: 0.030, // topshot same as anchor
        backDiameterIn: 0.015, // backing half the diameter -> 4x density
        fixed: FixedSegment.topshot,
        fixedYards: 300,
      );
      // Remaining volume after 300 yd topshot = K - 300*0.030^2.
      // backing yards = remaining / 0.015^2 = (700*0.030^2)/0.015^2 = 700*4 = 2800.
      expect(r.backingYards, closeTo(2800, 1e-6));
    });

    test('pinning the backing solves for the topshot', () {
      final r = mixFill(
        spoolK: k,
        topDiameterIn: 0.030,
        backDiameterIn: 0.030,
        fixed: FixedSegment.backing,
        fixedYards: 600,
      );
      expect(r.topshotYards, closeTo(400, 1e-6));
    });

    test('topshot alone exceeding the spool flags overflow', () {
      final r = mixFill(
        spoolK: k,
        topDiameterIn: 0.030,
        backDiameterIn: 0.030,
        fixed: FixedSegment.topshot,
        fixedYards: 1200,
      );
      expect(r.overflow, isTrue);
      expect(r.backingYards, 0);
      expect(r.fillFraction, greaterThan(1.0));
    });
  });

  group('braid packing calibration', () {
    test('per-type default factors', () {
      expect(LineType.mono.defaultPackingFactor, 1.0);
      expect(LineType.fluoro.defaultPackingFactor, 1.0);
      expect(LineType.braidSolid.defaultPackingFactor, 1.2);
      expect(LineType.braidHollow.defaultPackingFactor, 1.85);
    });

    test('catalog JSON without packing_factor falls back to the type default', () {
      final hollow = Line.fromJson({
        'id': 'x', 'brand': 'Momoi', 'product': 'G3 Hollow',
        'type': 'braid_hollow', 'lb_test': 100, 'diameter_in': 0.0185,
      });
      expect(hollow.packingFactor, 1.85);
      final mono = Line.fromJson({
        'id': 'y', 'brand': 'Ande', 'product': 'Premium',
        'type': 'mono', 'lb_test': 80, 'diameter_in': 0.035,
      });
      expect(mono.packingFactor, 1.0);
    });

    test('explicit packing_factor in JSON overrides the default', () {
      final l = Line.fromJson({
        'id': 'z', 'brand': 'X', 'product': 'Y', 'type': 'braid_hollow',
        'lb_test': 100, 'diameter_in': 0.0185, 'packing_factor': 1.5,
      });
      expect(l.packingFactor, 1.5);
    });

    test('reel anchor packing factor inferred from the anchor label', () {
      Reel r(String label) => Reel(
            id: 'r', brand: 'Avet', model: 'M', type: ReelType.conventional,
            anchorDiameterIn: 0.035, anchorYards: 1000, anchorLabel: label,
          );
      expect(r('80 lb mono').anchorPackingFactor, 1.0);
      expect(r('50 lb braid').anchorPackingFactor, 1.2);
      expect(r('100 lb hollow braid').anchorPackingFactor, 1.85);
    });

    test('Avet 80W (mono anchor) holds a realistic ~1900 yd of 100 lb hollow', () {
      // Regression for the over-estimate bug: published 80 lb mono / 1000 yd
      // anchor, Momoi G3 hollow 100 lb at its real 0.0185" spec.
      final reel = Reel(
        id: 'avet-trx-80w', brand: 'Avet', model: 'T-RX 80W',
        type: ReelType.conventional, anchorDiameterIn: 0.035,
        anchorYards: 1000, anchorLabel: '80 lb mono',
      );
      final hollow = Line.fromJson({
        'id': 'momoi', 'brand': 'Momoi', 'product': 'G3 Hollow',
        'type': 'braid_hollow', 'lb_test': 100, 'diameter_in': 0.0185,
      });
      final yards = straightYards(
        spoolK: reel.spoolK,
        diameterIn: hollow.diameterIn,
        packingFactor: hollow.packingFactor,
      );
      expect(yards, closeTo(1935, 25)); // was ~3579 before calibration
    });

    test('solid braid is unchanged on a braid-anchored reel (factor cancels)', () {
      // A reel rated in solid braid converts to other solid braid independent
      // of the factor — the anchor and line factors cancel.
      final reel = Reel(
        id: 'avet-sxj', brand: 'Avet', model: 'SXJ 6/3', type: ReelType.conventional,
        anchorDiameterIn: 0.014, anchorYards: 290, anchorLabel: '50 lb braid',
      );
      final otherSolid = Line.fromJson({
        'id': 's', 'brand': 'PowerPro', 'product': 'Slick',
        'type': 'braid_solid', 'lb_test': 65, 'diameter_in': 0.016,
      });
      final yards = straightYards(
        spoolK: reel.spoolK,
        diameterIn: otherSolid.diameterIn,
        packingFactor: otherSolid.packingFactor,
      );
      // Equals the naive (factor-free) diameter² conversion.
      final naive = 290 * (0.014 * 0.014) / (0.016 * 0.016);
      expect(yards, closeTo(naive, 1e-6));
    });
  });
}
