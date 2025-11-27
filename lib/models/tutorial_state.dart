import 'package:hive/hive.dart';

part 'tutorial_state.g.dart';

/// Tutorial topics for feature-specific guides
enum TutorialTopic {
  /// Core game tutorials (shown in intro)
  welcome,
  energyProduction,
  tapping,
  research,
  kardashevScale,
  darkMatter,
  prestige,
  entropy,
  
  /// Feature tutorials (shown on first access)
  expeditions,
  architectAbilities,
  dailyChallenges,
  weeklyChallenges,
  achievements,
  statistics,
  settings,
  eraProgression,
  generators,
  architects,
}

/// Tutorial hint data for contextual tooltips
class TutorialHint {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String? targetArea;
  final TutorialTopic topic;
  
  const TutorialHint({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.targetArea,
    required this.topic,
  });
}

/// Tutorial step with action requirement
class InteractiveTutorialStep {
  final String title;
  final String description;
  final String icon;
  final String? highlightWidget;
  final String? actionRequired; // e.g., 'tap_generator', 'start_expedition', etc.
  final bool canSkip;
  
  const InteractiveTutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.highlightWidget,
    this.actionRequired,
    this.canSkip = true,
  });
}

/// Expedition tutorial steps
const List<InteractiveTutorialStep> expeditionTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Expeditions',
    description: 'Send expedition teams to explore the cosmos and discover valuable resources!',
    icon: '🚀',
  ),
  InteractiveTutorialStep(
    title: 'Mission Selection',
    description: 'Each expedition has different risks, rewards, and time requirements. Choose wisely based on your resources.',
    icon: '🎯',
    highlightWidget: 'expedition_card',
  ),
  InteractiveTutorialStep(
    title: 'Risk vs Reward',
    description: 'Higher difficulty missions have better rewards but lower success rates. Assign Architects to boost your chances!',
    icon: '⚖️',
  ),
  InteractiveTutorialStep(
    title: 'Architect Assignment',
    description: 'Architects assigned to expeditions increase success rate based on their tier and type.',
    icon: '👨‍🚀',
    highlightWidget: 'architect_selector',
  ),
  InteractiveTutorialStep(
    title: 'Expedition Rewards',
    description: 'Successful expeditions grant Energy, Dark Matter, and occasionally rare Artifacts!',
    icon: '🎁',
  ),
  InteractiveTutorialStep(
    title: 'Start Your First Mission',
    description: 'Select an expedition and send your team to begin exploring!',
    icon: '✨',
    actionRequired: 'start_expedition',
    canSkip: true,
  ),
];

/// Architect abilities tutorial steps
const List<InteractiveTutorialStep> abilityTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Architect Abilities',
    description: 'Each Architect has a unique special ability that can be activated for powerful effects!',
    icon: '⚡',
  ),
  InteractiveTutorialStep(
    title: 'Ability Types',
    description: 'Abilities range from production boosts and time warps to cost reductions and instant rewards.',
    icon: '🎭',
  ),
  InteractiveTutorialStep(
    title: 'Cooldowns',
    description: 'After using an ability, it enters cooldown. Higher tier Architects have shorter cooldowns.',
    icon: '⏱️',
    highlightWidget: 'ability_cooldown',
  ),
  InteractiveTutorialStep(
    title: 'Strategic Timing',
    description: 'Save powerful abilities for key moments - before prestiging or during challenging milestones!',
    icon: '🎯',
  ),
  InteractiveTutorialStep(
    title: 'Try an Ability',
    description: 'Tap an available ability to activate it and see its effects!',
    icon: '👆',
    actionRequired: 'use_ability',
    canSkip: true,
  ),
];

/// Challenge tutorial steps
const List<InteractiveTutorialStep> challengeTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Challenges',
    description: 'Complete challenges to earn bonus rewards and prove your mastery!',
    icon: '🏆',
  ),
  InteractiveTutorialStep(
    title: 'Daily Challenges',
    description: 'Daily challenges reset every 24 hours. Complete them for quick rewards!',
    icon: '📅',
    highlightWidget: 'daily_tab',
  ),
  InteractiveTutorialStep(
    title: 'Weekly Challenges',
    description: 'Weekly challenges are more difficult but offer greater rewards. They reset every 7 days.',
    icon: '📆',
    highlightWidget: 'weekly_tab',
  ),
  InteractiveTutorialStep(
    title: 'Challenge Types',
    description: 'Challenges include production goals, research completion, expedition success, and more!',
    icon: '📋',
  ),
  InteractiveTutorialStep(
    title: 'Claim Rewards',
    description: 'Once completed, tap the claim button to collect your rewards before they reset!',
    icon: '🎁',
    actionRequired: 'claim_challenge',
    canSkip: true,
  ),
];

