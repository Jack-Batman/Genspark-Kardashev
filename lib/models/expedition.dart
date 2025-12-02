import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Expedition difficulty levels
enum ExpeditionDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

/// Expedition reward types
enum ExpeditionRewardType {
  energy,
  darkMatter,
  researchBoost,
  productionBoost,
  architectXP,
}

/// Expedition reward data
class ExpeditionReward {
  final ExpeditionRewardType type;
  final double amount;
  final String description;
  
  const ExpeditionReward({
    required this.type,
    required this.amount,
    required this.description,
  });
  
  IconData get icon {
    switch (type) {
      case ExpeditionRewardType.energy:
        return Icons.bolt;
      case ExpeditionRewardType.darkMatter:
        return Icons.dark_mode;
      case ExpeditionRewardType.researchBoost:
        return Icons.science;
      case ExpeditionRewardType.productionBoost:
        return Icons.speed;
      case ExpeditionRewardType.architectXP:
        return Icons.star;
    }
  }
  
  Color get color {
    switch (type) {
      case ExpeditionRewardType.energy:
        return Colors.amber;
      case ExpeditionRewardType.darkMatter:
        return Colors.purple;
      case ExpeditionRewardType.researchBoost:
        return Colors.cyan;
      case ExpeditionRewardType.productionBoost:
        return Colors.green;
      case ExpeditionRewardType.architectXP:
        return Colors.orange;
    }
  }
}

/// Expedition definition
class Expedition {
  final String id;
  final String name;
  final String description;
  final String location;
  final ExpeditionDifficulty difficulty;
  final int durationMinutes;
  final List<ExpeditionReward> baseRewards;
  final List<ExpeditionReward> bonusRewards;
  final int minArchitects;
  final int maxArchitects;
  final double successRateBase; // 0.0 - 1.0
  final ArchitectRarity? preferredRarity;
  final String? preferredArchitectId;
  
  const Expedition({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.difficulty,
    required this.durationMinutes,
    required this.baseRewards,
    this.bonusRewards = const [],
    this.minArchitects = 1,
    this.maxArchitects = 3,
    this.successRateBase = 0.7,
    this.preferredRarity,
    this.preferredArchitectId,
  });
  
  Color get difficultyColor {
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
  
  String get difficultyName {
    switch (difficulty) {
      case ExpeditionDifficulty.easy:
        return 'Easy';
      case ExpeditionDifficulty.medium:
        return 'Medium';
      case ExpeditionDifficulty.hard:
        return 'Hard';
      case ExpeditionDifficulty.legendary:
        return 'Legendary';
    }
  }
  
  String get durationDisplay {
    if (durationMinutes < 60) {
      return '${durationMinutes}m';
    } else if (durationMinutes < 1440) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    } else {
      final days = durationMinutes ~/ 1440;
      final hours = (durationMinutes % 1440) ~/ 60;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
  }
}

/// Active expedition state
class ActiveExpedition {
  final String expeditionId;
  final List<String> assignedArchitectIds;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  final bool isCollected;
  
  const ActiveExpedition({
    required this.expeditionId,
    required this.assignedArchitectIds,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    this.isCollected = false,
  });
  
  /// Get remaining time
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) {
      return Duration.zero;
    }
    return endTime.difference(now);
  }
  
  /// Get progress (0.0 - 1.0)
  double get progress {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return 1.0;
    
    final totalDuration = endTime.difference(startTime);
    final elapsed = now.difference(startTime);
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }
  
  /// Check if expedition is complete
  bool get canCollect {
    return DateTime.now().isAfter(endTime) && !isCollected;
  }
  
  /// Create copy with updated values
  ActiveExpedition copyWith({
    String? expeditionId,
    List<String>? assignedArchitectIds,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    bool? isCollected,
  }) {
    return ActiveExpedition(
      expeditionId: expeditionId ?? this.expeditionId,
      assignedArchitectIds: assignedArchitectIds ?? this.assignedArchitectIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isCollected: isCollected ?? this.isCollected,
    );
  }
  
  /// Serialize to map for persistence
  Map<String, dynamic> toMap() {
    return {
      'expeditionId': expeditionId,
      'assignedArchitectIds': assignedArchitectIds,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'isCollected': isCollected,
    };
  }
  
  /// Deserialize from map
  factory ActiveExpedition.fromMap(Map<String, dynamic> map) {
    return ActiveExpedition(
      expeditionId: map['expeditionId'] as String,
      assignedArchitectIds: List<String>.from(map['assignedArchitectIds'] as List),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      isCompleted: map['isCompleted'] as bool? ?? false,
      isCollected: map['isCollected'] as bool? ?? false,
    );
  }
}

