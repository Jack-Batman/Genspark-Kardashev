import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../services/ad_service.dart';
import 'glass_container.dart';

/// Offline Earnings Collection Dialog with Monetization
class OfflineEarningsDialog extends StatefulWidget {
  final double earnings;
  final VoidCallback onCollect;
  final VoidCallback onDismiss;
  final Duration? timeAway;
  final double offlineEfficiency;
  final int maxOfflineHours;
  final bool isMember;
  final Function(double)? onCollectWithBonus;
  
  const OfflineEarningsDialog({
    super.key,
    required this.earnings,
    required this.onCollect,
    required this.onDismiss,
    this.timeAway,
    this.offlineEfficiency = 0.5,
    this.maxOfflineHours = 3,
    this.isMember = false,
    this.onCollectWithBonus,
  });
  
  @override
  State<OfflineEarningsDialog> createState() => _OfflineEarningsDialogState();
}

class _OfflineEarningsDialogState extends State<OfflineEarningsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isWatchingAd = false;
  final AdService _adService = AdService();
  
  String _formatTimeAway(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _watchAdForBonus() async {
    if (_isWatchingAd) return;
    if (!_adService.canWatchAd(AdPlacement.offlineEarningsDouble)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily ad limit reached. Try again tomorrow!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    setState(() => _isWatchingAd = true);
    
    final result = await _adService.showRewardedAd(AdPlacement.offlineEarningsDouble);
    
    setState(() => _isWatchingAd = false);
    
    if (result.success) {
      // Double the earnings
      final doubledEarnings = widget.earnings * 2;
      widget.onCollectWithBonus?.call(doubledEarnings);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Ad failed to load. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final remainingAdWatches = _adService.getRemainingWatches(AdPlacement.offlineEarningsDouble);
    final canWatchAd = _adService.canWatchAd(AdPlacement.offlineEarningsDouble);
    final doubledEarnings = widget.earnings * 2;
    
    // Check if time was capped
    final actualHours = widget.timeAway?.inHours ?? 0;
    final wasCapped = actualHours > widget.maxOfflineHours;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              borderColor: AppColors.goldAccent.withValues(alpha: 0.6),
              showGlow: true,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.goldLight.withValues(alpha: _glowAnimation.value),
                            AppColors.goldAccent.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 0.6, 1.0],
                        ),
                      ),
                      child: const Icon(
                        Icons.wb_sunny,
                        size: 48,
                        color: AppColors.goldLight,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Title
                    const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Your civilization continued while you were away',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Time away info
                    if (widget.timeAway != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimeAway(widget.timeAway!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Offline limit indicator
                    if (wasCapped && !widget.isMember) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.warning.withValues(alpha: 0.2),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_off,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Earnings capped at ${widget.maxOfflineHours}h',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          // TODO: Navigate to membership screen
                        },
                        child: Text(
                          'Upgrade to Cosmic Membership for 24h limit →',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.goldLight,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                    
                    // Member badge
                    if (widget.isMember) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.goldAccent.withValues(alpha: 0.3),
                              AppColors.goldDark.withValues(alpha: 0.3),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.goldAccent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              size: 14,
                              color: AppColors.goldLight,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'COSMIC MEMBER',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldLight,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+50% efficiency • 24h max earnings',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.goldLight.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Earnings display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.goldAccent.withValues(alpha: 0.2),
                            AppColors.goldAccent.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'OFFLINE ENERGY',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bolt,
                                color: AppColors.goldLight,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${GameProvider.formatNumber(widget.earnings)}',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Efficiency indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.speed,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(widget.offlineEfficiency * 100).toStringAsFixed(0)}% efficiency',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Collect button
                    GlassButton(
                      text: 'COLLECT',
                      icon: Icons.download,
                      accentColor: AppColors.goldAccent,
                      width: double.infinity,
                      onPressed: widget.onCollect,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Watch ad for 2x bonus
                    GestureDetector(
                      onTap: canWatchAd && !_isWatchingAd ? _watchAdForBonus : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: canWatchAd 
                              ? AppColors.success.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: canWatchAd
                                ? AppColors.success.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isWatchingAd)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.success,
                                ),
                              )
                            else
                              Icon(
                                Icons.play_circle_filled,
                                size: 18,
                                color: canWatchAd 
                                    ? AppColors.success 
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      canWatchAd ? 'Watch ad for ' : 'No ads remaining ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: canWatchAd
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    if (canWatchAd)
                                      Text(
                                        '2x BONUS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                  ],
                                ),
                                if (canWatchAd)
                                  Text(
                                    '+${GameProvider.formatNumber(doubledEarnings - widget.earnings)} extra • $remainingAdWatches/3 remaining',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.success.withValues(alpha: 0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Show the offline earnings dialog
void showOfflineEarningsDialog(
  BuildContext context, {
  required double earnings,
  required VoidCallback onCollect,
  Duration? timeAway,
  double offlineEfficiency = 0.5,
  int maxOfflineHours = 3,
  bool isMember = false,
  Function(double)? onCollectWithBonus,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (context) => OfflineEarningsDialog(
      earnings: earnings,
      onCollect: () {
        Navigator.of(context).pop();
        onCollect();
      },
      onDismiss: () => Navigator.of(context).pop(),
      timeAway: timeAway,
      offlineEfficiency: offlineEfficiency,
      maxOfflineHours: maxOfflineHours,
      isMember: isMember,
      onCollectWithBonus: onCollectWithBonus,
    ),
  );
}
