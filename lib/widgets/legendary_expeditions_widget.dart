import 'dart:async';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../core/constants.dart';
import '../models/legendary_expedition.dart';
import '../models/architect.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

/// Legendary Expeditions display widget
class LegendaryExpeditionsWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const LegendaryExpeditionsWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<LegendaryExpeditionsWidget> createState() => _LegendaryExpeditionsWidgetState();
}

class _LegendaryExpeditionsWidgetState extends State<LegendaryExpeditionsWidget> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final currentEra = widget.gameProvider.state.currentEra;
    final prestigeTier = widget.gameProvider.state.prestigeTier;
    
    // Check for active legendary expedition first
    final activeLegendary = widget.gameProvider.activeLegendaryExpedition;
    if (activeLegendary != null) {
      return _buildActiveExpeditionView(activeLegendary, eraConfig);
    }
    
    // Get available legendary expeditions
    final availableExpeditions = getLegendaryExpeditionsForTier(prestigeTier, currentEra);
    
    if (availableExpeditions.isEmpty) {
      return _buildNoExpeditionsView(eraConfig, prestigeTier);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: availableExpeditions.length,
      itemBuilder: (context, index) {
        final expedition = availableExpeditions[index];
        final isOnCooldown = widget.gameProvider.state.isLegendaryOnCooldown(expedition.id);
        return _LegendaryExpeditionCard(
          expedition: expedition,
          gameProvider: widget.gameProvider,
          eraConfig: eraConfig,
          isLocked: expedition.requiredPrestigeTier > prestigeTier || 
                   expedition.requiredEra > currentEra,
          isOnCooldown: isOnCooldown,
          cooldownRemaining: isOnCooldown 
              ? widget.gameProvider.state.getLegendaryCooldownRemaining(expedition.id)
              : Duration.zero,
        );
      },
    );
  }
  
  /// Build the active expedition tracking view
  Widget _buildActiveExpeditionView(ActiveLegendaryExpedition active, EraConfig eraConfig) {
    final expedition = active.expedition;
    if (expedition == null) return const SizedBox();
    
    final currentStage = active.currentStageInfo;
    final progress = active.overallProgress;
    final stageProgress = active.currentStageProgress;
    final canResolve = active.canResolveCurrentStage;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.4),
                  Colors.indigo.withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.5), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('⚔️', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expedition.name,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            expedition.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: active.failed ? Colors.red : Colors.orange,
                      ),
                      child: Text(
                        active.isCompleted 
                            ? (active.failed ? 'FAILED' : 'COMPLETE!')
                            : 'IN PROGRESS',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Overall progress
                Text(
                  'OVERALL PROGRESS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: Colors.purple,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      active.failed ? Colors.red : Colors.purple,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stage ${active.currentStage + 1}/${expedition.stages.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current Stage
          if (!active.isCompleted && currentStage != null) ...[  
            Text(
              'CURRENT STAGE',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                color: Colors.purple,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: currentStage.boss != null
                    ? currentStage.boss!.color.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: currentStage.boss != null
                      ? currentStage.boss!.color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currentStage.boss?.emoji ?? '🎯',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStage.name,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: currentStage.boss?.color ?? Colors.white,
                              ),
                            ),
                            if (currentStage.boss != null)
                              Text(
                                'Boss: ${currentStage.boss!.name}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: currentStage.boss!.color.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStage.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stage progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stageProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(
                        canResolve ? Colors.green : Colors.orange,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canResolve 
                        ? 'Ready to resolve!' 
                        : 'Time remaining: ${_formatDuration(active.currentStageRemainingTime)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: canResolve ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Resolve button
            if (canResolve)
              GestureDetector(
                onTap: () => _resolveStage(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        currentStage.boss != null ? currentStage.boss!.color : Colors.purple,
                        Colors.deepPurple,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (currentStage.boss?.color ?? Colors.purple).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        currentStage.boss != null ? Icons.shield : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentStage.boss != null ? 'FIGHT BOSS' : 'COMPLETE STAGE',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          
          // Completed expedition - collect button
          if (active.isCompleted && !active.isCollected) ...[  
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _collectExpedition(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: active.failed ? Colors.grey : Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: (active.failed ? Colors.grey : Colors.green).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      active.failed ? Icons.close : Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      active.failed ? 'DISMISS' : 'COLLECT REWARDS',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Assigned architects
          Text(
            'ASSIGNED ARCHITECTS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: Colors.purple,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: active.assignedArchitectIds.map((id) {
              final architect = getArchitectById(id);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(architect?.rarityColor ?? 0xFF808080).withValues(alpha: 0.2),
                  border: Border.all(
                    color: Color(architect?.rarityColor ?? 0xFF808080).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  architect?.name ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(architect?.rarityColor ?? 0xFF808080),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Stage overview
          Text(
            'STAGE OVERVIEW',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: Colors.purple,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...expedition.stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isCompleted = index < active.stageResults.length;
            final isSuccess = isCompleted ? active.stageResults[index] : false;
            final isCurrent = index == active.currentStage && !active.isCompleted;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isCurrent
                    ? Colors.orange.withValues(alpha: 0.2)
                    : isCompleted
                        ? (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isCurrent
                      ? Colors.orange.withValues(alpha: 0.5)
                      : isCompleted
                          ? (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    stage.boss?.emoji ?? '🎯',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stage.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? Colors.orange : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Icon(
                    isCompleted
                        ? (isSuccess ? Icons.check_circle : Icons.cancel)
                        : isCurrent
                            ? Icons.play_circle
                            : Icons.circle_outlined,
                    size: 18,
                    color: isCompleted
                        ? (isSuccess ? Colors.green : Colors.red)
                        : isCurrent
                            ? Colors.orange
                            : Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
            );
          }),
          
          // Cancel button (only if not completed)
          if (!active.isCompleted) ...[  
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showCancelConfirmation(context),
              child: Center(
                child: Text(
                  'Cancel Expedition',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.withValues(alpha: 0.7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
  
  void _resolveStage() {
    final result = widget.gameProvider.resolveLegendaryStage();
    if (result != null) {
      AudioService.playClick();
      _showStageResultDialog(result);
    }
  }
  
  void _showStageResultDialog(LegendaryStageResult result) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    
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
              result.success ? Icons.check_circle : Icons.cancel,
              color: result.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              result.success ? 'STAGE COMPLETE!' : 'STAGE FAILED',
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
              result.message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            if (result.rewards.isNotEmpty) ...[  
              const SizedBox(height: 16),
              Text(
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
                    Icon(reward.icon, size: 14, color: reward.color),
                    const SizedBox(width: 6),
                    Text(
                      reward.description,
                      style: TextStyle(fontSize: 11, color: reward.color),
                    ),
                  ],
                ),
              )),
            ],
            if (result.expeditionCompleted) ...[  
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green.withValues(alpha: 0.2),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Legendary Expedition Complete!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
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
  
  void _collectExpedition() {
    widget.gameProvider.collectLegendaryExpedition();
    AudioService.playAchievement();
  }
  
  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.gameProvider.state.eraConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'CANCEL EXPEDITION?',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will forfeit all progress and any rewards earned so far. Your architects will be freed.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('KEEP GOING'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              widget.gameProvider.cancelLegendaryExpedition();
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoExpeditionsView(EraConfig eraConfig, int prestigeTier) {
    final nextTierRequired = legendaryExpeditions
        .where((e) => e.requiredPrestigeTier > prestigeTier)
        .map((e) => e.requiredPrestigeTier)
        .fold<int?>(null, (min, tier) => min == null || tier < min ? tier : min);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: eraConfig.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'LEGENDARY EXPEDITIONS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: eraConfig.accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nextTierRequired != null
                  ? 'Reach Prestige Tier $nextTierRequired to unlock'
                  : 'No expeditions available yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🏆 Multi-stage boss encounters\n⚔️ Epic rewards and challenges\n✨ Unique lore and story',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for displaying a legendary expedition
class _LegendaryExpeditionCard extends StatelessWidget {
  final LegendaryExpedition expedition;
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  final bool isLocked;
  final bool isOnCooldown;
  final Duration cooldownRemaining;
  
  const _LegendaryExpeditionCard({
    required this.expedition,
    required this.gameProvider,
    required this.eraConfig,
    required this.isLocked,
    this.isOnCooldown = false,
    this.cooldownRemaining = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final bosses = expedition.bosses;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withValues(alpha: 0.3),
            Colors.indigo.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: isLocked 
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.purple.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: isLocked ? null : [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.4),
                    Colors.indigo.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.deepPurple,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text('⚔️', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                expedition.name,
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isLocked 
                                      ? Colors.grey 
                                      : Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.purple.withValues(alpha: 0.5),
                              ),
                              child: Text(
                                'LEGENDARY',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📍 ${expedition.location}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expedition.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Lore (expandable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📜', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            expedition.lore,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stage overview
                  Text(
                    'STAGES (${expedition.stages.length})',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Stage progress indicators
                  Row(
                    children: List.generate(expedition.stages.length, (index) {
                      final stage = expedition.stages[index];
                      final hasBoss = stage.boss != null;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index < expedition.stages.length - 1 ? 4 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: hasBoss 
                                ? stage.boss!.color.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                            border: hasBoss ? Border.all(
                              color: stage.boss!.color.withValues(alpha: 0.5),
                            ) : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                hasBoss ? stage.boss!.emoji : '🎯',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stage.durationMinutes}m',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Boss encounters
                  if (bosses.isNotEmpty) ...[
                    Text(
                      'BOSS ENCOUNTERS',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: bosses.map((boss) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: boss.color.withValues(alpha: 0.2),
                          border: Border.all(
                            color: boss.color.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(boss.emoji, style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              boss.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: boss.color,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Stats row
                  Row(
                    children: [
                      _buildStatChip(
                        '⏱️',
                        expedition.durationDisplay,
                        'Duration',
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        '🎯',
                        '${(expedition.overallSuccessRate * 100).toStringAsFixed(0)}%',
                        'Base Success',
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        '👨‍🚀',
                        '${expedition.minArchitects}-${expedition.maxArchitects}',
                        'Architects',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rewards preview
                  Text(
                    'COMPLETION REWARDS',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: expedition.completionRewards.map((reward) => 
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: reward.color.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(reward.icon, size: 12, color: reward.color),
                            const SizedBox(width: 4),
                            Text(
                              reward.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: reward.color,
                              ),
                            ),
                          ],
                        ),
                      )
                    ).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Requirements / Start button
                  if (isLocked)
                    _buildLockedRequirements()
                  else if (isOnCooldown)
                    _buildCooldownInfo()
                  else
                    _buildStartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatChip(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCooldownInfo() {
    final hours = cooldownRemaining.inHours;
    final minutes = cooldownRemaining.inMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.orange.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'Cooldown: $timeStr',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLockedRequirements() {
    final requirements = <String>[];
    
    if (expedition.requiredPrestigeTier > gameProvider.state.prestigeTier) {
      requirements.add('Prestige Tier ${expedition.requiredPrestigeTier}');
    }
    if (expedition.requiredEra > gameProvider.state.currentEra) {
      requirements.add('Era ${['I', 'II', 'III', 'IV'][expedition.requiredEra]}');
    }
    if (expedition.requiredRarity != null) {
      requirements.add('${expedition.requiredRarity!.name} Architect');
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Requires: ${requirements.join(', ')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.playClick();
        _showExpeditionLaunchDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.purple,
              Colors.deepPurple,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'EMBARK ON LEGENDARY EXPEDITION',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showExpeditionLaunchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LegendaryLaunchSheet(
        expedition: expedition,
        gameProvider: gameProvider,
        eraConfig: eraConfig,
      ),
    );
  }
}

/// Launch dialog for legendary expeditions
class _LegendaryLaunchSheet extends StatefulWidget {
  final LegendaryExpedition expedition;
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  
  const _LegendaryLaunchSheet({
    required this.expedition,
    required this.gameProvider,
    required this.eraConfig,
  });

  @override
  State<_LegendaryLaunchSheet> createState() => _LegendaryLaunchSheetState();
}

class _LegendaryLaunchSheetState extends State<_LegendaryLaunchSheet> {
  final Set<String> _selectedArchitects = {};
  
  @override
  Widget build(BuildContext context) {
    final ownedArchitects = widget.gameProvider.state.ownedArchitects;
    // Get architects that are NOT on any expedition (regular or legendary)
    final unavailableArchitects = widget.gameProvider.architectsOnAnyExpedition;
    final availableArchitects = allArchitects
        .where((a) => ownedArchitects.contains(a.id) && !unavailableArchitects.contains(a.id))
        .toList();
    
    final canLaunch = _selectedArchitects.length >= widget.expedition.minArchitects;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.purple.withValues(alpha: 0.5),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('⚔️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
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
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.expedition.stages.length} Stages • ${widget.expedition.bossCount} Bosses',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.purple.withValues(alpha: 0.3)),
          
          // Architect selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'SELECT ARCHITECTS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedArchitects.length}/${widget.expedition.maxArchitects}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedArchitects.length >= widget.expedition.minArchitects
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Architect grid
          Expanded(
            child: availableArchitects.isEmpty
                ? Center(
                    child: Text(
                      'No architects available.\nSynthesize architects first!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: availableArchitects.length,
                    itemBuilder: (context, index) {
                      final architect = availableArchitects[index];
                      final isSelected = _selectedArchitects.contains(architect.id);
                      final canSelect = _selectedArchitects.length < widget.expedition.maxArchitects;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedArchitects.remove(architect.id);
                            } else if (canSelect) {
                              _selectedArchitects.add(architect.id);
                            }
                          });
                          AudioService.playClick();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? Colors.purple.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.white.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getArchitectEmoji(architect.rarity),
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                architect.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Color(architect.rarityColor).withValues(alpha: 0.3),
                                ),
                                child: Text(
                                  architect.rarityName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(architect.rarityColor),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Launch button
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: canLaunch ? () => _launchExpedition(context) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: canLaunch
                      ? LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                        )
                      : null,
                  color: canLaunch ? null : Colors.grey.withValues(alpha: 0.3),
                  boxShadow: canLaunch
                      ? [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: canLaunch ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canLaunch
                          ? 'LAUNCH EXPEDITION'
                          : 'SELECT ${widget.expedition.minArchitects - _selectedArchitects.length} MORE ARCHITECT(S)',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canLaunch ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _launchExpedition(BuildContext context) {
    AudioService.playClick();
    
    // Actually start the expedition in game provider
    final success = widget.gameProvider.startLegendaryExpedition(
      widget.expedition.id,
      _selectedArchitects.toList(),
    );
    
    if (success) {
      Navigator.pop(context);
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text('⚔️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Legendary expedition launched!'),
            ],
          ),
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Failed to start expedition'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// Get emoji for architect based on rarity
  String _getArchitectEmoji(ArchitectRarity rarity) {
    switch (rarity) {
      case ArchitectRarity.common:
        return '👤';
      case ArchitectRarity.rare:
        return '🧑‍🔬';
      case ArchitectRarity.epic:
        return '🧙';
      case ArchitectRarity.legendary:
        return '⭐';
    }
  }
}
