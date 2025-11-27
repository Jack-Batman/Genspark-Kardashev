import 'package:flutter/material.dart';
import 'dart:math';
import 'expedition.dart';
import '../core/constants.dart';

/// Boss encounter types for legendary expeditions
enum BossType {
  cosmicGuardian,    // Defensive boss - reduces success rate
  voidLeviathan,     // Aggressive boss - can destroy rewards
  temporalAnomaly,   // Chaos boss - randomizes outcomes
  darkMatterEntity,  // Absorb boss - steals dark matter if failed
  dimensionalRift,   // Portal boss - can transport to bonus stage
  omegaSentinel,     // Ultimate boss - combination of all effects
}

/// Boss difficulty modifiers
extension BossTypeExtension on BossType {
  String get name {
    switch (this) {
      case BossType.cosmicGuardian:
        return 'Cosmic Guardian';
      case BossType.voidLeviathan:
        return 'Void Leviathan';
      case BossType.temporalAnomaly:
        return 'Temporal Anomaly';
      case BossType.darkMatterEntity:
        return 'Dark Matter Entity';
      case BossType.dimensionalRift:
        return 'Dimensional Rift';
      case BossType.omegaSentinel:
        return 'Omega Sentinel';
    }
  }
  
  String get description {
    switch (this) {
      case BossType.cosmicGuardian:
        return 'A massive energy construct that defends against intruders.';
      case BossType.voidLeviathan:
        return 'A creature born from the void between realities.';
      case BossType.temporalAnomaly:
        return 'A tear in spacetime that defies causality.';
      case BossType.darkMatterEntity:
        return 'A sentient mass of dark matter that hungers for more.';
      case BossType.dimensionalRift:
        return 'A gateway to unknown dimensions with unpredictable effects.';
      case BossType.omegaSentinel:
        return 'The ultimate guardian of universal secrets.';
    }
  }
  
  String get emoji {
    switch (this) {
      case BossType.cosmicGuardian:
        return '🛡️';
      case BossType.voidLeviathan:
        return '🐉';
      case BossType.temporalAnomaly:
        return '⏳';
      case BossType.darkMatterEntity:
        return '🌑';
      case BossType.dimensionalRift:
        return '🌀';
      case BossType.omegaSentinel:
        return '⚔️';
    }
  }
  
  Color get color {
    switch (this) {
      case BossType.cosmicGuardian:
        return Colors.blue;
      case BossType.voidLeviathan:
        return Colors.deepPurple;
      case BossType.temporalAnomaly:
        return Colors.cyan;
      case BossType.darkMatterEntity:
        return Colors.purple;
      case BossType.dimensionalRift:
        return Colors.teal;
      case BossType.omegaSentinel:
        return Colors.amber;
    }
  }
  
  double get successPenalty {
    switch (this) {
      case BossType.cosmicGuardian:
        return 0.15; // -15% success rate
      case BossType.voidLeviathan:
        return 0.10;
      case BossType.temporalAnomaly:
        return 0.05; // Low penalty but chaotic
      case BossType.darkMatterEntity:
        return 0.12;
      case BossType.dimensionalRift:
        return 0.08;
      case BossType.omegaSentinel:
        return 0.20; // -20% success rate
    }
  }
  
  double get rewardMultiplier {
    switch (this) {
      case BossType.cosmicGuardian:
        return 1.5;
      case BossType.voidLeviathan:
        return 2.0;
      case BossType.temporalAnomaly:
        return 1.8;
      case BossType.darkMatterEntity:
        return 2.5;
      case BossType.dimensionalRift:
        return 1.7;
      case BossType.omegaSentinel:
        return 3.0;
    }
  }
}

/// A single stage in a legendary expedition
class LegendaryStage {
  final int stageNumber;
  final String name;
  final String description;
  final int durationMinutes;
  final double baseSuccessRate;
  final List<ExpeditionReward> stageRewards;
  final BossType? boss;
  final bool isBossStage;
  
  const LegendaryStage({
    required this.stageNumber,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.baseSuccessRate,
    required this.stageRewards,
    this.boss,
    this.isBossStage = false,
  });
  
