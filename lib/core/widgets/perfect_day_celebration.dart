import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_feedback.dart';

class PerfectDayCelebration extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const PerfectDayCelebration({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    AppFeedback.playMilestone();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => PerfectDayCelebration(
        title: title,
        message: message,
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  State<PerfectDayCelebration> createState() => _PerfectDayCelebrationState();
}

class _PerfectDayCelebrationState extends State<PerfectDayCelebration> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    // Generate 60 confetti particles
    final colors = [
      const Color(0xFF10B981), // Emerald
      const Color(0xFF0F766E), // Teal
      const Color(0xFFF59E0B), // Gold
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF38BDF8), // Sky
    ];

    for (int i = 0; i < 60; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _rnd.nextDouble(),
          y: -_rnd.nextDouble() * 0.4,
          speed: 0.4 + _rnd.nextDouble() * 0.7,
          size: 6.0 + _rnd.nextDouble() * 7.0,
          color: colors[_rnd.nextInt(colors.length)],
          rotation: _rnd.nextDouble() * 2 * pi,
          rotationSpeed: (_rnd.nextDouble() - 0.5) * 8.0,
          drift: (_rnd.nextDouble() - 0.5) * 0.3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Falling Confetti Animation Layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),

          // Central Celebratory Card
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Trophy Badge
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF08A), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    PhosphorIconsFill.trophy,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'অসাধারণ! ধন্যবাদ 🎉',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final Color color;
  double rotation;
  final double rotationSpeed;
  final double drift;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.drift,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + p.speed * progress) * size.height;
      final currentX = (p.x + p.drift * progress) * size.width;
      final currentRotation = p.rotation + p.rotationSpeed * progress;

      if (currentY > size.height + 20) continue;

      final paint = Paint()..color = p.color;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      // Draw confetti ribbon/rect
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
