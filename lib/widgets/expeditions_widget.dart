import 'dart:async';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../core/constants.dart';
import '../models/architect.dart';
import '../models/expedition.dart';
import '../models/tutorial_state.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import 'tutorial_manager.dart';
import 'legendary_expeditions_widget.dart';

/// Expeditions Tab Widget
class ExpeditionsWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const ExpeditionsWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<ExpeditionsWidget> createState() => _ExpeditionsWidgetState();
}

class _ExpeditionsWidgetState extends State<ExpeditionsWidget> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  final AdService _adService = AdService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Refresh UI every second to update timers
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    
    // Check if we should show the expeditions tutorial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (TutorialManager.instance.shouldShowTutorial(TutorialTopic.expeditions)) {
        TutorialManager.instance.startTutorial(TutorialTopic.expeditions);
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
    final activeExpeditions = widget.gameProvider.activeExpeditions;
    final hasActiveExpeditions = activeExpeditions.isNotEmpty;
    
    return Column(
      children: [
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
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore, size: 14),
                    const SizedBox(width: 4),
                    const Text('MISSIONS'),
                    if (hasActiveExpeditions) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${activeExpeditions.length}',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group, size: 14),
                    SizedBox(width: 4),
                    Text('TEAM'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚔️', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Text('LEGENDARY'),
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
              _buildMissionsTab(eraConfig),
              _buildTeamTab(eraConfig),
              LegendaryExpeditionsWidget(gameProvider: widget.gameProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionsTab(EraConfig eraConfig) {
    final activeExpeditions = widget.gameProvider.activeExpeditions;
    final currentEra = widget.gameProvider.state.eraName;
    
    // Get expeditions for current era
    final eraExpeditions = getExpeditionsForEra(currentEra);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active expeditions section
          if (activeExpeditions.isNotEmpty) ...[
            _SectionHeader(title: 'ACTIVE MISSIONS', color: Colors.orange),
            const SizedBox(height: 8),
            ...activeExpeditions.map((active) {
              final expedition = getExpeditionById(active.expeditionId);
              if (expedition == null) return const SizedBox();
              return _ActiveExpeditionCard(
                expedition: expedition,
                active: active,
                eraConfig: eraConfig,
                onCollect: () => _collectExpedition(active),
              );
            }),
            const SizedBox(height: 16),
          ],
          
          // Available expeditions by difficulty (filtered by era)
          _SectionHeader(title: 'ERA $currentEra MISSIONS', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          
          ...ExpeditionDifficulty.values.map((difficulty) {
            final expeditions = eraExpeditions.where((e) => e.difficulty == difficulty).toList();
            if (expeditions.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DifficultyHeader(difficulty: difficulty),
                const SizedBox(height: 4),
                ...expeditions.map((exp) => _ExpeditionCard(
                  expedition: exp,
                  eraConfig: eraConfig,
                  isActive: activeExpeditions.any((a) => a.expeditionId == exp.id),
                  canStart: _canStartExpedition(exp),
                  onStart: () => _showStartExpeditionDialog(exp),
                )),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTeamTab(EraConfig eraConfig) {
    final ownedArchitects = widget.gameProvider.state.ownedArchitects;
    
    // Get architects on ANY expedition (regular or legendary)
    final architectsOnExpedition = widget.gameProvider.architectsOnAnyExpedition;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: eraConfig.primaryColor.withValues(alpha: 0.1),
              border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TeamStat(
                  label: 'Total',
                  value: '${ownedArchitects.length}',
                  color: eraConfig.accentColor,
                ),
                _TeamStat(
                  label: 'Available',
                  value: '${ownedArchitects.length - architectsOnExpedition.length}',
                  color: Colors.green,
                ),
                _TeamStat(
                  label: 'On Mission',
                  value: '${architectsOnExpedition.length}',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          _SectionHeader(title: 'YOUR ARCHITECTS', color: eraConfig.primaryColor),
          const SizedBox(height: 8),
          
          if (ownedArchitects.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No architects yet',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Synthesize architects to send on expeditions',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...ownedArchitects.map((architectId) {
              final architect = getArchitectById(architectId);
              if (architect == null) return const SizedBox();
              
              final isOnExpedition = architectsOnExpedition.contains(architectId);
              
              return _ArchitectTeamCard(
                architect: architect,
                eraConfig: eraConfig,
                isOnExpedition: isOnExpedition,
              );
            }),
        ],
      ),
    );
  }

  bool _canStartExpedition(Expedition expedition) {
    final ownedArchitects = widget.gameProvider.state.ownedArchitects;
    final activeExpeditions = widget.gameProvider.activeExpeditions;
    
    // Check if expedition is already active
    if (activeExpeditions.any((a) => a.expeditionId == expedition.id)) {
      return false;
    }
    
    // Check max concurrent expeditions (3)
    if (activeExpeditions.length >= 3) {
      return false;
    }
    
    // Get available architects (not on ANY expedition - regular or legendary)
    final architectsOnExpedition = widget.gameProvider.architectsOnAnyExpedition;
    
    final availableCount = ownedArchitects.length - architectsOnExpedition.length;
    return availableCount >= expedition.minArchitects;
  }

  void _showStartExpeditionDialog(Expedition expedition) {
    AudioService.playClick();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StartExpeditionSheet(
        expedition: expedition,
        gameProvider: widget.gameProvider,
        onStart: (architectIds) {
          Navigator.pop(context);
          widget.gameProvider.startExpedition(expedition.id, architectIds);
          AudioService.playPurchase();
        },
      ),
    );
  }

  void _collectExpedition(ActiveExpedition active) {
    AudioService.playAchievement();
    final result = widget.gameProvider.completeExpedition(active.expeditionId);
    
    if (result != null) {
      _showExpeditionResultDialog(result, active);
    }
  }

  void _showExpeditionResultDialog(ExpeditionResult result, ActiveExpedition active) {
    final expedition = getExpeditionById(active.expeditionId);
    final eraConfig = widget.gameProvider.state.eraConfig;
    final canRetry = !result.success && _adService.canWatchAd(AdPlacement.expeditionRetry);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: eraConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: result.success 
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.red.withValues(alpha: 0.5),
          ),
        ),
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              result.success ? 'MISSION SUCCESS!' : 'MISSION FAILED',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: result.success ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expedition?.name ?? 'Unknown Mission',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            if (result.rewards.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'REWARDS:',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 8),
              ...result.rewards.map((reward) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(reward.icon, size: 16, color: reward.color),
                    const SizedBox(width: 8),
                    Text(
                      reward.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: reward.color,
                      ),
                    ),
                  ],
                ),
              )),
            ],
            // Ad retry option for failed expeditions
            if (!result.success && canRetry) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.info.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_filled,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Watch ad to retry this expedition!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_adService.getRemainingWatches(AdPlacement.expeditionRetry)}/3 retries remaining today',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.info.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!result.success && canRetry)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final adResult = await _adService.showRewardedAd(AdPlacement.expeditionRetry);
                if (adResult.success && expedition != null) {
                  // Restart the expedition with the same architects
                  widget.gameProvider.startExpedition(
                    expedition.id, 
                    active.assignedArchitectIds,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Expedition restarted! Good luck!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_filled, size: 16, color: AppColors.info),
                  const SizedBox(width: 4),
                  Text(
                    'WATCH AD TO RETRY',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: result.success ? Colors.green : Colors.grey,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

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

class _DifficultyHeader extends StatelessWidget {
  final ExpeditionDifficulty difficulty;
  
  const _DifficultyHeader({required this.difficulty});
  
  String get _difficultyName {
    switch (difficulty) {
      case ExpeditionDifficulty.easy:
        return 'EASY';
      case ExpeditionDifficulty.medium:
        return 'MEDIUM';
      case ExpeditionDifficulty.hard:
        return 'HARD';
      case ExpeditionDifficulty.legendary:
        return 'LEGENDARY';
    }
  }
  
  Color get _color {
    switch (difficulty) {
      case ExpeditionDifficulty.easy:
        return Colors.green;
      case ExpeditionDifficulty.medium:
        return Colors.orange;
      case ExpeditionDifficulty.hard:
        return Colors.red;
      case ExpeditionDifficulty.legendary:
        return Colors.purple;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _color.withValues(alpha: 0.2),
      ),
      child: Text(
        _difficultyName,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 9,
          color: _color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ExpeditionCard extends StatelessWidget {
  final Expedition expedition;
  final EraConfig eraConfig;
  final bool isActive;
  final bool canStart;
  final VoidCallback onStart;
  
  const _ExpeditionCard({
    required this.expedition,
    required this.eraConfig,
    required this.isActive,
    required this.canStart,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive 
            ? Colors.grey.withValues(alpha: 0.2)
            : expedition.difficultyColor.withValues(alpha: 0.1),
        border: Border.all(
          color: isActive 
              ? Colors.grey.withValues(alpha: 0.3)
              : expedition.difficultyColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expedition.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive 
                            ? Colors.grey
                            : expedition.difficultyColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expedition.location,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Duration and team size
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        expedition.durationDisplay,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.group,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${expedition.minArchitects}-${expedition.maxArchitects}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            expedition.description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Rewards preview
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: expedition.baseRewards.take(3).map((reward) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: reward.color.withValues(alpha: 0.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(reward.icon, size: 10, color: reward.color),
                          const SizedBox(width: 2),
                          Text(
                            reward.description,
                            style: TextStyle(
                              fontSize: 9,
                              color: reward.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (!isActive)
                GestureDetector(
                  onTap: canStart ? onStart : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: canStart 
                          ? expedition.difficultyColor.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                      border: Border.all(
                        color: canStart 
                            ? expedition.difficultyColor
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'START',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: canStart 
                            ? expedition.difficultyColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 8,
                      color: Colors.orange,
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

class _ActiveExpeditionCard extends StatelessWidget {
  final Expedition expedition;
  final ActiveExpedition active;
  final EraConfig eraConfig;
  final VoidCallback onCollect;
  
  const _ActiveExpeditionCard({
    required this.expedition,
    required this.active,
    required this.eraConfig,
    required this.onCollect,
  });

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCollect = active.canCollect;
    final remaining = active.remainingTime;
    final progress = active.progress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            expedition.difficultyColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: canCollect 
              ? Colors.green.withValues(alpha: 0.6)
              : Colors.orange.withValues(alpha: 0.4),
          width: canCollect ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expedition.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: expedition.difficultyColor,
                      ),
                    ),
                    Text(
                      expedition.location,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (canCollect)
                GestureDetector(
                  onTap: onCollect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'COLLECT',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(remaining),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                canCollect ? Colors.green : Colors.orange,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          // Assigned architects
          Row(
            children: [
              Icon(
                Icons.group,
                size: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              ...active.assignedArchitectIds.take(3).map((id) {
                final architect = getArchitectById(id);
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Color(architect?.rarityColor ?? 0xFF808080).withValues(alpha: 0.3),
                  ),
                  child: Text(
                    architect?.name ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(architect?.rarityColor ?? 0xFF808080),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  
  const _TeamStat({
    required this.label,
    required this.value,
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

class _ArchitectTeamCard extends StatelessWidget {
  final Architect architect;
  final EraConfig eraConfig;
  final bool isOnExpedition;
  
  const _ArchitectTeamCard({
    required this.architect,
    required this.eraConfig,
    required this.isOnExpedition,
  });

  String _getArchitectEmoji() {
    switch (architect.id) {
      // Era I - Planetary
      case 'tesla':
        return '⚡';
      case 'einstein':
        return '🧠';
      case 'curie':
        return '☢️';
      case 'dyson':
        return '🔮';
      case 'oppenheimer':
        return '💥';
      case 'lovelace':
        return '💻';
      case 'engineer_alpha':
        return '🔧';
      case 'scientist_alpha':
        return '🔬';
      // Era II - Stellar
      case 'dyson_ii':
        return '☀️';
      case 'kardashev':
        return '📊';
      case 'sagan':
        return '🌍';
      case 'von_neumann':
        return '🤖';
      case 'oberth':
        return '🚀';
      case 'tsiolkovsky':
        return '🌙';
      case 'stellar_engineer':
        return '⭐';
      case 'swarm_coordinator':
        return '🛰️';
      // Era III - Galactic
      case 'hawking':
        return '🕳️';
      case 'penrose':
        return '🔄';
      case 'thorne':
        return '🌀';
      case 'chandrasekhar':
        return '💫';
      case 'vera_rubin':
        return '🌑';
      case 'jocelyn_bell':
        return '📡';
      case 'galactic_commander':
        return '🎖️';
      case 'singularity_priest':
        return '🙏';
      // Era IV - Universal
      case 'omega':
        return '♾️';
      case 'eternus':
        return '⏳';
      case 'architect_prime':
        return '🏛️';
      case 'entropy_keeper':
        return '⚖️';
      case 'void_walker':
        return '👁️';
      case 'quantum_sage':
        return '🎲';
      case 'cosmic_initiate':
        return '✨';
      case 'multiverse_scout':
        return '🔭';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(architect.rarityColor);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isOnExpedition 
            ? Colors.grey.withValues(alpha: 0.1)
            : rarityColor.withValues(alpha: 0.1),
        border: Border.all(
          color: isOnExpedition 
              ? Colors.grey.withValues(alpha: 0.3)
              : rarityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Portrait
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rarityColor.withValues(alpha: isOnExpedition ? 0.2 : 0.3),
              border: Border.all(
                color: rarityColor.withValues(alpha: isOnExpedition ? 0.3 : 0.5),
              ),
            ),
            child: Center(
              child: Text(
                _getArchitectEmoji(),
                style: TextStyle(
                  fontSize: 20,
                  color: isOnExpedition ? Colors.grey : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  architect.name,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOnExpedition ? Colors.grey : rarityColor,
                  ),
                ),
                Text(
                  architect.title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: isOnExpedition ? 0.3 : 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isOnExpedition 
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
            ),
            child: Text(
              isOnExpedition ? 'ON MISSION' : 'AVAILABLE',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 8,
                color: isOnExpedition ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// START EXPEDITION SHEET
// ═══════════════════════════════════════════════════════════════

class _StartExpeditionSheet extends StatefulWidget {
  final Expedition expedition;
  final GameProvider gameProvider;
  final Function(List<String>) onStart;
  
  const _StartExpeditionSheet({
    required this.expedition,
    required this.gameProvider,
    required this.onStart,
  });

  @override
  State<_StartExpeditionSheet> createState() => _StartExpeditionSheetState();
}

class _StartExpeditionSheetState extends State<_StartExpeditionSheet> {
  final Set<String> _selectedArchitects = {};

  List<String> get _availableArchitects {
    final owned = widget.gameProvider.state.ownedArchitects;
    // Use the unified method that checks both regular and legendary expeditions
    final onExpedition = widget.gameProvider.architectsOnAnyExpedition;
    
    return owned.where((id) => !onExpedition.contains(id)).toList();
  }

  double get _successRate {
    final base = widget.expedition.successRateBase;
    double bonus = 0;
    
    for (final architectId in _selectedArchitects) {
      final architect = getArchitectById(architectId);
      if (architect == null) continue;
      
      // Rarity bonus
      switch (architect.rarity) {
        case ArchitectRarity.common:
          bonus += 0.05;
        case ArchitectRarity.rare:
          bonus += 0.10;
        case ArchitectRarity.epic:
          bonus += 0.15;
        case ArchitectRarity.legendary:
          bonus += 0.20;
      }
      
      // Preferred architect bonus
      if (widget.expedition.preferredArchitectId == architectId) {
        bonus += 0.25;
      }
      
      // Preferred rarity bonus
      if (widget.expedition.preferredRarity == architect.rarity) {
        bonus += 0.10;
      }
    }
    
    return (base + bonus).clamp(0.0, 0.99);
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final canStart = _selectedArchitects.length >= widget.expedition.minArchitects;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: eraConfig.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: widget.expedition.difficultyColor.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expedition.name,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.expedition.difficultyColor,
                        ),
                      ),
                      Text(
                        widget.expedition.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.expedition.durationDisplay,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: widget.expedition.difficultyColor.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        widget.expedition.difficultyName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 9,
                          color: widget.expedition.difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Success rate
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Success Rate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${(_successRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _successRate > 0.7 
                        ? Colors.green
                        : _successRate > 0.5 
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Team selection header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SELECT TEAM',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${_selectedArchitects.length}/${widget.expedition.maxArchitects}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    color: canStart ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Architect selection list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableArchitects.length,
              itemBuilder: (context, index) {
                final architectId = _availableArchitects[index];
                final architect = getArchitectById(architectId);
                if (architect == null) return const SizedBox();
                
                final isSelected = _selectedArchitects.contains(architectId);
                final canSelect = isSelected || 
                    _selectedArchitects.length < widget.expedition.maxArchitects;
                
                return _ArchitectSelectCard(
                  architect: architect,
                  isSelected: isSelected,
                  canSelect: canSelect,
                  expedition: widget.expedition,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedArchitects.remove(architectId);
                      } else if (canSelect) {
                        _selectedArchitects.add(architectId);
                      }
                    });
                  },
                );
              },
            ),
          ),
          
          // Start button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: canStart 
                  ? () => widget.onStart(_selectedArchitects.toList())
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: canStart 
                      ? widget.expedition.difficultyColor
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Text(
                    canStart 
                        ? 'START EXPEDITION'
                        : 'SELECT ${widget.expedition.minArchitects - _selectedArchitects.length} MORE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canStart ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchitectSelectCard extends StatelessWidget {
  final Architect architect;
  final bool isSelected;
  final bool canSelect;
  final Expedition expedition;
  final VoidCallback onTap;
  
  const _ArchitectSelectCard({
    required this.architect,
    required this.isSelected,
    required this.canSelect,
    required this.expedition,
    required this.onTap,
  });

  String _getArchitectEmoji() {
    switch (architect.id) {
      // Era I - Planetary
      case 'tesla':
        return '⚡';
      case 'einstein':
        return '🧠';
      case 'curie':
        return '☢️';
      case 'dyson':
        return '🔮';
      case 'oppenheimer':
        return '💥';
      case 'lovelace':
        return '💻';
      case 'engineer_alpha':
        return '🔧';
      case 'scientist_alpha':
        return '🔬';
      // Era II - Stellar
      case 'dyson_ii':
        return '☀️';
      case 'kardashev':
        return '📊';
      case 'sagan':
        return '🌍';
      case 'von_neumann':
        return '🤖';
      case 'oberth':
        return '🚀';
      case 'tsiolkovsky':
        return '🌙';
      case 'stellar_engineer':
        return '⭐';
      case 'swarm_coordinator':
        return '🛰️';
      // Era III - Galactic
      case 'hawking':
        return '🕳️';
      case 'penrose':
        return '🔄';
      case 'thorne':
        return '🌀';
      case 'chandrasekhar':
        return '💫';
      case 'vera_rubin':
        return '🌑';
      case 'jocelyn_bell':
        return '📡';
      case 'galactic_commander':
        return '🎖️';
      case 'singularity_priest':
        return '🙏';
      // Era IV - Universal
      case 'omega':
        return '♾️';
      case 'eternus':
        return '⏳';
      case 'architect_prime':
        return '🏛️';
      case 'entropy_keeper':
        return '⚖️';
      case 'void_walker':
        return '👁️';
      case 'quantum_sage':
        return '🎲';
      case 'cosmic_initiate':
        return '✨';
      case 'multiverse_scout':
        return '🔭';
      default:
        return '👤';
    }
  }
  
  bool get _isPreferred {
    return expedition.preferredArchitectId == architect.id ||
        expedition.preferredRarity == architect.rarity;
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(architect.rarityColor);
    
    return GestureDetector(
      onTap: canSelect ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected 
              ? rarityColor.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.3),
          border: Border.all(
            color: isSelected 
                ? rarityColor
                : canSelect 
                    ? rarityColor.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? rarityColor
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? rarityColor : Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: isSelected 
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            // Portrait
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rarityColor.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Text(_getArchitectEmoji(), style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        architect.name,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rarityColor,
                        ),
                      ),
                      if (_isPreferred) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                          child: const Text(
                            'BONUS',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 7,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    architect.rarityName,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
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
