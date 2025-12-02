import 'package:flutter/material.dart';
import '../models/legendary_expedition.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

/// Dialog that appears when a legendary expedition stage is ready to be resolved
class LegendaryStageReadyDialog extends StatelessWidget {
  final GameProvider gameProvider;
  final VoidCallback onDismiss;
  final VoidCallback onResolve;
  
  const LegendaryStageReadyDialog({
    super.key,
    required this.gameProvider,
    required this.onDismiss,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final active = gameProvider.activeLegendaryExpedition;
    if (active == null) return const SizedBox();
    
    final expedition = active.expedition;
    final currentStage = active.currentStageInfo;
    if (expedition == null || currentStage == null) return const SizedBox();
    
    final isBossStage = currentStage.boss != null;
    final primaryColor = isBossStage 
        ? currentStage.boss!.color 
        : Colors.purple;
    
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.95),
              ],
            ),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.4),
                      primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Animated icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.2),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Text(
                            isBossStage 
                                ? currentStage.boss!.emoji 
                                : '🎯',
                            style: const TextStyle(fontSize: 48),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isBossStage 
                          ? 'BOSS ENCOUNTER READY!' 
                          : 'STAGE READY!',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      expedition.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current stage info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: primaryColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                                child: Text(
                                  'STAGE ${active.currentStage + 1}/${expedition.stages.length}',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              if (isBossStage) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currentStage.boss!.emoji,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'BOSS',
                                        style: TextStyle(
                                          fontFamily: 'Orbitron',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentStage.name,
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentStage.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                          if (isBossStage) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    currentStage.boss!.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentStage.boss!.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: currentStage.boss!.color,
                                          ),
                                        ),
                                        Text(
                                          currentStage.boss!.description,
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
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Success rate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.casino,
                          size: 16,
                          color: Colors.amber.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Success Rate: ${(currentStage.effectiveSuccessRate * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Potential rewards preview
                    Text(
                      'Potential Rewards:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: currentStage.stageRewards.map((reward) =>
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
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
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
              
              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    // Later button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          AudioService.playClick();
                          onDismiss();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.withValues(alpha: 0.3),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'LATER',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Resolve button
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          AudioService.playClick();
                          HapticService.mediumImpact();
                          onResolve();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isBossStage ? Icons.shield : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isBossStage ? 'FIGHT BOSS' : 'CONTINUE',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
