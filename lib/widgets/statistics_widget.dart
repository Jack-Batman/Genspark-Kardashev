import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/game_state.dart';
import '../models/prestige_cosmetics.dart';
import '../providers/game_provider.dart';
import 'prestige_milestones_widget.dart';
import 'artifact_collection_widget.dart';
// leaderboard_widget.dart - Coming Soon (will be enabled for full release)

/// Enhanced Statistics Screen Widget
class StatisticsWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const StatisticsWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<StatisticsWidget> 
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
    final nextPrestige = widget.gameProvider.getNextPrestigeInfo();
    final canPrestige = nextPrestige != null && 
        state.kardashevLevel >= nextPrestige.requiredKardashev;

    return Column(
      children: [
        // Prestige card at top when available
        if (canPrestige)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: _PrestigeAvailableCard(
              nextPrestige: nextPrestige,
              eraConfig: eraConfig,
              onPrestige: () => _showPrestigeDialog(context),
            ),
          ),
        
        // Prestige Milestones & Artifact Collection buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: _PrestigeMilestonesButton(
                  gameProvider: widget.gameProvider,
                  eraConfig: eraConfig,
                  onTap: () => _showPrestigeMilestones(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ArtifactCollectionButton(
                  gameProvider: widget.gameProvider,
                  eraConfig: eraConfig,
                  onTap: () => _showArtifactCollection(context),
                ),
              ),
            ],
          ),
        ),
        
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'RANKING'),
              Tab(text: 'PRODUCTION'),
              Tab(text: 'RECORDS'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(state, eraConfig, nextPrestige, canPrestige),
              _buildLeaderboardTab(eraConfig),
              _buildProductionTab(state, eraConfig),
              _buildRecordsTab(state, eraConfig),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(EraConfig eraConfig) {
    // Coming Soon placeholder for beta release
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    eraConfig.primaryColor.withValues(alpha: 0.2),
                    eraConfig.accentColor.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: eraConfig.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.leaderboard_outlined,
                size: 48,
                color: eraConfig.primaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'COMING SOON',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: eraConfig.primaryColor,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Global Rankings',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: eraConfig.accentColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withValues(alpha: 0.3),
                border: Border.all(
                  color: eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Compete with players worldwide',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Leaderboards, weekly tournaments, and exclusive rewards will be available in a future update.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Feature preview icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ComingSoonFeatureChip(
                  icon: Icons.emoji_events,
                  label: 'Tournaments',
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                _ComingSoonFeatureChip(
                  icon: Icons.people,
                  label: 'Global Rank',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _ComingSoonFeatureChip(
                  icon: Icons.card_giftcard,
                  label: 'Rewards',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(GameState state, EraConfig eraConfig, 
      PrestigeInfo? nextPrestige, bool canPrestige) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key metrics row
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.bolt,
                  label: 'Per Second',
                  value: GameProvider.formatNumber(state.energyPerSecond),
                  color: eraConfig.accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  icon: Icons.show_chart,
                  label: 'Kardashev',
                  value: 'K${state.kardashevLevel.toStringAsFixed(3)}',
                  color: eraConfig.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.auto_awesome,
                  label: 'Dark Energy (+10%/unit)',
                  value: GameProvider.formatNumber(state.darkEnergy),
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  icon: Icons.people,
                  label: 'Architects',
                  value: '${state.ownedArchitects.length}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Era progress
          _SectionHeader(title: 'ERA PROGRESS', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _EraProgressCard(state: state, eraConfig: eraConfig),
          
          const SizedBox(height: 12),
          
          // Bonuses section
          _SectionHeader(title: 'ACTIVE BONUSES', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _BonusesCard(state: state, eraConfig: eraConfig),
          
          // Prestige progress if not available
          if (!canPrestige && nextPrestige != null) ...[
            const SizedBox(height: 12),
            _SectionHeader(title: 'PRESTIGE PROGRESS', color: eraConfig.primaryColor),
            const SizedBox(height: 8),
            _PrestigeProgressCard(
              state: state,
              nextPrestige: nextPrestige,
              eraConfig: eraConfig,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductionTab(GameState state, EraConfig eraConfig) {
    final generators = state.allUnlockedGenerators;
    
    // Calculate production breakdown
    final productionData = <String, double>{};
    double totalProduction = 0;
    
    for (final gen in generators) {
      final count = state.getGeneratorCount(gen.id);
      if (count == 0) continue;
      
      final level = state.getGeneratorLevel(gen.id);
      final eraMultiplier = eraConfigs[gen.era]?.prestigeMultiplier ?? 1.0;
      final production = gen.baseProduction * 
                        count * 
                        (1 + (level - 1) * 0.1) * 
                        state.energyMultiplier * 
                        (1 + state.productionBonus) *
                        (1 + state.prestigeBonus) *
                        eraMultiplier;
      
      productionData[gen.id] = production;
      totalProduction += production;
    }
    
    // Sort by production
    final sortedGens = productionData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total production header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  eraConfig.primaryColor.withValues(alpha: 0.2),
                  eraConfig.accentColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, color: eraConfig.accentColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${GameProvider.formatNumber(totalProduction)}/s',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: eraConfig.accentColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          _SectionHeader(title: 'PRODUCTION BREAKDOWN', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          
          if (sortedGens.isEmpty)
            Center(
              child: Text(
                'No generators owned yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...sortedGens.map((entry) {
              final genData = getGeneratorById(entry.key);
              if (genData == null) return const SizedBox();
              
              final percentage = totalProduction > 0 
                  ? (entry.value / totalProduction * 100) 
                  : 0.0;
              final count = state.getGeneratorCount(entry.key);
              final level = state.getGeneratorLevel(entry.key);
              
              return _ProductionBreakdownRow(
                name: genData.name,
                count: count,
                level: level,
                production: entry.value,
                percentage: percentage,
                eraConfig: eraConfig,
                era: genData.era,
              );
            }),
          
          const SizedBox(height: 12),
          
          // Multiplier breakdown
          _SectionHeader(title: 'MULTIPLIER STACK', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _MultiplierStackCard(state: state, eraConfig: eraConfig),
        ],
      ),
    );
  }

  Widget _buildRecordsTab(GameState state, EraConfig eraConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'ALL-TIME STATS', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _StatCard(
            stats: [
              _StatItem('Total Energy Earned', GameProvider.formatNumber(state.totalEnergyEarned)),
              _StatItem('Total Taps', state.totalTaps.toString()),
              _StatItem('Prestige Count', state.prestigeCount.toString()),
              _StatItem('Total Login Days', state.totalLoginDays.toString()),
            ],
            eraConfig: eraConfig,
          ),
          
          const SizedBox(height: 12),
          _SectionHeader(title: 'SESSION STATS', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _StatCard(
            stats: [
              _StatItem(
                'Play Time',
                _formatPlayTime(state.playTimeSeconds),
              ),
              _StatItem('Current Streak', '${state.loginStreak} days'),
              _StatItem('Generators Owned', state.totalGenerators.toString()),
              _StatItem('Research Completed', state.completedResearchCount.toString()),
            ],
            eraConfig: eraConfig,
          ),
          
          const SizedBox(height: 12),
          _SectionHeader(title: 'ACHIEVEMENTS', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _AchievementStatsCard(
            gameProvider: widget.gameProvider,
            eraConfig: eraConfig,
          ),
          
          const SizedBox(height: 12),
          _SectionHeader(title: 'ERA MILESTONES', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          _EraMilestonesCard(state: state, eraConfig: eraConfig),
        ],
      ),
    );
  }
  
  String _formatPlayTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
  
  void _showPrestigeDialog(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final nextPrestige = widget.gameProvider.getNextPrestigeInfo();
    
    if (nextPrestige == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: eraConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: eraConfig.primaryColor.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          'PRESTIGE: ${nextPrestige.tierName}',
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: eraConfig.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reset your progress for permanent bonuses?',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              '+${(nextPrestige.productionBonusGain * 100).toStringAsFixed(1)}% Production',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                color: eraConfig.accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '(Total: ${(nextPrestige.totalProductionBonus * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '+${GameProvider.formatNumber(nextPrestige.darkEnergyReward)} Dark Energy',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: eraConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            // Diminishing returns warning
            if (nextPrestige.hasDiminishingReturns) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'REDUCED REWARDS',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You\'ve reached K${nextPrestige.highestKardashev.toStringAsFixed(2)} before.\nProgress further to earn full rewards!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(${(nextPrestige.diminishingMultiplier * 100).toStringAsFixed(0)}% of normal rewards)',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.orange.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Each Dark Energy grants +10% Total Production Bonus',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: eraConfig.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.gameProvider.prestige();
              Navigator.pop(context);
            },
            child: const Text(
              'PRESTIGE',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPrestigeMilestones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => PrestigeMilestonesWidget(
          gameProvider: widget.gameProvider,
        ),
      ),
    );
  }
  
  void _showArtifactCollection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: widget.gameProvider.state.eraConfig.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: widget.gameProvider.state.eraConfig.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              // Content
              Expanded(
                child: ArtifactCollectionWidget(
                  gameProvider: widget.gameProvider,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _PrestigeMilestonesButton extends StatefulWidget {
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  final VoidCallback onTap;
  
  const _PrestigeMilestonesButton({
    required this.gameProvider,
    required this.eraConfig,
    required this.onTap,
  });

  @override
  State<_PrestigeMilestonesButton> createState() => _PrestigeMilestonesButtonState();
}

class _PrestigeMilestonesButtonState extends State<_PrestigeMilestonesButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = widget.gameProvider.state.prestigeTier;
    final currentMilestone = getMilestoneByTier(currentTier);
    final totalMilestones = prestigeMilestones.length;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withValues(alpha: 0.2),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.4 + 0.2 * _shimmerController.value),
              ),
            ),
            child: Row(
              children: [
                // Icon with current tier badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: currentMilestone != null
                          ? [currentMilestone.primaryColor, currentMilestone.accentColor]
                          : [Colors.grey, Colors.grey.shade600],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      currentMilestone?.emoji ?? '🌟',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Info and count combined
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MILESTONES',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$currentTier/$totalMilestones',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.purple.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ArtifactCollectionButton extends StatelessWidget {
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  final VoidCallback onTap;
  
  const _ArtifactCollectionButton({
    required this.gameProvider,
    required this.eraConfig,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get actual artifact counts from game state
    final ownedCount = gameProvider.state.ownedArtifactIds.length;
    const totalCount = 40; // Approximate total artifacts
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: 0.2),
              Colors.orange.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
            
            // Info and count combined
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ARTIFACTS',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$ownedCount/$totalCount',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.amber.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  
  const _SectionHeader({required this.title, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EraProgressCard extends StatelessWidget {
  final GameState state;
  final EraConfig eraConfig;
  
  const _EraProgressCard({required this.state, required this.eraConfig});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _getEraIcon(state.era),
                  const SizedBox(width: 8),
                  Text(
                    eraConfig.subtitle.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: eraConfig.primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: eraConfig.accentColor.withValues(alpha: 0.2),
                ),
                child: Text(
                  'TYPE ${_getRomanNumeral(state.era)}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: eraConfig.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Era progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'K${eraConfig.minKardashev.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    'K${state.kardashevLevel.toStringAsFixed(3)}',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: eraConfig.accentColor,
                    ),
                  ),
                  Text(
                    'K${eraConfig.maxKardashev.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.eraTechLevel,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(eraConfig.primaryColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Unlocked eras
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: Era.values.map((era) {
              final isUnlocked = state.unlockedEras.contains(era.index);
              final isCurrent = state.currentEra == era.index;
              final config = eraConfigs[era]!;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked 
                      ? config.primaryColor.withValues(alpha: isCurrent ? 0.4 : 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isCurrent 
                        ? config.accentColor
                        : isUnlocked 
                            ? config.primaryColor.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getRomanNumeral(era),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked 
                          ? config.primaryColor
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _getEraIcon(Era era) {
    IconData icon;
    switch (era) {
      case Era.planetary:
        icon = Icons.public;
      case Era.stellar:
        icon = Icons.wb_sunny;
      case Era.galactic:
        icon = Icons.blur_circular;
      case Era.universal:
        icon = Icons.all_inclusive;
      case Era.multiversal:
        icon = Icons.bubble_chart;
    }
    return Icon(icon, color: eraConfig.primaryColor, size: 18);
  }
  
  String _getRomanNumeral(Era era) {
    switch (era) {
      case Era.planetary:
        return 'I';
      case Era.stellar:
        return 'II';
      case Era.galactic:
        return 'III';
      case Era.universal:
        return 'IV';
      case Era.multiversal:
        return 'V';
    }
  }
}

class _BonusesCard extends StatelessWidget {
  final GameState state;
  final EraConfig eraConfig;
  
  const _BonusesCard({required this.state, required this.eraConfig});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _BonusRow(
            label: 'Energy Multiplier',
            value: '${state.energyMultiplier.toStringAsFixed(2)}x',
            color: eraConfig.accentColor,
          ),
          _BonusRow(
            label: 'Production Bonus',
            value: '+${(state.productionBonus * 100).toStringAsFixed(1)}%',
            color: Colors.green,
          ),
          _BonusRow(
            label: 'Prestige Bonus',
            value: '+${(state.prestigeBonus * 100).toStringAsFixed(1)}%',
            color: Colors.purple,
          ),
          _BonusRow(
            label: 'Cost Reduction',
            value: '-${(state.costReductionBonus * 100).toStringAsFixed(1)}%',
            color: Colors.orange,
          ),
          _BonusRow(
            label: 'Offline Bonus',
            value: '+${(state.offlineBonus * 100).toStringAsFixed(0)}%',
            color: Colors.blue,
          ),
          _BonusRow(
            label: 'Research Speed',
            value: '+${(state.researchSpeedBonus * 100).toStringAsFixed(0)}%',
            color: Colors.cyan,
          ),
        ],
      ),
    );
  }
}

class _BonusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _BonusRow({
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color.withValues(alpha: 0.2),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrestigeProgressCard extends StatelessWidget {
  final GameState state;
  final PrestigeInfo nextPrestige;
  final EraConfig eraConfig;
  
  const _PrestigeProgressCard({
    required this.state,
    required this.nextPrestige,
    required this.eraConfig,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = (state.kardashevLevel / nextPrestige.requiredKardashev).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.purple.withValues(alpha: 0.1),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next: ${nextPrestige.tierName}',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  color: Colors.purple,
                ),
              ),
              Text(
                'K${state.kardashevLevel.toStringAsFixed(2)} / K${nextPrestige.requiredKardashev.toStringAsFixed(1)}',
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
              valueColor: const AlwaysStoppedAnimation(Colors.purple),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '+${GameProvider.formatNumber(nextPrestige.darkEnergyReward)}',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'Dark Energy',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '+${(nextPrestige.productionBonusGain * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      color: eraConfig.accentColor,
                    ),
                  ),
                  Text(
                    'Production',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductionBreakdownRow extends StatelessWidget {
  final String name;
  final int count;
  final int level;
  final double production;
  final double percentage;
  final EraConfig eraConfig;
  final Era era;
  
  const _ProductionBreakdownRow({
    required this.name,
    required this.count,
    required this.level,
    required this.production,
    required this.percentage,
    required this.eraConfig,
    required this.era,
  });
  
  @override
  Widget build(BuildContext context) {
    final genEraConfig = eraConfigs[era]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: genEraConfig.primaryColor.withValues(alpha: 0.1),
        border: Border.all(color: genEraConfig.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: genEraConfig.primaryColor,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'x$count Lv.$level',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              Text(
                '${GameProvider.formatNumber(production)}/s',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  color: genEraConfig.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(genEraConfig.primaryColor.withValues(alpha: 0.6)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiplierStackCard extends StatelessWidget {
  final GameState state;
  final EraConfig eraConfig;
  
  const _MultiplierStackCard({required this.state, required this.eraConfig});
  
  @override
  Widget build(BuildContext context) {
    // Calculate total multiplier
    final totalMultiplier = state.energyMultiplier * 
                           (1 + state.productionBonus) * 
                           (1 + state.prestigeBonus);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _MultiplierRow(
            label: 'Base Energy Multiplier',
            value: state.energyMultiplier,
            color: eraConfig.accentColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '×',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          _MultiplierRow(
            label: 'Production Bonus',
            value: 1 + state.productionBonus,
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '×',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          _MultiplierRow(
            label: 'Prestige Bonus',
            value: 1 + state.prestigeBonus,
            color: Colors.purple,
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Multiplier',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      eraConfig.primaryColor.withValues(alpha: 0.3),
                      eraConfig.accentColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Text(
                  '${totalMultiplier.toStringAsFixed(2)}x',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: eraConfig.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MultiplierRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  
  const _MultiplierRow({
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)}x',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);
}

class _StatCard extends StatelessWidget {
  final List<_StatItem> stats;
  final EraConfig eraConfig;
  
  const _StatCard({required this.stats, required this.eraConfig});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: stats.map((stat) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                stat.value,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: eraConfig.accentColor,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _AchievementStatsCard extends StatelessWidget {
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  
  const _AchievementStatsCard({
    required this.gameProvider,
    required this.eraConfig,
  });
  
  @override
  Widget build(BuildContext context) {
    final unlocked = gameProvider.unlockedAchievementCount;
    final claimed = gameProvider.claimedAchievementCount;
    final total = 45; // Total achievements (can be dynamic later)
    final progress = unlocked / total;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AchievementStat(
                value: '$unlocked',
                label: 'Unlocked',
                color: Colors.amber,
              ),
              _AchievementStat(
                value: '$claimed',
                label: 'Claimed',
                color: Colors.green,
              ),
              _AchievementStat(
                value: '$total',
                label: 'Total',
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% Complete',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  
  const _AchievementStat({
    required this.value,
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
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
}

class _EraMilestonesCard extends StatelessWidget {
  final GameState state;
  final EraConfig eraConfig;
  
  const _EraMilestonesCard({required this.state, required this.eraConfig});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: Era.values.map((era) {
          final config = eraConfigs[era]!;
          final isUnlocked = state.unlockedEras.contains(era.index);
          final isCurrent = state.currentEra == era.index;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked 
                        ? config.primaryColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isUnlocked 
                          ? config.primaryColor
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Icon(
                            isCurrent ? Icons.star : Icons.check,
                            size: 12,
                            color: config.primaryColor,
                          )
                        : Icon(
                            Icons.lock,
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked 
                              ? config.primaryColor
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      Text(
                        'K${config.minKardashev.toStringAsFixed(1)} - K${config.maxKardashev.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: config.primaryColor.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      isCurrent ? 'ACTIVE' : 'UNLOCKED',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        color: config.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRESTIGE AVAILABLE CARD (duplicated from game_screen for modularity)
// ═══════════════════════════════════════════════════════════════

class _ComingSoonFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  
  const _ComingSoonFeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrestigeAvailableCard extends StatefulWidget {
  final PrestigeInfo nextPrestige;
  final EraConfig eraConfig;
  final VoidCallback onPrestige;
  
  const _PrestigeAvailableCard({
    required this.nextPrestige,
    required this.eraConfig,
    required this.onPrestige,
  });

  @override
  State<_PrestigeAvailableCard> createState() => _PrestigeAvailableCardState();
}

class _PrestigeAvailableCardState extends State<_PrestigeAvailableCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _borderAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPrestige,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.eraConfig.accentColor.withValues(alpha: 0.15),
                  widget.eraConfig.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: widget.eraConfig.accentColor.withValues(alpha: _borderAnimation.value),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.eraConfig.accentColor.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.rocket_launch,
                    color: widget.eraConfig.accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRESTIGE READY!',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: widget.eraConfig.accentColor,
                        ),
                      ),
                      Text(
                        '+${(widget.nextPrestige.productionBonusGain * 100).toStringAsFixed(1)}% · +${GameProvider.formatNumber(widget.nextPrestige.darkEnergyReward)} DE',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: widget.eraConfig.accentColor,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
