import 'dart:math';
import 'package:hive/hive.dart';
import '../core/era_data.dart';

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
  
  GameState({
    this.energy = 0,
    this.darkMatter = 0,
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
  })  : generators = generators ?? {},
        generatorLevels = generatorLevels ?? {},
        unlockedResearch = unlockedResearch ?? [],
        ownedArchitects = ownedArchitects ?? [],
        assignedArchitects = assignedArchitects ?? {},
        lastOnlineTime = lastOnlineTime ?? DateTime.now(),
        unlockedEras = unlockedEras ?? [0]; // Start with Era I unlocked
  
  /// Get current Era enum
  Era get era => Era.values[currentEra.clamp(0, Era.values.length - 1)];
  
  /// Get current Era config
  EraConfig get eraConfig => eraConfigs[era]!;
  
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
  
  /// Calculate offline earnings with bonuses
  double calculateOfflineEarnings() {
    final now = DateTime.now();
    final difference = now.difference(lastOnlineTime);
    final hours = difference.inSeconds / 3600;
    final cappedHours = hours.clamp(0, 8); // Max 8 hours offline
    
    // Offline efficiency with bonus from research
    final baseEfficiency = 0.5; // 50% base offline efficiency
    final totalEfficiency = baseEfficiency + offlineBonus;
    
    return energyPerSecond * cappedHours * 3600 * totalEfficiency;
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
    );
  }
  
  /// Log base 10
  double _log10(double x) {
    if (x <= 0) return 0;
    return log(x) / ln10;
  }
}