/// Expedition result after completion
class ExpeditionResult {
  final bool success;
  final List<ExpeditionReward> rewards;
  final double successRate;
  final String message;
  
  const ExpeditionResult({
    required this.success,
    required this.rewards,
    required this.successRate,
    required this.message,
  });
}

// ═══════════════════════════════════════════════════════════════
// PREDEFINED EXPEDITIONS
// ═══════════════════════════════════════════════════════════════

const List<Expedition> availableExpeditions = [
  // Easy expeditions (15-30 min)
  Expedition(
    id: 'exp_survey_local',
    name: 'Local Survey',
    description: 'Survey the surrounding area for energy sources.',
    location: 'Local Region',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 8,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 5000,
        description: '+5K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 2,
        description: '+2 Dark Matter',
      ),
    ],
    successRateBase: 0.98,
    minArchitects: 1,
    maxArchitects: 1,
  ),
  Expedition(
    id: 'exp_resource_scout',
    name: 'Resource Scouting',
    description: 'Scout for valuable resource deposits.',
    location: 'Outer Territories',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 15,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 12000,
        description: '+12K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 3,
        description: '+3 Dark Matter',
      ),
    ],
    successRateBase: 0.95,
    minArchitects: 1,
    maxArchitects: 2,
  ),
  
  // Medium expeditions (1-2 hours)
  Expedition(
    id: 'exp_ancient_ruins',
    name: 'Ancient Ruins',
    description: 'Explore mysterious ruins containing lost technology.',
    location: 'Forgotten Valley',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 35,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 35000,
        description: '+35K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 6,
        description: '+6 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.researchBoost,
        amount: 0.15,
        description: '+15% Research Speed (30 min)',
      ),
    ],
    successRateBase: 0.80,
    minArchitects: 1,
    maxArchitects: 2,
  ),
  Expedition(
    id: 'exp_energy_anomaly',
    name: 'Energy Anomaly',
    description: 'Investigate a strange energy signature detected nearby.',
    location: 'Quantum Rift',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 60,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 75000,
        description: '+75K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 8,
        description: '+8 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 0.50,
        description: '+50% Production (1 hour)',
      ),
    ],
    successRateBase: 0.75,
    minArchitects: 2,
    maxArchitects: 3,
  ),
  
  // Hard expeditions (4-8 hours)
  Expedition(
    id: 'exp_stellar_core',
    name: 'Stellar Core Sample',
    description: 'Extract energy samples from a nearby star\'s corona.',
    location: 'Solar Corona',
    difficulty: ExpeditionDifficulty.hard,
    durationMinutes: 120,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 300000,
        description: '+300K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 15,
        description: '+15 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 1.0,
        description: '+100% Production (2 hours)',
      ),
    ],
    successRateBase: 0.70,
    minArchitects: 2,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.epic,
  ),
  Expedition(
    id: 'exp_void_expedition',
    name: 'Void Expedition',
    description: 'Journey into the void between stars to harvest dark matter.',
    location: 'Interstellar Void',
    difficulty: ExpeditionDifficulty.hard,
    durationMinutes: 300,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 20,
        description: '+20 Dark Matter',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 100000,
        description: '+100K Energy',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 100,
        description: '+100 Architect XP',
      ),
    ],
    successRateBase: 0.60,
    minArchitects: 2,
    maxArchitects: 3,
  ),
  
  // Legendary expeditions (12-24 hours)
  Expedition(
    id: 'exp_galactic_nexus',
    name: 'Galactic Nexus',
    description: 'Explore the legendary nexus point where galaxies converge.',
    location: 'Galactic Convergence',
    difficulty: ExpeditionDifficulty.legendary,
    durationMinutes: 480,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 35,
        description: '+35 Dark Matter',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 1000000,
        description: '+1M Energy',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 1.5,
        description: '+150% Production (4 hours)',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 200,
        description: '+200 Architect XP',
      ),
    ],
    successRateBase: 0.50,
    minArchitects: 3,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.legendary,
  ),
  Expedition(
    id: 'exp_cosmic_forge',
    name: 'Cosmic Forge',
    description: 'Seek the mythical forge where stars are born.',
    location: 'Stellar Nursery',
    difficulty: ExpeditionDifficulty.legendary,
    durationMinutes: 960,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 50,
        description: '+50 Dark Matter',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 2500000,
        description: '+2.5M Energy',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 3.0,
        description: '+300% Production (8 hours)',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.researchBoost,
        amount: 0.75,
        description: '+75% Research Speed (4 hours)',
      ),
    ],
    successRateBase: 0.40,
    minArchitects: 3,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.legendary,
    preferredArchitectId: 'einstein',
  ),
];