/// Era progression tutorial steps
const List<InteractiveTutorialStep> eraProgressionTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Era Progression',
    description: 'Your civilization evolves through four distinct eras on the Kardashev Scale!',
    icon: '🌌',
  ),
  InteractiveTutorialStep(
    title: 'Era I: Planetary',
    description: 'Harness your home world\'s resources. Reach K1.0 to unlock the Stellar Era!',
    icon: '🌍',
  ),
  InteractiveTutorialStep(
    title: 'Era II: Stellar',
    description: 'Command the power of stars. New generators, research, and expeditions await!',
    icon: '⭐',
  ),
  InteractiveTutorialStep(
    title: 'Era III: Galactic',
    description: 'Tap into galactic energies. Master black holes and dark matter manipulation!',
    icon: '🌀',
  ),
  InteractiveTutorialStep(
    title: 'Era IV: Universal',
    description: 'The ultimate civilization. Control the fundamental forces of the universe!',
    icon: '✨',
  ),
  InteractiveTutorialStep(
    title: 'Era Benefits',
    description: 'Each new era unlocks exclusive generators, research trees, expeditions, and Architects!',
    icon: '🎯',
  ),
];

/// Generator tutorial steps
const List<InteractiveTutorialStep> generatorTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Generators',
    description: 'Generators automatically produce energy over time - the core of your civilization!',
    icon: '⚡',
  ),
  InteractiveTutorialStep(
    title: 'Generator Types',
    description: 'Each era has unique generators with different costs and production rates.',
    icon: '🏭',
    highlightWidget: 'generator_list',
  ),
  InteractiveTutorialStep(
    title: 'Purchasing',
    description: 'Buy generators to increase your energy per second. Costs increase with each purchase.',
    icon: '💰',
  ),
  InteractiveTutorialStep(
    title: 'Bulk Purchase',
    description: 'Use the multiplier buttons (x1, x10, x100, MAX) for efficient purchasing!',
    icon: '📈',
    highlightWidget: 'buy_multiplier',
  ),
  InteractiveTutorialStep(
    title: 'Architect Bonuses',
    description: 'Assign Architects to generators for production multipliers!',
    icon: '👨‍🔬',
  ),
];

/// Prestige tutorial steps (expanded)
const List<InteractiveTutorialStep> prestigeTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Prestige System',
    description: 'Prestige resets your progress but grants permanent bonuses and Dark Matter!',
    icon: '✨',
  ),
  InteractiveTutorialStep(
    title: 'When to Prestige',
    description: 'Prestige when you reach K0.3+. Higher Kardashev levels = more Dark Matter!',
    icon: '📊',
  ),
  InteractiveTutorialStep(
    title: 'Dark Matter',
    description: 'Dark Matter is used to synthesize Architects - powerful permanent allies!',
    icon: '🌑',
  ),
  InteractiveTutorialStep(
    title: 'Prestige Tiers',
    description: 'Each prestige increases your tier, unlocking new milestones and cosmetics!',
    icon: '🏅',
  ),
  InteractiveTutorialStep(
    title: 'Production Bonus',
    description: 'Each prestige grants a permanent production multiplier for faster progress!',
    icon: '💪',
  ),
  InteractiveTutorialStep(
    title: 'Strategic Prestige',
    description: 'Balance between pushing further for more Dark Matter vs prestiging early for bonuses!',
    icon: '🎯',
  ),
];

/// Architect tutorial steps
const List<InteractiveTutorialStep> architectTutorialSteps = [
  InteractiveTutorialStep(
    title: 'Architects',
    description: 'Architects are powerful allies who boost your civilization permanently!',
    icon: '👨‍🔬',
  ),
  InteractiveTutorialStep(
    title: 'Synthesizing',
    description: 'Use Dark Matter to synthesize new Architects. Higher tiers cost more but are stronger!',
    icon: '⚗️',
    highlightWidget: 'synthesize_button',
  ),
  InteractiveTutorialStep(
    title: 'Architect Tiers',
    description: 'Common, Rare, Epic, and Legendary tiers offer increasingly powerful bonuses.',
    icon: '⭐',
  ),
  InteractiveTutorialStep(
    title: 'Assignment',
    description: 'Assign Architects to generators for production boosts, or to expeditions for success bonuses!',
    icon: '📍',
    highlightWidget: 'assign_button',
  ),
  InteractiveTutorialStep(
    title: 'Abilities',
    description: 'Each Architect has a unique ability. Higher tier = stronger abilities!',
    icon: '⚡',
  ),
];

