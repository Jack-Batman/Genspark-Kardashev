import 'package:flutter/material.dart';

/// Achievement categories
enum AchievementCategory {
  production,
  generators,
  research,
  progression,
  prestige,
  special,
}

/// Achievement rarity for visual distinction
enum AchievementRarity {
  bronze,
  silver,
  gold,
  diamond,
}

/// Achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final double energyReward;
  final double darkMatterReward;
  final AchievementCondition condition;
  
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    this.energyReward = 0,
    this.darkMatterReward = 0,
    required this.condition,
  });
  
  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:
        return const Color(0xFFFFD700);
      case AchievementRarity.diamond:
        return const Color(0xFF00FFFF);
    }
  }
  
  String get rarityName {
    switch (rarity) {
      case AchievementRarity.bronze:
        return 'Bronze';
      case AchievementRarity.silver:
        return 'Silver';
      case AchievementRarity.gold:
        return 'Gold';
      case AchievementRarity.diamond:
        return 'Diamond';
    }
  }
  
  Color get categoryColor {
    switch (category) {
      case AchievementCategory.production:
        return const Color(0xFF4FC3F7);
      case AchievementCategory.generators:
        return const Color(0xFF81C784);
      case AchievementCategory.research:
        return const Color(0xFFBA68C8);
      case AchievementCategory.progression:
        return const Color(0xFFFFB74D);
      case AchievementCategory.prestige:
        return const Color(0xFFFF6B9D);
      case AchievementCategory.special:
        return const Color(0xFFFFD700);
    }
  }
}

/// Achievement condition types
enum ConditionType {
  totalEnergy,
  energyPerSecond,
  totalGenerators,
  specificGenerator,
  kardashevLevel,
  totalTaps,
  researchCompleted,
  prestigeCount,
  darkMatter,
  playTime,
  eraUnlocked,
  architectOwned,
}

/// Achievement condition
class AchievementCondition {
  final ConditionType type;
  final double targetValue;
  final String? targetId; // For specific generator/research
  
  const AchievementCondition({
    required this.type,
    required this.targetValue,
    this.targetId,
  });
}

