import 'dart:math';
import 'package:flutter/material.dart';
import 'package:solo_test/models/game_theme_model.dart';

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  double rotation;
  double rotSpeed;
  String emoji;
  double phase; // for sine wave drift

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.rotation,
    required this.rotSpeed,
    required this.emoji,
    required this.phase,
  });
}

class ParticleOverlay extends StatefulWidget {
  final GameThemeData themeData;
  final int count;

  const ParticleOverlay({
    super.key,
    required this.themeData,
    this.count = 12,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();
  }

  void _spawnParticles(Size size) {
    if (_particles.isNotEmpty) return;
    _size = size;
    final emojis = widget.themeData.particles;
    for (int i = 0; i < widget.count; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble() * size.width,
        y: _rng.nextDouble() * size.height,
        vx: (_rng.nextDouble() - 0.5) * 0.6,
        vy: -0.3 - _rng.nextDouble() * 0.5,
        size: 14 + _rng.nextDouble() * 14,
        opacity: 0.3 + _rng.nextDouble() * 0.55,
        rotation: _rng.nextDouble() * 2 * pi,
        rotSpeed: (_rng.nextDouble() - 0.5) * 0.04,
        emoji: emojis[_rng.nextInt(emojis.length)],
        phase: _rng.nextDouble() * 2 * pi,
      ));
    }
  }

  void _tick() {
    if (!mounted || _size == Size.zero) return;
    for (final p in _particles) {
      p.phase += 0.02;
      p.x += p.vx + sin(p.phase) * 0.4;
      p.y += p.vy;
      p.rotation += p.rotSpeed;

      // Wrap around
      if (p.y < -40) {
        p.y = _size.height + 20;
        p.x = _rng.nextDouble() * _size.width;
      }
      if (p.x < -40) p.x = _size.width + 20;
      if (p.x > _size.width + 40) p.x = -20;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _spawnParticles(size);

        return Stack(
          children: _particles.map((p) {
            return Positioned(
              left: p.x - p.size / 2,
              top: p.y - p.size / 2,
              child: Opacity(
                opacity: p.opacity.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: p.rotation,
                  child: Text(
                    p.emoji,
                    style: TextStyle(fontSize: p.size),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
