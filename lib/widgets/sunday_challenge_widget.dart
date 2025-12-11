import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';
import 'glass_container.dart';

/// Widget to display the Sunday Weekly Challenge
/// Shows challenge status, progress, and reward claiming
class SundayChallengeWidget extends StatefulWidget {
  final GameProvider gameProvider;
  final VoidCallback? onDismiss;
  
  const SundayChallengeWidget({
    super.key,
    required this.gameProvider,
    this.onDismiss,
  });
  
  @override
  State<SundayChallengeWidget> createState() => _SundayChallengeWidgetState();
}

class _SundayChallengeWidgetState extends State<SundayChallengeWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Update timer display every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final gp = widget.gameProvider;
    
    // Check if challenge is available to start
    if (gp.isSundayChallengeAvailable && !gp.isSundayChallengeActive) {
      return _buildChallengeOffer(context);
    }
    
    // Check if challenge is active
    if (gp.isSundayChallengeActive) {
      if (gp.canClaimSundayChallengeReward) {
        return _buildRewardClaim(context);
      }
      return _buildActiveChallenge(context);
    }
    
    return const SizedBox.shrink();
  }
  
  /// Build the challenge offer dialog (shown on Sunday)
  Widget _buildChallengeOffer(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderColor: AppColors.goldLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon with animation
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldLight.withValues(alpha: 0.3),
                          AppColors.goldLight.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: AppColors.goldLight,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Title
            const Text(
              'SUNDAY CHALLENGE',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.goldLight,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Weekly Prestige Challenge',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.goldLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.refresh, 'Your progress will be RESET (prestige)'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.timer, 'You have 24 HOURS to progress'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.block, 'NO PRESTIGE allowed during challenge'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.celebration, 'Earn 3X PRESTIGE REWARDS!'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Reward preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldLight.withValues(alpha: 0.2),
                    AppColors.goldLight.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.goldLight, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '3X DARK ENERGY REWARD',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldLight,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      widget.gameProvider.skipSundayChallenge();
                      widget.onDismiss?.call();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.gameProvider.startSundayChallenge();
                      widget.onDismiss?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldLight,
                      foregroundColor: AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'START CHALLENGE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the active challenge status banner
  Widget _buildActiveChallenge(BuildContext context) {
    final gp = widget.gameProvider;
    final timeRemaining = gp.sundayChallengeTimeRemainingText;
    final kardashevGain = gp.sundayChallengeKardashevProgress;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.info,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SUNDAY CHALLENGE ACTIVE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time Remaining: $timeRemaining',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress stats
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Kardashev Gained',
                  '+${kardashevGain.toStringAsFixed(3)}',
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Reward Multiplier',
                  '3X',
                  Icons.auto_awesome,
                  color: AppColors.goldLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Warning about no prestige
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.block, color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prestige is disabled until challenge ends',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the reward claim dialog
  Widget _buildRewardClaim(BuildContext context) {
    final gp = widget.gameProvider;
    final reward = gp.calculateSundayChallengeReward();
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderColor: AppColors.goldLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldLight.withValues(alpha: 0.4),
                          AppColors.goldLight.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.celebration,
                      size: 72,
                      color: AppColors.goldLight,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'CHALLENGE COMPLETE!',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.goldLight,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildRewardRow(
                    'Kardashev Gained',
                    '+${reward.kardashevGained.toStringAsFixed(3)}',
                    Icons.trending_up,
                  ),
                  Divider(color: AppColors.glassBorder, height: 24),
                  _buildRewardRow(
                    'Normal Reward',
                    '${GameProvider.formatNumber(reward.normalDarkEnergyReward)} DE',
                    Icons.circle,
                    valueColor: AppColors.textSecondary,
                    strikethrough: true,
                  ),
                  const SizedBox(height: 8),
                  _buildRewardRow(
                    '3X BONUS REWARD',
                    '${GameProvider.formatNumber(reward.darkEnergyReward)} DE',
                    Icons.auto_awesome,
                    valueColor: AppColors.goldLight,
                    isHighlighted: true,
                  ),
                  const SizedBox(height: 8),
                  _buildRewardRow(
                    'Bonus Dark Matter',
                    '+${GameProvider.formatNumber(reward.darkMatterReward)} DM',
                    Icons.diamond,
                    valueColor: AppColors.info,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Claim button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.gameProvider.claimSundayChallengeReward();
                  widget.onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: AppColors.backgroundDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CLAIM REWARDS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatBox(String label, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? AppColors.info).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? AppColors.info).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? AppColors.info, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.info,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardRow(
    String label, 
    String value, 
    IconData icon, {
    Color? valueColor,
    bool strikethrough = false,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: isHighlighted 
          ? const EdgeInsets.all(8) 
          : EdgeInsets.zero,
      decoration: isHighlighted 
          ? BoxDecoration(
              color: AppColors.goldLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          Icon(
            icon, 
            color: valueColor ?? AppColors.textSecondary, 
            size: isHighlighted ? 24 : 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHighlighted ? 14 : 13,
                color: AppColors.textSecondary,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: isHighlighted ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact banner version for the main game screen
class SundayChallengeBanner extends StatelessWidget {
  final GameProvider gameProvider;
  final VoidCallback? onTap;
  
  const SundayChallengeBanner({
    super.key,
    required this.gameProvider,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final gp = gameProvider;
    
    // Don't show if no challenge is active or available
    if (!gp.isSundayChallengeActive && !gp.isSundayChallengeAvailable) {
      return const SizedBox.shrink();
    }
    
    // Show "Challenge Available" banner on Sunday
    if (gp.isSundayChallengeAvailable && !gp.isSundayChallengeActive) {
      return _buildAvailableBanner(context);
    }
    
    // Show active challenge banner
    if (gp.isSundayChallengeActive) {
      return _buildActiveBanner(context);
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildAvailableBanner(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.goldLight.withValues(alpha: 0.2),
              AppColors.goldLight.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.goldLight.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: AppColors.goldLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SUNDAY CHALLENGE AVAILABLE!',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldLight,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to start - Earn 3X Prestige Rewards!',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.goldLight,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveBanner(BuildContext context) {
    final timeRemaining = gameProvider.sundayChallengeTimeRemainingText;
    final isEnded = gameProvider.canClaimSundayChallengeReward;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnded
                ? [
                    AppColors.success.withValues(alpha: 0.2),
                    AppColors.success.withValues(alpha: 0.1),
                  ]
                : [
                    AppColors.info.withValues(alpha: 0.2),
                    AppColors.info.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnded
                ? AppColors.success.withValues(alpha: 0.5)
                : AppColors.info.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isEnded ? AppColors.success : AppColors.info).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEnded ? Icons.celebration : Icons.timer,
                color: isEnded ? AppColors.success : AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnded ? 'CHALLENGE COMPLETE!' : 'SUNDAY CHALLENGE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isEnded ? AppColors.success : AppColors.info,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEnded 
                        ? 'Tap to claim your 3X rewards!'
                        : 'Time: $timeRemaining | +${gameProvider.sundayChallengeKardashevProgress.toStringAsFixed(3)} K',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '3X',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
