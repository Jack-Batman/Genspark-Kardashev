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
}

/// Challenge reward types
enum ChallengeRewardType {
  energy,
  darkMatter,
  productionBoost,
  timeWarp,
}

/// Individual challenge reward
class ChallengeReward {
  final ChallengeRewardType type;
  final double amount;
  final String description;
  
  const ChallengeReward({
    required this.type,
    required this.amount,
    required this.description,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'amount': amount,
      'description': description,
    };
  }
  
  factory ChallengeReward.fromMap(Map<String, dynamic> map) {
    return ChallengeReward(
      type: ChallengeRewardType.values[map['type'] as int],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
    );
  }
}

/// Challenge definition
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
  final int tier; // 1 = easy, 2 = medium, 3 = hard
  
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
// PREDEFINED CHALLENGES
// ═══════════════════════════════════════════════════════════════

/// Daily challenges pool - 3 random ones are picked each day
const List<Challenge> dailyChallengesPool = [
  // Energy production challenges
  Challenge(
    id: 'daily_produce_energy_easy',
    name: 'Energy Sprint',
    description: 'Produce 2,500 energy',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.produceEnergy,
    targetValue: 2500,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 7500,
        description: '7,500 Energy',
      ),
    ],
    icon: Icons.bolt,
    color: Colors.yellow,
    tier: 1,
  ),
  
  Challenge(
    id: 'daily_produce_energy_med',
    name: 'Power Surge',
    description: 'Produce 25,000 energy',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.produceEnergy,
    targetValue: 25000,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 35000,
        description: '35,000 Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 8,
        description: '8 Dark Matter',
      ),
    ],
    icon: Icons.bolt,
    color: Colors.amber,
    tier: 2,
  ),
  
  Challenge(
    id: 'daily_produce_energy_hard',
    name: 'Megawatt Mayhem',
    description: 'Produce 100,000 energy',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.produceEnergy,
    targetValue: 100000,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 20,
        description: '20 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        amount: 2.0,
        description: '2x Production (30m)',
      ),
    ],
    icon: Icons.flash_on,
    color: Colors.orange,
    tier: 3,
  ),
  
  // Generator purchase challenges
  Challenge(
    id: 'daily_buy_generators_easy',
    name: 'Expand the Grid',
    description: 'Purchase 5 generators',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.purchaseGenerators,
    targetValue: 5,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 3000,
        description: '3,000 Energy',
      ),
    ],
    icon: Icons.add_circle,
    color: Colors.green,
    tier: 1,
  ),
  
  Challenge(
    id: 'daily_buy_generators_med',
    name: 'Grid Expansion',
    description: 'Purchase 15 generators',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.purchaseGenerators,
    targetValue: 15,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 10000,
        description: '10,000 Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 3,
        description: '3 Dark Matter',
      ),
    ],
    icon: Icons.add_circle_outline,
    color: Colors.teal,
    tier: 2,
  ),
  
  // Tap challenges
  Challenge(
    id: 'daily_tap_easy',
    name: 'Finger Exercise',
    description: 'Tap 15 times',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.tapCount,
    targetValue: 15,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 3000,
        description: '3,000 Energy',
      ),
    ],
    icon: Icons.touch_app,
    color: Colors.blue,
    tier: 1,
  ),
  
  Challenge(
    id: 'daily_tap_med',
    name: 'Tapping Champion',
    description: 'Tap 50 times',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.tapCount,
    targetValue: 50,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 12000,
        description: '12,000 Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 5,
        description: '5 Dark Matter',
      ),
    ],
    icon: Icons.touch_app,
    color: Colors.indigo,
    tier: 2,
  ),
  
  // Research challenges
  Challenge(
    id: 'daily_research',
    name: 'Knowledge Seeker',
    description: 'Complete 1 research',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.completeResearch,
    targetValue: 1,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 5,
        description: '5 Dark Matter',
      ),
    ],
    icon: Icons.science,
    color: Colors.purple,
    tier: 2,
  ),
  
  // Play time challenge
  Challenge(
    id: 'daily_playtime',
    name: 'Dedicated Player',
    description: 'Play for 30 minutes',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.playTime,
    targetValue: 30,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 5000,
        description: '5,000 Energy',
      ),
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 3,
        description: '3 Dark Matter',
      ),
    ],
    icon: Icons.timer,
    color: Colors.cyan,
    tier: 1,
  ),
  
  // Expedition challenge
  Challenge(
    id: 'daily_expedition',
    name: 'Mission Control',
    description: 'Complete 1 expedition',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.completeExpedition,
    targetValue: 1,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 8,
        description: '8 Dark Matter',
      ),
    ],
    icon: Icons.explore,
    color: Colors.deepOrange,
    tier: 2,
  ),
  
  // Ability usage challenge
  Challenge(
    id: 'daily_use_ability',
    name: 'Power Activation',
    description: 'Use 1 architect ability',
    duration: ChallengeDuration.daily,
    objective: ChallengeObjective.useAbility,
    targetValue: 1,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        amount: 1.25,
        description: '1.25x Production (15m)',
      ),
    ],
    icon: Icons.auto_awesome,
    color: Colors.amber,
    tier: 2,
  ),
];

