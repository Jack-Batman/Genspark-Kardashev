import 'dart:math';

/// Daily Login Reward Configuration - Now scales with player progress!
class DailyReward {
  final int day;
  final double energyRewardBase;     // Base value, multiplied by player progress
  final double darkMatterRewardBase; // Base value, multiplied by player progress
  final double darkEnergyRewardBase; // Premium currency reward
  final String description;
  final bool isBonus; // Every 7th day is a bonus

  const DailyReward({
    required this.day,
    this.energyRewardBase = 0,
    this.darkMatterRewardBase = 0,
    this.darkEnergyRewardBase = 0,
    required this.description,
    this.isBonus = false,
  });
  
  /// Calculate actual energy reward based on player's production rate
  /// Rewards scale to be ~10-30 minutes of production
  double getEnergyReward(double energyPerSecond, double kardashevLevel) {
    if (energyRewardBase == 0) return 0;
    
    // Base: Give player 10-30 minutes worth of production
    final minutesWorth = energyRewardBase; // Base value represents minutes of production
    final productionReward = energyPerSecond * 60 * minutesWorth;
    
    // Minimum reward based on Kardashev level
    final minReward = _getMinEnergyByKardashev(kardashevLevel);
    
    return max(productionReward, minReward);
  }
  
  /// Calculate actual Dark Matter reward based on player's era
  double getDarkMatterReward(int currentEra, double kardashevLevel) {
    if (darkMatterRewardBase == 0) return 0;
    
    // Scale with era (1x Era I, 2x Era II, 4x Era III, 8x Era IV)
    final eraMultiplier = pow(2, currentEra).toDouble();
    
    // Additional scaling based on Kardashev level within era
    final progressMultiplier = 1.0 + (kardashevLevel % 1.0);
    
    return (darkMatterRewardBase * eraMultiplier * progressMultiplier).roundToDouble();
  }
  
  /// Calculate Dark Energy reward (premium currency)
  double getDarkEnergyReward(int prestigeCount) {
    if (darkEnergyRewardBase == 0) return 0;
    
    // Scales slightly with prestige count
    final prestigeMultiplier = 1.0 + (prestigeCount * 0.1);
    return (darkEnergyRewardBase * prestigeMultiplier).roundToDouble();
  }
  
  /// Get minimum energy reward by Kardashev level
  static double _getMinEnergyByKardashev(double kardashevLevel) {
    if (kardashevLevel < 0.5) return 100;
    if (kardashevLevel < 1.0) return 1000;
    if (kardashevLevel < 1.5) return 10000;
    if (kardashevLevel < 2.0) return 100000;
    if (kardashevLevel < 2.5) return 1000000;
    if (kardashevLevel < 3.0) return 10000000;
    if (kardashevLevel < 3.5) return 100000000;
    return 1000000000;
  }
}

/// 7-day reward cycle (repeats) - Values now represent scaling factors
/// Energy: minutes of production to reward
/// Dark Matter: base amount before era scaling
/// Dark Energy: base amount before prestige scaling
const List<DailyReward> dailyRewardCycle = [
  DailyReward(
    day: 1,
    energyRewardBase: 5,      // 5 minutes of production
    description: 'Welcome back!',
  ),
  DailyReward(
    day: 2,
    energyRewardBase: 10,     // 10 minutes of production
    description: 'Day 2 streak!',
  ),
  DailyReward(
    day: 3,
    energyRewardBase: 15,     // 15 minutes of production
    darkMatterRewardBase: 5,  // Scales with era
    description: 'Keep it up!',
  ),
  DailyReward(
    day: 4,
    energyRewardBase: 20,     // 20 minutes of production
    darkMatterRewardBase: 3,
    description: 'Halfway there!',
  ),
  DailyReward(
    day: 5,
    energyRewardBase: 25,     // 25 minutes of production
    darkMatterRewardBase: 10,
    darkEnergyRewardBase: 1,  // Small Dark Energy bonus
    description: 'Almost there!',
  ),
  DailyReward(
    day: 6,
    energyRewardBase: 30,     // 30 minutes of production
    darkMatterRewardBase: 8,
    description: 'One more day!',
  ),
  DailyReward(
    day: 7,
    energyRewardBase: 60,     // 1 HOUR of production!
    darkMatterRewardBase: 25,
    darkEnergyRewardBase: 3,  // Nice Dark Energy bonus
    description: 'WEEKLY BONUS!',
    isBonus: true,
  ),
];

/// Get reward for a specific streak day
DailyReward getRewardForDay(int streakDay) {
  // Cycle repeats every 7 days
  final cycleDay = ((streakDay - 1) % 7) + 1;
  return dailyRewardCycle[cycleDay - 1];
}

/// Calculate streak multiplier based on total login days
/// Now more impactful for long-term players
double getStreakMultiplier(int totalLoginDays) {
  // Base multiplier from login days
  // Every 7 days gives +5% bonus
  // Every 30 days gives additional +10% bonus
  // Max 300% (3x)
  
  final weeklyBonus = (totalLoginDays ~/ 7) * 5;
  final monthlyBonus = (totalLoginDays ~/ 30) * 10;
  final totalBonus = (weeklyBonus + monthlyBonus).clamp(0, 200);
  
  return 1.0 + (totalBonus / 100);
}

/// Get era name for display
String getEraName(int era) {
  switch (era) {
    case 0: return 'Planetary';
    case 1: return 'Stellar';
    case 2: return 'Galactic';
    case 3: return 'Universal';
    default: return 'Cosmic';
  }
}
