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

  /// Draw Era V - Multiverse/Void - TRANSCENDENT END-GAME VISUALS
  void _drawMultiverse(Canvas canvas, double techLevel) {
    // Layer 1: The Infinite Void with reality fractures
    _drawInfiniteVoid(canvas, techLevel);
    
    // Layer 2: Void Tendrils reaching from beyond
    _drawVoidTendrils(canvas, techLevel);
    
    // Layer 3: Timeline Cascade - infinite parallel realities
    if (techLevel > 0.1) {
      _drawTimelineCascade(canvas, techLevel);
    }
    
    // Layer 4: Reality Fractures - cracks in existence
    if (techLevel > 0.2) {
      _drawRealityFractures(canvas, techLevel);
    }
    
    // Layer 5: The Omniversal Throne - impossible geometry central object
    _drawOmniversalThrone(canvas, techLevel);
    
    // Layer 6: Dimensional Cascade - universes being born/dying
    if (techLevel > 0.4) {
      _drawDimensionalCascade(canvas, techLevel);
    }
    
    // Layer 7: The Watchers - ancient entities at the edge
    if (techLevel > 0.6) {
      _drawCosmicWatchers(canvas, techLevel);
    }
    
    // Layer 8: Logic Rewrite particles - reality being overwritten
    if (techLevel > 0.8) {
      _drawLogicRewriteEffect(canvas, techLevel);
    }
  }

  /// The Infinite Void - pure nothingness with subtle prismatic edges
  void _drawInfiniteVoid(Canvas canvas, double techLevel) {
    // Outer void gradient - deeper than black
    final voidGradient = RadialGradient(
      colors: [
        const Color(0xFF050008), // Slightly purple void
        const Color(0xFF000000), // True black
        const Color(0xFF000003), // Hint of existence at edges
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    canvas.drawCircle(
      Offset.zero,
      300,
      Paint()..shader = voidGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: 300),
      ),
    );
    
    // Prismatic void shimmer at the edges of reality
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + _wavePhase * 0.3;
      final hue = ((i * 45) + _pulse * 20) % 360;
      final shimmerColor = HSVColor.fromAHSV(0.15, hue, 1.0, 1.0).toColor();
      
      final path = Path();
      for (double t = 0; t < pi * 0.3; t += 0.05) {
        final r = 250 + sin(t * 5 + _wavePhase) * 20;
        final a = angle + t - pi * 0.15;
        if (t == 0) {
          path.moveTo(cos(a) * r, sin(a) * r);
        } else {
          path.lineTo(cos(a) * r, sin(a) * r);
        }
      }
      
      canvas.drawPath(
        path,
        Paint()
          ..color = shimmerColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  /// Void Tendrils - dark matter reaching from beyond existence
  void _drawVoidTendrils(Canvas canvas, double techLevel) {
    final fixedRandom = Random(555);
    final tendrilCount = 12;
    
    for (int i = 0; i < tendrilCount; i++) {
      final baseAngle = (i / tendrilCount) * 2 * pi + _rotation * 0.1;
      final path = Path();
      
      // Tendrils emerge from the void edge
      path.moveTo(cos(baseAngle) * 280, sin(baseAngle) * 280);
      
      // Organic, flowing tendril path
      for (double t = 0; t < 1.0; t += 0.05) {
        final progress = t;
        final dist = 280 - progress * (180 + fixedRandom.nextDouble() * 40);
        final wobble = sin(_wavePhase * 2 + t * 8 + i) * (20 * (1 - progress));
        final angle = baseAngle + wobble * 0.02;
        
        path.lineTo(
          cos(angle) * dist + wobble,
          sin(angle) * dist,
        );
      }
      
      // Draw tendril with gradient opacity
      final tendrilPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF1A0030).withValues(alpha: 0.0),
            const Color(0xFF3D0066).withValues(alpha: 0.4 * techLevel),
            const Color(0xFF6600AA).withValues(alpha: 0.6 * techLevel),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: 280))
        ..strokeWidth = 6 + sin(_pulse + i) * 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, tendrilPaint);
      
      // Glow effect
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF9900FF).withValues(alpha: 0.2 * techLevel)
          ..strokeWidth = 12
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  /// Timeline Cascade - infinite parallel realities stacked
  void _drawTimelineCascade(Canvas canvas, double techLevel) {
    final layerCount = (15 * techLevel).round().clamp(3, 15);
    
    for (int i = 0; i < layerCount; i++) {
      final offset = (i - layerCount / 2) * 8;
      final alpha = (0.3 - (i.abs() / layerCount) * 0.25) * techLevel;
      final hue = (i * 25 + _pulse * 30) % 360;
      final color = HSVColor.fromAHSV(alpha.clamp(0.05, 0.3), hue, 0.8, 1.0).toColor();
      
      // Each timeline is a thin slice of reality
      canvas.save();
      canvas.translate(offset * 0.5, offset * 0.3);
      
      // Draw timeline ring
      canvas.drawCircle(
        Offset.zero,
        60 + i * 3,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      
      canvas.restore();
    }
  }

  /// Reality Fractures - cracks in the fabric of existence
  void _drawRealityFractures(Canvas canvas, double techLevel) {
    final fixedRandom = Random(777);
    final fractureCount = (8 * techLevel).round();
    
    for (int i = 0; i < fractureCount; i++) {
      final startAngle = fixedRandom.nextDouble() * 2 * pi;
      final startDist = 70 + fixedRandom.nextDouble() * 60;
      final length = 40 + fixedRandom.nextDouble() * 80;
      
      final path = Path();
      path.moveTo(
        cos(startAngle) * startDist,
        sin(startAngle) * startDist,
      );
      
      // Jagged fracture line
      double currentDist = startDist;
      double currentAngle = startAngle;
      for (int j = 0; j < 8; j++) {
        currentDist += length / 8;
        currentAngle += (fixedRandom.nextDouble() - 0.5) * 0.4;
        path.lineTo(
          cos(currentAngle) * currentDist + (fixedRandom.nextDouble() - 0.5) * 10,
          sin(currentAngle) * currentDist + (fixedRandom.nextDouble() - 0.5) * 10,
        );
      }
      
      // Fracture glow - prismatic light bleeding through
      final hue = (_pulse * 50 + i * 40) % 360;
      canvas.drawPath(
        path,
        Paint()
          ..color = HSVColor.fromAHSV(0.8, hue, 1.0, 1.0).toColor()
          ..strokeWidth = 3 + sin(_pulse * 3 + i) * 1.5
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      
      // Core fracture line - bright white
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  /// The Omniversal Throne - impossible geometry at the center of all existence
  void _drawOmniversalThrone(Canvas canvas, double techLevel) {
    // Outer event horizon - swirling void energy
    for (int ring = 5; ring > 0; ring--) {
      final ringRadius = 45.0 + ring * 12 + sin(_pulse * 1.5) * 3;
      final hue = (_rotation * 30 + ring * 60) % 360;
      
      canvas.drawCircle(
        Offset.zero,
        ringRadius,
        Paint()
          ..color = HSVColor.fromAHSV(0.15 / ring, hue, 1.0, 1.0).toColor()
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 / ring),
      );
    }
    
    // Impossible geometry - nested rotating shapes
    _drawImpossibleGeometry(canvas, techLevel);
    
    // Core singularity - pure transcendence
    final coreRadius = 25.0 + sin(_pulse * 2) * 3;
    
    // Outer glow rings
    canvas.drawCircle(
      Offset.zero,
      coreRadius + 15,
      Paint()
        ..color = const Color(0xFFE0B0FF).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    
    // Rainbow chromatic aberration effect
    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        cos(_rotation * 2 + i * 2.1) * 3,
        sin(_rotation * 2 + i * 2.1) * 3,
      );
      final colors = [const Color(0xFFFF0080), const Color(0xFF00FF80), const Color(0xFF8000FF)];
      
      canvas.drawCircle(
        offset,
        coreRadius,
        Paint()
          ..color = colors[i].withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    
    // Core - shifting between states of existence
    final coreGradient = RadialGradient(
      colors: [
        Colors.white,
        const Color(0xFFE0B0FF),
        const Color(0xFF6600CC),
        Colors.black,
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );
    
    canvas.drawCircle(
      Offset.zero,
      coreRadius,
      Paint()..shader = coreGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: coreRadius),
      ),
    );
    
    // Inner eye - the consciousness of the multiverse
    canvas.drawCircle(
      Offset.zero,
      8,
      Paint()..color = Colors.black,
    );
    
    // Pupil shimmer
    canvas.drawCircle(
      const Offset(-2, -2),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  /// Impossible Geometry - Penrose-style impossible shapes
  void _drawImpossibleGeometry(Canvas canvas, double techLevel) {
    canvas.save();
    canvas.rotate(_rotation * 0.3);
    
    // Rotating impossible triangle frames
    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.rotate(i * 2 * pi / 3 + _wavePhase * 0.5);
      
      final size = 55.0 + i * 8;
      final path = Path();
      
      // Draw impossible triangle
      path.moveTo(0, -size);
      path.lineTo(size * 0.866, size * 0.5);
      path.lineTo(-size * 0.866, size * 0.5);
      path.close();
      
      final hue = (i * 120 + _pulse * 40) % 360;
      canvas.drawPath(
        path,
        Paint()
          ..color = HSVColor.fromAHSV(0.4 * techLevel, hue, 0.8, 1.0).toColor()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      
      canvas.restore();
    }
    
    // Rotating squares creating depth illusion
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * pi / 4 - _rotation * 0.2);
      final squareSize = 40.0 + i * 5;
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: squareSize, height: squareSize),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15 - i * 0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      
      canvas.restore();
    }
    
    canvas.restore();
  }

  /// Dimensional Cascade - universes being created and destroyed
  void _drawDimensionalCascade(Canvas canvas, double techLevel) {
    final fixedRandom = Random(999);
    final universeCount = (12 * techLevel).round();
    
    for (int i = 0; i < universeCount; i++) {
      final angle = fixedRandom.nextDouble() * 2 * pi - _rotation * 0.3;
      final dist = 130 + fixedRandom.nextDouble() * 70;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist;
      final size = 8 + fixedRandom.nextDouble() * 12;
      
      // Birth/death cycle based on time
      final lifecycle = ((_pulse + i * 0.5) % 4) / 4; // 0 to 1 cycle
      final alpha = sin(lifecycle * pi) * 0.7; // Fade in and out
      
      // Universe bubble
      final hue = (i * 30 + _pulse * 20) % 360;
      final universeColor = HSVColor.fromAHSV(alpha.clamp(0.1, 0.7), hue, 0.9, 1.0).toColor();
      
      // Outer glow
      canvas.drawCircle(
        Offset(x, y),
        size + 5,
        Paint()
          ..color = universeColor.withValues(alpha: alpha * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      
      // Universe membrane
      canvas.drawCircle(
        Offset(x, y),
        size,
        Paint()
          ..color = universeColor.withValues(alpha: alpha * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      
      // Inner galaxy spiral (tiny detail)
      if (size > 12 && alpha > 0.3) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(_rotation + i);
        
        final spiralPath = Path();
        for (double t = 0; t < 4 * pi; t += 0.3) {
          final r = t * size / (6 * pi);
          final sx = cos(t) * r;
          final sy = sin(t) * r * 0.4; // Tilted galaxy
          if (t == 0) {
            spiralPath.moveTo(sx, sy);
          } else {
            spiralPath.lineTo(sx, sy);
          }
        }
        
        canvas.drawPath(
          spiralPath,
          Paint()
            ..color = Colors.white.withValues(alpha: alpha * 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
        
        canvas.restore();
      }
    }
  }

  /// Cosmic Watchers - ancient entities at the edge of perception
  void _drawCosmicWatchers(Canvas canvas, double techLevel) {
    final watcherCount = 6;
    
    for (int i = 0; i < watcherCount; i++) {
      final angle = (i / watcherCount) * 2 * pi + _wavePhase * 0.1;
      final dist = 200 + sin(_pulse * 0.5 + i * 2) * 15;
      final x = cos(angle) * dist;
      final y = sin(angle) * dist;
      
      // Watcher body - ethereal presence
      final watcherPath = Path();
      watcherPath.moveTo(x, y - 25);
      watcherPath.quadraticBezierTo(x + 15, y, x, y + 25);
      watcherPath.quadraticBezierTo(x - 15, y, x, y - 25);
      
      canvas.drawPath(
        watcherPath,
        Paint()
          ..color = const Color(0xFF3D0066).withValues(alpha: 0.3 * techLevel)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      
      // Watcher eye
      final eyeGlow = 0.5 + sin(_pulse * 3 + i) * 0.3;
      canvas.drawCircle(
        Offset(x, y - 5),
        4 + sin(_pulse * 2 + i) * 1,
        Paint()
          ..color = const Color(0xFFFF00FF).withValues(alpha: eyeGlow * techLevel)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      
      canvas.drawCircle(
        Offset(x, y - 5),
        2,
        Paint()..color = Colors.white.withValues(alpha: eyeGlow * techLevel),
      );
    }
  }

  /// Logic Rewrite Effect - reality being overwritten with new rules
  void _drawLogicRewriteEffect(Canvas canvas, double techLevel) {
    // Glitch lines - reality code being rewritten
    final fixedRandom = Random(123);
    final glitchCount = (20 * techLevel).round();
    
    for (int i = 0; i < glitchCount; i++) {
      final y = (fixedRandom.nextDouble() - 0.5) * 400;
      final x = (fixedRandom.nextDouble() - 0.5) * 400;
      final width = 20 + fixedRandom.nextDouble() * 60;
      final height = 2 + fixedRandom.nextDouble() * 4;
      
      // Glitch appears and disappears
      final glitchPhase = (_pulse * 5 + i * 0.7) % 2;
      if (glitchPhase < 0.3) {
        final hue = fixedRandom.nextDouble() * 360;
        canvas.drawRect(
          Rect.fromLTWH(x, y, width, height),
          Paint()
            ..color = HSVColor.fromAHSV(0.8, hue, 1.0, 1.0).toColor()
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
    
    // Floating symbols - mathematical constants being rewritten
    final symbols = ['∞', 'Ω', 'π', 'Σ', 'Δ', '∀', '∃', 'ℵ'];
    for (int i = 0; i < 5; i++) {
      final symbolAngle = (i / 5) * 2 * pi + _rotation * 0.5;
      final symbolDist = 90 + sin(_pulse + i) * 10;
      final sx = cos(symbolAngle) * symbolDist;
      final sy = sin(symbolAngle) * symbolDist;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbols[i % symbols.length],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.4 * techLevel),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(sx, sy);
      canvas.rotate(_rotation + i);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
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
  /// REDESIGNED: Mature, realistic sun with animated sunspots and solar flares
  void _drawSun(Canvas canvas, double techLevel) {
    final sunRadius = 100.0;
    
    // Layer 1: Deep outer corona with realistic plasma glow
    _drawSolarCorona(canvas, sunRadius);
    
    // Layer 2: Dynamic solar flares and prominences
    _drawRealisticSolarFlares(canvas, sunRadius);
    
    // Layer 3: Sun surface with convection granulation
    _drawSunSurface(canvas, sunRadius);
    
    // Layer 4: Animated sunspot regions with umbra/penumbra
    _drawRealisticSunspots(canvas, sunRadius);
    
    // Layer 5: Surface plasma flow and turbulence
    _drawSurfacePlasmaFlow(canvas, sunRadius);
    
    // Layer 6: Chromosphere edge glow
    _drawChromosphere(canvas, sunRadius);
    
    // Dyson swarm elements
    if (techLevel > 0.1) {
      _drawDysonSwarm(canvas, sunRadius, techLevel);
    }
    
    // Dyson sphere progress
    if (techLevel > 0.5) {
      _drawDysonSphereProgress(canvas, sunRadius, techLevel);
    }
  }
  
  /// Realistic solar corona with streaming plasma
  void _drawSolarCorona(Canvas canvas, double radius) {
    // Outer diffuse corona
    for (int i = 6; i > 0; i--) {
      final coronaRadius = radius + i * 35;
      final coronaAlpha = 0.08 / i;
      
      // Corona color shifts from yellow-white near sun to red-orange further out
      final coronaColor = Color.lerp(
        const Color(0xFFFFE4B5), // Moccasin near sun
        const Color(0xFFFF4500), // OrangeRed far out
        i / 6.0,
      )!;
      
      canvas.drawCircle(
        Offset.zero,
        coronaRadius,
        Paint()
          ..color = coronaColor.withValues(alpha: coronaAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 25.0 * i),
      );
    }
    
    // Coronal streamers - plasma flowing outward
    final streamerCount = 16;
    for (int i = 0; i < streamerCount; i++) {
      final baseAngle = (i / streamerCount) * 2 * pi + _rotation * 0.05;
      final streamerLength = 60 + 30 * sin(_wavePhase * 0.5 + i * 0.7);
      final streamerWidth = 8 + 4 * sin(_pulse * 0.3 + i);
      
      final path = Path();
      path.moveTo(
        cos(baseAngle) * (radius + 5),
        sin(baseAngle) * (radius + 5),
      );
      
      // Wavy streamer path
      for (double t = 0; t <= 1.0; t += 0.1) {
        final dist = radius + 5 + streamerLength * t;
        final wobble = sin(_wavePhase * 2 + t * 4 + i) * 5 * t;
        final angle = baseAngle + wobble * 0.02;
        path.lineTo(cos(angle) * dist, sin(angle) * dist);
      }
      
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.15)
          ..strokeWidth = streamerWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }
  
  /// Realistic solar flares - plasma eruptions from the surface
  void _drawRealisticSolarFlares(Canvas canvas, double radius) {
    final fixedRandom = Random(314);
    final flareCount = 6;
    
    for (int i = 0; i < flareCount; i++) {
      // Each flare has different timing for natural look
      final flarePhase = (_pulse * 0.8 + i * 1.2) % (2 * pi);
      final flareIntensity = (sin(flarePhase) + 1) / 2; // 0 to 1
      
      if (flareIntensity < 0.2) continue; // Flare not active
      
      final baseAngle = (i / flareCount) * 2 * pi + fixedRandom.nextDouble() * 0.5;
      final maxHeight = 40 + fixedRandom.nextDouble() * 50;
      final flareHeight = maxHeight * flareIntensity;
      final flareWidth = 15 + fixedRandom.nextDouble() * 20;
      
      // Draw flare arc (prominence loop)
      final path = Path();
      final startAngle = baseAngle - flareWidth * 0.005;
      final endAngle = baseAngle + flareWidth * 0.005;
      
      path.moveTo(cos(startAngle) * radius, sin(startAngle) * radius);
      
      // Bezier curve for the flare arc
      final controlDist = radius + flareHeight * 1.3;
      final controlAngle = baseAngle + sin(_wavePhase + i) * 0.1;
      
      path.quadraticBezierTo(
        cos(controlAngle) * controlDist,
        sin(controlAngle) * controlDist,
        cos(endAngle) * radius,
        sin(endAngle) * radius,
      );
      
      // Draw flare with gradient-like effect
      for (int layer = 3; layer > 0; layer--) {
        final layerAlpha = 0.25 / layer * flareIntensity;
        final layerWidth = (8 + layer * 4) * flareIntensity;
        
        canvas.drawPath(
          path,
          Paint()
            ..color = Color.lerp(
              const Color(0xFFFFFFE0), // Light yellow core
              const Color(0xFFFF4500), // OrangeRed outer
              layer / 3.0,
            )!.withValues(alpha: layerAlpha)
            ..strokeWidth = layerWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 * layer),
        );
      }
      
      // Hot plasma particles along the flare
      if (flareIntensity > 0.5) {
        for (int p = 0; p < 8; p++) {
          final t = p / 8.0;
          final particleAngle = startAngle + (endAngle - startAngle) * t;
          final particleDist = radius + flareHeight * sin(t * pi) * 0.9;
          final particleX = cos(particleAngle + sin(_pulse * 3 + p) * 0.05) * particleDist;
          final particleY = sin(particleAngle + sin(_pulse * 3 + p) * 0.05) * particleDist;
          
          canvas.drawCircle(
            Offset(particleX, particleY),
            2 + sin(_pulse * 5 + p) * 1,
            Paint()
              ..color = const Color(0xFFFFFF80).withValues(alpha: 0.6 * flareIntensity)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      }
    }
  }
  
  /// Sun surface with convection cell granulation
  void _drawSunSurface(Canvas canvas, double radius) {
    // Base sun gradient - photosphere
    final sunGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 1.0,
      colors: const [
        Color(0xFFFFFFF0), // Ivory white hot center
        Color(0xFFFFEE58), // Bright yellow
        Color(0xFFFFB300), // Amber
        Color(0xFFFF8F00), // Dark orange
        Color(0xFFE65100), // Deep orange at limb
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
    
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()..shader = sunGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: radius),
      ),
    );
    
    // Granulation - convection cells on the surface
    _drawGranulation(canvas, radius);
  }
  
  /// Solar granulation - convection cell pattern
  void _drawGranulation(Canvas canvas, double radius) {
    final fixedRandom = Random(628);
    final cellCount = 80;
    
    for (int i = 0; i < cellCount; i++) {
      // Position on sun surface (spherical projection)
      final theta = fixedRandom.nextDouble() * pi - pi / 2; // latitude
      final phi = fixedRandom.nextDouble() * 2 * pi; // longitude
      
      // Only draw cells on visible hemisphere
      final visibleFactor = cos(phi + _rotation * 0.15);
      if (visibleFactor < 0.1) continue;
      
      final x = radius * 0.9 * cos(theta) * sin(phi + _rotation * 0.15);
      final y = radius * 0.9 * sin(theta);
      
      // Cell size varies - larger cells toward center
      final baseCellSize = 4 + fixedRandom.nextDouble() * 6;
      final cellSize = baseCellSize * visibleFactor;
      
      // Granulation animation - cells brighten and dim
      final cellPhase = (_pulse * 0.5 + i * 0.3) % (2 * pi);
      final brightness = 0.7 + 0.3 * sin(cellPhase);
      
      // Draw convection cell - bright center, darker edge
      canvas.drawCircle(
        Offset(x, y),
        cellSize,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color(0xFFFFFFE0).withValues(alpha: 0.3 * brightness * visibleFactor),
              Color(0xFFFFB300).withValues(alpha: 0.1 * brightness * visibleFactor),
            ],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: cellSize)),
      );
      
      // Dark intergranular lanes between cells
      if (fixedRandom.nextDouble() > 0.7) {
        canvas.drawCircle(
          Offset(x, y),
          cellSize,
          Paint()
            ..color = const Color(0xFF8B4513).withValues(alpha: 0.08 * visibleFactor)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }
  
  /// Realistic sunspots with umbra, penumbra, and movement
  void _drawRealisticSunspots(Canvas canvas, double radius) {
    final fixedRandom = Random(42);
    final spotCount = 7;
    
    for (int i = 0; i < spotCount; i++) {
      // Sunspots drift across the surface (solar rotation)
      final baseLon = fixedRandom.nextDouble() * 2 * pi;
      final lat = (fixedRandom.nextDouble() - 0.5) * 0.6; // ±30° latitude band
      final lon = baseLon + _rotation * 0.1; // Slow drift
      
      // Check visibility (on front hemisphere)
      final visibleFactor = cos(lon);
      if (visibleFactor < 0.2) continue;
      
      final x = radius * 0.85 * cos(lat) * sin(lon);
      final y = radius * 0.85 * sin(lat);
      
      // Spot size - some spots are larger active regions
      final isActiveRegion = fixedRandom.nextDouble() > 0.7;
      final baseSpotSize = isActiveRegion ? 12 + fixedRandom.nextDouble() * 8 : 5 + fixedRandom.nextDouble() * 8;
      final spotSize = baseSpotSize * visibleFactor;
      
      if (spotSize < 3) continue;
      
      // Penumbra (outer lighter region)
      final penumbraSize = spotSize * 1.8;
      canvas.drawCircle(
        Offset(x, y),
        penumbraSize,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF5D4037).withValues(alpha: 0.5 * visibleFactor), // Brown center
              const Color(0xFF8D6E63).withValues(alpha: 0.3 * visibleFactor), // Light brown
              const Color(0xFFFFB300).withValues(alpha: 0.0), // Fade to surface
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: penumbraSize)),
      );
      
      // Penumbra filaments - radial streaks
      for (int f = 0; f < 12; f++) {
        final fAngle = (f / 12) * 2 * pi + _rotation * 0.2;
        final fLength = penumbraSize * 0.4;
        
        canvas.drawLine(
          Offset(x + cos(fAngle) * spotSize * 0.8, y + sin(fAngle) * spotSize * 0.8),
          Offset(x + cos(fAngle) * (spotSize + fLength), y + sin(fAngle) * (spotSize + fLength)),
          Paint()
            ..color = const Color(0xFF4E342E).withValues(alpha: 0.2 * visibleFactor)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );
      }
      
      // Umbra (dark center)
      canvas.drawCircle(
        Offset(x, y),
        spotSize,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF1A1A1A).withValues(alpha: 0.8 * visibleFactor), // Very dark center
              const Color(0xFF3E2723).withValues(alpha: 0.6 * visibleFactor), // Dark brown edge
            ],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: spotSize)),
      );
      
      // Light bridge (bright lane across large spots)
      if (isActiveRegion && spotSize > 10) {
        final bridgeAngle = fixedRandom.nextDouble() * pi;
        canvas.drawLine(
          Offset(x + cos(bridgeAngle) * spotSize * 0.6, y + sin(bridgeAngle) * spotSize * 0.6),
          Offset(x - cos(bridgeAngle) * spotSize * 0.6, y - sin(bridgeAngle) * spotSize * 0.6),
          Paint()
            ..color = const Color(0xFFFFB300).withValues(alpha: 0.3 * visibleFactor)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }
  
  /// Surface plasma flow - hot material movement
  void _drawSurfacePlasmaFlow(Canvas canvas, double radius) {
    final flowCount = 20;
    
    for (int i = 0; i < flowCount; i++) {
      final angle = (i / flowCount) * 2 * pi + _wavePhase * 0.3;
      final flowRadius = radius * (0.7 + 0.2 * sin(_pulse * 0.5 + i * 0.8));
      
      // Only draw on visible part
      if (cos(angle) < 0) continue;
      
      final x = cos(angle) * flowRadius;
      final y = sin(angle) * flowRadius * 0.9;
      
      // Plasma flow streaks
      final flowLength = 8 + 6 * sin(_pulse + i);
      final flowAngle = angle + pi / 2 + sin(_wavePhase + i) * 0.3;
      
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(flowAngle) * flowLength, y + sin(flowAngle) * flowLength),
        Paint()
          ..color = const Color(0xFFFFFFE0).withValues(alpha: 0.2)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }
  
  /// Chromosphere - thin reddish layer at sun's edge
  void _drawChromosphere(Canvas canvas, double radius) {
    // Chromospheric rim - reddish glow at the edge
    canvas.drawCircle(
      Offset.zero,
      radius + 3,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFF6B6B).withValues(alpha: 0.0),
            const Color(0xFFFF6B6B).withValues(alpha: 0.4),
            const Color(0xFFFF4444).withValues(alpha: 0.2),
            Colors.transparent,
          ],
          stops: const [0.0, 0.92, 0.96, 0.98, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius + 5)),
    );
    
    // Spicules - small jets from chromosphere
    final spiculeCount = 30;
    for (int i = 0; i < spiculeCount; i++) {
      final angle = (i / spiculeCount) * 2 * pi + _wavePhase * 0.8;
      final height = 5 + 8 * sin(_pulse * 2 + i * 0.5);
      
      final startX = cos(angle) * radius;
      final startY = sin(angle) * radius;
      final endX = cos(angle + sin(_wavePhase + i) * 0.02) * (radius + height);
      final endY = sin(angle + sin(_wavePhase + i) * 0.02) * (radius + height);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.3)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }
  
  // Legacy methods removed - replaced by _drawRealisticSolarFlares and _drawRealisticSunspots
  
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
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.2)
      ..strokeWidth = 0.8;
    
    // Small, subtle timeline threads positioned around the edges (not over center)
    // Reduced from massive spirals to small decorative elements
    final threadCount = 6;
    final fixedRandom = Random(333);
    
    for (int thread = 0; thread < threadCount; thread++) {
      // Position threads in a ring around the center, away from the creation point
      final baseAngle = (thread / threadCount) * 2 * pi;
      final threadDist = 120 + fixedRandom.nextDouble() * 40; // Far from center
      final centerX = cos(baseAngle) * threadDist;
      final centerY = sin(baseAngle) * threadDist;
      
      final path = Path();
      
      // Small spiral at each position
      for (double t = 0; t < 3 * pi; t += 0.15) {
        final r = 5 + t * 3; // Much smaller spiral (max ~33 pixels)
        final angle = t * 0.8 + _wavePhase * 0.5 + thread;
        final x = centerX + cos(angle) * r;
        final y = centerY + sin(angle) * r * 0.5; // Flattened
        
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, threadPaint);
      
      // Small glow at the center of each thread
      canvas.drawCircle(
        Offset(centerX, centerY),
        3,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
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