// ═══════════════════════════════════════════════════════════════
// ERA II - STELLAR EXPEDITIONS
// ═══════════════════════════════════════════════════════════════

const List<Expedition> eraIIExpeditions = [
  // Easy
  Expedition(
    id: 'exp_solar_probe',
    name: 'Solar Probe Mission',
    description: 'Deploy a probe to collect data from the corona.',
    location: 'Solar Corona',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 20,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 50000,
        description: '+50K Energy',
      ),
    ],
    successRateBase: 0.95,
    minArchitects: 1,
    maxArchitects: 1,
  ),
  Expedition(
    id: 'exp_satellite_swarm',
    name: 'Satellite Swarm Deployment',
    description: 'Deploy a swarm of collector satellites.',
    location: 'Inner System',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 45,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 100000,
        description: '+100K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 4,
        description: '+4 Dark Matter',
      ),
    ],
    successRateBase: 0.90,
    minArchitects: 1,
    maxArchitects: 2,
  ),
  
  // Medium
  Expedition(
    id: 'exp_dyson_fragment',
    name: 'Dyson Fragment Assembly',
    description: 'Assemble a fragment of the Dyson Sphere.',
    location: 'Solar Orbit',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 90,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 500000,
        description: '+500K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 8,
        description: '+8 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 0.3,
        description: '+30% Production (1 hour)',
      ),
    ],
    successRateBase: 0.75,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'dyson_ii',
  ),
  Expedition(
    id: 'exp_stellar_harvest',
    name: 'Stellar Matter Harvest',
    description: 'Extract exotic matter from stellar prominences.',
    location: 'Stellar Surface',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 150,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 750000,
        description: '+750K Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 10,
        description: '+10 Dark Matter',
      ),
    ],
    successRateBase: 0.70,
    minArchitects: 2,
    maxArchitects: 3,
  ),
  
  // Hard
  Expedition(
    id: 'exp_interstellar_probe',
    name: 'Interstellar Probe Launch',
    description: 'Send a probe to the nearest star system.',
    location: 'Alpha Centauri',
    difficulty: ExpeditionDifficulty.hard,
    durationMinutes: 360,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 2000000,
        description: '+2M Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 18,
        description: '+18 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.researchBoost,
        amount: 0.25,
        description: '+25% Research Speed (2 hours)',
      ),
    ],
    successRateBase: 0.55,
    minArchitects: 2,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.epic,
  ),
  
  // Legendary
  Expedition(
    id: 'exp_sphere_activation',
    name: 'Dyson Sphere Activation',
    description: 'Activate the first complete section of the Dyson Sphere.',
    location: 'Dyson Sphere Core',
    difficulty: ExpeditionDifficulty.legendary,
    durationMinutes: 960,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 10000000,
        description: '+10M Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 40,
        description: '+40 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 1.5,
        description: '+150% Production (6 hours)',
      ),
    ],
    successRateBase: 0.35,
    minArchitects: 3,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.legendary,
    preferredArchitectId: 'kardashev',
  ),
];

