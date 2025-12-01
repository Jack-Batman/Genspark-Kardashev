import 'dart:math';
import 'package:flutter/material.dart';
import '../core/era_data.dart';

/// Era-specific visual rendering
/// Each Era has unique central object, color scheme, and particle effects

class EraVisuals {
  final Era era;
  
  // Animation timers
  double _rotation = 0;
  double _pulse = 0;
  double _wavePhase = 0;
  
  EraVisuals(this.era);
  
  void update(double dt) {
    _rotation += dt * 0.1;
    _pulse += dt * 2;
    _wavePhase += dt;
  }
  
  /// Draw the central object for the current era
  void drawCentralObject(Canvas canvas, double techLevel) {
    switch (era) {
      case Era.planetary:
        _drawEarth(canvas, techLevel);
        break;
      case Era.stellar:
        _drawSun(canvas, techLevel);
        break;
      case Era.galactic:
        _drawGalaxy(canvas, techLevel);
        break;
      case Era.universal:
        _drawUniverse(canvas, techLevel);
        break;
      case Era.multiversal:
        _drawMultiverse(canvas, techLevel);
        break;
    }
  }

  /// Draw Era V - Multiverse/Void
  void _drawMultiverse(Canvas canvas, double techLevel) {
    // Void background with timeline threads
    _drawVoidThreads(canvas, techLevel);
    
    // Omniversal core
    _drawOmniversalCore(canvas, techLevel);
    
    // Brane collisions
    if (techLevel > 0.2) {
      _drawBraneCollisions(canvas, techLevel);
    }
    
    // Reality bubbles (multiple universes)
    if (techLevel > 0.5) {
      _drawMultiverseBubbles(canvas, techLevel);
    }
  }

  void _drawVoidThreads(Canvas canvas, double techLevel) {
    final paint = Paint()
      ..color = const Color(0xFF6200EA).withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fixedRandom = Random(777);
    
    for (int i = 0; i < 20; i++) {
      final path = Path();
      final startAngle = fixedRandom.nextDouble() * 2 * pi;
      final radius = 100.0 + fixedRandom.nextDouble() * 50;
      
      for (double t = 0; t < 2 * pi; t += 0.2) {
        final r = radius + 10 * sin(t * 3 + _wavePhase);
        final angle = startAngle + t + _rotation * 0.2;
        final x = cos(angle) * r;
        final y = sin(angle) * r;
        
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawOmniversalCore(Canvas canvas, double techLevel) {
    final radius = 40.0 + 5 * sin(_pulse * 2);
    
    // Core glow
    canvas.drawCircle(
      Offset.zero,
      radius + 20,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    
    // Solid core
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0xFF6200EA), Colors.black],
          stops: [0.2, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );
  }

  void _drawBraneCollisions(Canvas canvas, double techLevel) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
      
    final count = (5 * techLevel).round();
    final fixedRandom = Random(888);
    
    for (int i = 0; i < count; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi + _rotation;
      final dist = 60 + fixedRandom.nextDouble() * 40;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist;
      
      canvas.drawCircle(
        Offset(x, y),
        8 + 4 * sin(_pulse + i),
        paint,
      );
    }
  }

  void _drawMultiverseBubbles(Canvas canvas, double techLevel) {
    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final count = (10 * techLevel).round();
    final fixedRandom = Random(999);
    
    for (int i = 0; i < count; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi - _rotation * 0.5;
      final dist = 120 + fixedRandom.nextDouble() * 80;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist;
      final r = 10 + fixedRandom.nextDouble() * 15;
      
      bubblePaint.color = HSLColor.fromAHSL(0.5, (i * 30.0) % 360, 1.0, 0.5).toColor();
      canvas.drawCircle(Offset(x, y), r, bubblePaint);
    }
  }
  
  /// Draw Era I - Earth
  void _drawEarth(Canvas canvas, double techLevel) {
    final earthRadius = 80.0;
    
    // Outer glow
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        Offset.zero,
        earthRadius + i * 8,
        Paint()
          ..color = const Color(0xFF00BFFF).withValues(alpha: 0.05 / i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * i),
      );
    }
    
