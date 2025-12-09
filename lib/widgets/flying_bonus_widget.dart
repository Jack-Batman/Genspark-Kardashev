import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import 'notification_banner.dart';
import 'ship_painters.dart';

class FlyingBonusWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const FlyingBonusWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<FlyingBonusWidget> createState() => _FlyingBonusWidgetState();
}

class _FlyingBonusWidgetState extends State<FlyingBonusWidget> with TickerProviderStateMixin {
  // Timers and Controllers
  Timer? _spawnTimer;
  late AnimationController _flightController;
  late AnimationController _shipAnimationController; // For ship internal animations
  late Animation<double> _positionAnimation;
  
  // State
  bool _isVisible = false;
  bool _isCollected = false;
  double _verticalPosition = 0.2; // 0.0 to 1.0 (relative to screen height)
  bool _flightDirectionRight = true; // true = left to right, false = right to left
  
  // Constants
  static const int _spawnIntervalSeconds = 3 * 60; // 3 minutes
  // static const int _spawnIntervalSeconds = 15; // Debug: 15 seconds
  static const int _flightDurationSeconds = 8; // How long it takes to cross screen
  static const double _shipSize = 80.0; // Size of the premium ship

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for flight path
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _flightDurationSeconds),
    );

    // Initialize animation controller for ship internal animations (engines, glow, etc.)
    _shipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _flightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _resetObject();
      }
    });

    // Schedule first spawn
    _scheduleNextSpawn();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _flightController.dispose();
    _shipAnimationController.dispose();
    super.dispose();
  }

  void _scheduleNextSpawn() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer(const Duration(seconds: _spawnIntervalSeconds), _spawnObject);
  }

  void _spawnObject() {
    if (!mounted) return;

    final random = Random();
    
    setState(() {
      _isVisible = true;
      _isCollected = false;
      // Randomize height (between 15% and 45% of screen height to stay in sky area)
      _verticalPosition = 0.15 + (random.nextDouble() * 0.3);
      // Randomize direction
      _flightDirectionRight = random.nextBool();
    });

    // Setup animation based on direction
    if (_flightDirectionRight) {
      // Fly Left to Right
      _positionAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(
        CurvedAnimation(parent: _flightController, curve: Curves.linear)
      );
    } else {
      // Fly Right to Left
      _positionAnimation = Tween<double>(begin: 1.2, end: -0.2).animate(
        CurvedAnimation(parent: _flightController, curve: Curves.linear)
      );
    }

    _flightController.forward(from: 0.0);
    
    // Play notification sound when ship appears
    AudioService.playNotification();
  }

  void _resetObject() {
    if (!mounted) return;
    setState(() {
      _isVisible = false;
      _flightController.reset();
    });
    _scheduleNextSpawn();
  }

  void _onTap() {
    if (_isCollected) return;
    
    setState(() {
      _isCollected = true;
    });
    
    // Stop movement
    _flightController.stop();
    
    // Feedback
    AudioService.playAchievement(); // Good generic reward sound
    HapticService.mediumImpact();
    
    // Give Reward
    _distributeReward();
    
    // Hide after short delay (for explosion/collection animation if we had one)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _resetObject();
    });
  }

  void _distributeReward() {
    final random = Random();
    final isEnergy = random.nextBool(); // 50/50 chance
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    // Calculate 5 minutes of production
    final energyPerSecond = widget.gameProvider.state.energyPerSecond;
    // Minimum reward of 100 energy if production is low
    final baseReward = max(100.0, energyPerSecond * 5 * 60); 
    
    if (isEnergy) {
      widget.gameProvider.addEnergy(baseReward);
      _showNotification(
        'SHIP SALVAGED!',
        '+${GameProvider.formatNumber(baseReward)} Energy',
        Icons.bolt,
        eraConfig.accentColor,
      );
    } else {
      // Dark Matter Reward (scaled)
      // Dark Matter is much rarer. Let's say 1% of energy value converted or fixed amount.
      // A safer bet is a small fixed amount relative to progression, or calculated from energy.
      // Let's use a logic similar to TimedAdReward but smaller since it's free/frequent.
      double dmReward = (baseReward / 15000).clamp(0.5, 10.0);
      
      widget.gameProvider.addDarkMatter(dmReward);
      _showNotification(
        'ALIEN ARTIFACT!',
        '+${dmReward.toStringAsFixed(1)} Dark Matter',
        Icons.auto_awesome,
        AppColors.eraIIIEnergy, // Purple
      );
    }
  }

  void _showNotification(String title, String message, IconData icon, Color color) {
    widget.gameProvider.notificationController.show(
      NotificationBannerData(
        id: 'flying_bonus_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.dailyReward, // Reuse generic positive type
        title: title,
        message: message,
        icon: icon,
        color: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _flightController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Calculate position
        final dx = _positionAnimation.value * screenWidth;
        final dy = _verticalPosition * screenHeight;
        
        // Add a slight bobbing motion (Sine wave)
        final bobOffset = sin(_flightController.value * 4 * pi) * 20.0;

        return Positioned(
          left: dx,
          top: dy + bobOffset,
          child: GestureDetector(
            onTap: _onTap,
            child: _isCollected
                ? _buildExplosion()
                : _buildSpaceship(widget.gameProvider.state.era),
          ),
        );
      },
    );
  }

  Widget _buildExplosion() {
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return SizedBox(
          width: _shipSize * 2,
          height: _shipSize * 2,
          child: CustomPaint(
            painter: _CollectionExplosionPainter(
              progress: value,
              primaryColor: eraConfig.primaryColor,
              accentColor: eraConfig.accentColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpaceship(Era era) {
    return AnimatedBuilder(
      animation: _shipAnimationController,
      builder: (context, child) {
        return SizedBox(
          width: _shipSize,
          height: _shipSize,
          child: CustomPaint(
            size: Size(_shipSize, _shipSize),
            painter: ShipPainter.forEra(
              era,
              animationValue: _shipAnimationController.value,
              isMovingRight: _flightDirectionRight,
            ),
          ),
        );
      },
    );
  }
}

/// Premium collection explosion effect painter
class _CollectionExplosionPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color accentColor;
  
  _CollectionExplosionPainter({
    required this.progress,
    required this.primaryColor,
    required this.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    // Multiple expanding rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress - i * 0.15).clamp(0.0, 1.0);
      final ringRadius = ringProgress * maxRadius;
      final ringAlpha = (1.0 - ringProgress) * 0.6;
      
      // Outer glow
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..color = primaryColor.withValues(alpha: ringAlpha * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
      
      // Ring
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..color = accentColor.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - ringProgress),
      );
    }
    
    // Energy particles flying outward
    final particleCount = 16;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      final particleProgress = progress;
      final distance = particleProgress * maxRadius * 0.8;
      final particleAlpha = (1 - particleProgress) * 0.8;
      
      final px = center.dx + cos(angle) * distance;
      final py = center.dy + sin(angle) * distance;
      
      // Particle trail
      final trailLength = 15 * (1 - particleProgress);
      canvas.drawLine(
        Offset(px, py),
        Offset(
          px - cos(angle) * trailLength,
          py - sin(angle) * trailLength,
        ),
        Paint()
          ..color = accentColor.withValues(alpha: particleAlpha * 0.5)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      
      // Particle
      canvas.drawCircle(
        Offset(px, py),
        3 * (1 - particleProgress * 0.5),
        Paint()
          ..color = Colors.white.withValues(alpha: particleAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    
    // Central flash
    final flashAlpha = (1 - progress * 2).clamp(0.0, 1.0);
    if (flashAlpha > 0) {
      canvas.drawCircle(
        center,
        30 * (1 - progress),
        Paint()
          ..color = Colors.white.withValues(alpha: flashAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    
    // Star burst
    if (progress < 0.5) {
      final starProgress = progress * 2;
      final starAlpha = (1 - starProgress) * 0.8;
      
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi;
        final starLength = 25 * (1 + starProgress);
        
        canvas.drawLine(
          center,
          Offset(
            center.dx + cos(angle) * starLength,
            center.dy + sin(angle) * starLength,
          ),
          Paint()
            ..color = accentColor.withValues(alpha: starAlpha)
            ..strokeWidth = 2 * (1 - starProgress)
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _CollectionExplosionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