// ═══════════════════════════════════════════════════════════════
// ERA III - GALACTIC EXPEDITIONS
// ═══════════════════════════════════════════════════════════════

const List<Expedition> eraIIIExpeditions = [
  // Easy
  Expedition(
    id: 'exp_black_hole_scan',
    name: 'Black Hole Survey',
    description: 'Survey a nearby stellar black hole for harvesting potential.',
    location: 'Cygnus X-1',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 30,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 1000000,
        description: '+1M Energy',
      ),
    ],
    successRateBase: 0.95,
    minArchitects: 1,
    maxArchitects: 1,
  ),
  Expedition(
    id: 'exp_neutron_probe',
    name: 'Neutron Star Probe',
    description: 'Deploy a probe to study neutron star magnetic fields.',
    location: 'Pulsar SGR-1806',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 60,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 2500000,
        description: '+2.5M Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 5,
        description: '+5 Dark Matter',
      ),
    ],
    successRateBase: 0.90,
    minArchitects: 1,
    maxArchitects: 2,
  ),
  
  // Medium
  Expedition(
    id: 'exp_penrose_extraction',
    name: 'Penrose Energy Extraction',
    description: 'Extract rotational energy from a spinning black hole.',
    location: 'Kerr Black Hole',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 180,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 25000000,
        description: '+25M Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 12,
        description: '+12 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 0.5,
        description: '+50% Production (2 hours)',
      ),
    ],
    successRateBase: 0.70,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'penrose',
  ),
  Expedition(
    id: 'exp_dark_matter_survey',
    name: 'Dark Matter Halo Survey',
    description: 'Map and harvest from the galactic dark matter halo.',
    location: 'Galactic Halo',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 240,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 15,
        description: '+15 Dark Matter',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 15000000,
        description: '+15M Energy',
      ),
    ],
    successRateBase: 0.65,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'vera_rubin',
  ),
  
  // Hard
  Expedition(
    id: 'exp_wormhole_scout',
    name: 'Wormhole Scout Mission',
    description: 'Send scouts through a traversable wormhole.',
    location: 'Einstein-Rosen Bridge',
    difficulty: ExpeditionDifficulty.hard,
    durationMinutes: 480,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 100000000,
        description: '+100M Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 22,
        description: '+22 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.researchBoost,
        amount: 0.5,
        description: '+50% Research Speed (3 hours)',
      ),
    ],
    successRateBase: 0.50,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'thorne',
    preferredRarity: ArchitectRarity.epic,
  ),
  
  // Legendary
  Expedition(
    id: 'exp_sagittarius_approach',
    name: 'Sagittarius A* Approach',
    description: 'Harvest energy from the supermassive black hole at the galactic center.',
    location: 'Sagittarius A*',
    difficulty: ExpeditionDifficulty.legendary,
    durationMinutes: 1080,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 1000000000,
        description: '+1B Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 55,
        description: '+55 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 2.0,
        description: '+200% Production (8 hours)',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 200,
        description: '+200 Architect XP',
      ),
    ],
    successRateBase: 0.30,
    minArchitects: 3,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.legendary,
    preferredArchitectId: 'hawking',
  ),
];

// ═══════════════════════════════════════════════════════════════
// ERA IV - UNIVERSAL EXPEDITIONS
// ═══════════════════════════════════════════════════════════════