    // Earth base
    final dayGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [
        const Color(0xFF4a8fc7),
        const Color(0xFF2d5a87),
        const Color(0xFF1a3a5c),
      ],
    );
    
    canvas.drawCircle(
      Offset.zero,
      earthRadius,
      Paint()..shader = dayGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: earthRadius),
      ),
    );
    
    // City lights
    _drawCityLights(canvas, earthRadius, techLevel, const Color(0xFFFFD700));
    
    // Tech grid
    if (techLevel > 0.2) {
      _drawTechGrid(canvas, earthRadius, techLevel, const Color(0xFFFFB347));
    }
    
    // Atmosphere
    canvas.drawCircle(
      Offset.zero,
      earthRadius + 10,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF00BFFF).withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const [0.85, 0.95, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: earthRadius + 10)),
    );
  }
  
  /// Draw Era II - Sun with Dyson structures
  void _drawSun(Canvas canvas, double techLevel) {
    final sunRadius = 100.0;
    
    // Massive outer corona
    for (int i = 5; i > 0; i--) {
      final coronaRadius = sunRadius + i * 30;
      canvas.drawCircle(
        Offset.zero,
        coronaRadius,
        Paint()
          ..color = const Color(0xFFFF6B35).withValues(alpha: 0.1 / i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30.0 * i),
      );
    }
    
    // Solar flares
    _drawSolarFlares(canvas, sunRadius);
    
    // Sun surface with granulation
    final sunGradient = RadialGradient(
      colors: [
        const Color(0xFFFFFFAA),
        const Color(0xFFFFD700),
        const Color(0xFFFF8C00),
        const Color(0xFFFF4500),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    canvas.drawCircle(
      Offset.zero,
      sunRadius,
      Paint()..shader = sunGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: sunRadius),
      ),
    );
    
    // Sunspots
    _drawSunspots(canvas, sunRadius);
    
    // Dyson swarm elements
    if (techLevel > 0.1) {
      _drawDysonSwarm(canvas, sunRadius, techLevel);
    }
    
    // Dyson sphere progress
    if (techLevel > 0.5) {
      _drawDysonSphereProgress(canvas, sunRadius, techLevel);
    }
  }
  
  void _drawSolarFlares(Canvas canvas, double radius) {
    final flarePaint = Paint()
      ..color = const Color(0xFFFF6B35).withValues(alpha: 0.3);
    
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + _rotation * 0.2;
      final flareLength = 30 + 20 * sin(_pulse + i);
      
      final path = Path();
      path.moveTo(cos(angle) * radius, sin(angle) * radius);
      path.quadraticBezierTo(
        cos(angle + 0.1) * (radius + flareLength),
        sin(angle + 0.1) * (radius + flareLength),
        cos(angle + 0.05) * (radius + flareLength * 1.5),
        sin(angle + 0.05) * (radius + flareLength * 1.5),
      );
      path.quadraticBezierTo(
        cos(angle - 0.1) * (radius + flareLength),
        sin(angle - 0.1) * (radius + flareLength),
        cos(angle) * radius,
        sin(angle) * radius,
      );
      
      canvas.drawPath(path, flarePaint);
    }
  }
  
  void _drawSunspots(Canvas canvas, double radius) {
    final spotPaint = Paint()..color = const Color(0xFF8B4513).withValues(alpha: 0.3);
    final fixedRandom = Random(42);
    
    for (int i = 0; i < 5; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi + _rotation * 0.1;
      final dist = fixedRandom.nextDouble() * radius * 0.6;
      final spotRadius = 5 + fixedRandom.nextDouble() * 10;
      
      canvas.drawCircle(
        Offset(cos(angle) * dist, sin(angle) * dist),
        spotRadius,
        spotPaint,
      );
    }
  }
  
  void _drawDysonSwarm(Canvas canvas, double radius, double techLevel) {
    final satelliteCount = (50 * techLevel).round();
    final fixedRandom = Random(123);
    
    for (int i = 0; i < satelliteCount; i++) {
      final orbitRadius = radius * 1.3 + fixedRandom.nextDouble() * 50;
      final angle = (i / satelliteCount) * 2 * pi + _rotation * (0.5 + fixedRandom.nextDouble() * 0.5);
      final tilt = 0.2 + fixedRandom.nextDouble() * 0.3;
      
      final x = cos(angle) * orbitRadius;
      final y = sin(angle) * orbitRadius * tilt;
      
      // Draw satellite
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white,
      );
      
      // Draw reflection
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }
  
  void _drawDysonSphereProgress(Canvas canvas, double radius, double techLevel) {
    final progress = ((techLevel - 0.5) * 2).clamp(0.0, 1.0);
    final shellRadius = radius * 1.5;
    
    // Draw partial shell
    final shellPaint = Paint()
      ..color = const Color(0xFF333333).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    // Draw arc based on progress
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: shellRadius),
      -pi / 2,
      2 * pi * progress,
      false,
      shellPaint,
    );
    
    // Draw energy collection beams
    if (progress > 0.3) {
      final beamCount = (progress * 12).round();
      for (int i = 0; i < beamCount; i++) {
        final angle = (i / beamCount) * 2 * pi * progress - pi / 2;
        canvas.drawLine(
          Offset(cos(angle) * radius, sin(angle) * radius),
          Offset(cos(angle) * shellRadius, sin(angle) * shellRadius),
          Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: 0.2)
            ..strokeWidth = 1,
        );
      }
    }
  }
  
  /// Draw Era III - Spiral Galaxy
  void _drawGalaxy(Canvas canvas, double techLevel) {
    final galaxyRadius = 120.0;
    
    // Galactic halo
    canvas.drawCircle(
      Offset.zero,
      galaxyRadius * 1.5,
      Paint()
        ..color = const Color(0xFF6B35FF).withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );
    
    // Spiral arms
    _drawSpiralArms(canvas, galaxyRadius, techLevel);
    
    // Central bulge (supermassive black hole)
    _drawGalacticCore(canvas);
    
    // Star systems (colonized)
    if (techLevel > 0.1) {
      _drawColonizedSystems(canvas, galaxyRadius, techLevel);
    }
    
    // Galactic network connections
    if (techLevel > 0.3) {
      _drawGalacticNetwork(canvas, galaxyRadius, techLevel);
    }
  }
  
  void _drawSpiralArms(Canvas canvas, double radius, double techLevel) {
    
    for (int arm = 0; arm < 2; arm++) {
      final armOffset = arm * pi;
      
      for (double t = 0; t < 4 * pi; t += 0.1) {
        final r = 10 + t * radius / (4 * pi);
        final angle = t + armOffset + _rotation * 0.05;
        final x = cos(angle) * r;
        final y = sin(angle) * r * 0.4; // Tilt
        
        final starBrightness = 0.3 + 0.7 * (1 - t / (4 * pi));
        canvas.drawCircle(
          Offset(x, y),
          2 + starBrightness * 2,
          Paint()
            ..color = const Color(0xFFAA77FF).withValues(alpha: starBrightness * 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }
  
  void _drawGalacticCore(Canvas canvas) {
    // Accretion disk
    for (int i = 0; i < 20; i++) {
      final diskRadius = 15.0 + i * 2;
      final opacity = 0.3 * (1 - i / 20);
      canvas.drawCircle(
        Offset.zero,
        diskRadius,
        Paint()
          ..color = const Color(0xFFE040FB).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    
    // Central black hole
    canvas.drawCircle(
      Offset.zero,
      10,
      Paint()..color = Colors.black,
    );
    
    // Event horizon glow
    canvas.drawCircle(
      Offset.zero,
      12,
      Paint()
        ..color = const Color(0xFFE040FB).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
  
  void _drawColonizedSystems(Canvas canvas, double radius, double techLevel) {
    final systemCount = (30 * techLevel).round();
    final fixedRandom = Random(456);
    
    for (int i = 0; i < systemCount; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi;
      final dist = 20 + fixedRandom.nextDouble() * radius;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist * 0.4;
      
      // Colonized star
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = const Color(0xFFFFD700),
      );
      
      // Dyson indicator
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }
  
  void _drawGalacticNetwork(Canvas canvas, double radius, double techLevel) {
    final networkPaint = Paint()
      ..color = const Color(0xFFE040FB).withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    
    final nodeCount = (20 * techLevel).round();
    final fixedRandom = Random(789);
    final nodes = <Offset>[];
    
    for (int i = 0; i < nodeCount; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi;
      final dist = 20 + fixedRandom.nextDouble() * radius;
      nodes.add(Offset(cos(angle) * dist, sin(angle) * dist * 0.4));
    }
    
    // Connect nearby nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < 50) {
          canvas.drawLine(nodes[i], nodes[j], networkPaint);
        }
      }
    }
  }
  
  /// Draw Era IV - Universal/Cosmic Web
  void _drawUniverse(Canvas canvas, double techLevel) {
    // Cosmic background
    _drawCosmicWeb(canvas, techLevel);
    
    // Central singularity (creation point)
    _drawCreationPoint(canvas, techLevel);
    
    // Dimensional rifts
    if (techLevel > 0.2) {
      _drawDimensionalRifts(canvas, techLevel);
    }
    
    // Timeline threads
    if (techLevel > 0.4) {
      _drawTimelineThreads(canvas, techLevel);
    }
    
    // Reality bubbles
    if (techLevel > 0.6) {
      _drawRealityBubbles(canvas, techLevel);
    }
  }
  
  void _drawCosmicWeb(Canvas canvas, double techLevel) {
    final webPaint = Paint()
      ..color = const Color(0xFF00FFFF).withValues(alpha: 0.15)
      ..strokeWidth = 1;
    
    // Draw interconnected filaments
    final fixedRandom = Random(999);
    final nodes = <Offset>[];
    
    for (int i = 0; i < 50; i++) {
      nodes.add(Offset(
        (fixedRandom.nextDouble() - 0.5) * 400,
        (fixedRandom.nextDouble() - 0.5) * 400,
      ));
    }
    
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < 80) {
          canvas.drawLine(nodes[i], nodes[j], webPaint);
        }
      }
    }
    
    // Galaxy clusters at nodes
    for (final node in nodes) {
      canvas.drawCircle(
        node,
        3,
        Paint()
          ..color = const Color(0xFFFF6B9D).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }
  
  void _drawCreationPoint(Canvas canvas, double techLevel) {
    // Pulsing singularity
    final pulseSize = 30 + 10 * sin(_pulse);
    
    // Outer glow rings
    for (int i = 5; i > 0; i--) {
      canvas.drawCircle(
        Offset.zero,
        pulseSize + i * 15,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1 / i)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * i),
      );
    }
    
    // Rainbow energy ring
    for (int i = 0; i < 360; i += 5) {
      final angle = i * pi / 180 + _rotation;
      final hue = (i + _pulse * 50) % 360;
      final color = HSVColor.fromAHSV(0.6, hue, 1.0, 1.0).toColor();
      
      canvas.drawLine(
        Offset(cos(angle) * pulseSize, sin(angle) * pulseSize),
        Offset(cos(angle) * (pulseSize + 20), sin(angle) * (pulseSize + 20)),
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    
    // Core
    canvas.drawCircle(
      Offset.zero,
      20,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0xFFFF6B9D), Colors.transparent],
        ).createShader(const Rect.fromLTWH(-20, -20, 40, 40)),
    );
  }
  
  void _drawDimensionalRifts(Canvas canvas, double techLevel) {
    final riftCount = (5 * techLevel).round();
    final fixedRandom = Random(111);
    
    for (int i = 0; i < riftCount; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi;
      final dist = 80 + fixedRandom.nextDouble() * 80;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist;
      
      // Rift portal
      final riftAngle = _rotation + i;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(riftAngle);
      
      // Draw oval rift
      canvas.drawOval(
        const Rect.fromLTWH(-15, -8, 30, 16),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF), Color(0xFF00FFFF)],
          ).createShader(const Rect.fromLTWH(-15, -8, 30, 16)),
      );
      
      // Inner darkness
      canvas.drawOval(
        const Rect.fromLTWH(-10, -5, 20, 10),
        Paint()..color = const Color(0xFF000020),
      );
      
      canvas.restore();
    }
  }
  
  void _drawTimelineThreads(Canvas canvas, double techLevel) {
    final threadPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
      ..strokeWidth = 1;
    
    // Spiraling timeline threads
    for (int thread = 0; thread < 3; thread++) {
      final path = Path();
      final startAngle = thread * 2 * pi / 3;
      
      for (double t = 0; t < 8 * pi; t += 0.1) {
        final r = 50 + t * 15;
        final angle = startAngle + t * 0.5 + _wavePhase;
        final x = cos(angle) * r;
        final y = sin(angle) * r * 0.3;
        
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, threadPaint);
    }
  }
  
  void _drawRealityBubbles(Canvas canvas, double techLevel) {
    final bubbleCount = (4 * techLevel).round();
    final fixedRandom = Random(222);
    
    for (int i = 0; i < bubbleCount; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi;
      final dist = 100 + fixedRandom.nextDouble() * 60;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist;
      final radius = 20 + fixedRandom.nextDouble() * 15;
      
      // Bubble membrane
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      
      // Inner universe glimpse
      canvas.drawCircle(
        Offset(x, y),
        radius - 5,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF000033),
              const Color(0xFF330033),
            ],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius)),
      );
      
      // Mini stars
      for (int j = 0; j < 5; j++) {
        final starAngle = fixedRandom.nextDouble() * 2 * pi;
        final starDist = fixedRandom.nextDouble() * (radius - 8);
        canvas.drawCircle(
          Offset(x + cos(starAngle) * starDist, y + sin(starAngle) * starDist),
          1,
          Paint()..color = Colors.white.withValues(alpha: 0.5),
        );
      }
    }
  }
  
  // Helper methods
  void _drawCityLights(Canvas canvas, double radius, double techLevel, Color color) {
    final fixedRandom = Random(42);
    final lightCount = (30 * techLevel).round();
    
    for (int i = 0; i < lightCount; i++) {
      final lat = (fixedRandom.nextDouble() - 0.5) * pi * 0.8;
      final lon = fixedRandom.nextDouble() * 2 * pi + _rotation;
      
      if (cos(lon) > -0.2) {
        final x = cos(lat) * sin(lon) * radius * 0.95;
        final y = sin(lat) * radius * 0.95;
        final brightness = (cos(lon) + 0.2) / 1.2;
        final pulse = 0.8 + 0.2 * sin(_pulse * 5 + i);
        
        canvas.drawCircle(
          Offset(x, y),
          2 + techLevel * 2,
          Paint()
            ..color = color.withValues(alpha: brightness * 0.8 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }
  
  void _drawTechGrid(Canvas canvas, double radius, double techLevel, Color color) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.2 * techLevel)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    final hexCount = (6 + techLevel * 10).round();
    for (int i = 0; i < hexCount; i++) {
      final angle = (i / hexCount) * 2 * pi + _rotation * 0.5;
      final dist = radius * 0.3 + (i % 3) * radius * 0.2;
      
      if (cos(angle + _rotation) > 0) {
        final x = cos(angle) * dist;
        final y = sin(angle) * dist * 0.8;
        
        final path = Path();
        for (int j = 0; j < 6; j++) {
          final hAngle = j * pi / 3;
          final hx = x + cos(hAngle) * 8;
          final hy = y + sin(hAngle) * 8;
          if (j == 0) {
            path.moveTo(hx, hy);
          } else {
            path.lineTo(hx, hy);
          }
        }
        path.close();
        canvas.drawPath(path, gridPaint);
      }
    }
  }
}
