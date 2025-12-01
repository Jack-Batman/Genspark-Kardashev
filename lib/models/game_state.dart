import 'dart:math';
import 'package:hive/hive.dart';
import '../core/era_data.dart';
import 'legendary_expedition.dart';

part 'game_state.g.dart';

/// Main Game State Model - Multi-Era Support
@HiveType(typeId: 0)
class GameState extends HiveObject {
  @HiveField(0)
  double energy;
  
  @HiveField(1)
  double darkMatter;
  
  @HiveField(2)
  double kardashevLevel;
  
  @HiveField(3)
  int currentEra; // 0=planetary, 1=stellar, 2=galactic, 3=universal
  
  @HiveField(4)
  Map<String, int> generators; // generator_id -> count
  
  @HiveField(5)
  Map<String, int> generatorLevels; // generator_id -> level
  
  @HiveField(6)
  List<String> unlockedResearch;
  
  @HiveField(7)
  List<String> ownedArchitects;
  
  @HiveField(8)
  Map<String, String> assignedArchitects;
  
  @HiveField(9)
  DateTime lastOnlineTime;
  
  @HiveField(10)
  int totalTaps;
  
  @HiveField(11)
  double totalEnergyEarned;
  
  @HiveField(12)
  int playTimeSeconds;
  
  @HiveField(13)
  double energyMultiplier;
  
  @HiveField(14)
  double productionBonus;
  
  @HiveField(15)
  bool tutorialCompleted;
  
  @HiveField(16)
  int prestigeCount;
  
  @HiveField(17)
  double prestigeBonus;
  
  @HiveField(18)
  int prestigeTier; // Current prestige tier
  
  @HiveField(19)
  List<int> unlockedEras; // Eras that have been unlocked
  
  @HiveField(20)
  double autoTapPerSecond; // Auto-tap from research
  
  @HiveField(21)
  double costReductionBonus; // Cost reduction from research
  
  @HiveField(22)
  double offlineBonus; // Offline earnings bonus from research
  
  @HiveField(23)
  double researchSpeedBonus; // Research speed bonus
  
  @HiveField(24)
  double darkMatterBonus; // Dark matter bonus from research
  
  // Offline research support
  @HiveField(25)
  DateTime? researchStartTime; // When current research started
  
  @HiveField(26)
  String? currentResearchIdPersisted; // Currently researching ID
  
  @HiveField(27, defaultValue: 0)
  int researchTotalPersisted; // Total time for current research
  
  // Achievements
  @HiveField(28)
  List<String> unlockedAchievements; // List of unlocked achievement IDs
  
  @HiveField(29)
  List<String> claimedAchievements; // List of claimed achievement IDs
  
  // Settings
  @HiveField(30, defaultValue: true)
  bool soundEnabled;
  
  @HiveField(31, defaultValue: true)
  bool hapticsEnabled;
  
  @HiveField(32, defaultValue: true)
  bool notificationsEnabled;
  
  // Daily login
  @HiveField(33)
  DateTime? lastLoginDate;
  
  @HiveField(34, defaultValue: 0)
  int loginStreak;
  
  @HiveField(35, defaultValue: 0)
  int totalLoginDays;
  
  // Artifact system
  @HiveField(36)
  List<String> ownedArtifactIds; // List of owned artifact IDs
  
  @HiveField(37)
  Map<String, int> artifactAcquiredAt; // artifact_id -> timestamp (milliseconds)
  
  @HiveField(38)
  Map<String, String> artifactSources; // artifact_id -> source (expedition_id, 'prestige', 'legendary')
  
  // Legendary expedition system
  @HiveField(39)
  Map<String, dynamic>? activeLegendaryExpedition; // Serialized ActiveLegendaryExpedition
  
  @HiveField(40)
  List<String> completedLegendaryExpeditions; // IDs of completed legendary expeditions
  
  @HiveField(41)
  Map<String, int> legendaryExpeditionCooldowns; // expedition_id -> cooldown end timestamp
  
  // Monetization - Membership
  @HiveField(42, defaultValue: false)
  bool isMember;
  
