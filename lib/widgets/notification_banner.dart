import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../services/audio_service.dart';

/// Notification types for in-app notifications
enum NotificationType {
  offlineEarnings,
  achievementUnlocked,
  prestigeReady,
  eraTransition,
  dailyReward,
  researchComplete,
  architectGained,
  // Sprint 4 additions
  expeditionComplete,
  expeditionFailed,
  abilityReady,
  challengeComplete,
  dailyChallengeReset,
  weeklyChallengeReset,
  generatorMilestone,
  productionMilestone,
  // Artifact and legendary expedition additions
  artifactFound,
  legendaryStageComplete,
}

/// In-app notification banner model
class NotificationBannerData {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Duration duration;
  
  const NotificationBannerData({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.onTap,
    this.duration = const Duration(seconds: 4),
  });
}

/// Animated notification banner widget
class NotificationBanner extends StatefulWidget {
  final NotificationBannerData data;
  final VoidCallback onDismiss;
  final EraConfig eraConfig;
  
  const NotificationBanner({
    super.key,
    required this.data,
    required this.onDismiss,
    required this.eraConfig,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
    
    // Auto dismiss after duration
    Future.delayed(widget.data.duration, () {
      if (mounted) {
        _dismissBanner();
      }
    });
  }
  
  void _dismissBanner() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            AudioService.playClick();
            widget.data.onTap?.call();
            _dismissBanner();
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && 
                details.primaryVelocity!.abs() > 200) {
              _dismissBanner();
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.eraConfig.backgroundColor.withValues(alpha: 0.95),
              border: Border.all(
                color: widget.data.color.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.data.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.data.color.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: widget.data.color,
                    size: 22,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.data.title,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.data.color,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.message,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Dismiss button
                GestureDetector(
                  onTap: _dismissBanner,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification banner controller for managing multiple banners
class NotificationBannerController extends ChangeNotifier {
  final List<NotificationBannerData> _notifications = [];
  
  List<NotificationBannerData> get notifications => List.unmodifiable(_notifications);
  
  void show(NotificationBannerData notification) {
    // Prevent duplicate notifications
    if (_notifications.any((n) => n.id == notification.id)) return;
    
    _notifications.add(notification);
    notifyListeners();
  }
  
  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
  
  void dismissAll() {
    _notifications.clear();
    notifyListeners();
  }
  
  // Factory methods for common notifications
  void showOfflineEarnings(double earnings, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'offline_earnings_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.offlineEarnings,
      title: 'WELCOME BACK',
      message: 'Tap to collect offline earnings!',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      onTap: onTap,
      duration: const Duration(seconds: 5),
    ));
  }
  
  void showPrestigeReady(String tierName, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'prestige_ready_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.prestigeReady,
      title: 'PRESTIGE READY!',
      message: 'Ascend to $tierName for permanent bonuses',
      icon: Icons.rocket_launch,
      color: Colors.purple,
      onTap: onTap,
      duration: const Duration(seconds: 6),
    ));
  }
  
  void showResearchComplete(String researchName, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'research_complete_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.researchComplete,
      title: 'RESEARCH COMPLETE',
      message: '$researchName has been unlocked!',
      icon: Icons.science,
      color: Colors.cyan,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
  
  void showArchitectGained(String architectName, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'architect_gained_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.architectGained,
      title: 'NEW ARCHITECT!',
      message: '$architectName has joined your cause',
      icon: Icons.person_add,
      color: Colors.teal,
      onTap: onTap,
      duration: const Duration(seconds: 5),
    ));
  }
  
  // ═══════════════════════════════════════════════════════════════
  // SPRINT 4: NEW NOTIFICATION TYPES
  // ═══════════════════════════════════════════════════════════════
  
  void showExpeditionComplete(String expeditionName, String rewards, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'expedition_complete_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.expeditionComplete,
      title: 'EXPEDITION SUCCESS!',
      message: '$expeditionName completed! $rewards',
      icon: Icons.rocket_launch,
      color: Colors.green,
      onTap: onTap,
      duration: const Duration(seconds: 5),
    ));
  }
  
  void showExpeditionFailed(String expeditionName, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'expedition_failed_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.expeditionFailed,
      title: 'EXPEDITION FAILED',
      message: '$expeditionName was unsuccessful. Try again!',
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
  
  void showAbilityReady(String architectName, String abilityName, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'ability_ready_${architectName}_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.abilityReady,
      title: 'ABILITY READY!',
      message: '$architectName\'s $abilityName is available',
      icon: Icons.flash_on,
      color: Colors.amber,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
  
  void showChallengeComplete(String challengeName, String reward, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'challenge_complete_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.challengeComplete,
      title: 'CHALLENGE COMPLETE!',
      message: '$challengeName - Claim your $reward!',
      icon: Icons.emoji_events,
      color: Colors.amber,
      onTap: onTap,
      duration: const Duration(seconds: 5),
    ));
  }
  
  void showDailyChallengeReset(int challengeCount, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'daily_challenge_reset_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.dailyChallengeReset,
      title: 'DAILY CHALLENGES RESET',
      message: '$challengeCount new daily challenges available!',
      icon: Icons.today,
      color: Colors.blue,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
  
  void showWeeklyChallengeReset(int challengeCount, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'weekly_challenge_reset_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.weeklyChallengeReset,
      title: 'WEEKLY CHALLENGES RESET',
      message: '$challengeCount new weekly challenges available!',
      icon: Icons.date_range,
      color: Colors.purple,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
  
  void showGeneratorMilestone(String generatorName, int count, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'generator_milestone_${generatorName}_$count',
      type: NotificationType.generatorMilestone,
      title: 'MILESTONE REACHED!',
      message: 'Built $count $generatorName generators',
      icon: Icons.construction,
      color: Colors.teal,
      onTap: onTap,
      duration: const Duration(seconds: 3),
    ));
  }
  
  void showProductionMilestone(String milestone, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'production_milestone_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.productionMilestone,
      title: 'PRODUCTION MILESTONE!',
      message: 'Reached $milestone energy per second!',
      icon: Icons.bolt,
      color: Colors.yellow,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
  
  void showArtifactFound(String artifactName, String rarity, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'artifact_found_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.artifactFound,
      title: 'ARTIFACT DISCOVERED!',
      message: '$rarity artifact: $artifactName',
      icon: Icons.diamond,
      color: Colors.deepPurple,
      onTap: onTap,
      duration: const Duration(seconds: 5),
    ));
  }
  
  void showLegendaryStageComplete(String stageName, bool isBossStage, VoidCallback onTap) {
    show(NotificationBannerData(
      id: 'legendary_stage_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.expeditionComplete,
      title: isBossStage ? 'BOSS DEFEATED!' : 'STAGE COMPLETE!',
      message: stageName,
      icon: isBossStage ? Icons.shield : Icons.check_circle,
      color: isBossStage ? Colors.red : Colors.purple,
      onTap: onTap,
      duration: const Duration(seconds: 4),
    ));
  }
}

/// Stack of notification banners
class NotificationBannerStack extends StatelessWidget {
  final NotificationBannerController controller;
  final EraConfig eraConfig;
  
  const NotificationBannerStack({
    super.key,
    required this.controller,
    required this.eraConfig,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        if (controller.notifications.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.notifications.map((notification) {
            return NotificationBanner(
              key: ValueKey(notification.id),
              data: notification,
              eraConfig: eraConfig,
              onDismiss: () => controller.dismiss(notification.id),
            );
          }).toList(),
        );
      },
    );
  }
}