/// Tutorial state for tracking which tutorials have been seen
@HiveType(typeId: 20)
class TutorialStateData extends HiveObject {
  @HiveField(0)
  bool introCompleted;
  
  @HiveField(1)
  List<String> seenTutorials; // List of TutorialTopic names
  
  @HiveField(2)
  List<String> seenHints; // List of hint IDs
  
  @HiveField(3)
  bool hintsEnabled;
  
  @HiveField(4)
  DateTime? lastHintTime;
  
  TutorialStateData({
    this.introCompleted = false,
    List<String>? seenTutorials,
    List<String>? seenHints,
    this.hintsEnabled = true,
    this.lastHintTime,
  }) : seenTutorials = seenTutorials ?? [],
       seenHints = seenHints ?? [];
  
  /// Check if a tutorial has been seen
  bool hasSeenTutorial(TutorialTopic topic) {
    return seenTutorials.contains(topic.name);
  }
  
  /// Mark a tutorial as seen
  void markTutorialSeen(TutorialTopic topic) {
    if (!seenTutorials.contains(topic.name)) {
      seenTutorials.add(topic.name);
    }
  }
  
  /// Check if a hint has been seen
  bool hasSeenHint(String hintId) {
    return seenHints.contains(hintId);
  }
  
  /// Mark a hint as seen
  void markHintSeen(String hintId) {
    if (!seenHints.contains(hintId)) {
      seenHints.add(hintId);
      lastHintTime = DateTime.now();
    }
  }
  
  /// Reset all tutorial progress
  void resetAll() {
    introCompleted = false;
    seenTutorials.clear();
    seenHints.clear();
    lastHintTime = null;
  }
  
  /// Reset feature tutorials only (keep intro completed)
  void resetFeatureTutorials() {
    seenTutorials.removeWhere((t) => 
      t != TutorialTopic.welcome.name &&
      t != TutorialTopic.energyProduction.name &&
      t != TutorialTopic.tapping.name &&
      t != TutorialTopic.research.name &&
      t != TutorialTopic.kardashevScale.name
    );
    seenHints.clear();
  }
}

/// Get tutorial steps for a topic
List<InteractiveTutorialStep> getTutorialSteps(TutorialTopic topic) {
  switch (topic) {
    case TutorialTopic.expeditions:
      return expeditionTutorialSteps;
    case TutorialTopic.architectAbilities:
      return abilityTutorialSteps;
    case TutorialTopic.dailyChallenges:
    case TutorialTopic.weeklyChallenges:
      return challengeTutorialSteps;
    case TutorialTopic.eraProgression:
      return eraProgressionTutorialSteps;
    case TutorialTopic.generators:
      return generatorTutorialSteps;
    case TutorialTopic.prestige:
      return prestigeTutorialSteps;
    case TutorialTopic.architects:
      return architectTutorialSteps;
    default:
      return [];
  }
}

/// Get topic display name
String getTutorialTopicName(TutorialTopic topic) {
  switch (topic) {
    case TutorialTopic.welcome:
      return 'Welcome';
    case TutorialTopic.energyProduction:
      return 'Energy Production';
    case TutorialTopic.tapping:
      return 'Manual Tapping';
    case TutorialTopic.research:
      return 'Research';
    case TutorialTopic.kardashevScale:
      return 'Kardashev Scale';
    case TutorialTopic.darkMatter:
      return 'Dark Matter';
    case TutorialTopic.prestige:
      return 'Prestige System';
    case TutorialTopic.entropy:
      return 'ENTROPY Assistant';
    case TutorialTopic.expeditions:
      return 'Expeditions';
    case TutorialTopic.architectAbilities:
      return 'Architect Abilities';
    case TutorialTopic.dailyChallenges:
      return 'Daily Challenges';
    case TutorialTopic.weeklyChallenges:
      return 'Weekly Challenges';
    case TutorialTopic.achievements:
      return 'Achievements';
    case TutorialTopic.statistics:
      return 'Statistics';
    case TutorialTopic.settings:
      return 'Settings';
    case TutorialTopic.eraProgression:
      return 'Era Progression';
    case TutorialTopic.generators:
      return 'Generators';
    case TutorialTopic.architects:
      return 'Architects';
  }
}
