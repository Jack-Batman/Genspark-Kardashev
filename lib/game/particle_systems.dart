import 'dart:math';
import 'package:flutter/material.dart';

/// Advanced Particle System for Kardashev: Ascension
/// Handles energy flows, nebula clouds, lens flares, and ambient effects

class ParticleSystem {
  final List<Particle> particles = [];
  
  void update(double dt) {
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].isDead) {
        particles.removeAt(i);
      }
    }
  }
  
  void clear() => particles.clear();
}

/// Base Particle class
class Particle {
  Offset position;
  Offset velocity;
  double size;
  double lifetime;
  double maxLifetime;
  Color color;
  double rotation;
  double rotationSpeed;
  double alpha;
  
  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifetime,
    required this.color,
    this.rotation = 0,
    this.rotationSpeed = 0,
    this.alpha = 1.0,
  }) : maxLifetime = lifetime;
  
  void update(double dt) {
    position += velocity * dt;
    lifetime -= dt;
    rotation += rotationSpeed * dt;
    alpha = (lifetime / maxLifetime).clamp(0.0, 1.0);
  }
  
  bool get isDead => lifetime <= 0;
  
  double get progress => 1 - (lifetime / maxLifetime);
}

/// Energy Stream Particle - flows toward Earth
class EnergyStreamParticle extends Particle {
  final Offset target;
  double trailLength;
  
  EnergyStreamParticle({
    required super.position,
    required this.target,
    required super.color,
    super.size = 3.0,
    super.lifetime = 2.0,
    this.trailLength = 20,
  }) : super(velocity: Offset.zero);
  
  @override
  void update(double dt) {
    // Move toward target with easing
    final direction = target - position;
    final distance = direction.distance;
    if (distance > 5) {
      final normalizedDir = direction / distance;
      final speed = 100 + (1 - lifetime / maxLifetime) * 200;
      velocity = normalizedDir * speed;
    }
    super.update(dt);
  }
}

/// Nebula Cloud Particle - ambient background effect
class NebulaParticle extends Particle {
  double pulsePhase;
  double pulseSpeed;
  double baseSize;
  
  NebulaParticle({
    required super.position,
    required super.color,
    required this.baseSize,
    this.pulseSpeed = 1.0,
  }) : pulsePhase = Random().nextDouble() * 2 * pi,
       super(
         velocity: Offset.zero,
         size: baseSize,
         lifetime: double.infinity,
         alpha: 0.3,
       );
  
  @override
  void update(double dt) {
    pulsePhase += pulseSpeed * dt;
    size = baseSize * (0.8 + 0.4 * sin(pulsePhase));
    alpha = 0.2 + 0.15 * sin(pulsePhase * 0.5);
  }
  
  @override
  bool get isDead => false;
}

/// Spark Particle - burst effects on tap
class SparkParticle extends Particle {
  final double gravity;
  final double drag;
  
  SparkParticle({
    required super.position,
    required super.velocity,
    required super.color,
    super.size = 2.0,
    super.lifetime = 1.0,
    this.gravity = 50,
    this.drag = 0.98,
  }) : super(rotation: 0, rotationSpeed: Random().nextDouble() * 10);
  
  @override
  void update(double dt) {
    velocity = Offset(velocity.dx * drag, velocity.dy * drag + gravity * dt);
    super.update(dt);
    size *= 0.98;
  }
}

/// Orbital Ring Particle - circles around Earth
class OrbitalParticle extends Particle {
  final double orbitRadius;
  double orbitAngle;
  final double orbitSpeed;
  final double orbitTilt;
  
  OrbitalParticle({
    required this.orbitRadius,
    required this.orbitAngle,
    required this.orbitSpeed,
    required super.color,
    this.orbitTilt = 0.3,
    super.size = 2.0,
  }) : super(
         position: Offset.zero,
         velocity: Offset.zero,
         lifetime: double.infinity,
       );
  
  @override
  void update(double dt) {
    orbitAngle += orbitSpeed * dt;
    final x = cos(orbitAngle) * orbitRadius;
    final y = sin(orbitAngle) * orbitRadius * orbitTilt;
    position = Offset(x, y);
  }
  
