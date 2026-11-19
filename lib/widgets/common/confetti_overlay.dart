import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Launches a non-blocking 60fps confetti celebration burst over the current screen.
void showConfettiCelebration(BuildContext context) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ConfettiOverlayWidget(
      onFinished: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _ConfettiParticle {
  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double size;
  final double rotation;
  final double vRotation;
  final Color color;
  final bool isCircle;

  const _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.vRotation,
    required this.color,
    required this.isCircle,
  });
}

class _ConfettiOverlayWidget extends StatefulWidget {
  final VoidCallback onFinished;

  const _ConfettiOverlayWidget({required this.onFinished});

  @override
  State<_ConfettiOverlayWidget> createState() => _ConfettiOverlayWidgetState();
}

class _ConfettiOverlayWidgetState extends State<_ConfettiOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_ConfettiParticle> _particles;

  static const _palette = [
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFFBBF24), // Gold
  ];

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(72, (i) {
      final fromLeft = i.isEven;
      final angle = fromLeft
          ? (-math.pi / 2.2) + (rng.nextDouble() * 0.9)
          : (-math.pi / 1.8) - (rng.nextDouble() * 0.9);
      final speed = 280 + rng.nextDouble() * 420;
      return _ConfettiParticle(
        startX: fromLeft ? 0.15 + rng.nextDouble() * 0.25 : 0.60 + rng.nextDouble() * 0.25,
        startY: 0.28 + rng.nextDouble() * 0.12,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 120,
        size: 6 + rng.nextDouble() * 7,
        rotation: rng.nextDouble() * math.pi * 2,
        vRotation: (rng.nextDouble() - 0.5) * 10,
        color: _palette[rng.nextInt(_palette.length)],
        isCircle: rng.nextBool(),
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFinished();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          size: MediaQuery.sizeOf(context),
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _ctrl.value,
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2.5; // seconds
    const gravity = 680.0;
    final opacity = progress > 0.72
        ? (1.0 - ((progress - 0.72) / 0.28)).clamp(0.0, 1.0)
        : 1.0;

    for (final p in particles) {
      final drag = 1.0 - (0.18 * progress);
      final x = (p.startX * size.width) + (p.vx * t * drag);
      final y = (p.startY * size.height) + (p.vy * t) + (0.5 * gravity * t * t);
      if (y > size.height + 40) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.vRotation * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        final tilt = math.cos(t * 7 + p.rotation).abs().clamp(0.3, 1.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 1.35,
              height: p.size * 0.65 * tilt,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
