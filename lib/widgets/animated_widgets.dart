import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Shimmer Effect Widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color shimmerColor;
  final Duration duration;
  
  const ShimmerEffect({
    super.key,
    required this.child,
    this.shimmerColor = AppColors.goldLight,
    this.duration = const Duration(milliseconds: 2000),
  });
  
  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                widget.shimmerColor.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Pulsing Glow Widget
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minOpacity;
  final double maxOpacity;
  final double blurRadius;
  
  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = AppColors.goldAccent,
    this.minOpacity = 0.3,
    this.maxOpacity = 0.8,
    this.blurRadius = 20,
  });
  
  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: 5,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Rotating Border Widget
class RotatingBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final List<Color> gradientColors;
  
  const RotatingBorder({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = 16,
    this.gradientColors = const [
      AppColors.goldLight,
      AppColors.goldAccent,
      AppColors.eraIIEnergy,
      AppColors.goldLight,
    ],
  });
  
  @override
  State<RotatingBorder> createState() => _RotatingBorderState();
}

class _RotatingBorderState extends State<RotatingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RotatingBorderPainter(
            rotation: _controller.value * 2 * pi,
            colors: widget.gradientColors,
            strokeWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth + 2),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double rotation;
  final List<Color> colors;
  final double strokeWidth;
  final double borderRadius;
  
  _RotatingBorderPainter({
    required this.rotation,
    required this.colors,
    required this.strokeWidth,
    required this.borderRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: colors,
        startAngle: rotation,
        endAngle: rotation + 2 * pi,
      ).createShader(rect);
    
    canvas.drawRRect(rrect, paint);
  }
  
  @override
  bool shouldRepaint(covariant _RotatingBorderPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

/// Floating Animation Widget
class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  
  const FloatingWidget({
    super.key,
    required this.child,
    this.amplitude = 10,
    this.duration = const Duration(seconds: 2),
  });
  
  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_controller.value * pi) * widget.amplitude),
          child: widget.child,
        );
      },
    );
  }
}

/// Energy Pulse Effect (radial pulse from center)
class EnergyPulse extends StatefulWidget {
  final double maxRadius;
  final Color color;
  final Duration duration;
  
  const EnergyPulse({
    super.key,
    this.maxRadius = 100,
    this.color = AppColors.goldAccent,
    this.duration = const Duration(milliseconds: 1500),
  });
  
  @override
  State<EnergyPulse> createState() => _EnergyPulseState();
}

class _EnergyPulseState extends State<EnergyPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.maxRadius * 2, widget.maxRadius * 2),
          painter: _EnergyPulsePainter(
            progress: _controller.value,
            maxRadius: widget.maxRadius,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _EnergyPulsePainter extends CustomPainter {
  final double progress;
  final double maxRadius;
  final Color color;
  
  _EnergyPulsePainter({
    required this.progress,
    required this.maxRadius,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw multiple rings at different phases
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1.0;
      final radius = phase * maxRadius;
      final opacity = (1 - phase) * 0.6;
      
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _EnergyPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Particle Background (ambient floating particles)
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  
  const ParticleBackground({
    super.key,
    this.particleCount = 30,
    this.particleColor = AppColors.goldAccent,
  });
  
  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FloatingParticle> _particles;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    final random = Random();
    _particles = List.generate(widget.particleCount, (index) {
      return _FloatingParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 3,
        speed: 0.01 + random.nextDouble() * 0.02,
        opacity: 0.2 + random.nextDouble() * 0.4,
      );
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticleBackgroundPainter(
            particles: _particles,
            time: _controller.value,
            color: widget.particleColor,
          ),
        );
      },
    );
  }
}

class _FloatingParticle {
  double x, y, size, speed, opacity;
  _FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticleBackgroundPainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double time;
  final Color color;
  
  _ParticleBackgroundPainter({
    required this.particles,
    required this.time,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y + time * particle.speed) % 1.0;
      final x = particle.x + sin(time * 2 * pi + particle.y * 10) * 0.02;
      
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        Paint()
          ..color = color.withValues(alpha: particle.opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _ParticleBackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

/// Typewriter Text Animation
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;
  final VoidCallback? onComplete;
  
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 50),
    this.onComplete,
  });
  
  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _startTyping();
  }
  
  void _startTyping() async {
    for (int i = 0; i < widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.charDelay);
      setState(() {
        _currentIndex = i + 1;
        _displayText = widget.text.substring(0, _currentIndex);
      });
    }
    widget.onComplete?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style ?? const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }
}

/// Particle Burst Effect (for ability activation)
class ParticleBurst extends StatefulWidget {
  final Color color;
  final int particleCount;
  final double maxRadius;
  final VoidCallback? onComplete;
  
