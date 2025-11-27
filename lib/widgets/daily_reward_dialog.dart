import 'package:flutter/material.dart';
import '../models/daily_reward.dart';
import '../providers/game_provider.dart';

/// Daily Login Reward Dialog
class DailyRewardDialog extends StatelessWidget {
  final DailyReward reward;
  final int currentStreak;
  final int totalLoginDays;
  final VoidCallback onClaim;
  final VoidCallback onDismiss;

  const DailyRewardDialog({
    super.key,
    required this.reward,
    required this.currentStreak,
    required this.totalLoginDays,
    required this.onClaim,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final multiplier = getStreakMultiplier(totalLoginDays);
    final isBonus = reward.isBonus;
    final accentColor = isBonus ? Colors.amber : Colors.cyan;

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E),
                isBonus 
                    ? Colors.amber.withValues(alpha: 0.2)
                    : const Color(0xFF16213E),
              ],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.3),
                        accentColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isBonus ? '🎉 WEEKLY BONUS! 🎉' : '☀️ DAILY LOGIN',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: isBonus ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reward.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Streak display
                      _buildStreakDisplay(accentColor),

                      const SizedBox(height: 20),

                      // 7-day calendar
                      _buildWeekCalendar(accentColor),

                      const SizedBox(height: 20),

                      // Rewards
                      _buildRewardsSection(multiplier, accentColor),

                      if (multiplier > 1.0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '🔥 ${((multiplier - 1) * 100).toInt()}% LOYALTY BONUS!',
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Claim button
                      GestureDetector(
                        onTap: onClaim,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                accentColor,
                                accentColor.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'CLAIM REWARD',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Skip button
                      GestureDetector(
                        onTap: onDismiss,
                        child: Text(
                          'Claim later',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakDisplay(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: accentColor.withValues(alpha: 0.1),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                '🔥',
                style: TextStyle(fontSize: currentStreak >= 7 ? 24 : 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currentStreak DAY STREAK',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    '$totalLoginDays total logins',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(Color accentColor) {
    final cycleDay = ((currentStreak - 1) % 7) + 1;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Text(
            'WEEKLY REWARDS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final day = index + 1;
              final dayReward = dailyRewardCycle[index];
              final isPast = day < cycleDay;
              final isCurrent = day == cycleDay;
              final isBonus = day == 7;
              
              return _buildDayCircle(
                day: day,
                isPast: isPast,
                isCurrent: isCurrent,
                isBonus: isBonus,
                reward: dayReward,
                accentColor: accentColor,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle({
    required int day,
    required bool isPast,
    required bool isCurrent,
    required bool isBonus,
    required DailyReward reward,
    required Color accentColor,
  }) {
    final color = isCurrent 
        ? accentColor 
        : isPast 
            ? Colors.green 
            : Colors.white.withValues(alpha: 0.2);
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent 
                ? accentColor.withValues(alpha: 0.3)
                : isPast 
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: color,
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: isCurrent ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ] : null,
          ),
          child: Center(
            child: isPast
                ? const Icon(Icons.check, size: 18, color: Colors.green)
                : Text(
                    isBonus ? '🎁' : '$day',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: isBonus ? 16 : 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        if (reward.darkMatterReward > 0)
          Text(
            '🌑${reward.darkMatterReward.toInt()}',
            style: TextStyle(
              fontSize: 8,
              color: Colors.purple.shade200,
            ),
          )
        else
          Text(
            '⚡${_formatShort(reward.energyReward)}',
            style: TextStyle(
              fontSize: 8,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }

  Widget _buildRewardsSection(double multiplier, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            "TODAY'S REWARD",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (reward.energyReward > 0) ...[
                _buildRewardItem(
                  '⚡',
                  GameProvider.formatNumber(reward.energyReward * multiplier),
                  'Energy',
                  Colors.amber,
                ),
              ],
              if (reward.energyReward > 0 && reward.darkMatterReward > 0)
                const SizedBox(width: 24),
              if (reward.darkMatterReward > 0) ...[
                _buildRewardItem(
                  '🌑',
                  (reward.darkMatterReward * multiplier).toStringAsFixed(0),
                  'Dark Matter',
                  Colors.purple.shade200,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String icon, String value, String label, Color color) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          '+$value',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  String _formatShort(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
