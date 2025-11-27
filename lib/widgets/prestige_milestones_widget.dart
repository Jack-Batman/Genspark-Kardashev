import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/prestige_cosmetics.dart';
import '../providers/game_provider.dart';

/// Prestige Milestones Display Widget
/// Shows visual progression through prestige tiers with unlockable cosmetics
class PrestigeMilestonesWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const PrestigeMilestonesWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<PrestigeMilestonesWidget> createState() => _PrestigeMilestonesWidgetState();
}

class _PrestigeMilestonesWidgetState extends State<PrestigeMilestonesWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameProvider.state;
    final eraConfig = state.eraConfig;
    final currentTier = state.prestigeTier;
    
    return Container(
      decoration: BoxDecoration(
        color: eraConfig.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(currentTier, eraConfig),
          
          // Current status card
          _buildCurrentStatusCard(currentTier, eraConfig),
          
          // Era tabs
          _buildEraTabs(eraConfig),
          
          // Milestone list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMilestoneList(Era.planetary, currentTier, eraConfig),
                _buildMilestoneList(Era.stellar, currentTier, eraConfig),
                _buildMilestoneList(Era.galactic, currentTier, eraConfig),
                _buildMilestoneList(Era.universal, currentTier, eraConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(int currentTier, EraConfig eraConfig) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.workspace_premium,
                color: eraConfig.accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'PRESTIGE MILESTONES',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: eraConfig.primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentStatusCard(int currentTier, EraConfig eraConfig) {
    final milestone = getMilestoneByTier(currentTier);
    final nextMilestone = getNextMilestone(currentTier);
    final highestBorder = getHighestUnlockedBorder(currentTier);
    final highestBadge = getHighestUnlockedBadge(currentTier);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: milestone != null
              ? [
                  milestone.primaryColor.withValues(alpha: 0.3),
                  milestone.accentColor.withValues(alpha: 0.2),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.2),
                  Colors.grey.withValues(alpha: 0.1),
                ],
        ),
        border: Border.all(
          color: milestone?.primaryColor.withValues(alpha: 0.5) ?? Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Current tier display with border preview
          Row(
            children: [
              // Animated border preview
              _AnimatedBorderPreview(
                border: highestBorder,
                badge: highestBadge,
                size: 60,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          milestone?.emoji ?? '🌟',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            milestone?.name ?? 'Unranked',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: milestone?.primaryColor ?? Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tier $currentTier / ${prestigeMilestones.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (milestone != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: milestone.primaryColor.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          milestone.title.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            color: milestone.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Next milestone progress
          if (nextMilestone != null) ...[
            const SizedBox(height: 16),
            _NextMilestoneProgress(
              currentTier: currentTier,
              nextMilestone: nextMilestone,
              currentKardashev: widget.gameProvider.state.kardashevLevel,
            ),
          ],
          
          // Cosmetics summary
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CosmeticCounter(
                icon: Icons.border_all,
                label: 'Borders',
                count: prestigeBorders.where((b) => b.requiredPrestigeTier <= currentTier).length,
                total: prestigeBorders.length,
                color: eraConfig.accentColor,
              ),
              _CosmeticCounter(
                icon: Icons.military_tech,
                label: 'Badges',
                count: prestigeBadges.where((b) => b.requiredPrestigeTier <= currentTier).length,
                total: prestigeBadges.length,
                color: eraConfig.primaryColor,
              ),
              _CosmeticCounter(
                icon: Icons.emoji_events,
                label: 'Titles',
                count: currentTier,
                total: prestigeMilestones.length,
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEraTabs(EraConfig eraConfig) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: eraConfig.primaryColor.withValues(alpha: 0.3),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: eraConfig.accentColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'ERA I'),
          Tab(text: 'ERA II'),
          Tab(text: 'ERA III'),
          Tab(text: 'ERA IV'),
        ],
      ),
    );
  }
  
  Widget _buildMilestoneList(Era era, int currentTier, EraConfig eraConfig) {
    final milestones = getMilestonesForEra(era);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isUnlocked = milestone.tier <= currentTier;
        final isCurrent = milestone.tier == currentTier;
        final isNext = milestone.tier == currentTier + 1;
        
        return _MilestoneCard(
          milestone: milestone,
          isUnlocked: isUnlocked,
          isCurrent: isCurrent,
          isNext: isNext,
          currentKardashev: widget.gameProvider.state.kardashevLevel,
          onTap: () => _showMilestoneDetails(milestone, isUnlocked),
        );
      },
    );
  }
  
  void _showMilestoneDetails(PrestigeMilestone milestone, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MilestoneDetailSheet(
        milestone: milestone,
        isUnlocked: isUnlocked,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _AnimatedBorderPreview extends StatefulWidget {
  final PrestigeCosmetic? border;
  final PrestigeCosmetic? badge;
  final double size;
  
  const _AnimatedBorderPreview({
    required this.border,
    required this.badge,
    required this.size,
  });

  @override
  State<_AnimatedBorderPreview> createState() => _AnimatedBorderPreviewState();
}

class _AnimatedBorderPreviewState extends State<_AnimatedBorderPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.border?.colors ?? [Colors.grey, Colors.grey.shade400];
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              startAngle: _controller.value * 2 * math.pi,
              colors: [
                colors.first,
                colors.length > 1 ? colors[1] : colors.first,
                colors.first,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.8),
            ),
            child: Center(
              child: Text(
                widget.badge?.icon ?? '🌟',
                style: TextStyle(fontSize: widget.size * 0.4),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NextMilestoneProgress extends StatelessWidget {
  final int currentTier;
  final PrestigeMilestone nextMilestone;
  final double currentKardashev;
  
  const _NextMilestoneProgress({
    required this.currentTier,
    required this.nextMilestone,
    required this.currentKardashev,
  });

  @override
  Widget build(BuildContext context) {
    final previousRequired = currentTier > 0 
        ? getMilestoneByTier(currentTier)?.requiredKardashev ?? 0
        : 0.0;
    final progress = ((currentKardashev - previousRequired) / 
        (nextMilestone.requiredKardashev - previousRequired)).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next: ${nextMilestone.name}',
              style: TextStyle(
                fontSize: 11,
                color: nextMilestone.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'K${currentKardashev.toStringAsFixed(2)} / K${nextMilestone.requiredKardashev.toStringAsFixed(1)}',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(nextMilestone.primaryColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                color: nextMilestone.primaryColor,
              ),
            ),
            Row(
              children: [
                Text(nextMilestone.emoji, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  nextMilestone.title,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CosmeticCounter extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final Color color;
  
  const _CosmeticCounter({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          '$count/$total',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final PrestigeMilestone milestone;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isNext;
  final double currentKardashev;
  final VoidCallback onTap;
  
  const _MilestoneCard({
    required this.milestone,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isNext,
    required this.currentKardashev,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    milestone.primaryColor.withValues(alpha: 0.2),
                    milestone.accentColor.withValues(alpha: 0.1),
                  ]
                : [
                    Colors.grey.withValues(alpha: 0.1),
                    Colors.grey.withValues(alpha: 0.05),
                  ],
          ),
          border: Border.all(
            color: isCurrent
                ? milestone.accentColor
                : isUnlocked
                    ? milestone.primaryColor.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.2),
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Tier icon/badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [milestone.primaryColor, milestone.accentColor],
                      )
                    : null,
                color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.2),
                border: Border.all(
                  color: isUnlocked 
                      ? milestone.primaryColor
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        milestone.emoji,
                        style: const TextStyle(fontSize: 22),
                      )
                    : Icon(
                        Icons.lock,
                        color: Colors.grey.withValues(alpha: 0.5),
                        size: 20,
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
                      Text(
                        milestone.name,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked 
                              ? milestone.primaryColor
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: milestone.accentColor,
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (isNext && !isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: isUnlocked ? 0.7 : 0.4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isUnlocked
                              ? milestone.primaryColor.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'K${milestone.requiredKardashev.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 9,
                            color: isUnlocked 
                                ? milestone.primaryColor
                                : Colors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tier ${milestone.tier}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const Spacer(),
                      // Reward previews
                      ...milestone.rewards.take(2).map((reward) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked
                                  ? reward.rarity.color.withValues(alpha: 0.3)
                                  : Colors.grey.withValues(alpha: 0.1),
                              border: Border.all(
                                color: isUnlocked
                                    ? reward.rarity.color
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: reward.icon != null
                                  ? Text(
                                      reward.icon!,
                                      style: const TextStyle(fontSize: 10),
                                    )
                                  : Icon(
                                      reward.type == CosmeticType.border
                                          ? Icons.border_all
                                          : Icons.military_tech,
                                      size: 10,
                                      color: isUnlocked
                                          ? reward.rarity.color
                                          : Colors.grey.withValues(alpha: 0.5),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            
            // Chevron
            Icon(
              Icons.chevron_right,
              color: isUnlocked 
                  ? milestone.primaryColor.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneDetailSheet extends StatelessWidget {
  final PrestigeMilestone milestone;
  final bool isUnlocked;
  
  const _MilestoneDetailSheet({
    required this.milestone,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: milestone.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header with milestone info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Large badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [milestone.primaryColor, milestone.accentColor],
                          )
                        : null,
                    color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.2),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: milestone.primaryColor.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Text(milestone.emoji, style: const TextStyle(fontSize: 36))
                        : const Icon(Icons.lock, color: Colors.grey, size: 36),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.name,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? milestone.primaryColor : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        milestone.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: milestone.primaryColor.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              'Tier ${milestone.tier}',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 11,
                                color: milestone.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.blue.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              'K${milestone.requiredKardashev.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 11,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Rewards section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REWARDS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: milestone.primaryColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                ...milestone.rewards.map((reward) => _RewardCard(
                  reward: reward,
                  isUnlocked: isUnlocked,
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? milestone.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.lock_outline,
                  color: isUnlocked ? milestone.accentColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isUnlocked ? 'MILESTONE ACHIEVED' : 'LOCKED - REACH TIER ${milestone.tier}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? milestone.accentColor : Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final PrestigeCosmetic reward;
  final bool isUnlocked;
  
  const _RewardCard({
    required this.reward,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: isUnlocked
              ? reward.rarity.gradientColors.map((c) => c.withValues(alpha: 0.2)).toList()
              : [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.05)],
        ),
        border: Border.all(
          color: isUnlocked
              ? reward.rarity.color.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon or preview
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked && reward.colors != null
                  ? LinearGradient(colors: reward.colors!)
                  : null,
              color: isUnlocked ? reward.rarity.color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
              border: Border.all(
                color: isUnlocked ? reward.rarity.color : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: reward.icon != null
                  ? Text(reward.icon!, style: const TextStyle(fontSize: 20))
                  : Icon(
                      reward.type == CosmeticType.border ? Icons.border_all : Icons.military_tech,
                      color: isUnlocked ? reward.rarity.color : Colors.grey,
                      size: 20,
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
                    Text(
                      reward.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? reward.rarity.color : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isUnlocked
                            ? reward.rarity.color.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        reward.rarity.displayName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 8,
                          color: isUnlocked ? reward.rarity.color : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: isUnlocked ? 0.7 : 0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.type == CosmeticType.border ? 'Border' : 'Badge',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