  const ParticleBurst({
    super.key,
    this.color = AppColors.goldAccent,
    this.particleCount = 24,
    this.maxRadius = 80,
    this.onComplete,
  });
  
  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_BurstParticle> _particles;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    final random = Random();
    _particles = List.generate(widget.particleCount, (index) {
      final angle = (index / widget.particleCount) * 2 * pi + random.nextDouble() * 0.3;
      return _BurstParticle(
        angle: angle,
        speed: 0.6 + random.nextDouble() * 0.4,
        size: 2 + random.nextDouble() * 4,
        decay: 0.8 + random.nextDouble() * 0.2,
      );
    });
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.maxRadius * 2, widget.maxRadius * 2),
          painter: _ParticleBurstPainter(
            particles: _particles,
            progress: _controller.value,
            maxRadius: widget.maxRadius,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _BurstParticle {
  final double angle;
  final double speed;
  final double size;
  final double decay;
  
  _BurstParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.decay,
  });
}

class _ParticleBurstPainter extends CustomPainter {
  final List<_BurstParticle> particles;
  final double progress;
  final double maxRadius;
  final Color color;
  
  _ParticleBurstPainter({
    required this.particles,
    required this.progress,
    required this.maxRadius,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final easeProgress = Curves.easeOut.transform(progress);
    
    for (final particle in particles) {
      final radius = maxRadius * easeProgress * particle.speed;
      final opacity = (1 - progress * particle.decay).clamp(0.0, 1.0);
      final particleSize = particle.size * (1 - progress * 0.5);
      
      final x = center.dx + cos(particle.angle) * radius;
      final y = center.dy + sin(particle.angle) * radius;
      
      // Main particle
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 0.5),
      );
      
      // Trail effect
      for (int i = 1; i <= 3; i++) {
        final trailRadius = radius * (1 - i * 0.15);
        final trailOpacity = opacity * (1 - i * 0.25);
        final trailX = center.dx + cos(particle.angle) * trailRadius;
        final trailY = center.dy + sin(particle.angle) * trailRadius;
        
        canvas.drawCircle(
          Offset(trailX, trailY),
          particleSize * (1 - i * 0.2),
          Paint()
            ..color = color.withValues(alpha: trailOpacity.clamp(0.0, 1.0))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 0.3),
        );
      }
    }
    
    // Central flash
    final flashOpacity = (1 - progress * 2).clamp(0.0, 1.0);
    canvas.drawCircle(
      center,
      maxRadius * 0.3 * (1 - progress),
      Paint()
        ..color = Colors.white.withValues(alpha: flashOpacity * 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10),
    );
  }
  
  @override
  bool shouldRepaint(covariant _ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Sparkle Effect (continuous sparkles)
class SparkleEffect extends StatefulWidget {
  final Widget child;
  final Color sparkleColor;
  final int sparkleCount;
  
  const SparkleEffect({
    super.key,
    required this.child,
    this.sparkleColor = AppColors.goldLight,
    this.sparkleCount = 8,
  });
  
  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Sparkle> _sparkles;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    final random = Random();
    _sparkles = List.generate(widget.sparkleCount, (index) {
      return _Sparkle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        phase: random.nextDouble(),
        size: 2 + random.nextDouble() * 3,
      );
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SparklePainter(
                    sparkles: _sparkles,
                    progress: _controller.value,
                    color: widget.sparkleColor,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Sparkle {
  final double x, y, phase, size;
  _Sparkle({required this.x, required this.y, required this.phase, required this.size});
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double progress;
  final Color color;
  
  _SparklePainter({
    required this.sparkles,
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final phase = (progress + sparkle.phase) % 1.0;
      final opacity = sin(phase * pi);
      final scale = 0.5 + sin(phase * pi) * 0.5;
      
      final x = sparkle.x * size.width;
      final y = sparkle.y * size.height;
      
      // 4-point star sparkle
      final path = Path();
      final sparkleSize = sparkle.size * scale;
      path.moveTo(x, y - sparkleSize);
      path.lineTo(x + sparkleSize * 0.3, y);
      path.lineTo(x, y + sparkleSize);
      path.lineTo(x - sparkleSize * 0.3, y);
      path.close();
      
      path.moveTo(x - sparkleSize, y);
      path.lineTo(x, y + sparkleSize * 0.3);
      path.lineTo(x + sparkleSize, y);
      path.lineTo(x, y - sparkleSize * 0.3);
      path.close();
      
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: opacity * 0.8)
          ..style = PaintingStyle.fill,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Scale Bounce Animation Widget
class ScaleBounce extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  
  const ScaleBounce({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });
  
  @override
  State<ScaleBounce> createState() => _ScaleBounceState();
}

class _ScaleBounceState extends State<ScaleBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Glowing Icon
class GlowingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double glowRadius;
  
  const GlowingIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = AppColors.goldLight,
    this.glowRadius = 10,
  });
  
  @override
  State<GlowingIcon> createState() => _GlowingIconState();
}

class _GlowingIconState extends State<GlowingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3 + 0.4 * _controller.value),
                blurRadius: widget.glowRadius * (0.8 + 0.4 * _controller.value),
                spreadRadius: widget.glowRadius * 0.3 * _controller.value,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}
