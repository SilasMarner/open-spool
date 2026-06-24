import 'package:flutter_test/flutter_test.dart';
import 'package:reel_planner/services/capacity_calculator.dart';

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
}
