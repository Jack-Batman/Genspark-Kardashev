import 'dart:math';
import 'package:flutter/material.dart';

/// Challenge duration types
enum ChallengeDuration {
  daily,   // Resets every 24 hours
  weekly,  // Resets every 7 days
  event,   // Special limited-time challenges
}

/// Challenge objective types
enum ChallengeObjective {
  produceEnergy,       // Produce X energy
  purchaseGenerators,  // Buy X generators
  earnDarkMatter,      // Earn X dark matter
  completeResearch,    // Complete X research
  tapCount,            // Tap X times
  reachKardashev,      // Reach Kardashev level X
  completeExpedition,  // Complete X expeditions
  useAbility,          // Use X abilities
  playTime,            // Play for X minutes
  prestige,            // Perform X prestiges (weekly only)
  upgradeGenerators,   // Upgrade generators X times
}

/// Challenge reward types
enum ChallengeRewardType {
  energy,
  darkMatter,
  darkEnergy,
  productionBoost,
  timeWarp,
}

/// Player progress data for scaling challenges
class PlayerProgress {
  final double kardashevLevel;
  final int currentEra;
  final double energyPerSecond;
  final int prestigeCount;
  final int totalGenerators;
  final double totalEnergyEarned;
  
  const PlayerProgress({
    this.kardashevLevel = 0.0,
    this.currentEra = 0,
    this.energyPerSecond = 1.0,
    this.prestigeCount = 0,
    this.totalGenerators = 0,
    this.totalEnergyEarned = 0,
  });
  
  /// Get scaling multiplier based on era (exponential scaling)
  double get eraMultiplier => pow(10, currentEra * 3).toDouble();
  
  /// Get scaling for Kardashev-based targets
  double get kardashevMultiplier => pow(10, kardashevLevel).toDouble();
}

/// Individual challenge reward - now supports scaling
class ChallengeReward {
  final ChallengeRewardType type;
  final double baseAmount;      // Base value before scaling
  final String descriptionTemplate; // Use {amount} for dynamic value
  final bool scalesWithProgress;
  
  const ChallengeReward({
    required this.type,
    required this.baseAmount,
    required this.descriptionTemplate,
    this.scalesWithProgress = true,
  });
  
  /// Get actual reward amount based on player progress
  double getAmount(PlayerProgress progress) {
    if (!scalesWithProgress) return baseAmount;
    
    switch (type) {
      case ChallengeRewardType.energy:
        // Energy rewards scale with production rate (give X minutes worth)
        return max(baseAmount * progress.energyPerSecond * 60, _getMinEnergy(progress));
      case ChallengeRewardType.darkMatter:
        // Dark Matter scales with era
        return baseAmount * pow(2, progress.currentEra);
      case ChallengeRewardType.darkEnergy:
        // Dark Energy scales slightly with prestige
        return baseAmount * (1 + progress.prestigeCount * 0.1);
      case ChallengeRewardType.productionBoost:
      case ChallengeRewardType.timeWarp:
        // These don't scale - fixed multipliers/durations
        return baseAmount;
    }
  }
  
  double _getMinEnergy(PlayerProgress progress) {
    final k = progress.kardashevLevel;
    if (k < 0.5) return 500;
    if (k < 1.0) return 5000;
    if (k < 1.5) return 50000;
    if (k < 2.0) return 500000;
    if (k < 2.5) return 5000000;
    return 50000000;
  }
  
  String getDescription(PlayerProgress progress) {
    final amount = getAmount(progress);
    return descriptionTemplate.replaceAll('{amount}', _formatNumber(amount));
  }
  
  String _formatNumber(double value) {
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(1)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'baseAmount': baseAmount,
      'descriptionTemplate': descriptionTemplate,
      'scalesWithProgress': scalesWithProgress,
    };
  }
  
  factory ChallengeReward.fromMap(Map<String, dynamic> map) {
    return ChallengeReward(
      type: ChallengeRewardType.values[map['type'] as int],
      baseAmount: (map['baseAmount'] ?? map['amount'] as num).toDouble(),
      descriptionTemplate: map['descriptionTemplate'] ?? map['description'] as String,
      scalesWithProgress: map['scalesWithProgress'] ?? true,
    );
  }
  
  // Legacy getter for compatibility
  double get amount => baseAmount;
  String get description => descriptionTemplate;
}

