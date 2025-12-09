import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/era_data.dart';

/// Premium Ship Painters for Kardashev: Ascension
/// Each Era has a unique, beautifully designed ship that matches the game's premium visuals.

/// Base class for ship painters
abstract class ShipPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 for continuous animation
  final bool isMovingRight; // Direction of flight
  final Color primaryColor;
  final Color accentColor;
  
  ShipPainter({
    required this.animationValue,
    required this.isMovingRight,
    required this.primaryColor,
    required this.accentColor,
  });
  
  /// Get the appropriate ship painter for the current era
  static ShipPainter forEra(
    Era era, {
    required double animationValue,
    required bool isMovingRight,
  }) {
    switch (era) {
      case Era.planetary:
        return PlanetaryShipPainter(
          animationValue: animationValue,
          isMovingRight: isMovingRight,
          primaryColor: const Color(0xFF00D9FF), // Cyan
          accentColor: const Color(0xFFFFD700), // Gold
        );
      case Era.stellar:
        return StellarShipPainter(
          animationValue: animationValue,
          isMovingRight: isMovingRight,
          primaryColor: const Color(0xFFFFB347), // Orange
          accentColor: const Color(0xFFFF6B35), // Solar orange
        );
      case Era.galactic:
        return GalacticShipPainter(
          animationValue: animationValue,
          isMovingRight: isMovingRight,
          primaryColor: const Color(0xFFAA77FF), // Violet
          accentColor: const Color(0xFFE040FB), // Magenta
        );
      case Era.universal:
        return UniversalShipPainter(
          animationValue: animationValue,
          isMovingRight: isMovingRight,
          primaryColor: const Color(0xFFFF6B9D), // Cosmic pink
          accentColor: const Color(0xFF00FFFF), // Cyan
        );
      case Era.multiversal:
        return MultiversalShipPainter(
          animationValue: animationValue,
          isMovingRight: isMovingRight,
          primaryColor: const Color(0xFFE0B0FF), // Prismatic
          accentColor: const Color(0xFF00FFAB), // Void Green
        );
    }
  }
  
  @override
  bool shouldRepaint(covariant ShipPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.isMovingRight != isMovingRight;
  }
}

/// Era I - Planetary: Sleek alien scout ship
/// Design: Smooth, aerodynamic shape with glowing engines and energy core
class PlanetaryShipPainter extends ShipPainter {
  PlanetaryShipPainter({
    required super.animationValue,
    required super.isMovingRight,
    required super.primaryColor,
    required super.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    
    // Flip if moving left
    if (!isMovingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    
    // Ship dimensions
    final shipLength = size.width * 0.8;
    final shipHeight = size.height * 0.35;
    
    // Engine glow (pulsing)
    final pulseValue = 0.7 + 0.3 * sin(animationValue * 2 * pi);
    
    // Draw engine exhaust trail
    _drawEngineTrail(canvas, centerX - shipLength * 0.35, centerY, pulseValue);
    
    // Draw main hull
    _drawHull(canvas, centerX, centerY, shipLength, shipHeight);
    
    // Draw cockpit
    _drawCockpit(canvas, centerX + shipLength * 0.2, centerY, shipLength * 0.2, shipHeight * 0.5);
    
    // Draw energy core (glowing center)
    _drawEnergyCore(canvas, centerX - shipLength * 0.05, centerY, shipHeight * 0.3, pulseValue);
    
    // Draw wing details
    _drawWingDetails(canvas, centerX, centerY, shipLength, shipHeight);
    
    // Draw front lights
    _drawNavigationLights(canvas, centerX + shipLength * 0.35, centerY, pulseValue);
    
    canvas.restore();
  }
  
  void _drawEngineTrail(Canvas canvas, double x, double y, double pulse) {
    // Multiple layers of engine glow
    for (int i = 3; i >= 0; i--) {
      final trailLength = 25 + i * 12 * pulse;
      final trailWidth = 4 + i * 3;
      final alpha = (0.3 - i * 0.06) * pulse;
      
      final trailGradient = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: alpha),
          primaryColor.withValues(alpha: alpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      );
      
      final trailRect = Rect.fromCenter(
        center: Offset(x - trailLength / 2, y),
        width: trailLength,
        height: trailWidth.toDouble(),
      );
      
      canvas.drawRect(
        trailRect,
        Paint()
          ..shader = trailGradient.createShader(trailRect)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, trailWidth / 2),
      );
    }
    
    // Core engine flame
    final flamePath = Path()
      ..moveTo(x, y - 4)
      ..lineTo(x - 15 * pulse, y)
      ..lineTo(x, y + 4)
      ..close();
    
    canvas.drawPath(
      flamePath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    canvas.drawPath(
      flamePath,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }
  
  void _drawHull(Canvas canvas, double cx, double cy, double length, double height) {
    final hullPath = Path();
    
    // Streamlined hull shape
    hullPath.moveTo(cx - length * 0.4, cy);
    hullPath.quadraticBezierTo(cx - length * 0.3, cy - height * 0.6, cx, cy - height * 0.5);
    hullPath.quadraticBezierTo(cx + length * 0.3, cy - height * 0.3, cx + length * 0.4, cy);
    hullPath.quadraticBezierTo(cx + length * 0.3, cy + height * 0.3, cx, cy + height * 0.5);
    hullPath.quadraticBezierTo(cx - length * 0.3, cy + height * 0.6, cx - length * 0.4, cy);
    hullPath.close();
    
    // Hull gradient
    final hullGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF445566),
        const Color(0xFF223344),
        const Color(0xFF112233),
      ],
    );
    
