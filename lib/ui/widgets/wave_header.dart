import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Animated cyan wave band shown at the top of the calculator, matching the
/// OpenTides "Live NOAA Conditions" header so the two apps read as one family.
/// Purely decorative — a moving set of sine waves over the navy background with
/// a short tagline.
class WaveHeader extends StatefulWidget {
  /// Optional second line under the tagline (e.g. the picked reel).
  final String? subtitle;
  const WaveHeader({super.key, this.subtitle});

  @override
  State<WaveHeader> createState() => _WaveHeaderState();
}

class _WaveHeaderState extends State<WaveHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          painter: _WavePainter(_ctrl.value),
          child: SizedBox(
            height: 100,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Saltwater line-capacity planner',
                    style: TextStyle(color: AppTheme.cyanLight, fontSize: 13),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(color: AppTheme.cyan, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}

class _WavePainter extends CustomPainter {
  final double phase;
  _WavePainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final waves = [
      (AppTheme.cyan.withValues(alpha: 0.25), 0.0, 18.0, size.height * 0.72),
      (AppTheme.cyan.withValues(alpha: 0.18), 0.4, 14.0, size.height * 0.78),
      (AppTheme.cyanLight.withValues(alpha: 0.12), 0.7, 10.0, size.height * 0.82),
    ];

    for (final (color, offset, amp, baseline) in waves) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      final path = Path();
      path.moveTo(0, baseline);
      for (var x = 0.0; x <= size.width; x++) {
        final y = baseline +
            amp * sin((x / size.width * 2 * pi) + (phase + offset) * 2 * pi);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.phase != phase;
}