/// Challenge template - defines structure, actual values calculated at runtime
class ChallengeTemplate {
  final String id;
  final String name;
  final String descriptionTemplate; // Use {target} for dynamic value
  final ChallengeDuration duration;
  final ChallengeObjective objective;
  final double baseTargetValue;     // Base target before scaling
  final List<ChallengeReward> rewards;
  final IconData icon;
  final Color color;
  final int tier; // 1 = easy, 2 = medium, 3 = hard
  final double scalingFactor;       // How aggressively it scales (0.5 = slow, 2.0 = fast)
  
  const ChallengeTemplate({
    required this.id,
    required this.name,
    required this.descriptionTemplate,
    required this.duration,
    required this.objective,
    required this.baseTargetValue,
    required this.rewards,
    required this.icon,
    required this.color,
    this.tier = 1,
    this.scalingFactor = 1.0,
  });
  
  /// Generate actual challenge with scaled values
  Challenge generateChallenge(PlayerProgress progress) {
    final targetValue = _calculateTarget(progress);
    final description = descriptionTemplate.replaceAll('{target}', _formatTarget(targetValue));
    
    return Challenge(
      id: id,
      name: name,
      description: description,
      duration: duration,
      objective: objective,
      targetValue: targetValue,
      rewards: rewards,
      icon: icon,
      color: color,
      tier: tier,
      playerProgress: progress,
    );
  }
  
  double _calculateTarget(PlayerProgress progress) {
    switch (objective) {
      case ChallengeObjective.produceEnergy:
        // Scale with energy per second - target is X minutes of production
        final minutesOfProduction = baseTargetValue * scalingFactor;
        return max(progress.energyPerSecond * 60 * minutesOfProduction, _getMinEnergy(progress));
        
      case ChallengeObjective.purchaseGenerators:
      case ChallengeObjective.upgradeGenerators:
        // Slight scaling with era
        return baseTargetValue * (1 + progress.currentEra * 0.5);
        
      case ChallengeObjective.earnDarkMatter:
        // Scale with era
        return baseTargetValue * pow(2, progress.currentEra);
        
      case ChallengeObjective.completeResearch:
      case ChallengeObjective.completeExpedition:
      case ChallengeObjective.useAbility:
      case ChallengeObjective.prestige:
        // Fixed targets for action-based challenges
        return baseTargetValue;
        
      case ChallengeObjective.tapCount:
        // Slight scaling
        return baseTargetValue * (1 + progress.currentEra * 0.25);
        
      case ChallengeObjective.reachKardashev:
        // This is an increase amount, scales down as player progresses
        // Early game: 0.1 increase is easy
        // Late game: 0.1 increase is harder relative to total
        final baseIncrease = baseTargetValue;
        // Slightly reduce target at higher K levels to keep it achievable
        return baseIncrease * (1 - progress.kardashevLevel * 0.05).clamp(0.5, 1.0);
        
      case ChallengeObjective.playTime:
        // Fixed time targets
        return baseTargetValue;
    }
  }
  
  double _getMinEnergy(PlayerProgress progress) {
    final k = progress.kardashevLevel;
    if (k < 0.5) return 1000;
    if (k < 1.0) return 10000;
    if (k < 1.5) return 100000;
    if (k < 2.0) return 1000000;
    return 10000000;
  }
  
  String _formatTarget(double value) {
    if (objective == ChallengeObjective.reachKardashev) {
      return value.toStringAsFixed(2);
    }
    if (objective == ChallengeObjective.playTime) {
      if (value >= 60) return '${(value / 60).toStringAsFixed(1)} hours';
      return '${value.toStringAsFixed(0)} minutes';
    }
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(1)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

/// Challenge definition - generated from template with actual values
class Challenge {
  final String id;
  final String name;
  final String description;
  final ChallengeDuration duration;
  final ChallengeObjective objective;
  final double targetValue;
  final List<ChallengeReward> rewards;
  final IconData icon;
  final Color color;
  final int tier;
  final PlayerProgress? playerProgress;
  
  const Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.objective,
    required this.targetValue,
    required this.rewards,
    required this.icon,
    required this.color,
    this.tier = 1,
    this.playerProgress,
  });
  
  String get durationText {
    switch (duration) {
      case ChallengeDuration.daily:
        return 'Daily';
      case ChallengeDuration.weekly:
        return 'Weekly';
      case ChallengeDuration.event:
        return 'Event';
    }
  }
  
  String get tierText {
    switch (tier) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }
  