  @override
  bool get isDead => false;
}

/// Comet Particle - streaks across the screen
class CometParticle extends Particle {
  final List<Offset> trail = [];
  final int maxTrailLength;
  
  CometParticle({
    required super.position,
    required super.velocity,
    required super.color,
    super.size = 4.0,
    super.lifetime = 5.0,
    this.maxTrailLength = 30,
  });
  
  @override
  void update(double dt) {
    trail.insert(0, position);
    if (trail.length > maxTrailLength) {
      trail.removeLast();
    }
    super.update(dt);
  }
}

/// Lens Flare Component
class LensFlare {
  final Offset position;
  final Color color;
  final double intensity;
  final List<FlareElement> elements;
  
  LensFlare({
    required this.position,
    this.color = const Color(0xFFFFD700),
    this.intensity = 1.0,
  }) : elements = _generateFlareElements(color);
  
  static List<FlareElement> _generateFlareElements(Color baseColor) {
    return [
      FlareElement(offset: 0.0, size: 60, color: baseColor.withValues(alpha: 0.3), type: FlareType.glow),
      FlareElement(offset: 0.2, size: 20, color: baseColor.withValues(alpha: 0.5), type: FlareType.ring),
      FlareElement(offset: 0.4, size: 40, color: baseColor.withValues(alpha: 0.2), type: FlareType.hexagon),
      FlareElement(offset: 0.6, size: 15, color: baseColor.withValues(alpha: 0.4), type: FlareType.circle),
      FlareElement(offset: 0.8, size: 30, color: baseColor.withValues(alpha: 0.15), type: FlareType.glow),
      FlareElement(offset: 1.0, size: 25, color: baseColor.withValues(alpha: 0.3), type: FlareType.ring),
      FlareElement(offset: 1.3, size: 50, color: baseColor.withValues(alpha: 0.1), type: FlareType.glow),
    ];
  }
}

enum FlareType { glow, ring, circle, hexagon }

class FlareElement {
  final double offset;
  final double size;
  final Color color;
  final FlareType type;
  
  FlareElement({
    required this.offset,
    required this.size,
    required this.color,
    required this.type,
  });
}

/// Particle System Painter
class ParticleSystemPainter {
  
  /// Draw energy streams
  static void drawEnergyStreams(
    Canvas canvas,
    List<EnergyStreamParticle> particles,
  ) {
    for (final particle in particles) {
      // Draw trail
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            particle.color.withValues(alpha: 0),
            particle.color.withValues(alpha: particle.alpha * 0.8),
          ],
        ).createShader(Rect.fromPoints(
          particle.position - particle.velocity.scale(0.1, 0.1),
          particle.position,
        ));
      
      final trailPath = Path()
        ..moveTo(
          particle.position.dx - particle.velocity.dx * 0.15,
          particle.position.dy - particle.velocity.dy * 0.15,
        )
        ..lineTo(particle.position.dx, particle.position.dy);
      
      canvas.drawPath(
        trailPath,
        trailPaint..strokeWidth = particle.size..style = PaintingStyle.stroke,
      );
      