const List<Expedition> eraIVExpeditions = [
  // Easy
  Expedition(
    id: 'exp_void_sample',
    name: 'Void Energy Sample',
    description: 'Extract energy from the quantum vacuum.',
    location: 'Quantum Vacuum',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 45,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 100000000,
        description: '+100M Energy',
      ),
    ],
    successRateBase: 0.95,
    minArchitects: 1,
    maxArchitects: 1,
  ),
  Expedition(
    id: 'exp_timeline_scan',
    name: 'Timeline Survey',
    description: 'Scan adjacent timelines for harvestable energy.',
    location: 'Temporal Nexus',
    difficulty: ExpeditionDifficulty.easy,
    durationMinutes: 75,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 250000000,
        description: '+250M Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 6,
        description: '+6 Dark Matter',
      ),
    ],
    successRateBase: 0.90,
    minArchitects: 1,
    maxArchitects: 2,
  ),
  
  // Medium
  Expedition(
    id: 'exp_entropy_reversal',
    name: 'Entropy Reversal Field',
    description: 'Create a localized entropy reversal zone.',
    location: 'Entropy Boundary',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 200,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 2500000000,
        description: '+2.5B Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 15,
        description: '+15 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 1.0,
        description: '+100% Production (3 hours)',
      ),
    ],
    successRateBase: 0.65,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'entropy_keeper',
  ),
  Expedition(
    id: 'exp_dimensional_rift',
    name: 'Dimensional Rift Exploration',
    description: 'Explore a rift between dimensions for exotic energy.',
    location: 'Interdimensional Space',
    difficulty: ExpeditionDifficulty.medium,
    durationMinutes: 300,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 5000000000,
        description: '+5B Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 18,
        description: '+18 Dark Matter',
      ),
    ],
    successRateBase: 0.60,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'void_walker',
  ),
  
  // Hard
  Expedition(
    id: 'exp_reality_fragment',
    name: 'Reality Fragment Collection',
    description: 'Collect fragments of collapsing pocket realities.',
    location: 'Multiverse Edge',
    difficulty: ExpeditionDifficulty.hard,
    durationMinutes: 600,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 50000000000,
        description: '+50B Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 28,
        description: '+28 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 2.0,
        description: '+200% Production (4 hours)',
      ),
    ],
    successRateBase: 0.45,
    minArchitects: 2,
    maxArchitects: 3,
    preferredArchitectId: 'multiverse_scout',
    preferredRarity: ArchitectRarity.epic,
  ),
  
  // Legendary
  Expedition(
    id: 'exp_omega_point',
    name: 'Omega Point Access',
    description: 'Tap into the energy of the universe\'s ultimate convergence.',
    location: 'The Omega Point',
    difficulty: ExpeditionDifficulty.legendary,
    durationMinutes: 1440,
    baseRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.energy,
        amount: 1000000000000,
        description: '+1T Energy',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.darkMatter,
        amount: 65,
        description: '+65 Dark Matter',
      ),
    ],
    bonusRewards: [
      ExpeditionReward(
        type: ExpeditionRewardType.productionBoost,
        amount: 5.0,
        description: '+500% Production (12 hours)',
      ),
      ExpeditionReward(
        type: ExpeditionRewardType.architectXP,
        amount: 500,
        description: '+500 Architect XP',
      ),
    ],
    successRateBase: 0.25,
    minArchitects: 3,
    maxArchitects: 3,
    preferredRarity: ArchitectRarity.legendary,
    preferredArchitectId: 'omega',
  ),
];

/// All expeditions across all eras (Era I is the base availableExpeditions)
List<Expedition> get allExpeditions => [
  ...availableExpeditions, // Era I
  ...eraIIExpeditions,
  ...eraIIIExpeditions,
  ...eraIVExpeditions,
];

/// Get expeditions for a specific era (I, II, III, IV)
List<Expedition> getExpeditionsForEra(String era) {
  switch (era) {
    case 'I':
      return availableExpeditions;
    case 'II':
      return eraIIExpeditions;
    case 'III':
      return eraIIIExpeditions;
    case 'IV':
      return eraIVExpeditions;
    default:
      return availableExpeditions;
  }
}

/// Get expedition by ID (searches all eras)
Expedition? getExpeditionById(String id) {
  try {
    return allExpeditions.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
}

/// Get expeditions by difficulty (from all eras)
List<Expedition> getExpeditionsByDifficulty(ExpeditionDifficulty difficulty) {
  return allExpeditions.where((e) => e.difficulty == difficulty).toList();
}