  /// Get effective success rate considering boss penalties
  double get effectiveSuccessRate {
    if (boss != null) {
      return (baseSuccessRate - boss!.successPenalty).clamp(0.1, 1.0);
    }
    return baseSuccessRate;
  }
  
  /// Get reward multiplier from boss
  double get rewardMultiplier => boss?.rewardMultiplier ?? 1.0;
}

/// Legendary expedition definition
class LegendaryExpedition {
  final String id;
  final String name;
  final String description;
  final String location;
  final String lore;
  final int requiredEra; // 0=I, 1=II, 2=III, 3=IV
  final int requiredPrestigeTier;
  final List<LegendaryStage> stages;
  final List<ExpeditionReward> completionRewards;
  final int minArchitects;
  final int maxArchitects;
  final ArchitectRarity? requiredRarity;
  final String? requiredArchitectId;
  final bool isRepeatable;
  final Duration cooldownAfterCompletion;
  
  const LegendaryExpedition({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.lore,
    required this.requiredEra,
    required this.requiredPrestigeTier,
    required this.stages,
    required this.completionRewards,
    this.minArchitects = 3,
    this.maxArchitects = 3,
    this.requiredRarity,
    this.requiredArchitectId,
    this.isRepeatable = true,
    this.cooldownAfterCompletion = const Duration(hours: 24),
  });
  
  /// Total duration of all stages
  int get totalDurationMinutes => 
      stages.fold(0, (sum, stage) => sum + stage.durationMinutes);
  
  /// Get duration display string
  String get durationDisplay {
    final mins = totalDurationMinutes;
    if (mins < 60) {
      return '${mins}m';
    } else if (mins < 1440) {
      final hours = mins ~/ 60;
      final remainingMins = mins % 60;
      return remainingMins > 0 ? '${hours}h ${remainingMins}m' : '${hours}h';
    } else {
      final days = mins ~/ 1440;
      final hours = (mins % 1440) ~/ 60;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
  }
  
  /// Get total base success rate (product of all stages)
  double get overallSuccessRate {
    return stages.fold(1.0, (rate, stage) => rate * stage.effectiveSuccessRate);
  }
  
  /// Get number of boss encounters
  int get bossCount => stages.where((s) => s.boss != null).length;
  
  /// Get all unique boss types in this expedition
  List<BossType> get bosses => 
      stages.where((s) => s.boss != null).map((s) => s.boss!).toList();
}

/// Active legendary expedition state
class ActiveLegendaryExpedition {
  final String expeditionId;
  final List<String> assignedArchitectIds;
  final DateTime startTime;
  final int currentStage; // 0-indexed
  final List<bool> stageResults; // Results of completed stages
  final List<List<ExpeditionReward>> collectedRewards;
  final bool isCompleted;
  final bool isCollected;
  final bool failed; // If any stage failed
  
  const ActiveLegendaryExpedition({
    required this.expeditionId,
    required this.assignedArchitectIds,
    required this.startTime,
    this.currentStage = 0,
    this.stageResults = const [],
    this.collectedRewards = const [],
    this.isCompleted = false,
    this.isCollected = false,
    this.failed = false,
  });
  
  /// Get the legendary expedition definition
  LegendaryExpedition? get expedition => getLegendaryExpeditionById(expeditionId);
  
  /// Get current stage info
  LegendaryStage? get currentStageInfo {
    final exp = expedition;
    if (exp == null || currentStage >= exp.stages.length) return null;
    return exp.stages[currentStage];
  }
  
  /// Get end time for current stage
  DateTime get currentStageEndTime {
    final exp = expedition;
    if (exp == null) return startTime;
    
    var elapsed = 0;
    for (var i = 0; i <= currentStage && i < exp.stages.length; i++) {
      elapsed += exp.stages[i].durationMinutes;
    }
    return startTime.add(Duration(minutes: elapsed));
  }
  
  /// Get remaining time for current stage
  Duration get currentStageRemainingTime {
    final now = DateTime.now();
    final endTime = currentStageEndTime;
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }
  