      // Draw particle head
      final headPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);
      
      canvas.drawCircle(particle.position, particle.size, headPaint);
      
      // Bright core
      canvas.drawCircle(
        particle.position,
        particle.size * 0.5,
        Paint()..color = Colors.white.withValues(alpha: particle.alpha * 0.8),
      );
    }
  }
  
  /// Draw nebula clouds
  static void drawNebulaClouds(
    Canvas canvas,
    List<NebulaParticle> particles,
  ) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.8);
      
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }
  
  /// Draw spark burst
  static void drawSparks(
    Canvas canvas,
    List<SparkParticle> particles,
  ) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha);
      
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      
      // Draw as small line/streak
      canvas.drawLine(
        Offset(-particle.size, 0),
        Offset(particle.size, 0),
        paint..strokeWidth = particle.size * 0.5,
      );
      
      canvas.restore();
      
      // Glow
      canvas.drawCircle(
        particle.position,
        particle.size * 0.5,
        Paint()
          ..color = particle.color.withValues(alpha: particle.alpha * 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size),
      );
    }
  }
  
  /// Draw orbital rings
  static void drawOrbitalParticles(
    Canvas canvas,
    List<OrbitalParticle> particles,
  ) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.8);
      
      canvas.drawCircle(particle.position, particle.size, paint);
      
      // Glow
      canvas.drawCircle(
        particle.position,
        particle.size * 2,
        Paint()
          ..color = particle.color.withValues(alpha: 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 2),
      );
    }
  }
  
  /// Draw comets with trails
  static void drawComets(
    Canvas canvas,
    List<CometParticle> particles,
  ) {
    for (final particle in particles) {
      if (particle.trail.isEmpty) continue;
      
      // Draw trail
      final trailPath = Path()..moveTo(particle.trail.first.dx, particle.trail.first.dy);
      for (int i = 1; i < particle.trail.length; i++) {
        trailPath.lineTo(particle.trail[i].dx, particle.trail[i].dy);
      }
      
      for (int i = 0; i < particle.trail.length; i++) {
        final alpha = (1 - i / particle.trail.length) * particle.alpha;
        final size = particle.size * (1 - i / particle.trail.length * 0.8);
        
        canvas.drawCircle(
          particle.trail[i],
          size,
          Paint()
            ..color = particle.color.withValues(alpha: alpha * 0.5)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, size),
        );
      }
      
      // Draw head
      canvas.drawCircle(
        particle.position,
        particle.size,
        Paint()..color = particle.color.withValues(alpha: particle.alpha),
      );
      
      canvas.drawCircle(
        particle.position,
        particle.size * 0.5,
        Paint()..color = Colors.white.withValues(alpha: particle.alpha),
      );
    }
  }
  
  /// Draw lens flare
  static void drawLensFlare(
    Canvas canvas,
    LensFlare flare,
    Offset screenCenter,
  ) {
    final direction = screenCenter - flare.position;
    
    for (final element in flare.elements) {
      final elementPos = flare.position + direction * element.offset;
      
      switch (element.type) {
        case FlareType.glow:
          canvas.drawCircle(
            elementPos,
            element.size,
            Paint()
              ..color = element.color.withValues(alpha: element.color.a * flare.intensity)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, element.size * 0.8),
          );
          break;
          
        case FlareType.ring:
          canvas.drawCircle(
            elementPos,
            element.size,
            Paint()
              ..color = element.color.withValues(alpha: element.color.a * flare.intensity)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          break;
          
        case FlareType.circle:
          canvas.drawCircle(
            elementPos,
            element.size,
            Paint()..color = element.color.withValues(alpha: element.color.a * flare.intensity),
          );
          break;
          
        case FlareType.hexagon:
          _drawHexagon(canvas, elementPos, element.size, 
            Paint()..color = element.color.withValues(alpha: element.color.a * flare.intensity));
          break;
      }
    }
  }
  
  static void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3 - pi / 6;
      final point = Offset(
        center.dx + cos(angle) * size,
        center.dy + sin(angle) * size,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Floating Number Animation
class FloatingNumber {
  Offset position;
  final String text;
  final Color color;
  double lifetime;
  final double maxLifetime;
  double scale;
  
  FloatingNumber({
    required this.position,
    required this.text,
    this.color = const Color(0xFFFFD700),
    this.lifetime = 1.5,
  }) : maxLifetime = lifetime, scale = 0.5;
  
  void update(double dt) {
    position = Offset(position.dx, position.dy - 60 * dt);
    lifetime -= dt;
    
    // Scale animation
    final progress = 1 - lifetime / maxLifetime;
    if (progress < 0.2) {
      scale = 0.5 + progress * 2.5; // Pop in
    } else if (progress > 0.7) {
      scale = 1.0 - (progress - 0.7) * 3.33; // Fade out
    } else {
      scale = 1.0;
    }
  }
  
  bool get isDead => lifetime <= 0;
  double get alpha => (lifetime / maxLifetime).clamp(0.0, 1.0);
}
