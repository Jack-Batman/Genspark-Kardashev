/// Daily Login Reward Configuration
class DailyReward {
  final int day;
  final double energyReward;
  final double darkMatterReward;
  final String description;
  final bool isBonus; // Every 7th day is a bonus

  const DailyReward({
    required this.day,
    this.energyReward = 0,
    this.darkMatterReward = 0,
    required this.description,
    this.isBonus = false,
  });
}

/// 7-day reward cycle (repeats)
const List<DailyReward> dailyRewardCycle = [
  DailyReward(
    day: 1,
    energyReward: 100,
    description: 'Welcome back!',
  ),
  DailyReward(
    day: 2,
    energyReward: 200,
    description: 'Day 2 streak!',
  ),
  DailyReward(
    day: 3,
    energyReward: 500,
    darkMatterReward: 5,
    description: 'Keep it up!',
  ),
  DailyReward(
    day: 4,
    energyReward: 1000,
    description: 'Halfway there!',
  ),
  DailyReward(
    day: 5,
    energyReward: 2000,
    darkMatterReward: 10,
    description: 'Almost there!',
  ),
  DailyReward(
    day: 6,
    energyReward: 5000,
    description: 'One more day!',
  ),
  DailyReward(
    day: 7,
    energyReward: 10000,
    darkMatterReward: 25,
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
double getStreakMultiplier(int totalLoginDays) {
  // Every 30 days gives +10% bonus, up to 100%
  final bonusPercent = (totalLoginDays ~/ 30) * 10;
  return 1.0 + (bonusPercent.clamp(0, 100) / 100);
}