  /// Get progress for current stage (0.0 - 1.0)
  double get currentStageProgress {
    final exp = expedition;
    if (exp == null) return 0.0;
    
    var stageStartTime = startTime;
    for (var i = 0; i < currentStage && i < exp.stages.length; i++) {
      stageStartTime = stageStartTime.add(
        Duration(minutes: exp.stages[i].durationMinutes)
      );
    }
    
    final now = DateTime.now();
    final stageDuration = Duration(minutes: exp.stages[currentStage].durationMinutes);
    final elapsed = now.difference(stageStartTime);
    
    return (elapsed.inSeconds / stageDuration.inSeconds).clamp(0.0, 1.0);
  }
  
  /// Get overall progress (0.0 - 1.0)
  double get overallProgress {
    final exp = expedition;
    if (exp == null) return 0.0;
    
    final totalStages = exp.stages.length;
    final completedStages = stageResults.length;
    final currentProgress = currentStageProgress;
    
    return (completedStages + currentProgress) / totalStages;
  }
  
  /// Check if current stage is ready to resolve
  bool get canResolveCurrentStage {
    final now = DateTime.now();
    return now.isAfter(currentStageEndTime) && !isCompleted && !failed;
  }
  
  /// Create copy with updated values
  ActiveLegendaryExpedition copyWith({
    String? expeditionId,
    List<String>? assignedArchitectIds,
    DateTime? startTime,
    int? currentStage,
    List<bool>? stageResults,
    List<List<ExpeditionReward>>? collectedRewards,
    bool? isCompleted,
    bool? isCollected,
    bool? failed,
  }) {
    return ActiveLegendaryExpedition(
      expeditionId: expeditionId ?? this.expeditionId,
      assignedArchitectIds: assignedArchitectIds ?? this.assignedArchitectIds,
      startTime: startTime ?? this.startTime,
      currentStage: currentStage ?? this.currentStage,
      stageResults: stageResults ?? this.stageResults,
      collectedRewards: collectedRewards ?? this.collectedRewards,
      isCompleted: isCompleted ?? this.isCompleted,
      isCollected: isCollected ?? this.isCollected,
      failed: failed ?? this.failed,
    );
  }
  
  /// Serialize to map
  Map<String, dynamic> toMap() {
    return {
      'expeditionId': expeditionId,
      'assignedArchitectIds': assignedArchitectIds,
      'startTime': startTime.millisecondsSinceEpoch,
      'currentStage': currentStage,
      'stageResults': stageResults,
      'collectedRewards': collectedRewards.map((rewards) => 
        rewards.map((r) => {
          'type': r.type.index,
          'amount': r.amount,
          'description': r.description,
        }).toList()
      ).toList(),
      'isCompleted': isCompleted,
      'isCollected': isCollected,
      'failed': failed,
    };
  }
  
  /// Deserialize from map
  factory ActiveLegendaryExpedition.fromMap(Map<String, dynamic> map) {
    return ActiveLegendaryExpedition(
      expeditionId: map['expeditionId'] as String,
      assignedArchitectIds: List<String>.from(map['assignedArchitectIds'] as List),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      currentStage: map['currentStage'] as int? ?? 0,
      stageResults: List<bool>.from(map['stageResults'] as List? ?? []),
      collectedRewards: (map['collectedRewards'] as List? ?? []).map((stageRewards) =>
        (stageRewards as List).map((r) => ExpeditionReward(
          type: ExpeditionRewardType.values[r['type'] as int],
          amount: (r['amount'] as num).toDouble(),
          description: r['description'] as String,
        )).toList()
      ).toList(),
      isCompleted: map['isCompleted'] as bool? ?? false,
      isCollected: map['isCollected'] as bool? ?? false,
      failed: map['failed'] as bool? ?? false,
    );
  }
}

/// Result of resolving a legendary stage
class LegendaryStageResult {
  final bool success;
  final int stageNumber;
  final List<ExpeditionReward> rewards;
  final double successRate;
  final String message;
  final BossType? defeatedBoss;
  final bool expeditionFailed;
  final bool expeditionCompleted;
  