/// All achievements in the game
const List<Achievement> allAchievements = [
  // ═══════════════════════════════════════════════════════════════
  // PRODUCTION ACHIEVEMENTS (spaced out - no immediate triggers)
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'prod_1', name: 'First Spark', description: 'Earn 10,000 total energy',
    icon: '⚡', category: AchievementCategory.production, rarity: AchievementRarity.bronze,
    energyReward: 500, condition: AchievementCondition(type: ConditionType.totalEnergy, targetValue: 10000),
  ),
  Achievement(
    id: 'prod_2', name: 'Power Up', description: 'Earn 100,000 total energy',
    icon: '⚡', category: AchievementCategory.production, rarity: AchievementRarity.bronze,
    energyReward: 2500, condition: AchievementCondition(type: ConditionType.totalEnergy, targetValue: 100000),
  ),
  Achievement(
    id: 'prod_3', name: 'Megawatt', description: 'Earn 1 million total energy',
    icon: '🔋', category: AchievementCategory.production, rarity: AchievementRarity.silver,
    energyReward: 10000, darkMatterReward: 5, condition: AchievementCondition(type: ConditionType.totalEnergy, targetValue: 1000000),
  ),
  Achievement(
    id: 'prod_4', name: 'Gigawatt', description: 'Earn 1 billion total energy',
    icon: '🔋', category: AchievementCategory.production, rarity: AchievementRarity.gold,
    darkMatterReward: 25, condition: AchievementCondition(type: ConditionType.totalEnergy, targetValue: 1e9),
  ),
  Achievement(
    id: 'prod_5', name: 'Terawatt', description: 'Earn 1 trillion total energy',
    icon: '💎', category: AchievementCategory.production, rarity: AchievementRarity.gold,
    darkMatterReward: 100, condition: AchievementCondition(type: ConditionType.totalEnergy, targetValue: 1e12),
  ),
  Achievement(
    id: 'prod_6', name: 'Petawatt', description: 'Earn 1 quadrillion total energy',
    icon: '💎', category: AchievementCategory.production, rarity: AchievementRarity.diamond,
    darkMatterReward: 500, condition: AchievementCondition(type: ConditionType.totalEnergy, targetValue: 1e15),
  ),
  
  // Production per second (higher thresholds)
  Achievement(
    id: 'eps_1', name: 'Trickle', description: 'Reach 50 energy per second',
    icon: '💧', category: AchievementCategory.production, rarity: AchievementRarity.bronze,
    energyReward: 250, condition: AchievementCondition(type: ConditionType.energyPerSecond, targetValue: 50),
  ),
  Achievement(
    id: 'eps_2', name: 'Stream', description: 'Reach 500 energy per second',
    icon: '🌊', category: AchievementCategory.production, rarity: AchievementRarity.bronze,
    energyReward: 1000, condition: AchievementCondition(type: ConditionType.energyPerSecond, targetValue: 500),
  ),
  Achievement(
    id: 'eps_3', name: 'River', description: 'Reach 5,000 energy per second',
    icon: '🌊', category: AchievementCategory.production, rarity: AchievementRarity.silver,
    energyReward: 5000, darkMatterReward: 10, condition: AchievementCondition(type: ConditionType.energyPerSecond, targetValue: 5000),
  ),
  Achievement(
    id: 'eps_4', name: 'Torrent', description: 'Reach 100,000 energy per second',
    icon: '🌀', category: AchievementCategory.production, rarity: AchievementRarity.gold,
    darkMatterReward: 50, condition: AchievementCondition(type: ConditionType.energyPerSecond, targetValue: 100000),
  ),
  Achievement(
    id: 'eps_5', name: 'Tsunami', description: 'Reach 10 million energy per second',
    icon: '🌀', category: AchievementCategory.production, rarity: AchievementRarity.diamond,
    darkMatterReward: 250, condition: AchievementCondition(type: ConditionType.energyPerSecond, targetValue: 1e7),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // GENERATOR ACHIEVEMENTS (higher thresholds, removed trivial ones)
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'gen_1', name: 'Small Grid', description: 'Own 15 total generators',
    icon: '🔧', category: AchievementCategory.generators, rarity: AchievementRarity.bronze,
    energyReward: 500, condition: AchievementCondition(type: ConditionType.totalGenerators, targetValue: 15),
  ),
  Achievement(
    id: 'gen_2', name: 'Growing Network', description: 'Own 35 total generators',
    icon: '🏭', category: AchievementCategory.generators, rarity: AchievementRarity.bronze,
    energyReward: 1500, condition: AchievementCondition(type: ConditionType.totalGenerators, targetValue: 35),
  ),
  Achievement(
    id: 'gen_3', name: 'Power Plant', description: 'Own 75 total generators',
    icon: '🏭', category: AchievementCategory.generators, rarity: AchievementRarity.silver,
    energyReward: 5000, darkMatterReward: 10, condition: AchievementCondition(type: ConditionType.totalGenerators, targetValue: 75),
  ),
  Achievement(
    id: 'gen_4', name: 'Energy Empire', description: 'Own 150 total generators',
    icon: '🌐', category: AchievementCategory.generators, rarity: AchievementRarity.gold,
    darkMatterReward: 50, condition: AchievementCondition(type: ConditionType.totalGenerators, targetValue: 150),
  ),
  Achievement(
    id: 'gen_5', name: 'Mega Corporation', description: 'Own 300 total generators',
    icon: '🌐', category: AchievementCategory.generators, rarity: AchievementRarity.gold,
    darkMatterReward: 150, condition: AchievementCondition(type: ConditionType.totalGenerators, targetValue: 300),
  ),
  Achievement(
    id: 'gen_6', name: 'Galactic Conglomerate', description: 'Own 500 total generators',
    icon: '🌌', category: AchievementCategory.generators, rarity: AchievementRarity.diamond,
    darkMatterReward: 500, condition: AchievementCondition(type: ConditionType.totalGenerators, targetValue: 500),
  ),
  
  // Specific generators (higher thresholds)
  Achievement(
    id: 'gen_wind_10', name: 'Wind Farmer', description: 'Own 25 Wind Turbines',
    icon: '🌀', category: AchievementCategory.generators, rarity: AchievementRarity.bronze,
    energyReward: 500, condition: AchievementCondition(type: ConditionType.specificGenerator, targetValue: 25, targetId: 'wind_turbine'),
  ),
  Achievement(
    id: 'gen_solar_10', name: 'Solar Pioneer', description: 'Own 15 Solar Arrays',
    icon: '☀️', category: AchievementCategory.generators, rarity: AchievementRarity.bronze,
    energyReward: 2000, condition: AchievementCondition(type: ConditionType.specificGenerator, targetValue: 15, targetId: 'solar_panel'),
  ),
  Achievement(
    id: 'gen_fusion_5', name: 'Fusion Master', description: 'Own 10 Fusion Cores',
    icon: '🔥', category: AchievementCategory.generators, rarity: AchievementRarity.silver,
    energyReward: 25000, darkMatterReward: 15, condition: AchievementCondition(type: ConditionType.specificGenerator, targetValue: 10, targetId: 'fusion_reactor'),
  ),
  Achievement(
    id: 'gen_orbital_1', name: 'Space Age', description: 'Own 3 Orbital Collectors',
    icon: '🛰️', category: AchievementCategory.generators, rarity: AchievementRarity.silver,
    darkMatterReward: 20, condition: AchievementCondition(type: ConditionType.specificGenerator, targetValue: 3, targetId: 'orbital_array'),
  ),
  Achievement(
    id: 'gen_planetary_1', name: 'World Power', description: 'Own 2 Planetary Grids',
    icon: '🌐', category: AchievementCategory.generators, rarity: AchievementRarity.gold,
    darkMatterReward: 50, condition: AchievementCondition(type: ConditionType.specificGenerator, targetValue: 2, targetId: 'planetary_grid'),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // PROGRESSION ACHIEVEMENTS (Kardashev Level - spaced out more)
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'kard_03', name: 'Rising Power', description: 'Reach Kardashev 0.3',
    icon: '📈', category: AchievementCategory.progression, rarity: AchievementRarity.bronze,
    energyReward: 1000, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 0.3),
  ),
  Achievement(
    id: 'kard_05', name: 'Halfway There', description: 'Reach Kardashev 0.5',
    icon: '🎯', category: AchievementCategory.progression, rarity: AchievementRarity.silver,
    darkMatterReward: 15, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 0.5),
  ),
  Achievement(
    id: 'kard_07', name: 'Almost There', description: 'Reach Kardashev 0.7',
    icon: '🎯', category: AchievementCategory.progression, rarity: AchievementRarity.silver,
    darkMatterReward: 25, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 0.7),
  ),
  Achievement(
    id: 'kard_10', name: 'Type I Civilization', description: 'Reach Kardashev 1.0',
    icon: '🌍', category: AchievementCategory.progression, rarity: AchievementRarity.gold,
    darkMatterReward: 100, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 1.0),
  ),
  Achievement(
    id: 'kard_15', name: 'Stellar Pioneer', description: 'Reach Kardashev 1.5',
    icon: '☀️', category: AchievementCategory.progression, rarity: AchievementRarity.gold,
    darkMatterReward: 250, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 1.5),
  ),
  Achievement(
    id: 'kard_20', name: 'Type II Civilization', description: 'Reach Kardashev 2.0',
    icon: '⭐', category: AchievementCategory.progression, rarity: AchievementRarity.diamond,
    darkMatterReward: 1000, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 2.0),
  ),
  Achievement(
    id: 'kard_30', name: 'Type III Civilization', description: 'Reach Kardashev 3.0',
    icon: '🌌', category: AchievementCategory.progression, rarity: AchievementRarity.diamond,
    darkMatterReward: 10000, condition: AchievementCondition(type: ConditionType.kardashevLevel, targetValue: 3.0),
  ),
  
  // Era unlocks
  Achievement(
    id: 'era_2', name: 'Stellar Dawn', description: 'Unlock the Stellar Era',
    icon: '☀️', category: AchievementCategory.progression, rarity: AchievementRarity.gold,
    darkMatterReward: 150, condition: AchievementCondition(type: ConditionType.eraUnlocked, targetValue: 1),
  ),
  Achievement(
    id: 'era_3', name: 'Galactic Awakening', description: 'Unlock the Galactic Era',
    icon: '🌌', category: AchievementCategory.progression, rarity: AchievementRarity.diamond,
    darkMatterReward: 1500, condition: AchievementCondition(type: ConditionType.eraUnlocked, targetValue: 2),
  ),
  Achievement(
    id: 'era_4', name: 'Universal Consciousness', description: 'Unlock the Universal Era',
    icon: '✨', category: AchievementCategory.progression, rarity: AchievementRarity.diamond,
    darkMatterReward: 15000, condition: AchievementCondition(type: ConditionType.eraUnlocked, targetValue: 3),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // TAP ACHIEVEMENTS (higher thresholds - no immediate triggers)
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'tap_100', name: 'First Clicks', description: 'Tap 100 times',
    icon: '👆', category: AchievementCategory.special, rarity: AchievementRarity.bronze,
    energyReward: 100, condition: AchievementCondition(type: ConditionType.totalTaps, targetValue: 100),
  ),
  Achievement(
    id: 'tap_500', name: 'Tapper', description: 'Tap 500 times',
    icon: '👆', category: AchievementCategory.special, rarity: AchievementRarity.bronze,
    energyReward: 500, condition: AchievementCondition(type: ConditionType.totalTaps, targetValue: 500),
  ),
  Achievement(
    id: 'tap_2000', name: 'Click Master', description: 'Tap 2,000 times',
    icon: '🖱️', category: AchievementCategory.special, rarity: AchievementRarity.silver,
    energyReward: 2000, darkMatterReward: 5, condition: AchievementCondition(type: ConditionType.totalTaps, targetValue: 2000),
  ),
  Achievement(
    id: 'tap_10000', name: 'Finger Athlete', description: 'Tap 10,000 times',
    icon: '💪', category: AchievementCategory.special, rarity: AchievementRarity.gold,
    darkMatterReward: 50, condition: AchievementCondition(type: ConditionType.totalTaps, targetValue: 10000),
  ),
  Achievement(
    id: 'tap_100000', name: 'Tap Legend', description: 'Tap 100,000 times',
    icon: '🏆', category: AchievementCategory.special, rarity: AchievementRarity.diamond,
    darkMatterReward: 500, condition: AchievementCondition(type: ConditionType.totalTaps, targetValue: 100000),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // RESEARCH ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'research_1', name: 'Curious Mind', description: 'Complete 1 research',
    icon: '🔬', category: AchievementCategory.research, rarity: AchievementRarity.bronze,
    energyReward: 500, condition: AchievementCondition(type: ConditionType.researchCompleted, targetValue: 1),
  ),
  Achievement(
    id: 'research_5', name: 'Researcher', description: 'Complete 5 researches',
    icon: '🔬', category: AchievementCategory.research, rarity: AchievementRarity.bronze,
    energyReward: 2500, condition: AchievementCondition(type: ConditionType.researchCompleted, targetValue: 5),
  ),
  Achievement(
    id: 'research_10', name: 'Scientist', description: 'Complete 10 researches',
    icon: '🧪', category: AchievementCategory.research, rarity: AchievementRarity.silver,
    darkMatterReward: 25, condition: AchievementCondition(type: ConditionType.researchCompleted, targetValue: 10),
  ),
  Achievement(
    id: 'research_25', name: 'Lead Researcher', description: 'Complete 25 researches',
    icon: '🧪', category: AchievementCategory.research, rarity: AchievementRarity.gold,
    darkMatterReward: 100, condition: AchievementCondition(type: ConditionType.researchCompleted, targetValue: 25),
  ),
  Achievement(
    id: 'research_50', name: 'Research Director', description: 'Complete 50 researches',
    icon: '🎓', category: AchievementCategory.research, rarity: AchievementRarity.diamond,
    darkMatterReward: 500, condition: AchievementCondition(type: ConditionType.researchCompleted, targetValue: 50),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // PRESTIGE ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'prestige_1', name: 'New Beginning', description: 'Prestige 1 time',
    icon: '🔄', category: AchievementCategory.prestige, rarity: AchievementRarity.silver,
    darkMatterReward: 50, condition: AchievementCondition(type: ConditionType.prestigeCount, targetValue: 1),
  ),
  Achievement(
    id: 'prestige_5', name: 'Seasoned', description: 'Prestige 5 times',
    icon: '🔄', category: AchievementCategory.prestige, rarity: AchievementRarity.gold,
    darkMatterReward: 250, condition: AchievementCondition(type: ConditionType.prestigeCount, targetValue: 5),
  ),
  Achievement(
    id: 'prestige_10', name: 'Veteran', description: 'Prestige 10 times',
    icon: '⭐', category: AchievementCategory.prestige, rarity: AchievementRarity.gold,
    darkMatterReward: 1000, condition: AchievementCondition(type: ConditionType.prestigeCount, targetValue: 10),
  ),
  Achievement(
    id: 'prestige_25', name: 'Eternal', description: 'Prestige 25 times',
    icon: '♾️', category: AchievementCategory.prestige, rarity: AchievementRarity.diamond,
    darkMatterReward: 5000, condition: AchievementCondition(type: ConditionType.prestigeCount, targetValue: 25),
  ),
  
  // Dark Matter
  Achievement(
    id: 'dm_100', name: 'Dark Collector', description: 'Accumulate 100 Dark Matter',
    icon: '🌑', category: AchievementCategory.prestige, rarity: AchievementRarity.silver,
    darkMatterReward: 25, condition: AchievementCondition(type: ConditionType.darkMatter, targetValue: 100),
  ),
  Achievement(
    id: 'dm_1000', name: 'Dark Hoarder', description: 'Accumulate 1,000 Dark Matter',
    icon: '🌑', category: AchievementCategory.prestige, rarity: AchievementRarity.gold,
    darkMatterReward: 250, condition: AchievementCondition(type: ConditionType.darkMatter, targetValue: 1000),
  ),
  Achievement(
    id: 'dm_10000', name: 'Dark Lord', description: 'Accumulate 10,000 Dark Matter',
    icon: '🕳️', category: AchievementCategory.prestige, rarity: AchievementRarity.diamond,
    darkMatterReward: 2500, condition: AchievementCondition(type: ConditionType.darkMatter, targetValue: 10000),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // SPECIAL ACHIEVEMENTS
  // ═══════════════════════════════════════════════════════════════
  Achievement(
    id: 'playtime_1h', name: 'Dedicated', description: 'Play for 1 hour',
    icon: '⏰', category: AchievementCategory.special, rarity: AchievementRarity.bronze,
    energyReward: 500, condition: AchievementCondition(type: ConditionType.playTime, targetValue: 3600),
  ),
  Achievement(
    id: 'playtime_10h', name: 'Committed', description: 'Play for 10 hours',
    icon: '⏰', category: AchievementCategory.special, rarity: AchievementRarity.silver,
    darkMatterReward: 50, condition: AchievementCondition(type: ConditionType.playTime, targetValue: 36000),
  ),
  Achievement(
    id: 'playtime_100h', name: 'Devoted', description: 'Play for 100 hours',
    icon: '🕐', category: AchievementCategory.special, rarity: AchievementRarity.gold,
    darkMatterReward: 500, condition: AchievementCondition(type: ConditionType.playTime, targetValue: 360000),
  ),
  
  // Architect
  Achievement(
    id: 'architect_1', name: 'First Recruit', description: 'Own 1 Architect',
    icon: '👤', category: AchievementCategory.special, rarity: AchievementRarity.silver,
    darkMatterReward: 25, condition: AchievementCondition(type: ConditionType.architectOwned, targetValue: 1),
  ),
  Achievement(
    id: 'architect_5', name: 'Dream Team', description: 'Own 5 Architects',
    icon: '👥', category: AchievementCategory.special, rarity: AchievementRarity.gold,
    darkMatterReward: 150, condition: AchievementCondition(type: ConditionType.architectOwned, targetValue: 5),
  ),
  Achievement(
    id: 'architect_all', name: 'Full Roster', description: 'Own all Era I Architects',
    icon: '🏆', category: AchievementCategory.special, rarity: AchievementRarity.diamond,
    darkMatterReward: 500, condition: AchievementCondition(type: ConditionType.architectOwned, targetValue: 8),
  ),
];

/// Get achievement by ID
Achievement? getAchievementById(String id) {
  try {
    return allAchievements.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}

/// Get achievements by category
List<Achievement> getAchievementsByCategory(AchievementCategory category) {
  return allAchievements.where((a) => a.category == category).toList();
}