  @HiveField(43)
  DateTime? membershipExpiresAt;
  
  @HiveField(44)
  DateTime? membershipStartedAt;
  
  // Monetization - IAP tracking
  @HiveField(45)
  List<String> purchasedProductIds;
  
  // Monetization - Ad tracking
  @HiveField(46, defaultValue: 0)
  int dailyAdsWatched;
  
  @HiveField(47)
  DateTime? lastAdWatchDate;
  
  // Monetization - Free time warps used today (for members)
  @HiveField(48, defaultValue: 0)
  int freeTimeWarpsUsedToday;
  
  @HiveField(49)
  DateTime? lastTimeWarpResetDate;
  
  // Founder's Pack
  @HiveField(50, defaultValue: false)
  bool hasFoundersPack;
  
  // Cosmetics
  @HiveField(51)
  String? activeTheme;
  
  @HiveField(52)
  String? activeBorder;
  
  @HiveField(53)
  String? activeParticles;
  
  @HiveField(54)
  List<String> ownedCosmetics;
  
  // Monthly DM claimed
  @HiveField(55)
  DateTime? lastMonthlyDMClaimed;

  @HiveField(56)
  double darkEnergy;
  
  GameState({
    this.energy = 0,
    this.darkMatter = 0,
    this.darkEnergy = 0,
    this.kardashevLevel = 0.0,
    this.currentEra = 0,
    Map<String, int>? generators,
    Map<String, int>? generatorLevels,
    List<String>? unlockedResearch,
    List<String>? ownedArchitects,
    Map<String, String>? assignedArchitects,
    DateTime? lastOnlineTime,
    this.totalTaps = 0,
    this.totalEnergyEarned = 0,
    this.playTimeSeconds = 0,
    this.energyMultiplier = 1.0,
    this.productionBonus = 0.0,
    this.tutorialCompleted = false,
    this.prestigeCount = 0,
    this.prestigeBonus = 0.0,
    this.prestigeTier = 0,
    List<int>? unlockedEras,
    this.autoTapPerSecond = 0.0,
    this.costReductionBonus = 0.0,
    this.offlineBonus = 0.0,
    this.researchSpeedBonus = 0.0,
    this.darkMatterBonus = 0.0,
    this.researchStartTime,
    this.currentResearchIdPersisted,
    this.researchTotalPersisted = 0,
    List<String>? unlockedAchievements,
    List<String>? claimedAchievements,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.lastLoginDate,
    this.loginStreak = 0,
    this.totalLoginDays = 0,
    List<String>? ownedArtifactIds,
    Map<String, int>? artifactAcquiredAt,
    Map<String, String>? artifactSources,
    this.activeLegendaryExpedition,
    List<String>? completedLegendaryExpeditions,
    Map<String, int>? legendaryExpeditionCooldowns,
    this.isMember = false,
    this.membershipExpiresAt,
    this.membershipStartedAt,
    List<String>? purchasedProductIds,
    this.dailyAdsWatched = 0,
    this.lastAdWatchDate,
    this.freeTimeWarpsUsedToday = 0,
    this.lastTimeWarpResetDate,
    this.hasFoundersPack = false,
    this.activeTheme,
    this.activeBorder,
    this.activeParticles,
    List<String>? ownedCosmetics,
    this.lastMonthlyDMClaimed,
  })  : generators = generators ?? {},
        ownedArtifactIds = ownedArtifactIds ?? [],
        artifactAcquiredAt = artifactAcquiredAt ?? {},
        artifactSources = artifactSources ?? {},
        completedLegendaryExpeditions = completedLegendaryExpeditions ?? [],
        legendaryExpeditionCooldowns = legendaryExpeditionCooldowns ?? {},
        purchasedProductIds = purchasedProductIds ?? [],
        ownedCosmetics = ownedCosmetics ?? [],
        unlockedAchievements = unlockedAchievements ?? [],
        claimedAchievements = claimedAchievements ?? [],
        generatorLevels = generatorLevels ?? {},
        unlockedResearch = unlockedResearch ?? [],
        ownedArchitects = ownedArchitects ?? [],
        assignedArchitects = assignedArchitects ?? {},
        lastOnlineTime = lastOnlineTime ?? DateTime.now(),
        unlockedEras = unlockedEras ?? [0]; // Start with Era I unlocked
  