  const LegendaryStageResult({
    required this.success,
    required this.stageNumber,
    required this.rewards,
    required this.successRate,
    required this.message,
    this.defeatedBoss,
    this.expeditionFailed = false,
    this.expeditionCompleted = false,
  });
}

// ═══════════════════════════════════════════════════════════════
// LEGENDARY EXPEDITION DEFINITIONS
// ═══════════════════════════════════════════════════════════════

const List<LegendaryExpedition> legendaryExpeditions = [
  // ERA I - Planetary Legendary
  LegendaryExpedition(
    id: 'leg_primordial_engine',
    name: 'The Primordial Engine',
    description: 'Venture into the planet\'s core to discover an ancient energy machine.',
    location: 'Planetary Core',
    lore: 'Legends speak of an engine built by an ancient civilization, buried deep within the planet\'s mantle. Its power could accelerate our ascension beyond measure.',
    requiredEra: 0,
    requiredPrestigeTier: 2,
    stages: [
      LegendaryStage(
        stageNumber: 1,
        name: 'Descent Preparation',
        description: 'Gather resources and prepare for the journey.',
        durationMinutes: 30,
        baseSuccessRate: 0.95,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 5000,
            description: '+5K Energy',
          ),
        ],
      ),
      LegendaryStage(
        stageNumber: 2,
        name: 'Mantle Breach',
        description: 'Drill through the planet\'s mantle to reach the core.',
        durationMinutes: 60,
        baseSuccessRate: 0.80,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 15000,
            description: '+15K Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 25,
            description: '+25 Dark Matter',
          ),
        ],
        boss: BossType.cosmicGuardian,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 3,
        name: 'Engine Activation',
        description: 'Reactivate the ancient engine and harness its power.',
        durationMinutes: 90,
        baseSuccessRate: 0.65,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 50000,
            description: '+50K Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 75,
            description: '+75 Dark Matter',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.productionBoost,
            amount: 0.5,
            description: '+50% Production (2 hours)',
          ),
        ],
        boss: BossType.temporalAnomaly,
        isBossStage: true,
      ),
    ],
    completionRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 200,
        description: '+200 Dark Matter Bonus',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 1.0,
        description: '+100% Production (4 hours)',
      ),
    ],
    minArchitects: 2,
    maxArchitects: 3,
  ),
  
  // ERA II - Stellar Legendary
  LegendaryExpedition(
    id: 'leg_stellar_leviathan',
    name: 'Hunt for the Stellar Leviathan',
    description: 'Track and confront the legendary creature that feeds on star energy.',
    location: 'Stellar Corona',
    lore: 'Ancient sensors detected a massive entity moving between stars. The Stellar Leviathan, as astronomers named it, consumes stellar radiation. Defeating it could yield unprecedented energy.',
    requiredEra: 1,
    requiredPrestigeTier: 4,
    stages: [
      LegendaryStage(
        stageNumber: 1,
        name: 'Signal Tracking',
        description: 'Track the Leviathan\'s energy signature across the system.',
        durationMinutes: 45,
        baseSuccessRate: 0.90,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 100000,
            description: '+100K Energy',
          ),
        ],
      ),
      LegendaryStage(
        stageNumber: 2,
        name: 'Approach Vector',
        description: 'Navigate the stellar winds to approach the creature.',
        durationMinutes: 90,
        baseSuccessRate: 0.75,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 500000,
            description: '+500K Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 100,
            description: '+100 Dark Matter',
          ),
        ],
        boss: BossType.cosmicGuardian,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 3,
        name: 'The Confrontation',
        description: 'Face the Stellar Leviathan in combat.',
        durationMinutes: 120,
        baseSuccessRate: 0.55,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 2000000,
            description: '+2M Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 250,
            description: '+250 Dark Matter',
          ),
        ],
        boss: BossType.voidLeviathan,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 4,
        name: 'Energy Harvest',
        description: 'Harvest the defeated Leviathan\'s stored energy.',
        durationMinutes: 60,
        baseSuccessRate: 0.85,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 5000000,
            description: '+5M Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.productionBoost,
            amount: 1.0,
            description: '+100% Production (3 hours)',
          ),
        ],
      ),
    ],
    completionRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 500,
        description: '+500 Dark Matter Bonus',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 150,
        description: '+150 Architect XP',
      ),
    ],
    requiredRarity: ArchitectRarity.epic,
  ),
  
  // ERA III - Galactic Legendary
  LegendaryExpedition(
    id: 'leg_black_hole_heart',
    name: 'Heart of the Black Hole',
    description: 'Journey beyond the event horizon to discover what lies within.',
    location: 'Singularity Core',
    lore: 'Theoretical physics suggested nothing could survive beyond the event horizon. But our Architects believe the singularity holds the key to unlimited power.',
    requiredEra: 2,
    requiredPrestigeTier: 6,
    stages: [
      LegendaryStage(
        stageNumber: 1,
        name: 'Event Horizon Approach',
        description: 'Navigate to the edge of the black hole safely.',
        durationMinutes: 60,
        baseSuccessRate: 0.85,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 10000000,
            description: '+10M Energy',
          ),
        ],
      ),
      LegendaryStage(
        stageNumber: 2,
        name: 'Horizon Breach',
        description: 'Cross the point of no return.',
        durationMinutes: 120,
        baseSuccessRate: 0.65,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 50000000,
            description: '+50M Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 300,
            description: '+300 Dark Matter',
          ),
        ],
        boss: BossType.darkMatterEntity,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 3,
        name: 'Temporal Distortion Zone',
        description: 'Navigate through warped spacetime.',
        durationMinutes: 180,
        baseSuccessRate: 0.50,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 200000000,
            description: '+200M Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 500,
            description: '+500 Dark Matter',
          ),
        ],
        boss: BossType.temporalAnomaly,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 4,
        name: 'Singularity Contact',
        description: 'Touch the singularity itself and extract its power.',
        durationMinutes: 240,
        baseSuccessRate: 0.35,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 1000000000,
            description: '+1B Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 1000,
            description: '+1000 Dark Matter',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.productionBoost,
            amount: 2.0,
            description: '+200% Production (6 hours)',
          ),
        ],
        boss: BossType.dimensionalRift,
        isBossStage: true,
      ),
    ],
    completionRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 2000,
        description: '+2000 Dark Matter Bonus',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 3.0,
        description: '+300% Production (12 hours)',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 300,
        description: '+300 Architect XP',
      ),
    ],
    requiredRarity: ArchitectRarity.legendary,
    requiredArchitectId: 'hawking',
  ),
  
  // ERA IV - Universal Legendary
  LegendaryExpedition(
    id: 'leg_omega_confrontation',
    name: 'The Omega Confrontation',
    description: 'Face the ultimate guardian of the universe\'s secrets.',
    location: 'The End of Time',
    lore: 'At the omega point where all timelines converge stands a sentinel of cosmic proportions. It guards the final secrets of existence. Only the mightiest civilizations dare approach.',
    requiredEra: 3,
    requiredPrestigeTier: 10,
    stages: [
      LegendaryStage(
        stageNumber: 1,
        name: 'Timeline Navigation',
        description: 'Navigate through the tangled web of converging timelines.',
        durationMinutes: 90,
        baseSuccessRate: 0.80,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 500000000,
            description: '+500M Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 500,
            description: '+500 Dark Matter',
          ),
        ],
      ),
      LegendaryStage(
        stageNumber: 2,
        name: 'Dimensional Gauntlet',
        description: 'Pass through multiple reality shifts.',
        durationMinutes: 150,
        baseSuccessRate: 0.60,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 5000000000,
            description: '+5B Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 1000,
            description: '+1000 Dark Matter',
          ),
        ],
        boss: BossType.dimensionalRift,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 3,
        name: 'Guardian\'s Test',
        description: 'Prove your civilization\'s worth to the cosmic guardians.',
        durationMinutes: 240,
        baseSuccessRate: 0.45,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 50000000000,
            description: '+50B Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 2500,
            description: '+2500 Dark Matter',
          ),
        ],
        boss: BossType.cosmicGuardian,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 4,
        name: 'Void Between Realities',
        description: 'Cross the emptiness that separates all existence.',
        durationMinutes: 300,
        baseSuccessRate: 0.35,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 200000000000,
            description: '+200B Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 5000,
            description: '+5000 Dark Matter',
          ),
        ],
        boss: BossType.voidLeviathan,
        isBossStage: true,
      ),
      LegendaryStage(
        stageNumber: 5,
        name: 'The Final Battle',
        description: 'Confront the Omega Sentinel in the ultimate showdown.',
        durationMinutes: 420,
        baseSuccessRate: 0.25,
        stageRewards: [
          ExpeditionReward(
            type: ExpeditionRewardType.energy,
            amount: 1000000000000,
            description: '+1T Energy',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.darkMatter,
            amount: 10000,
            description: '+10000 Dark Matter',
          ),
          ExpeditionReward(
            type: ExpeditionRewardType.productionBoost,
            amount: 5.0,
            description: '+500% Production (24 hours)',
          ),
        ],
        boss: BossType.omegaSentinel,
        isBossStage: true,
      ),
    ],
    completionRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 25000,
        description: '+25000 Dark Matter Bonus',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 10.0,
        description: '+1000% Production (48 hours)',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 1000,
        description: '+1000 Architect XP',
      ),
    ],
    requiredRarity: ArchitectRarity.legendary,
  ),
];

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

