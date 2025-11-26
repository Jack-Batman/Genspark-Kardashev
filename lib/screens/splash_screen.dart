import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Cinematic Splash Screen
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({
    super.key,
    required this.onComplete,
  });
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _blackHoleController;
  late AnimationController _fadeController;
  late AnimationController _textController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Black hole rotation and pulse
    _blackHoleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_blackHoleController);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _blackHoleController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
    
    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animations sequence
    _startAnimationSequence();
  }
  
  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 3000));
    widget.onComplete();
  }
  
  @override
  void dispose() {
    _blackHoleController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _blackHoleController,
          _textController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Starfield background
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _StarfieldPainter(
                  opacity: _fadeAnimation.value,
                ),
              ),
              
              // Black hole
              Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: CustomPaint(
                      size: const Size(250, 250),
                      painter: _BlackHolePainter(
                        rotation: _rotationAnimation.value,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Title
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.2,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Column(
                      children: [
                        // Logo text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.goldLight,
                              AppColors.goldAccent,
                              AppColors.goldDark,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'KARDASHEV',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A S C E N S I O N',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 14,
                            color: AppColors.goldAccent.withValues(alpha: 0.8),
                            letterSpacing: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Loading indicator
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textFadeAnimation.value,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.goldAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'INITIALIZING QUANTUM CORES...',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Starfield background painter
class _StarfieldPainter extends CustomPainter {
  final double opacity;
  final List<_Star> _stars = [];
  
  _StarfieldPainter({required this.opacity}) {
    // Generate stars
    final random = Random(42);
    for (int i = 0; i < 150; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        brightness: random.nextDouble(),
      ));
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: star.brightness * opacity * 0.8);
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

class _Star {
  final double x, y, size, brightness;
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
  });
}

/// Black hole with accretion disk painter
class _BlackHolePainter extends CustomPainter {
  final double rotation;
  
  _BlackHolePainter({required this.rotation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Outer glow
    for (int i = 5; i > 0; i--) {
      final glowPaint = Paint()
        ..color = AppColors.goldAccent.withValues(alpha: 0.1 / i)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.2 * i);
      
      canvas.drawCircle(center, radius * 0.8, glowPaint);
    }
    
    // Accretion disk
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    // Draw disk rings
    for (int i = 0; i < 8; i++) {
      final diskRadius = radius * (0.5 + i * 0.08);
      final diskPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + i * 2
        ..shader = SweepGradient(
          colors: [
            AppColors.goldLight.withValues(alpha: 0.0),
            AppColors.goldLight.withValues(alpha: 0.8),
            AppColors.goldAccent.withValues(alpha: 0.6),
            AppColors.eraIIEnergy.withValues(alpha: 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          startAngle: rotation + i * 0.2,
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: diskRadius));
      
      // Elliptical disk (tilted view)
      canvas.save();
      canvas.scale(1.0, 0.3);
      canvas.drawCircle(Offset.zero, diskRadius, diskPaint);
      canvas.restore();
    }
    
    canvas.restore();
    
    // Event horizon (black center)
    final eventHorizonGradient = RadialGradient(
      colors: [
        Colors.black,
        Colors.black,
        const Color(0xFF1a0a2e).withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    canvas.drawCircle(
      center,
      radius * 0.25,
      Paint()..shader = eventHorizonGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.25),
      ),
    );
    
    // Gravitational lensing effect (bright ring around event horizon)
    final lensingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          AppColors.goldLight.withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3));
    
    canvas.drawCircle(center, radius * 0.27, lensingPaint);
    
    // Particle jets
    _drawJets(canvas, center, radius);
  }
  
  void _drawJets(Canvas canvas, Offset center, double radius) {
    final jetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.center,
        end: Alignment.topCenter,
        colors: [
          AppColors.eraIIIEnergy.withValues(alpha: 0.6),
          AppColors.eraIIIEnergy.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(
        center.dx - 10,
        center.dy - radius,
        20,
        radius,
      ));
    
    // Top jet
    final topJetPath = Path()
      ..moveTo(center.dx - 5, center.dy - radius * 0.3)
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 0.6,
        center.dx - 15,
        center.dy - radius * 1.2,
      )
      ..lineTo(center.dx + 15, center.dy - radius * 1.2)
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 0.6,
        center.dx + 5,
        center.dy - radius * 0.3,
      )
      ..close();
    
    canvas.drawPath(topJetPath, jetPaint);
    
    // Bottom jet (mirrored)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(topJetPath, jetPaint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant _BlackHolePainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
