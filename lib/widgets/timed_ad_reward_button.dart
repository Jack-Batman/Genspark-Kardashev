import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import 'notification_banner.dart';

/// Reward type for the timed ad bonus
enum TimedRewardType {
  energy,
  darkMatter,
}

/// Timed Ad Reward Button - Appears every 5-10 minutes of gameplay
/// Offers 5 minutes worth of Energy or Dark Matter for watching a 30s ad
class TimedAdRewardButton extends StatefulWidget {
  final GameProvider gameProvider;
  final VoidCallback? onRewardClaimed;
  
  const TimedAdRewardButton({
    super.key,
    required this.gameProvider,
    this.onRewardClaimed,
  });

  @override
  State<TimedAdRewardButton> createState() => _TimedAdRewardButtonState();
}

class _TimedAdRewardButtonState extends State<TimedAdRewardButton>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  bool _isWatchingAd = false;
  Timer? _appearanceTimer;
  Timer? _hideTimer;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  
  // Random interval between 5-10 minutes (in seconds)
  static const int _minIntervalSeconds = 5 * 60; // 5 minutes
  static const int _maxIntervalSeconds = 10 * 60; // 10 minutes
  static const int _visibleDurationSeconds = 60; // Button visible for 60 seconds
  
  // For testing: use shorter intervals (uncomment for development)
  // static const int _minIntervalSeconds = 30; // 30 seconds
  // static const int _maxIntervalSeconds = 60; // 1 minute
  // static const int _visibleDurationSeconds = 30; // 30 seconds
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    // Start the appearance timer
    _scheduleNextAppearance();
  }
  
  @override
  void dispose() {
    _appearanceTimer?.cancel();
    _hideTimer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  void _scheduleNextAppearance() {
    _appearanceTimer?.cancel();
    
    // Random interval between min and max
    final random = Random();
    final intervalSeconds = _minIntervalSeconds + 
        random.nextInt(_maxIntervalSeconds - _minIntervalSeconds);
    
    _appearanceTimer = Timer(Duration(seconds: intervalSeconds), () {
      if (mounted && AdService().canWatchAd(AdPlacement.timedBonusReward)) {
        _showButton();
      } else {
        // If can't show ad, schedule next appearance
        _scheduleNextAppearance();
      }
    });
  }
  
  void _showButton() {
    if (!mounted) return;
    
    setState(() {
      _isVisible = true;
    });
    
    // Play notification sound
    AudioService.playAchievement();
    HapticService.mediumImpact();
    
    // Auto-hide after duration
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: _visibleDurationSeconds), () {
      _hideButton();
    });
  }
  
  void _hideButton() {
    if (!mounted) return;
    
    setState(() {
      _isVisible = false;
    });
    
    // Schedule next appearance
    _scheduleNextAppearance();
  }
  
  Future<void> _onTap() async {
    if (_isWatchingAd) return;
    
    AudioService.playClick();
    HapticService.mediumImpact();
    
    // Show reward selection dialog
    final rewardType = await _showRewardSelectionDialog();
    if (rewardType == null) return;
    
    setState(() {
      _isWatchingAd = true;
    });
    
    // Simulate watching ad
    final result = await AdService().showRewardedAd(AdPlacement.timedBonusReward);
    
    if (result.success) {
      // Calculate reward: 5 minutes worth of production
      final energyPerSecond = widget.gameProvider.state.energyPerSecond;
      final fiveMinutesEnergy = energyPerSecond * 5 * 60; // 5 minutes
      
      if (rewardType == TimedRewardType.energy) {
        // Award energy
        widget.gameProvider.addEnergy(fiveMinutesEnergy);
        _showRewardNotification(
          'Energy Boost!',
          '+${GameProvider.formatNumber(fiveMinutesEnergy)} Energy',
          Icons.bolt,
          AppColors.eraIEnergy,
        );
      } else {
        // Award Dark Matter (scaled relative to energy)
        // Dark Matter is more valuable, so give less - max 20 DM to encourage IAP
        final darkMatterReward = (fiveMinutesEnergy / 10000).clamp(1.0, 20.0);
        widget.gameProvider.addDarkMatter(darkMatterReward);
        _showRewardNotification(
          'Dark Matter Boost!',
          '+${darkMatterReward.toStringAsFixed(1)} Dark Matter',
          Icons.auto_awesome,
          AppColors.eraIIIEnergy,
        );
      }
      
      widget.onRewardClaimed?.call();
      _hideTimer?.cancel();
      _hideButton();
    } else {
      // Ad failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to load ad'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _isWatchingAd = false;
      });
    }
  }
  
  Future<TimedRewardType?> _showRewardSelectionDialog() async {
    final energyPerSecond = widget.gameProvider.state.energyPerSecond;
    final fiveMinutesEnergy = energyPerSecond * 5 * 60;
    final darkMatterReward = (fiveMinutesEnergy / 10000).clamp(1.0, 20.0);
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    return showDialog<TimedRewardType>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceDark,
                AppColors.backgroundDark,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldAccent.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goldAccent.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      color: AppColors.goldLight,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BONUS REWARD!',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldLight,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Watch a short ad to claim your reward',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Reward Options
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Energy Option
                    _buildRewardOption(
                      icon: Icons.bolt,
                      title: 'Energy Boost',
                      subtitle: '+${GameProvider.formatNumber(fiveMinutesEnergy)}',
                      description: '5 minutes of production',
                      color: eraConfig.accentColor,
                      onTap: () => Navigator.of(context).pop(TimedRewardType.energy),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Dark Matter Option
                    _buildRewardOption(
                      icon: Icons.auto_awesome,
                      title: 'Dark Matter',
                      subtitle: '+${darkMatterReward.toStringAsFixed(1)}',
                      description: 'Premium currency',
                      color: AppColors.eraIIIEnergy,
                      onTap: () => Navigator.of(context).pop(TimedRewardType.darkMatter),
                    ),
                  ],
                ),
              ),
              
              // Cancel Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 200.ms),
    );
  }
  
  Widget _buildRewardOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.4),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_fill,
                color: color,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showRewardNotification(String title, String message, IconData icon, Color color) {
    if (!mounted) return;
    
    AudioService.playAchievement();
    HapticService.heavyImpact();
    
    widget.gameProvider.notificationController.show(
      NotificationBannerData(
        id: 'ad_reward_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.dailyReward,
        title: title,
        message: message,
        icon: icon,
        color: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = sin(_glowController.value * 2 * pi) * 0.5 + 0.5;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldAccent.withValues(alpha: 0.3 + glowValue * 0.3),
                blurRadius: 15 + glowValue * 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isWatchingAd ? null : _onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + _pulseController.value * 0.05;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.goldAccent.withValues(alpha: 0.9),
                    AppColors.goldDark.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.goldLight.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isWatchingAd)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FREE BONUS',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        _isWatchingAd ? 'Loading...' : 'Watch Ad',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideX(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutBack);
  }
}