/// Get legendary expedition by ID
LegendaryExpedition? getLegendaryExpeditionById(String id) {
  try {
    return legendaryExpeditions.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
}

/// Get legendary expeditions available for an era
List<LegendaryExpedition> getLegendaryExpeditionsForEra(int eraIndex) {
  return legendaryExpeditions.where((e) => e.requiredEra <= eraIndex).toList();
}

/// Get legendary expeditions available for a prestige tier
List<LegendaryExpedition> getLegendaryExpeditionsForTier(int tier, int eraIndex) {
  return legendaryExpeditions
      .where((e) => e.requiredPrestigeTier <= tier && e.requiredEra <= eraIndex)
      .toList();
}

/// Calculate stage success based on architects and bonuses
double calculateLegendaryStageSuccess(
  LegendaryStage stage,
  List<String> architectIds,
  double baseBonus,
) {
  var successRate = stage.effectiveSuccessRate;
  
  // Add architect bonuses (simplified)
  final architectBonus = architectIds.length * 0.05; // 5% per architect
  successRate += architectBonus;
  
  // Add base bonus (from research, etc.)
  successRate += baseBonus;
  
  return successRate.clamp(0.1, 0.95); // Cap at 95%
}

/// Roll for stage success
LegendaryStageResult rollStageSuccess(
  LegendaryExpedition expedition,
  LegendaryStage stage,
  List<String> architectIds,
  double baseBonus,
) {
  final random = Random();
  final successRate = calculateLegendaryStageSuccess(stage, architectIds, baseBonus);
  final roll = random.nextDouble();
  final success = roll < successRate;
  
  List<ExpeditionReward> rewards = [];
  String message;
  
  if (success) {
    // Apply reward multiplier from boss
    rewards = stage.stageRewards.map((r) => ExpeditionReward(
      type: r.type,
      amount: r.amount * stage.rewardMultiplier,
      description: r.description,
    )).toList();
    
    if (stage.boss != null) {
      message = '${stage.boss!.emoji} ${stage.boss!.name} defeated! Stage ${stage.stageNumber} complete!';
    } else {
      message = 'Stage ${stage.stageNumber} complete!';
    }
  } else {
    // Partial rewards on failure (25% of base)
    rewards = stage.stageRewards.map((r) => ExpeditionReward(
      type: r.type,
      amount: r.amount * 0.25,
      description: '(Salvaged) ${r.description}',
    )).toList();
    
    if (stage.boss != null) {
      message = '${stage.boss!.emoji} ${stage.boss!.name} was too powerful! Expedition failed at stage ${stage.stageNumber}.';
    } else {
      message = 'Stage ${stage.stageNumber} failed. Expedition aborted.';
    }
  }
  
  final isLastStage = stage.stageNumber == expedition.stages.length;
  
  return LegendaryStageResult(
    success: success,
    stageNumber: stage.stageNumber,
    rewards: rewards,
    successRate: successRate,
    message: message,
    defeatedBoss: success ? stage.boss : null,
    expeditionFailed: !success,
    expeditionCompleted: success && isLastStage,
  );
}