  Color get tierColor {
    switch (tier) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Active challenge with progress tracking
class ActiveChallenge {
  final Challenge challenge;
  final DateTime startTime;
  final DateTime endTime;
  double currentProgress;
  bool isCompleted;
  bool isClaimed;
  
  ActiveChallenge({
    required this.challenge,
    required this.startTime,
    required this.endTime,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });
  
  double get progressPercent => 
      (currentProgress / challenge.targetValue).clamp(0.0, 1.0);
  
  bool get isExpired => DateTime.now().isAfter(endTime);
  
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }
  
  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m';
    } else {
      return 'Expired';
    }
  }
  
  void updateProgress(double newProgress) {
    currentProgress = newProgress;
    if (currentProgress >= challenge.targetValue && !isCompleted) {
      isCompleted = true;
    }
  }
  
  Map<String, dynamic> toMap() {
    return {
      'challengeId': challenge.id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
    };
  }
}

// ═══════════════════════════════════════════════════════════════
// DYNAMIC CHALLENGE TEMPLATES - Scale with player progress!
// ═══════════════════════════════════════════════════════════════

/// Daily challenge templates - targets scale with player progress
const List<ChallengeTemplate> dailyChallengeTemplates = [
  // ─────────────────────────────────────────────────────────────
  // TIER 1 - EASY (achievable in ~15-30 minutes of play)
  // ─────────────────────────────────────────────────────────────
  ChallengeTemplate(
    id: 'daily_energy_easy',
    name: 'Energy Sprint',
    descriptionTemplate: 'Produce {target} energy',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.produceEnergy,
    baseTargetValue: 15,  // 15 minutes of production
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 10,  // 10 minutes of production as reward
        descriptionTemplate: '{amount} Energy',
      ),
    ],
    icon: Icons.bolt,
    color: Colors.yellow,
    tier: 1,
  ),
  
  ChallengeTemplate(
    id: 'daily_generators_easy',
    name: 'Expand the Grid',
    descriptionTemplate: 'Purchase {target} generators',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.purchaseGenerators,
    baseTargetValue: 5,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 8,
        descriptionTemplate: '{amount} Energy',
      ),
    ],
    icon: Icons.add_circle,
    color: Colors.green,
    tier: 1,
  ),
  
  ChallengeTemplate(
    id: 'daily_tap_easy',
    name: 'Finger Exercise',
    descriptionTemplate: 'Tap {target} times',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.tapCount,
    baseTargetValue: 20,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 5,
        descriptionTemplate: '{amount} Energy',
      ),
    ],
    icon: Icons.touch_app,
    color: Colors.blue,
    tier: 1,
  ),
  
  ChallengeTemplate(
    id: 'daily_playtime',
    name: 'Dedicated Player',
    descriptionTemplate: 'Play for {target}',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.playTime,
    baseTargetValue: 20,  // 20 minutes
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 8,
        descriptionTemplate: '{amount} Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 3,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.timer,
    color: Colors.cyan,
    tier: 1,
  ),

  // ─────────────────────────────────────────────────────────────
  // TIER 2 - MEDIUM (achievable in ~1-2 hours of play)
  // ─────────────────────────────────────────────────────────────
  ChallengeTemplate(
    id: 'daily_energy_med',
    name: 'Power Surge',
    descriptionTemplate: 'Produce {target} energy',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.produceEnergy,
    baseTargetValue: 60,  // 1 hour of production
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 20,
        descriptionTemplate: '{amount} Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 8,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.bolt,
    color: Colors.amber,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'daily_generators_med',
    name: 'Grid Expansion',
    descriptionTemplate: 'Purchase {target} generators',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.purchaseGenerators,
    baseTargetValue: 15,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 15,
        descriptionTemplate: '{amount} Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 5,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.add_circle_outline,
    color: Colors.teal,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'daily_tap_med',
    name: 'Tapping Champion',
    descriptionTemplate: 'Tap {target} times',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.tapCount,
    baseTargetValue: 75,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 12,
        descriptionTemplate: '{amount} Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 5,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.touch_app,
    color: Colors.indigo,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'daily_research',
    name: 'Knowledge Seeker',
    descriptionTemplate: 'Complete {target} research',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.completeResearch,
    baseTargetValue: 1,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 10,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.science,
    color: Colors.purple,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'daily_expedition',
    name: 'Mission Control',
    descriptionTemplate: 'Complete {target} expedition',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.completeExpedition,
    baseTargetValue: 1,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 12,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.explore,
    color: Colors.deepOrange,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'daily_use_ability',
    name: 'Power Activation',
    descriptionTemplate: 'Use {target} architect ability',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.useAbility,
    baseTargetValue: 2,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 1.5,
        descriptionTemplate: '1.5x Production (30m)',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.auto_awesome,
    color: Colors.amber,
    tier: 2,
  ),

  // ─────────────────────────────────────────────────────────────
  // TIER 3 - HARD (requires dedicated daily play)
  // ─────────────────────────────────────────────────────────────
  ChallengeTemplate(
    id: 'daily_energy_hard',
    name: 'Megawatt Mayhem',
    descriptionTemplate: 'Produce {target} energy',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.produceEnergy,
    baseTargetValue: 180,  // 3 hours of production
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 25,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 2.0,
        descriptionTemplate: '2x Production (30m)',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.flash_on,
    color: Colors.orange,
    tier: 3,
  ),
  
  ChallengeTemplate(
    id: 'daily_generators_hard',
    name: 'Infrastructure Overhaul',
    descriptionTemplate: 'Purchase {target} generators',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.purchaseGenerators,
    baseTargetValue: 30,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 20,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 30,
        descriptionTemplate: '{amount} Energy',
      ),
    ],
    icon: Icons.factory,
    color: Colors.brown,
    tier: 3,
  ),
];