  /// Get total generators count
  int get totalGenerators => generators.values.fold(0, (a, b) => a + b);
  
  /// Get completed research count (excluding "researching_" markers)
  int get completedResearchCount => unlockedResearch.where((r) => !r.startsWith('researching_')).length;
  
  /// Get current Era enum
  Era get era => Era.values[currentEra.clamp(0, Era.values.length - 1)];
  
  /// Get current Era config
  EraConfig get eraConfig => eraConfigs[era]!;
  
  /// Get owned artifact count
  int get ownedArtifactCount => ownedArtifactIds.length;
  
  /// Check if artifact is owned
  bool hasArtifact(String artifactId) => ownedArtifactIds.contains(artifactId);
  
  /// Get active legendary expedition if any
  ActiveLegendaryExpedition? get activeLegendary {
    if (activeLegendaryExpedition == null) return null;
    try {
      return ActiveLegendaryExpedition.fromMap(
        Map<String, dynamic>.from(activeLegendaryExpedition!)
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a legendary expedition is on cooldown
  bool isLegendaryOnCooldown(String expeditionId) {
    final cooldownEnd = legendaryExpeditionCooldowns[expeditionId];
    if (cooldownEnd == null) return false;
    return DateTime.now().millisecondsSinceEpoch < cooldownEnd;
  }
  
  /// Get remaining cooldown for legendary expedition
  Duration getLegendaryCooldownRemaining(String expeditionId) {
    final cooldownEnd = legendaryExpeditionCooldowns[expeditionId];
    if (cooldownEnd == null) return Duration.zero;
    final remaining = cooldownEnd - DateTime.now().millisecondsSinceEpoch;
    if (remaining <= 0) return Duration.zero;
    return Duration(milliseconds: remaining);
  }
  
  /// Get architects currently on legendary expedition
  Set<String> get architectsOnLegendaryExpedition {
    final active = activeLegendary;
    if (active == null) return {};
    return active.assignedArchitectIds.toSet();
  }
  
  /// Get era name as Roman numeral (I, II, III, IV)
  String get eraName {
    switch (currentEra) {
      case 0: return 'I';
      case 1: return 'II';
      case 2: return 'III';
      case 3: return 'IV';
      default: return 'I';
    }
  }
  
  /// Get generators for current era
  List<GeneratorDataV2> get currentEraGenerators => getGeneratorsForEra(era);
  
  /// Get all unlocked generators across all unlocked eras
  List<GeneratorDataV2> get allUnlockedGenerators {
    final generators = <GeneratorDataV2>[];
    for (final eraIndex in unlockedEras) {
      final eraEnum = Era.values[eraIndex.clamp(0, Era.values.length - 1)];
      generators.addAll(getGeneratorsForEra(eraEnum));
    }
    return generators;
  }
  
  /// Calculate total energy production per second
  double get energyPerSecond {
    double total = 0;
    
    for (var entry in generators.entries) {
      final genData = getGeneratorById(entry.key);
      if (genData == null) continue;
      
      final count = entry.value;
      final level = generatorLevels[entry.key] ?? 1;
      
      // Base production * count * level bonus * multipliers * era multiplier
      final eraMultiplier = eraConfigs[genData.era]?.prestigeMultiplier ?? 1.0;
      final production = genData.baseProduction * 
                        count * 
                        (1 + (level - 1) * 0.1) * 
                        energyMultiplier * 
                        (1 + productionBonus) *
                        (1 + prestigeBonus) *
                        eraMultiplier;
      total += production;
    }
    
    // Add auto-tap contribution
    total += autoTapPerSecond * (1 + productionBonus) * (1 + prestigeBonus);
    
    return total;
  }
  
  /// Get count of specific generator
  int getGeneratorCount(String generatorId) {
    return generators[generatorId] ?? 0;
  }
  
  /// Get level of specific generator
  int getGeneratorLevel(String generatorId) {
    return generatorLevels[generatorId] ?? 1;
  }
  
  /// Calculate cost for next generator (with cost reduction)
  double getGeneratorCost(GeneratorDataV2 genData) {
    final count = getGeneratorCount(genData.id);
    final baseCost = genData.baseCost * 
           (count == 0 ? 1 : pow(genData.costMultiplier, count));
    return baseCost * (1 - costReductionBonus);
  }
  
  /// Calculate upgrade cost for generator
  double getUpgradeCost(GeneratorDataV2 genData) {
    final level = getGeneratorLevel(genData.id);
    final baseCost = genData.baseCost * 10 * pow(genData.costMultiplier, level);
    return baseCost * (1 - costReductionBonus);
  }
  
  /// Check if generator is unlocked based on total generators in its era
  bool isGeneratorUnlocked(GeneratorDataV2 genData) {
    // Check if era is unlocked
    if (!unlockedEras.contains(genData.era.index)) return false;
    
    // Count total generators in this era
    final eraGenerators = getGeneratorsForEra(genData.era);
    int totalInEra = 0;
    for (final gen in eraGenerators) {
      totalInEra += generators[gen.id] ?? 0;
    }
    
    return totalInEra >= genData.unlockRequirement;
  }
  
  /// Calculate Kardashev level from total energy production
  /// Kardashev Scale:
  /// Type I (0.0-1.0): Planetary - 10^16 watts
  /// Type II (1.0-2.0): Stellar - 10^26 watts
  /// Type III (2.0-3.0): Galactic - 10^36 watts
  /// Type IV (3.0-4.0): Universal - 10^46+ watts
  void updateKardashevLevel() {
    final totalProduction = energyPerSecond;
    if (totalProduction <= 0) {
      kardashevLevel = 0.0;
      return;
    }
    
    // Game-friendly logarithmic scale
    // Maps production to Kardashev level
    final logProduction = _log10(totalProduction);
    
    // Scale: 
    // Era I: 0 -> 0.0, 10^7 -> 1.0
    // Era II: 10^7 -> 1.0, 10^15 -> 2.0
    // Era III: 10^15 -> 2.0, 10^23 -> 3.0
    // Era IV: 10^23 -> 3.0, 10^31 -> 4.0
    
    if (logProduction < 7) {
      // Era I: 0.0 - 1.0
      kardashevLevel = (logProduction / 7).clamp(0.0, 1.0);
    } else if (logProduction < 15) {
      // Era II: 1.0 - 2.0
      kardashevLevel = 1.0 + ((logProduction - 7) / 8).clamp(0.0, 1.0);
    } else if (logProduction < 23) {
      // Era III: 2.0 - 3.0
      kardashevLevel = 2.0 + ((logProduction - 15) / 8).clamp(0.0, 1.0);
    } else {
      // Era IV: 3.0 - 4.0
      kardashevLevel = 3.0 + ((logProduction - 23) / 8).clamp(0.0, 1.0);
    }
    
    kardashevLevel = kardashevLevel.clamp(0.0, 4.0);
  }
  
  /// Get era from Kardashev level
  Era getEraFromKardashev() {
    if (kardashevLevel < 1.0) return Era.planetary;
    if (kardashevLevel < 2.0) return Era.stellar;
    if (kardashevLevel < 3.0) return Era.galactic;
    return Era.universal;
  }
  
  /// Check if can transition to next era
  bool canTransitionToNextEra() {
    final transition = getTransitionFromEra(era);
    if (transition == null) return false;
    
    // Check Kardashev requirement
    if (kardashevLevel < transition.requiredKardashev) return false;
    
    // Check energy cost
    if (energy < transition.energyCost) return false;
    
    // Check if next era is not already current
    if (currentEra >= transition.toEra.index) return false;
    
    return true;
  }
  
  /// Get the next era transition info
  EraTransition? get nextTransition => getTransitionFromEra(era);
  
  /// Check if membership is currently active
  bool get isMembershipActive {
    if (!isMember || membershipExpiresAt == null) return false;
    return DateTime.now().isBefore(membershipExpiresAt!);
  }
  
  /// Get max offline hours based on membership
  int get maxOfflineHours => isMembershipActive ? 24 : 3;
  
  /// Get offline efficiency bonus from membership
  double get membershipOfflineBonus => isMembershipActive ? 0.5 : 0.0;
  
  /// Calculate offline earnings with bonuses (3hr default, 24hr for members)
  double calculateOfflineEarnings() {
    final now = DateTime.now();
    final difference = now.difference(lastOnlineTime);
    final hours = difference.inSeconds / 3600;
    final cappedHours = hours.clamp(0, maxOfflineHours); // 3 hours default, 24 hours for members
    
    // Offline efficiency with bonus from research + membership bonus
    final baseEfficiency = 0.5; // 50% base offline efficiency
    final totalEfficiency = baseEfficiency + offlineBonus + membershipOfflineBonus;
    
    return energyPerSecond * cappedHours * 3600 * totalEfficiency;
  }
  
  /// Calculate what offline earnings would be with 2x ad bonus
  double calculateDoubledOfflineEarnings() {
    return calculateOfflineEarnings() * 2;
  }
  
  /// Get progress towards next Kardashev milestone
  double get kardashevProgress {
    final level = kardashevLevel;
    return level - level.floor();
  }
  
  /// Get tech level within current era (0.0 - 1.0)
  double get eraTechLevel {
    final eraMin = eraConfig.minKardashev;
    final eraMax = eraConfig.maxKardashev;
    return ((kardashevLevel - eraMin) / (eraMax - eraMin)).clamp(0.0, 1.0);
  }
  
  /// Copy with modifications
  GameState copyWith({
    double? energy,
    double? darkMatter,
    double? kardashevLevel,
    int? currentEra,
    Map<String, int>? generators,
    Map<String, int>? generatorLevels,
    List<String>? unlockedResearch,
    List<String>? ownedArchitects,
    Map<String, String>? assignedArchitects,
    DateTime? lastOnlineTime,
    int? totalTaps,
    double? totalEnergyEarned,
    int? playTimeSeconds,
    double? energyMultiplier,
    double? productionBonus,
    bool? tutorialCompleted,
    int? prestigeCount,
    double? prestigeBonus,
    int? prestigeTier,
    List<int>? unlockedEras,
    double? autoTapPerSecond,
    double? costReductionBonus,
    double? offlineBonus,
    double? researchSpeedBonus,
    double? darkMatterBonus,
    DateTime? researchStartTime,
    String? currentResearchIdPersisted,
    int? researchTotalPersisted,
    List<String>? unlockedAchievements,
    List<String>? claimedAchievements,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? notificationsEnabled,
    DateTime? lastLoginDate,
    int? loginStreak,
    int? totalLoginDays,
    List<String>? ownedArtifactIds,
    Map<String, int>? artifactAcquiredAt,
    Map<String, String>? artifactSources,
    Map<String, dynamic>? activeLegendaryExpedition,
    List<String>? completedLegendaryExpeditions,
    Map<String, int>? legendaryExpeditionCooldowns,
    bool? isMember,
    DateTime? membershipExpiresAt,
    DateTime? membershipStartedAt,
    List<String>? purchasedProductIds,
    int? dailyAdsWatched,
    DateTime? lastAdWatchDate,
    int? freeTimeWarpsUsedToday,
    DateTime? lastTimeWarpResetDate,
    bool? hasFoundersPack,
    String? activeTheme,
    String? activeBorder,
    String? activeParticles,
    List<String>? ownedCosmetics,
    DateTime? lastMonthlyDMClaimed,
  }) {
    return GameState(
      energy: energy ?? this.energy,
      darkMatter: darkMatter ?? this.darkMatter,
      kardashevLevel: kardashevLevel ?? this.kardashevLevel,
      currentEra: currentEra ?? this.currentEra,
      generators: generators ?? Map.from(this.generators),
      generatorLevels: generatorLevels ?? Map.from(this.generatorLevels),
      unlockedResearch: unlockedResearch ?? List.from(this.unlockedResearch),
      ownedArchitects: ownedArchitects ?? List.from(this.ownedArchitects),
      assignedArchitects: assignedArchitects ?? Map.from(this.assignedArchitects),
      lastOnlineTime: lastOnlineTime ?? this.lastOnlineTime,
      totalTaps: totalTaps ?? this.totalTaps,
      totalEnergyEarned: totalEnergyEarned ?? this.totalEnergyEarned,
      playTimeSeconds: playTimeSeconds ?? this.playTimeSeconds,
      energyMultiplier: energyMultiplier ?? this.energyMultiplier,
      productionBonus: productionBonus ?? this.productionBonus,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      prestigeCount: prestigeCount ?? this.prestigeCount,
      prestigeBonus: prestigeBonus ?? this.prestigeBonus,
      prestigeTier: prestigeTier ?? this.prestigeTier,
      unlockedEras: unlockedEras ?? List.from(this.unlockedEras),
      autoTapPerSecond: autoTapPerSecond ?? this.autoTapPerSecond,
      costReductionBonus: costReductionBonus ?? this.costReductionBonus,
      offlineBonus: offlineBonus ?? this.offlineBonus,
      researchSpeedBonus: researchSpeedBonus ?? this.researchSpeedBonus,
      darkMatterBonus: darkMatterBonus ?? this.darkMatterBonus,
      researchStartTime: researchStartTime ?? this.researchStartTime,
      currentResearchIdPersisted: currentResearchIdPersisted ?? this.currentResearchIdPersisted,
      researchTotalPersisted: researchTotalPersisted ?? this.researchTotalPersisted,
      unlockedAchievements: unlockedAchievements ?? List.from(this.unlockedAchievements),
      claimedAchievements: claimedAchievements ?? List.from(this.claimedAchievements),
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      loginStreak: loginStreak ?? this.loginStreak,
      totalLoginDays: totalLoginDays ?? this.totalLoginDays,
      ownedArtifactIds: ownedArtifactIds ?? List.from(this.ownedArtifactIds),
      artifactAcquiredAt: artifactAcquiredAt ?? Map.from(this.artifactAcquiredAt),
      artifactSources: artifactSources ?? Map.from(this.artifactSources),
      activeLegendaryExpedition: activeLegendaryExpedition ?? (this.activeLegendaryExpedition != null ? Map.from(this.activeLegendaryExpedition!) : null),
      completedLegendaryExpeditions: completedLegendaryExpeditions ?? List.from(this.completedLegendaryExpeditions),
      legendaryExpeditionCooldowns: legendaryExpeditionCooldowns ?? Map.from(this.legendaryExpeditionCooldowns),
      isMember: isMember ?? this.isMember,
      membershipExpiresAt: membershipExpiresAt ?? this.membershipExpiresAt,
      membershipStartedAt: membershipStartedAt ?? this.membershipStartedAt,
      purchasedProductIds: purchasedProductIds ?? List.from(this.purchasedProductIds),
      dailyAdsWatched: dailyAdsWatched ?? this.dailyAdsWatched,
      lastAdWatchDate: lastAdWatchDate ?? this.lastAdWatchDate,
      freeTimeWarpsUsedToday: freeTimeWarpsUsedToday ?? this.freeTimeWarpsUsedToday,
      lastTimeWarpResetDate: lastTimeWarpResetDate ?? this.lastTimeWarpResetDate,
      hasFoundersPack: hasFoundersPack ?? this.hasFoundersPack,
      activeTheme: activeTheme ?? this.activeTheme,
      activeBorder: activeBorder ?? this.activeBorder,
      activeParticles: activeParticles ?? this.activeParticles,
      ownedCosmetics: ownedCosmetics ?? List.from(this.ownedCosmetics),
      lastMonthlyDMClaimed: lastMonthlyDMClaimed ?? this.lastMonthlyDMClaimed,
      darkEnergy: darkEnergy ?? this.darkEnergy,
    );
  }
  
  /// Log base 10
  double _log10(double x) {
    if (x <= 0) return 0;
    return log(x) / ln10;
  }
}
