import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';

/// Achievements tab widget
class AchievementsWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const AchievementsWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<AchievementsWidget> createState() => _AchievementsWidgetState();
}

class _AchievementsWidgetState extends State<AchievementsWidget> {
  AchievementCategory _selectedCategory = AchievementCategory.production;

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final achievements = getAchievementsByCategory(_selectedCategory);

    return Column(
      children: [
        // Summary bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: eraConfig.primaryColor.withValues(alpha: 0.1),
            border: Border.all(
              color: eraConfig.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '${widget.gameProvider.unlockedAchievementCount}/${allAchievements.length}',
                'Unlocked',
                eraConfig.accentColor,
              ),
              Container(
                height: 24,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildSummaryItem(
                '${widget.gameProvider.unclaimedAchievementCount}',
                'Unclaimed',
                widget.gameProvider.unclaimedAchievementCount > 0
                    ? Colors.green
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),

        // Category tabs - 6 columns grid that fits all categories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: AchievementCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              final categoryAchievements = getAchievementsByCategory(category);
              final unlockedCount = categoryAchievements
                  .where((a) => widget.gameProvider.isAchievementUnlocked(a.id))
                  .length;
              final hasUnclaimed = categoryAchievements.any((a) =>
                  widget.gameProvider.isAchievementUnlocked(a.id) &&
                  !widget.gameProvider.isAchievementClaimed(a.id));

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isSelected
                          ? _getCategoryColor(category).withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.2),
                      border: Border.all(
                        color: isSelected
                            ? _getCategoryColor(category).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 16,
                              color: isSelected
                                  ? _getCategoryColor(category)
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                            // Green dot for unclaimed achievements
                            if (hasUnclaimed)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$unlockedCount/${categoryAchievements.length}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 8,
                            color: isSelected
                                ? _getCategoryColor(category)
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 6),

        // Achievement list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementCard(achievements[index], eraConfig);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
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

  Widget _buildAchievementCard(Achievement achievement, EraConfig eraConfig) {
    final isUnlocked = widget.gameProvider.isAchievementUnlocked(achievement.id);
    final isClaimed = widget.gameProvider.isAchievementClaimed(achievement.id);
    final progress = widget.gameProvider.getAchievementProgress(achievement);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: isUnlocked ? 0.2 : 0.4),
        border: Border.all(
          color: isUnlocked
              ? achievement.rarityColor.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon with rarity glow
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? achievement.rarityColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isUnlocked
                      ? achievement.rarityColor.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: achievement.rarityColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  isUnlocked ? achievement.icon : '?',
                  style: TextStyle(
                    fontSize: isUnlocked ? 22 : 18,
                    color: isUnlocked ? null : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isUnlocked ? achievement.name : '???',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? achievement.rarityColor
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      // Rarity badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: achievement.rarityColor.withValues(alpha: isUnlocked ? 0.3 : 0.1),
                        ),
                        child: Text(
                          achievement.rarityName,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 8,
                            color: isUnlocked
                                ? achievement.rarityColor
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked ? achievement.description : 'Keep playing to unlock',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: isUnlocked ? 0.6 : 0.3),
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 6),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                          achievement.rarityColor.withValues(alpha: 0.6),
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Claim button or rewards display
            if (isUnlocked)
              isClaimed
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 20,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => widget.gameProvider.claimAchievement(achievement.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: achievement.rarityColor.withValues(alpha: 0.3),
                          border: Border.all(
                            color: achievement.rarityColor.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'CLAIM',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (achievement.energyReward > 0)
                              Text(
                                '+${GameProvider.formatNumber(achievement.energyReward)}⚡',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.amber,
                                ),
                              ),
                            if (achievement.darkMatterReward > 0)
                              Text(
                                '+${achievement.darkMatterReward.toInt()}🌑',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.purple.shade200,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.production:
        return const Color(0xFF4FC3F7);
      case AchievementCategory.generators:
        return const Color(0xFF81C784);
      case AchievementCategory.research:
        return const Color(0xFFBA68C8);
      case AchievementCategory.progression:
        return const Color(0xFFFFB74D);
      case AchievementCategory.prestige:
        return const Color(0xFFFF6B9D);
      case AchievementCategory.special:
        return const Color(0xFFFFD700);
    }
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.production:
        return Icons.bolt;
      case AchievementCategory.generators:
        return Icons.factory;
      case AchievementCategory.research:
        return Icons.science;
      case AchievementCategory.progression:
        return Icons.trending_up;
      case AchievementCategory.prestige:
        return Icons.auto_awesome;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}

/// Achievement notification popup
class AchievementNotification extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                achievement.rarityColor.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(
              color: achievement.rarityColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: achievement.rarityColor.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: achievement.rarityColor.withValues(alpha: 0.3),
                      border: Border.all(
                        color: achievement.rarityColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACHIEVEMENT UNLOCKED!',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            color: achievement.rarityColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.name,
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: achievement.rarityColor.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      achievement.rarityName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: achievement.rarityColor,
                      ),
                    ),
                  ),
                  if (achievement.energyReward > 0 || achievement.darkMatterReward > 0) ...[
                    const SizedBox(width: 12),
                    if (achievement.energyReward > 0)
                      Text(
                        '+${GameProvider.formatNumber(achievement.energyReward)} ⚡',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 11,
                          color: Colors.amber,
                        ),
                      ),
                    if (achievement.darkMatterReward > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '+${achievement.darkMatterReward.toInt()} 🌑',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 11,
                            color: Colors.purple.shade200,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to dismiss',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