/// Weekly challenge templates - MUCH HARDER, scales with progress
/// These require significant dedication over the week
const List<ChallengeTemplate> weeklyChallengeTemplates = [
  // ─────────────────────────────────────────────────────────────
  // TIER 2 - MEDIUM WEEKLY (achievable with regular play)
  // ─────────────────────────────────────────────────────────────
  ChallengeTemplate(
    id: 'weekly_playtime',
    name: 'Devoted Player',
    descriptionTemplate: 'Play for {target} total',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.playTime,
    baseTargetValue: 420,  // 7 hours over the week
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 40,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 60,
        descriptionTemplate: '{amount} Energy',
      ),
    ],
    icon: Icons.access_time,
    color: Colors.teal,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'weekly_abilities',
    name: 'Ability Master',
    descriptionTemplate: 'Use {target} architect abilities',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.useAbility,
    baseTargetValue: 10,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 35,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 2.0,
        descriptionTemplate: '2x Production (1h)',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.star,
    color: Colors.yellow,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'weekly_expeditions',
    name: 'Explorer',
    descriptionTemplate: 'Complete {target} expeditions',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.completeExpedition,
    baseTargetValue: 10,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 50,
        descriptionTemplate: '{amount} Dark Matter',
      ),
    ],
    icon: Icons.rocket_launch,
    color: Colors.red,
    tier: 2,
  ),
  
  ChallengeTemplate(
    id: 'weekly_taps',
    name: 'Tap Legend',
    descriptionTemplate: 'Tap {target} times',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.tapCount,
    baseTargetValue: 500,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 30,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 2.0,
        descriptionTemplate: '2x Production (30m)',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.pan_tool,
    color: Colors.blue,
    tier: 2,
  ),

  // ─────────────────────────────────────────────────────────────
  // TIER 3 - HARD WEEKLY (requires serious dedication)
  // ─────────────────────────────────────────────────────────────
  ChallengeTemplate(
    id: 'weekly_energy_massive',
    name: 'Energy Tycoon',
    descriptionTemplate: 'Produce {target} energy',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.produceEnergy,
    baseTargetValue: 1440,  // 24 HOURS of production over the week!
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 100,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 3.0,
        descriptionTemplate: '3x Production (2h)',
        scalesWithProgress: false,
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkEnergy,
        baseAmount: 5,
        descriptionTemplate: '{amount} Dark Energy',
      ),
    ],
    icon: Icons.emoji_events,
    color: Colors.amber,
    tier: 3,
  ),
  
  ChallengeTemplate(
    id: 'weekly_generators',
    name: 'Industrial Revolution',
    descriptionTemplate: 'Purchase {target} generators',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.purchaseGenerators,
    baseTargetValue: 75,  // Much harder!
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 75,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.energy,
        baseAmount: 120,
        descriptionTemplate: '{amount} Energy',
      ),
    ],
    icon: Icons.factory,
    color: Colors.brown,
    tier: 3,
  ),
  
  ChallengeTemplate(
    id: 'weekly_research_master',
    name: 'Research Master',
    descriptionTemplate: 'Complete {target} research projects',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.completeResearch,
    baseTargetValue: 5,  // Harder!
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 80,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.timeWarp,
        baseAmount: 4,
        descriptionTemplate: '4h Time Warp',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.school,
    color: Colors.deepPurple,
    tier: 3,
  ),
  
  ChallengeTemplate(
    id: 'weekly_kardashev',
    name: 'Civilization Growth',
    descriptionTemplate: 'Increase Kardashev level by {target}',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.reachKardashev,
    baseTargetValue: 0.15,  // Harder increase target
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 120,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 4.0,
        descriptionTemplate: '4x Production (1h)',
        scalesWithProgress: false,
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkEnergy,
        baseAmount: 8,
        descriptionTemplate: '{amount} Dark Energy',
      ),
    ],
    icon: Icons.trending_up,
    color: Colors.green,
    tier: 3,
  ),

  // ─────────────────────────────────────────────────────────────
  // TIER 3 - EXTREME WEEKLY (for hardcore players only!)
  // ─────────────────────────────────────────────────────────────
  ChallengeTemplate(
    id: 'weekly_energy_extreme',
    name: 'Galactic Powerhouse',
    descriptionTemplate: 'Produce {target} energy',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.produceEnergy,
    baseTargetValue: 4320,  // 72 HOURS (3 days) of production!
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        baseAmount: 200,
        descriptionTemplate: '{amount} Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 5.0,
        descriptionTemplate: '5x Production (2h)',
        scalesWithProgress: false,
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkEnergy,
        baseAmount: 15,
        descriptionTemplate: '{amount} Dark Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.timeWarp,
        baseAmount: 8,
        descriptionTemplate: '8h Time Warp',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.local_fire_department,
    color: Colors.deepOrange,
    tier: 3,
  ),
  
  ChallengeTemplate(
    id: 'weekly_prestige',
    name: 'Rebirth Master',
    descriptionTemplate: 'Perform {target} prestiges',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.prestige,
    baseTargetValue: 3,
    scalingFactor: 1.0,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkEnergy,
        baseAmount: 25,
        descriptionTemplate: '{amount} Dark Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        baseAmount: 3.0,
        descriptionTemplate: '3x Production (2h)',
        scalesWithProgress: false,
      ),
    ],
    icon: Icons.autorenew,
    color: Colors.purple,
    tier: 3,
  ),
];

