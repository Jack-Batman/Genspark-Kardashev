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