/// Weekly challenges - more ambitious, bigger rewards
const List<Challenge> weeklyChallengesPool = [
  Challenge(
    id: 'weekly_energy_massive',
    name: 'Energy Tycoon',
    description: 'Produce 750,000 energy',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.produceEnergy,
    targetValue: 750000,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 75,
        description: '75 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        amount: 2.5,
        description: '2.5x Production (1h)',
      ),
    ],
    icon: Icons.emoji_events,
    color: Colors.amber,
    tier: 3,
  ),
  
  Challenge(
    id: 'weekly_generators',
    name: 'Industrial Revolution',
    description: 'Purchase 30 generators',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.purchaseGenerators,
    targetValue: 30,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 30,
        description: '30 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 100000,
        description: '100,000 Energy',
      ),
    ],
    icon: Icons.factory,
    color: Colors.brown,
    tier: 2,
  ),
  
  Challenge(
    id: 'weekly_research_master',
    name: 'Research Master',
    description: 'Complete 3 research projects',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.completeResearch,
    targetValue: 3,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 40,
        description: '40 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.timeWarp,
        amount: 2,
        description: '2h Time Warp',
      ),
    ],
    icon: Icons.school,
    color: Colors.deepPurple,
    tier: 3,
  ),
  
  Challenge(
    id: 'weekly_expeditions',
    name: 'Explorer',
    description: 'Complete 5 expeditions',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.completeExpedition,
    targetValue: 5,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 35,
        description: '35 Dark Matter',
      ),
    ],
    icon: Icons.rocket_launch,
    color: Colors.red,
    tier: 2,
  ),
  
  Challenge(
    id: 'weekly_kardashev',
    name: 'Civilization Growth',
    description: 'Increase Kardashev level by 0.1',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.reachKardashev,
    targetValue: 0.1,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 75,
        description: '75 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        amount: 3.0,
        description: '3x Production (1h)',
      ),
    ],
    icon: Icons.trending_up,
    color: Colors.green,
    tier: 3,
  ),
  
  Challenge(
    id: 'weekly_abilities',
    name: 'Ability Master',
    description: 'Use 5 architect abilities',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.useAbility,
    targetValue: 5,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 25,
        description: '25 Dark Matter',
      ),
    ],
    icon: Icons.star,
    color: Colors.yellow,
    tier: 2,
  ),
  
  Challenge(
    id: 'weekly_playtime',
    name: 'Devoted Player',
    description: 'Play for 5 hours total',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.playTime,
    targetValue: 300, // 5 hours in minutes
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 20,
        description: '20 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.energy,
        amount: 50000,
        description: '50,000 Energy',
      ),
    ],
    icon: Icons.access_time,
    color: Colors.teal,
    tier: 1,
  ),
  
  Challenge(
    id: 'weekly_taps',
    name: 'Tap Legend',
    description: 'Tap 250 times',
    duration: ChallengeDuration.weekly,
    objective: ChallengeObjective.tapCount,
    targetValue: 250,
    rewards: [
      ChallengeReward(
        type: ChallengeRewardType.darkMatter,
        amount: 25,
        description: '25 Dark Matter',
      ),
      ChallengeReward(
        type: ChallengeRewardType.productionBoost,
        amount: 2.0,
        description: '2x Production (30m)',
      ),
    ],
    icon: Icons.pan_tool,
    color: Colors.blue,
    tier: 1,
  ),
];

/// Get a challenge by ID
Challenge? getChallengeById(String id) {
  for (final c in dailyChallengesPool) {
    if (c.id == id) return c;
  }
  for (final c in weeklyChallengesPool) {
    if (c.id == id) return c;
  }
  return null;
}

/// Generate daily challenges (picks 3 random)
List<Challenge> generateDailyChallenges(int seed) {
  // Use seed combined with day for deterministic daily selection
  final shuffled = List<Challenge>.from(dailyChallengesPool);
  shuffled.shuffle(Random(DateTime.now().day + seed));
  
  // Pick one from each tier if possible
  final easy = shuffled.where((c) => c.tier == 1).take(1);
  final medium = shuffled.where((c) => c.tier == 2).take(1);
  final hard = shuffled.where((c) => c.tier == 3).take(1);
  
  return [...easy, ...medium, ...hard].take(3).toList();
}

/// Generate weekly challenges (picks 3)
List<Challenge> generateWeeklyChallenges(int seed) {
  // Use seed combined with weekday for deterministic weekly selection
  final shuffled = List<Challenge>.from(weeklyChallengesPool);
  shuffled.shuffle(Random(DateTime.now().weekday + seed));
  
  return shuffled.take(3).toList();
}
