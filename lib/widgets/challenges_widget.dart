import 'dart:async';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/challenge.dart';
import '../models/tutorial_state.dart';
import '../providers/game_provider.dart';
import 'tutorial_manager.dart';

/// Challenges/Contracts widget with daily and weekly objectives
class ChallengesWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const ChallengesWidget({
    super.key,
    required this.gameProvider,
  });
  
  @override
  State<ChallengesWidget> createState() => _ChallengesWidgetState();
}

class _ChallengesWidgetState extends State<ChallengesWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Refresh progress display every second
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    
    // Check if we should show the challenges tutorial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (TutorialManager.instance.shouldShowTutorial(TutorialTopic.dailyChallenges)) {
        TutorialManager.instance.startTutorial(TutorialTopic.dailyChallenges);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: eraConfig.primaryColor.withValues(alpha: 0.3),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: eraConfig.accentColor,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
            labelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today, size: 14),
                    const SizedBox(width: 4),
                    const Text('DAILY'),
                    _buildUnclaimedBadge(ChallengeDuration.daily),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.date_range, size: 14),
                    const SizedBox(width: 4),
                    const Text('WEEKLY'),
                    _buildUnclaimedBadge(ChallengeDuration.weekly),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChallengesList(ChallengeDuration.daily),
              _buildChallengesList(ChallengeDuration.weekly),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildUnclaimedBadge(ChallengeDuration duration) {
    final challenges = widget.gameProvider.getActiveChallenges(duration);
    final unclaimed = challenges.where((c) => c.isCompleted && !c.isClaimed).length;
    
    if (unclaimed == 0) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$unclaimed',
        style: const TextStyle(
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildChallengesList(ChallengeDuration duration) {
    final challenges = widget.gameProvider.getActiveChallenges(duration);
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              duration == ChallengeDuration.daily 
                  ? Icons.today 
                  : Icons.date_range,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${duration == ChallengeDuration.daily ? "daily" : "weekly"} challenges available',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        // Reset timer
        _buildResetTimer(duration, eraConfig),
        
        const SizedBox(height: 8),
        
        // Progress summary
        _buildProgressSummary(challenges, eraConfig),
        
        const SizedBox(height: 12),
        
        // Challenge cards
        ...challenges.map((c) => _buildChallengeCard(c, eraConfig)),
      ],
    );
  }
  
  Widget _buildResetTimer(ChallengeDuration duration, EraConfig eraConfig) {
    final now = DateTime.now();
    Duration timeUntilReset;
    
    if (duration == ChallengeDuration.daily) {
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      timeUntilReset = tomorrow.difference(now);
    } else {
      // Weekly resets on Monday
      final daysUntilMonday = (8 - now.weekday) % 7;
      final nextMonday = DateTime(now.year, now.month, now.day + (daysUntilMonday == 0 ? 7 : daysUntilMonday));
      timeUntilReset = nextMonday.difference(now);
    }
    
    final hours = timeUntilReset.inHours;
    final minutes = timeUntilReset.inMinutes % 60;
    final seconds = timeUntilReset.inSeconds % 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh,
            size: 14,
            color: eraConfig.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Resets in: ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          Text(
            duration == ChallengeDuration.daily
                ? '${hours}h ${minutes}m ${seconds}s'
                : '${timeUntilReset.inDays}d ${hours % 24}h',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: eraConfig.accentColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSummary(List<ActiveChallenge> challenges, EraConfig eraConfig) {
    final completed = challenges.where((c) => c.isCompleted).length;
    final claimed = challenges.where((c) => c.isClaimed).length;
    final total = challenges.length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            eraConfig.primaryColor.withValues(alpha: 0.2),
            eraConfig.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(
                    completed == total ? Colors.green : eraConfig.accentColor,
                  ),
                ),
                Text(
                  '$completed/$total',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHALLENGE PROGRESS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildProgressStat('Completed', completed, Colors.green),
                    const SizedBox(width: 12),
                    _buildProgressStat('Claimed', claimed, Colors.amber),
                    const SizedBox(width: 12),
                    _buildProgressStat('Remaining', total - completed, Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
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
            fontSize: 8,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChallengeCard(ActiveChallenge activeChallenge, EraConfig eraConfig) {
    final challenge = activeChallenge.challenge;
    final isCompleted = activeChallenge.isCompleted;
    final isClaimed = activeChallenge.isClaimed;
    final progress = activeChallenge.progressPercent;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isClaimed
            ? Colors.grey.withValues(alpha: 0.1)
            : isCompleted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: isClaimed
              ? Colors.grey.withValues(alpha: 0.3)
              : isCompleted
                  ? Colors.green.withValues(alpha: 0.5)
                  : challenge.color.withValues(alpha: 0.3),
          width: isCompleted && !isClaimed ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isClaimed ? Colors.grey : challenge.color)
                            .withValues(alpha: 0.2),
                        border: Border.all(
                          color: isClaimed ? Colors.grey : challenge.color,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isClaimed ? Icons.check : challenge.icon,
                        size: 20,
                        color: isClaimed 
                            ? Colors.grey 
                            : challenge.color,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Title and tier
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isClaimed 
                                  ? Colors.grey 
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: challenge.tierColor.withValues(alpha: 0.2),
                                ),
                                child: Text(
                                  challenge.tierText.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: challenge.tierColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!isClaimed)
                                Text(
                                  activeChallenge.timeRemainingText,
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
                    
                    // Status / Claim button
                    if (isCompleted && !isClaimed)
                      _buildClaimButton(activeChallenge)
                    else if (isClaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'CLAIMED',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: isClaimed ? 0.4 : 0.8),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Progress bar
                if (!isClaimed) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(
                              isCompleted ? Colors.green : challenge.color,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.green : challenge.color,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${GameProvider.formatNumber(activeChallenge.currentProgress)} / ${GameProvider.formatNumber(challenge.targetValue)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Rewards
                _buildRewardsRow(challenge.rewards, isClaimed, playerProgress: challenge.playerProgress),
              ],
            ),
          ),
          
          // Completed overlay
          if (isCompleted && !isClaimed)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'COMPLETE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildClaimButton(ActiveChallenge activeChallenge) {
    return GestureDetector(
      onTap: () => _claimReward(activeChallenge),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'CLAIM',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardsRow(List<ChallengeReward> rewards, bool isClaimed, {PlayerProgress? playerProgress}) {
    // Get player progress for scaling rewards display
    final progress = playerProgress ?? PlayerProgress(
      kardashevLevel: widget.gameProvider.state.kardashevLevel,
      currentEra: widget.gameProvider.state.era.index,
      energyPerSecond: widget.gameProvider.state.energyPerSecond,
      prestigeCount: widget.gameProvider.state.prestigeCount,
      totalGenerators: widget.gameProvider.state.totalGenerators,
      totalEnergyEarned: widget.gameProvider.state.totalEnergyEarned,
    );
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: rewards.map((reward) {
        IconData icon;
        Color color;
        
        switch (reward.type) {
          case ChallengeRewardType.energy:
            icon = Icons.bolt;
            color = Colors.yellow;
          case ChallengeRewardType.darkMatter:
            icon = Icons.dark_mode;
            color = Colors.purple;
          case ChallengeRewardType.darkEnergy:
            icon = Icons.auto_awesome;
            color = Colors.deepPurple;
          case ChallengeRewardType.productionBoost:
            icon = Icons.speed;
            color = Colors.orange;
          case ChallengeRewardType.timeWarp:
            icon = Icons.fast_forward;
            color = Colors.cyan;
        }
        
        // Use getDescription to get formatted reward text with actual amounts
        final rewardText = reward.getDescription(progress);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: (isClaimed ? Colors.grey : color).withValues(alpha: 0.15),
            border: Border.all(
              color: (isClaimed ? Colors.grey : color).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: isClaimed ? Colors.grey : color,
              ),
              const SizedBox(width: 4),
              Text(
                rewardText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isClaimed 
                      ? Colors.grey 
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  void _claimReward(ActiveChallenge activeChallenge) {
    final result = widget.gameProvider.claimChallengeReward(activeChallenge);
    
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${activeChallenge.challenge.name} reward claimed!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