    canvas.drawPath(
      hullPath,
      Paint()..shader = hullGradient.createShader(hullPath.getBounds()),
    );
    
    // Hull edge highlight
    canvas.drawPath(
      hullPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    
    // Top highlight
    final highlightPath = Path();
    highlightPath.moveTo(cx - length * 0.3, cy - height * 0.3);
    highlightPath.quadraticBezierTo(cx, cy - height * 0.45, cx + length * 0.25, cy - height * 0.2);
    
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
  
  void _drawCockpit(Canvas canvas, double x, double y, double width, double height) {
    final cockpitPath = Path();
    cockpitPath.addOval(Rect.fromCenter(
      center: Offset(x, y),
      width: width,
      height: height,
    ));
    
    // Cockpit gradient (glass effect)
    final cockpitGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        primaryColor.withValues(alpha: 0.6),
        primaryColor.withValues(alpha: 0.3),
        const Color(0xFF001122).withValues(alpha: 0.8),
      ],
    );
    
    canvas.drawPath(
      cockpitPath,
      Paint()..shader = cockpitGradient.createShader(cockpitPath.getBounds()),
    );
    
    // Cockpit reflection
    canvas.drawPath(
      cockpitPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
  
  void _drawEnergyCore(Canvas canvas, double x, double y, double radius, double pulse) {
    // Outer glow
    canvas.drawCircle(
      Offset(x, y),
      radius * 2,
      Paint()
        ..color = accentColor.withValues(alpha: 0.2 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius),
    );
    
    // Core
    final coreGradient = RadialGradient(
      colors: [
        Colors.white,
        accentColor,
        accentColor.withValues(alpha: 0.5),
      ],
    );
    
    canvas.drawCircle(
      Offset(x, y),
      radius * pulse,
      Paint()..shader = coreGradient.createShader(
        Rect.fromCircle(center: Offset(x, y), radius: radius),
      ),
    );
  }
  
  void _drawWingDetails(Canvas canvas, double cx, double cy, double length, double height) {
    // Wing panel lines
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    
    // Top wing line
    canvas.drawLine(
      Offset(cx - length * 0.15, cy - height * 0.3),
      Offset(cx + length * 0.15, cy - height * 0.2),
      linePaint,
    );
    
    // Bottom wing line
    canvas.drawLine(
      Offset(cx - length * 0.15, cy + height * 0.3),
      Offset(cx + length * 0.15, cy + height * 0.2),
      linePaint,
    );
  }
  
  void _drawNavigationLights(Canvas canvas, double x, double y, double pulse) {
    // Front navigation light
    canvas.drawCircle(
      Offset(x, y),
      2,
      Paint()
        ..color = Colors.white.withValues(alpha: pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    canvas.drawCircle(
      Offset(x, y),
      1,
      Paint()..color = Colors.white,
    );
  }
}

/// Era II - Stellar: Solar harvesting vessel
/// Design: Angular with solar collectors, golden/orange energy streams
class StellarShipPainter extends ShipPainter {
  StellarShipPainter({
    required super.animationValue,
    required super.isMovingRight,
    required super.primaryColor,
    required super.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    
    if (!isMovingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    
    final pulse = 0.7 + 0.3 * sin(animationValue * 2 * pi);
    
    // Draw solar flare trail
    _drawSolarTrail(canvas, centerX - 25, centerY, pulse);
    
    // Draw solar collector wings
    _drawSolarCollectors(canvas, centerX, centerY, pulse);
    
    // Draw main hull (more angular, industrial)
    _drawAngularHull(canvas, centerX, centerY);
    
    // Draw plasma core
    _drawPlasmaCore(canvas, centerX, centerY, pulse);
    
    // Draw heat radiators
    _drawHeatRadiators(canvas, centerX, centerY, pulse);
    
    canvas.restore();
  }
  
  void _drawSolarTrail(Canvas canvas, double x, double y, double pulse) {
    // Solar plasma exhaust
    for (int i = 0; i < 5; i++) {
      final trailOffset = i * 8.0;
      final alpha = (0.5 - i * 0.1) * pulse;
      
      final flamePath = Path()
        ..moveTo(x - trailOffset, y - 6 + sin(animationValue * 4 * pi + i) * 2)
        ..lineTo(x - trailOffset - 20 - i * 5, y)
        ..lineTo(x - trailOffset, y + 6 + sin(animationValue * 4 * pi + i + 1) * 2)
        ..close();
      
      canvas.drawPath(
        flamePath,
        Paint()
          ..color = primaryColor.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + i.toDouble()),
      );
    }
    
    // Core flame
    final coreFlamePath = Path()
      ..moveTo(x, y - 4)
      ..lineTo(x - 25 * pulse, y)
      ..lineTo(x, y + 4)
      ..close();
    
    final flameGradient = LinearGradient(
      colors: [
        Colors.white,
        accentColor,
        primaryColor.withValues(alpha: 0),
      ],
    );
    
    canvas.drawPath(
      coreFlamePath,
      Paint()..shader = flameGradient.createShader(coreFlamePath.getBounds()),
    );
  }
  
  void _drawSolarCollectors(Canvas canvas, double cx, double cy, double pulse) {
    // Upper solar panel
    final upperPanel = Path()
      ..moveTo(cx - 15, cy - 8)
      ..lineTo(cx - 5, cy - 18)
      ..lineTo(cx + 20, cy - 18)
      ..lineTo(cx + 10, cy - 8)
      ..close();
    
    // Lower solar panel
    final lowerPanel = Path()
      ..moveTo(cx - 15, cy + 8)
      ..lineTo(cx - 5, cy + 18)
      ..lineTo(cx + 20, cy + 18)
      ..lineTo(cx + 10, cy + 8)
      ..close();
    
    // Panel gradient
    final panelGradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.7),
        accentColor.withValues(alpha: 0.5),
        primaryColor.withValues(alpha: 0.3),
      ],
    );
    
    for (final panel in [upperPanel, lowerPanel]) {
      canvas.drawPath(
        panel,
        Paint()..shader = panelGradient.createShader(panel.getBounds()),
      );
      
      // Panel glow
      canvas.drawPath(
        panel,
        Paint()
          ..color = primaryColor.withValues(alpha: 0.3 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      
      // Panel edge
      canvas.drawPath(
        panel,
        Paint()
          ..color = accentColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    
    // Panel energy lines
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5 * pulse)
      ..strokeWidth = 0.5;
    
    for (int i = 0; i < 3; i++) {
      final offset = -10 + i * 10.0;
      canvas.drawLine(
        Offset(cx + offset, cy - 10),
        Offset(cx + offset + 5, cy - 16),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx + offset, cy + 10),
        Offset(cx + offset + 5, cy + 16),
        linePaint,
      );
    }
  }
  
  void _drawAngularHull(Canvas canvas, double cx, double cy) {
    final hullPath = Path()
      ..moveTo(cx - 20, cy)
      ..lineTo(cx - 10, cy - 6)
      ..lineTo(cx + 25, cy - 4)
      ..lineTo(cx + 30, cy)
      ..lineTo(cx + 25, cy + 4)
      ..lineTo(cx - 10, cy + 6)
      ..close();
    
    final hullGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF664422),
        const Color(0xFF443311),
        const Color(0xFF332211),
      ],
    );
    
    canvas.drawPath(
      hullPath,
      Paint()..shader = hullGradient.createShader(hullPath.getBounds()),
    );
    
    // Hull highlight
    canvas.drawPath(
      hullPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
  
  void _drawPlasmaCore(Canvas canvas, double cx, double cy, double pulse) {
    // Rotating plasma energy
    for (int i = 0; i < 4; i++) {
      final angle = (animationValue * 2 * pi) + (i * pi / 2);
      final orbX = cx + cos(angle) * 4;
      final orbY = cy + sin(angle) * 4;
      
      canvas.drawCircle(
        Offset(orbX, orbY),
        2,
        Paint()
          ..color = accentColor.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    
    // Central core
    canvas.drawCircle(
      Offset(cx, cy),
      6,
      Paint()
        ..color = accentColor.withValues(alpha: 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    
    final coreGradient = RadialGradient(
      colors: [
        Colors.white,
        accentColor,
        primaryColor,
      ],
    );
    
    canvas.drawCircle(
      Offset(cx, cy),
      4 * pulse,
      Paint()..shader = coreGradient.createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: 4),
      ),
    );
  }
  
  void _drawHeatRadiators(Canvas canvas, double cx, double cy, double pulse) {
    // Small radiator fins
    final finPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(Offset(cx - 15, cy - 5), Offset(cx - 18, cy - 8), finPaint);
    canvas.drawLine(Offset(cx - 15, cy + 5), Offset(cx - 18, cy + 8), finPaint);
  }
}

/// Era III - Galactic: Majestic interstellar cruiser
/// Design: Elegant curved hull with purple energy conduits, spiral galaxy patterns
class GalacticShipPainter extends ShipPainter {
  GalacticShipPainter({
    required super.animationValue,
    required super.isMovingRight,
    required super.primaryColor,
    required super.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    
    if (!isMovingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    
    final pulse = 0.7 + 0.3 * sin(animationValue * 2 * pi);
    
    // Draw warp trail (purple energy wake)
    _drawWarpTrail(canvas, centerX - 25, centerY, pulse);
    
    // Draw main hull (elegant cruiser shape)
    _drawCruiserHull(canvas, centerX, centerY);
    
    // Draw energy conduits
    _drawEnergyConduits(canvas, centerX, centerY, pulse);
    
    // Draw spiral galaxy core
    _drawGalaxyCore(canvas, centerX, centerY, pulse);
    
    // Draw wing nacelles
    _drawNacelles(canvas, centerX, centerY, pulse);
    
    canvas.restore();
  }
  
  void _drawWarpTrail(Canvas canvas, double x, double y, double pulse) {
    // Multiple warp rings
    for (int i = 0; i < 4; i++) {
      final ringOffset = i * 12.0 + sin(animationValue * 4 * pi) * 3;
      final ringAlpha = (0.4 - i * 0.1) * pulse;
      final ringSize = 15.0 - i * 2;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - ringOffset, y),
          width: 6,
          height: ringSize,
        ),
        Paint()
          ..color = primaryColor.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    
    // Energy trail
    final trailGradient = LinearGradient(
      colors: [
        accentColor.withValues(alpha: 0.6 * pulse),
        primaryColor.withValues(alpha: 0.3),
        Colors.transparent,
      ],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(x - 40, y - 3, 35, 6),
      Paint()
        ..shader = trailGradient.createShader(Rect.fromLTWH(x - 40, y - 3, 35, 6))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
  
  void _drawCruiserHull(Canvas canvas, double cx, double cy) {
    // Elegant curved hull
    final hullPath = Path()
      ..moveTo(cx - 25, cy)
      ..quadraticBezierTo(cx - 15, cy - 10, cx + 5, cy - 8)
      ..quadraticBezierTo(cx + 25, cy - 5, cx + 35, cy)
      ..quadraticBezierTo(cx + 25, cy + 5, cx + 5, cy + 8)
      ..quadraticBezierTo(cx - 15, cy + 10, cx - 25, cy)
      ..close();
    
    // Dark purple metallic gradient
    final hullGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF553388),
        const Color(0xFF332255),
        const Color(0xFF221144),
      ],
    );
    
    canvas.drawPath(
      hullPath,
      Paint()..shader = hullGradient.createShader(hullPath.getBounds()),
    );
    
    // Hull edge glow
    canvas.drawPath(
      hullPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    
    // Hull highlight
    final highlightPath = Path()
      ..moveTo(cx - 15, cy - 6)
      ..quadraticBezierTo(cx + 5, cy - 7, cx + 25, cy - 3);
    
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
  
  void _drawEnergyConduits(Canvas canvas, double cx, double cy, double pulse) {
    final conduitPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6 * pulse)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Top conduit
    canvas.drawLine(
      Offset(cx - 10, cy - 6),
      Offset(cx + 20, cy - 4),
      conduitPaint,
    );
    
    // Bottom conduit
    canvas.drawLine(
      Offset(cx - 10, cy + 6),
      Offset(cx + 20, cy + 4),
      conduitPaint,
    );
    
    // Flowing energy particles
    for (int i = 0; i < 3; i++) {
      final particlePos = ((animationValue + i * 0.33) % 1.0) * 30 - 10;
      canvas.drawCircle(
        Offset(cx + particlePos, cy - 5),
        1.5,
        Paint()
          ..color = accentColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(
        Offset(cx + particlePos, cy + 5),
        1.5,
        Paint()
          ..color = accentColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }
  
  void _drawGalaxyCore(Canvas canvas, double cx, double cy, double pulse) {
    // Spiral galaxy effect in the core
    canvas.drawCircle(
      Offset(cx + 5, cy),
      10,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    
    // Rotating spiral arms
    for (int arm = 0; arm < 2; arm++) {
      final armPath = Path();
      for (double t = 0; t < 2; t += 0.1) {
        final angle = animationValue * 2 * pi + arm * pi + t * 1.5;
        final radius = 2 + t * 3;
        final x = cx + 5 + cos(angle) * radius;
        final y = cy + sin(angle) * radius;
        if (t == 0) {
          armPath.moveTo(x, y);
        } else {
          armPath.lineTo(x, y);
        }
      }
      
      canvas.drawPath(
        armPath,
        Paint()
          ..color = accentColor.withValues(alpha: 0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
    
    // Core center
    final coreGradient = RadialGradient(
      colors: [
        Colors.white,
        accentColor,
        primaryColor.withValues(alpha: 0),
      ],
    );
    
    canvas.drawCircle(
      Offset(cx + 5, cy),
      4 * pulse,
      Paint()..shader = coreGradient.createShader(
        Rect.fromCircle(center: Offset(cx + 5, cy), radius: 4),
      ),
    );
  }
  
  void _drawNacelles(Canvas canvas, double cx, double cy, double pulse) {
    // Upper nacelle
    final upperNacelle = Path()
      ..moveTo(cx - 5, cy - 10)
      ..lineTo(cx + 15, cy - 10)
      ..lineTo(cx + 20, cy - 8)
      ..lineTo(cx, cy - 8)
      ..close();
    
    // Lower nacelle
    final lowerNacelle = Path()
      ..moveTo(cx - 5, cy + 10)
      ..lineTo(cx + 15, cy + 10)
      ..lineTo(cx + 20, cy + 8)
      ..lineTo(cx, cy + 8)
      ..close();
    
    final nacellePaint = Paint()
      ..color = const Color(0xFF443366);
    
    canvas.drawPath(upperNacelle, nacellePaint);
    canvas.drawPath(lowerNacelle, nacellePaint);
    
    // Nacelle glow
    canvas.drawCircle(
      Offset(cx - 5, cy - 10),
      3,
      Paint()
        ..color = accentColor.withValues(alpha: 0.5 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(cx - 5, cy + 10),
      3,
      Paint()
        ..color = accentColor.withValues(alpha: 0.5 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}

/// Era IV - Universal: Reality-warping entity vessel
/// Design: Abstract geometric shape that phases/shifts, rainbow energy fields
class UniversalShipPainter extends ShipPainter {
  UniversalShipPainter({
    required super.animationValue,
    required super.isMovingRight,
    required super.primaryColor,
    required super.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    
    if (!isMovingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    
    final pulse = 0.7 + 0.3 * sin(animationValue * 2 * pi);
    
    // Draw dimensional distortion field
    _drawDimensionalField(canvas, centerX, centerY, pulse);
    
    // Draw reality fragments
    _drawRealityFragments(canvas, centerX, centerY, pulse);
    
    // Draw core construct (shifting geometry)
    _drawCoreConstruct(canvas, centerX, centerY, pulse);
    
    // Draw rainbow energy streams
    _drawRainbowStreams(canvas, centerX, centerY);
    
    // Draw central singularity
    _drawSingularityCore(canvas, centerX, centerY, pulse);
    
    canvas.restore();
  }
  
  void _drawDimensionalField(Canvas canvas, double cx, double cy, double pulse) {
    // Warped space effect
    for (int i = 3; i >= 0; i--) {
      final fieldRadius = 30 + i * 8;
      final distortion = sin(animationValue * 2 * pi + i) * 5;
      
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + distortion, cy),
          width: fieldRadius.toDouble(),
          height: fieldRadius * 0.6,
        ),
        Paint()
          ..color = accentColor.withValues(alpha: 0.1 * pulse)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + i.toDouble()),
      );
    }
  }
  
  void _drawRealityFragments(Canvas canvas, double cx, double cy, double pulse) {
    // Floating geometric fragments around the ship
    for (int i = 0; i < 8; i++) {
      final angle = animationValue * pi + i * pi / 4;
      final distance = 18 + sin(animationValue * 3 * pi + i) * 5;
      final fragX = cx + cos(angle) * distance;
      final fragY = cy + sin(angle) * distance * 0.5;
      final fragSize = 3 + sin(animationValue * 4 * pi + i) * 1;
      
      // Rainbow hue for each fragment
      final hue = (i * 45 + animationValue * 360) % 360;
      final fragColor = HSVColor.fromAHSV(0.6 * pulse, hue, 0.8, 1.0).toColor();
      
      // Draw as small diamond
      final fragPath = Path()
        ..moveTo(fragX, fragY - fragSize)
        ..lineTo(fragX + fragSize, fragY)
        ..lineTo(fragX, fragY + fragSize)
        ..lineTo(fragX - fragSize, fragY)
        ..close();
      
      canvas.drawPath(
        fragPath,
        Paint()
          ..color = fragColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }
  
  void _drawCoreConstruct(Canvas canvas, double cx, double cy, double pulse) {
    // Shifting geometric core
    final rotation = animationValue * pi / 2;
    
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    
    // Inner octagon
    final innerPath = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final x = cos(angle) * 12;
      final y = sin(angle) * 12;
      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    
    // Cosmic gradient
    final constructGradient = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: 0.8),
        accentColor.withValues(alpha: 0.5),
        const Color(0xFF220033).withValues(alpha: 0.6),
      ],
    );
    
    canvas.drawPath(
      innerPath,
      Paint()..shader = constructGradient.createShader(
        innerPath.getBounds(),
      ),
    );
    
    // Edge glow
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    
    canvas.restore();
  }
  
  void _drawRainbowStreams(Canvas canvas, double cx, double cy) {
    // Trailing rainbow energy
    for (int i = 0; i < 5; i++) {
      final streamY = cy - 8 + i * 4;
      final hue = (i * 72 + animationValue * 180) % 360;
      final streamColor = HSVColor.fromAHSV(0.6, hue, 0.9, 1.0).toColor();
      
      final streamLength = 25 + sin(animationValue * 3 * pi + i) * 8;
      
      canvas.drawLine(
        Offset(cx - 15, streamY),
        Offset(cx - 15 - streamLength, streamY),
        Paint()
          ..shader = LinearGradient(
            colors: [
              streamColor,
              streamColor.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(cx - 15 - streamLength, streamY - 1, streamLength, 2))
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }
  
  void _drawSingularityCore(Canvas canvas, double cx, double cy, double pulse) {
    // White-hot singularity center
    canvas.drawCircle(
      Offset(cx, cy),
      12,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    
    // Rainbow ring
    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6 + animationValue * 2 * pi;
      final hue = (i * 30) % 360;
      final ringColor = HSVColor.fromAHSV(0.8, hue.toDouble(), 1.0, 1.0).toColor();
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: 8),
        angle,
        pi / 8,
        false,
        Paint()
          ..color = ringColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
    
    // Core
    canvas.drawCircle(
      Offset(cx, cy),
      4,
      Paint()..color = Colors.white,
    );
  }
}

/// Era V - Multiversal: Void entity - transcendent being
/// Design: Amorphous, prismatic form that defies physical shape, void energy
class MultiversalShipPainter extends ShipPainter {
  MultiversalShipPainter({
    required super.animationValue,
    required super.isMovingRight,
    required super.primaryColor,
    required super.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    
    if (!isMovingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    
    final pulse = 0.7 + 0.3 * sin(animationValue * 2 * pi);
    
    // Draw void wake (reality dissolving)
    _drawVoidWake(canvas, centerX - 25, centerY, pulse);
    
    // Draw prismatic aura
    _drawPrismaticAura(canvas, centerX, centerY, pulse);
    
    // Draw amorphous form
    _drawAmorphousForm(canvas, centerX, centerY, pulse);
    
    // Draw void eye
    _drawVoidEye(canvas, centerX, centerY, pulse);
    
    // Draw dimensional tendrils
    _drawDimensionalTendrils(canvas, centerX, centerY, pulse);
    
    canvas.restore();
  }
  
  void _drawVoidWake(Canvas canvas, double x, double y, double pulse) {
    // Reality fragments dissolving
    final random = Random(42); // Fixed seed for consistent pattern
    
    for (int i = 0; i < 12; i++) {
      final fragX = x - 10 - random.nextDouble() * 40;
      final fragY = y - 15 + random.nextDouble() * 30;
      final fragSize = 1 + random.nextDouble() * 3;
      final fragAlpha = (0.5 - (x - fragX).abs() / 60) * pulse;
      
      // Prismatic color
      final hue = (i * 30 + animationValue * 360) % 360;
      final fragColor = HSVColor.fromAHSV(fragAlpha.clamp(0, 1), hue, 0.8, 1.0).toColor();
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset(fragX, fragY), width: fragSize, height: fragSize),
        Paint()
          ..color = fragColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
    
    // Void trail
    final trailGradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.4 * pulse),
        Colors.black.withValues(alpha: 0.8),
        Colors.transparent,
      ],
    );
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 45, height: 15),
      Paint()
        ..shader = trailGradient.createShader(Rect.fromCenter(center: Offset(x, y), width: 45, height: 15))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }
  
  void _drawPrismaticAura(Canvas canvas, double cx, double cy, double pulse) {
    // Shifting prismatic field
    for (int layer = 3; layer >= 0; layer--) {
      final layerRadius = 25 + layer * 5;
      final shift = sin(animationValue * 2 * pi + layer) * 3;
      
      // Each layer shifts color
      final hue = (layer * 90 + animationValue * 120) % 360;
      final layerColor = HSVColor.fromAHSV(0.15 * pulse, hue, 0.7, 1.0).toColor();
      
      final auraPath = Path();
      for (int i = 0; i < 8; i++) {
        final angle = i * pi / 4 + animationValue * 0.5;
        final variation = sin(angle * 3 + animationValue * 4 * pi) * 5;
        final r = layerRadius + variation;
        final px = cx + shift + cos(angle) * r;
        final py = cy + sin(angle) * r * 0.6;
        if (i == 0) {
          auraPath.moveTo(px, py);
        } else {
          auraPath.quadraticBezierTo(
            cx + shift + cos(angle - pi / 8) * (r + 5),
            cy + sin(angle - pi / 8) * (r + 5) * 0.6,
            px, py,
          );
        }
      }
      auraPath.close();
      
      canvas.drawPath(
        auraPath,
        Paint()
          ..color = layerColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + layer.toDouble()),
      );
    }
  }
  
  void _drawAmorphousForm(Canvas canvas, double cx, double cy, double pulse) {
    // Main body - shifting, organic shape
    final formPath = Path();
    
    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final variation = sin(angle * 2 + animationValue * 4 * pi) * 4;
      final r = 15 + variation;
      final px = cx + cos(angle) * r;
      final py = cy + sin(angle) * r * 0.7;
      
      if (i == 0) {
        formPath.moveTo(px, py);
      } else {
        // Smooth curves between points
        final prevAngle = (i - 1) * pi / 6;
        final controlAngle = (angle + prevAngle) / 2;
        final controlR = r + 3;
        formPath.quadraticBezierTo(
          cx + cos(controlAngle) * controlR,
          cy + sin(controlAngle) * controlR * 0.7,
          px, py,
        );
      }
    }
    formPath.close();
    
    // Void gradient
    final formGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      colors: [
        primaryColor.withValues(alpha: 0.6),
        const Color(0xFF2200AA).withValues(alpha: 0.4),
        Colors.black.withValues(alpha: 0.9),
      ],
    );
    
    canvas.drawPath(
      formPath,
      Paint()..shader = formGradient.createShader(formPath.getBounds()),
    );
    
    // Edge shimmer
    canvas.drawPath(
      formPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
  
  void _drawVoidEye(Canvas canvas, double cx, double cy, double pulse) {
    // Central void eye - window to nothingness
    
    // Outer ring (prismatic)
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + animationValue * pi;
      final hue = (i * 45 + animationValue * 180) % 360;
      final ringColor = HSVColor.fromAHSV(0.6, hue, 1.0, 1.0).toColor();
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: 8),
        angle,
        pi / 5,
        false,
        Paint()
          ..color = ringColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
    
    // The void itself - pure black with white edge
    canvas.drawCircle(
      Offset(cx, cy),
      6,
      Paint()..color = Colors.black,
    );
    
    // White hot ring
    canvas.drawCircle(
      Offset(cx, cy),
      5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Inner void spark
    canvas.drawCircle(
      Offset(cx, cy),
      2,
      Paint()
        ..color = primaryColor.withValues(alpha: pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
  
  void _drawDimensionalTendrils(Canvas canvas, double cx, double cy, double pulse) {
    // Ethereal tendrils reaching out
    for (int i = 0; i < 4; i++) {
      final baseAngle = i * pi / 2 + animationValue * pi;
      final tendrilPath = Path();
      tendrilPath.moveTo(cx, cy);
      
      // Wavy tendril
      for (double t = 0; t <= 1; t += 0.1) {
        final angle = baseAngle + sin(t * 2 * pi + animationValue * 4 * pi) * 0.3;
        final distance = 15 + t * 20;
        final tx = cx + cos(angle) * distance;
        final ty = cy + sin(angle) * distance * 0.5;
        tendrilPath.lineTo(tx, ty);
      }
      
      final hue = (i * 90 + animationValue * 180) % 360;
      final tendrilColor = HSVColor.fromAHSV(0.4 * pulse, hue, 0.8, 1.0).toColor();
      
      canvas.drawPath(
        tendrilPath,
        Paint()
          ..color = tendrilColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }
}

/// Widget to display an animated ship
class AnimatedShipWidget extends StatefulWidget {
  final Era era;
  final bool isMovingRight;
  final double size;
  
  const AnimatedShipWidget({
    super.key,
    required this.era,
    required this.isMovingRight,
    this.size = 80,
  });
  
  @override
  State<AnimatedShipWidget> createState() => _AnimatedShipWidgetState();
}

class _AnimatedShipWidgetState extends State<AnimatedShipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
          size: Size(widget.size, widget.size),
          painter: ShipPainter.forEra(
            widget.era,
            animationValue: _controller.value,
            isMovingRight: widget.isMovingRight,
          ),
        );
      },
    );
  }
}