// Legacy pools for backwards compatibility - will be replaced by dynamic generation
List<Challenge> dailyChallengesPool = [];
List<Challenge> weeklyChallengesPool = [];

/// Get a challenge by ID from legacy pools
Challenge? getChallengeById(String id) {
  for (final c in dailyChallengesPool) {
    if (c.id == id) return c;
  }
  for (final c in weeklyChallengesPool) {
    if (c.id == id) return c;
  }
  return null;
}

/// Generate daily challenges with dynamic scaling based on player progress
List<Challenge> generateDailyChallenges(int seed, {PlayerProgress? progress}) {
  progress ??= const PlayerProgress();
  
  // Use seed combined with day for deterministic daily selection
  final rng = Random(DateTime.now().day + seed);
  final shuffled = List<ChallengeTemplate>.from(dailyChallengeTemplates);
  shuffled.shuffle(rng);
  
  // Pick one from each tier if possible
  final easy = shuffled.where((c) => c.tier == 1).take(1);
  final medium = shuffled.where((c) => c.tier == 2).take(1);
  final hard = shuffled.where((c) => c.tier == 3).take(1);
  
  final templates = [...easy, ...medium, ...hard].take(3).toList();
  
  // Generate actual challenges with scaled values
  return templates.map((t) => t.generateChallenge(progress!)).toList();
}

/// Generate weekly challenges with dynamic scaling - MUCH HARDER!
List<Challenge> generateWeeklyChallenges(int seed, {PlayerProgress? progress}) {
  progress ??= const PlayerProgress();
  
  // Use seed combined with week number for deterministic weekly selection
  final weekNumber = DateTime.now().difference(DateTime(2024, 1, 1)).inDays ~/ 7;
  final rng = Random(weekNumber + seed);
  final shuffled = List<ChallengeTemplate>.from(weeklyChallengeTemplates);
  shuffled.shuffle(rng);
  
  // Pick a good mix - always include at least one tier 3 challenge
  final tier2 = shuffled.where((c) => c.tier == 2).take(1);
  final tier3 = shuffled.where((c) => c.tier == 3).take(2);
  
  final templates = [...tier2, ...tier3].take(3).toList();
  
  // If we don't have enough tier 3, fill with tier 2
  if (templates.length < 3) {
    final moreTier2 = shuffled.where((c) => c.tier == 2 && !templates.contains(c))
        .take(3 - templates.length);
    templates.addAll(moreTier2);
  }
  
  // Generate actual challenges with scaled values
  return templates.map((t) => t.generateChallenge(progress!)).toList();
}
