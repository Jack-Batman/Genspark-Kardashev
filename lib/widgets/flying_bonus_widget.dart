import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import 'notification_banner.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _flightDurationSeconds),
    );

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
    
    // Play sound hint (faint engine sound or sparkle)
    // AudioService.playAmbientEvent(); // Assuming this exists or similar
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1.0 - value,
          child: Transform.scale(
            scale: 1.0 + (value * 2),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.star, color: Colors.orange, size: 40),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpaceship(Era era) {
    String emoji;
    Color glowColor;
    
    switch (era) {
      case Era.planetary:
        emoji = '🛸'; // UFO
        glowColor = Colors.cyan;
        break;
      case Era.stellar:
        emoji = '🚀'; // Rocket
        glowColor = Colors.orange;
        break;
      case Era.galactic:
        emoji = '🛰️'; // Satellite/Station
        glowColor = Colors.purple;
        break;
      case Era.universal:
        emoji = '💠'; // Energy shape
        glowColor = Colors.pink;
        break;
    }

    // Determine rotation based on direction
    // 🛸 doesn't need much rotation, 🚀 points up usually (45 deg)
    // Let's just rotate slightly for effect or flip if needed
    
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Transform.scale(
        scale: _flightDirectionRight ? 1.0 : -1.0, // Flip horizontally if going left
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
