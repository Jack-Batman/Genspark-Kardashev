import 'package:flutter/material.dart';

/// Era definitions and progression data
/// Kardashev Scale: Type I (Planetary) → Type II (Stellar) → Type III (Galactic) → Type IV (Universal)

enum Era {
  planetary,  // Era I: 0.0 - 1.0
  stellar,    // Era II: 1.0 - 2.0
  galactic,   // Era III: 2.0 - 3.0
  universal,  // Era IV: 3.0+
}

/// Era configuration and theming
class EraConfig {
  final Era era;
  final String name;
  final String subtitle;
  final String description;
  final double minKardashev;
  final double maxKardashev;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String centralObject; // What's shown in the center (Earth, Sun, Galaxy, Universe)
  final double prestigeMultiplier;
  final double darkMatterMultiplier;
  final String unlockMessage;
  
  const EraConfig({
    required this.era,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.minKardashev,
    required this.maxKardashev,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.centralObject,
    required this.prestigeMultiplier,
    required this.darkMatterMultiplier,
    required this.unlockMessage,
  });
}

/// All Era configurations
const Map<Era, EraConfig> eraConfigs = {
  Era.planetary: EraConfig(
    era: Era.planetary,
    name: 'ERA I',
    subtitle: 'PLANETARY',
    description: 'Harness the energy of your home world. Build renewable grids, fusion reactors, and orbital infrastructure.',
    minKardashev: 0.0,
    maxKardashev: 1.0,
    primaryColor: Color(0xFF00D9FF), // Cyan
    secondaryColor: Color(0xFFFFB347), // Golden amber
    accentColor: Color(0xFFFFD700), // Gold
    backgroundColor: Color(0xFF0A0A14),
    centralObject: 'earth',
    prestigeMultiplier: 1.0,
    darkMatterMultiplier: 1.0,
    unlockMessage: 'Welcome to Kardashev: Ascension. Begin your journey to harness planetary energy.',
  ),
  Era.stellar: EraConfig(
    era: Era.stellar,
    name: 'ERA II',
    subtitle: 'STELLAR',
    description: 'Construct Dyson structures around your star. Mine stellar mass and colonize the solar system.',
    minKardashev: 1.0,
    maxKardashev: 2.0,
    primaryColor: Color(0xFFFFB347), // Orange/Gold
    secondaryColor: Color(0xFFFF6B35), // Solar orange
    accentColor: Color(0xFFFFD700), // Bright gold
    backgroundColor: Color(0xFF1A0A00),
    centralObject: 'sun',
    prestigeMultiplier: 2.5,
    darkMatterMultiplier: 3.0,
    unlockMessage: 'Type I Civilization Achieved! Your species now commands planetary-scale energy. The stars await.',
  ),
  Era.galactic: EraConfig(
    era: Era.galactic,
    name: 'ERA III',
    subtitle: 'GALACTIC',
    description: 'Harvest black holes with Penrose spheres. Build an interstellar network spanning the galaxy.',
    minKardashev: 2.0,
    maxKardashev: 3.0,
    primaryColor: Color(0xFFAA77FF), // Violet
    secondaryColor: Color(0xFF6B35FF), // Deep purple
    accentColor: Color(0xFFE040FB), // Magenta
    backgroundColor: Color(0xFF0A001A),
    centralObject: 'galaxy',
    prestigeMultiplier: 10.0,
    darkMatterMultiplier: 15.0,
    unlockMessage: 'Type II Civilization Achieved! You have mastered stellar energy. The galaxy is your canvas.',
  ),
  Era.universal: EraConfig(
    era: Era.universal,
    name: 'ERA IV',
    subtitle: 'UNIVERSAL',
    description: 'Manipulate spacetime itself. Harvest vacuum energy and engineer the fabric of reality.',
    minKardashev: 3.0,
    maxKardashev: 4.0,
    primaryColor: Color(0xFFFF6B9D), // Cosmic pink
    secondaryColor: Color(0xFF00FFFF), // Cyan
    accentColor: Color(0xFFFFFFFF), // Pure white
    backgroundColor: Color(0xFF000005),
    centralObject: 'universe',
    prestigeMultiplier: 100.0,
    darkMatterMultiplier: 100.0,
    unlockMessage: 'Type III Civilization Achieved! The galaxy bends to your will. Reality itself awaits reshaping.',
  ),
};

/// Generator types for all Eras
enum GeneratorTypeV2 {
  // Era I - Planetary
  windTurbine,
  solarPanel,
  nuclearPlant,
  fusionReactor,
  orbitalArray,
  planetaryGrid,
  
  // Era II - Stellar
  solarSatellite,
  dysonMirror,
  starLifter,
  dysonSwarm,
  stellarForge,
  dysonSphere,
  
  // Era III - Galactic
  neutronHarvester,
  penroseSphere,
  quasarTap,
  stellarEngine,
  galacticHub,
  cosmicString,
  
  // Era IV - Universal
  vacuumExtractor,
  dimensionalRift,
  timelineHarvester,
  realityEngine,
  entropyReverser,
  omniversalCore,
}

/// Generator data structure
class GeneratorDataV2 {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Era era;
  final double baseProduction;
  final double baseCost;
  final double costMultiplier;
  final int unlockRequirement; // Total generators needed to unlock
  final double prestigeBonus; // Bonus per prestige level
  
  const GeneratorDataV2({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.era,
    required this.baseProduction,
    required this.baseCost,
    required this.costMultiplier,
    required this.unlockRequirement,
    this.prestigeBonus = 0.05,
  });
}

/// All generators organized by Era
const List<GeneratorDataV2> allGenerators = [
  // ═══════════════════════════════════════════════════════════════
  // ERA I - PLANETARY (Kardashev 0.0 - 1.0)
  // ═══════════════════════════════════════════════════════════════
  GeneratorDataV2(
    id: 'wind_turbine',
    name: 'Wind Turbine',
    description: 'Harness atmospheric currents for clean energy.',
    icon: '🌀',
    era: Era.planetary,
    baseProduction: 1.0,
    baseCost: 15,
    costMultiplier: 1.12,
    unlockRequirement: 0,
  ),
  GeneratorDataV2(
    id: 'solar_panel',
    name: 'Solar Array',
    description: 'Convert stellar radiation into power.',
    icon: '☀️',
    era: Era.planetary,
    baseProduction: 5.0,
    baseCost: 100,
    costMultiplier: 1.14,
    unlockRequirement: 5,
  ),
  GeneratorDataV2(
    id: 'nuclear_plant',
    name: 'Fission Reactor',
    description: 'Split atoms to release binding energy.',
    icon: '⚛️',
    era: Era.planetary,
    baseProduction: 25.0,
    baseCost: 1100,
    costMultiplier: 1.16,
    unlockRequirement: 15,
  ),
  GeneratorDataV2(
    id: 'fusion_reactor',
    name: 'Fusion Core',
    description: 'Stellar fire contained and controlled.',
    icon: '🔥',
    era: Era.planetary,
    baseProduction: 150.0,
    baseCost: 12000,
    costMultiplier: 1.18,
    unlockRequirement: 30,
  ),
  GeneratorDataV2(
    id: 'orbital_array',
    name: 'Orbital Collector',
    description: 'Space-based solar harvesting platform.',
    icon: '🛰️',
    era: Era.planetary,
    baseProduction: 800.0,
    baseCost: 130000,
    costMultiplier: 1.20,
    unlockRequirement: 50,
  ),
  GeneratorDataV2(
    id: 'planetary_grid',
    name: 'Planetary Grid',
    description: 'Global unified energy distribution network.',
    icon: '🌐',
    era: Era.planetary,
    baseProduction: 4500.0,
    baseCost: 1400000,
    costMultiplier: 1.22,
    unlockRequirement: 75,
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA II - STELLAR (Kardashev 1.0 - 2.0)
  // ═══════════════════════════════════════════════════════════════
  GeneratorDataV2(
    id: 'solar_satellite',
    name: 'Solar Satellite',
    description: 'Orbital platform beaming energy from near-sun orbit.',
    icon: '📡',
    era: Era.stellar,
    baseProduction: 25000.0,
    baseCost: 15000000,
    costMultiplier: 1.12,
    unlockRequirement: 0,
  ),
  GeneratorDataV2(
    id: 'dyson_mirror',
    name: 'Dyson Mirror',
    description: 'Massive reflector focusing stellar energy.',
    icon: '🪞',
    era: Era.stellar,
    baseProduction: 125000.0,
    baseCost: 100000000,
    costMultiplier: 1.14,
    unlockRequirement: 10,
  ),
  GeneratorDataV2(
    id: 'star_lifter',
    name: 'Star Lifter',
    description: 'Extract matter directly from the stellar corona.',
    icon: '⬆️',
    era: Era.stellar,
    baseProduction: 600000.0,
    baseCost: 1000000000,
    costMultiplier: 1.16,
    unlockRequirement: 25,
  ),
  GeneratorDataV2(
    id: 'dyson_swarm',
    name: 'Dyson Swarm',
    description: 'Thousands of satellites orbiting the star.',
    icon: '✨',
    era: Era.stellar,
    baseProduction: 3000000.0,
    baseCost: 12000000000,
    costMultiplier: 1.18,
    unlockRequirement: 45,
  ),
  GeneratorDataV2(
    id: 'stellar_forge',
    name: 'Stellar Forge',
    description: 'Manufacture heavy elements using stellar fusion.',
    icon: '🔨',
    era: Era.stellar,
    baseProduction: 15000000.0,
    baseCost: 150000000000,
    costMultiplier: 1.20,
    unlockRequirement: 70,
  ),
  GeneratorDataV2(
    id: 'dyson_sphere',
    name: 'Dyson Sphere',
    description: 'Complete stellar enclosure capturing all output.',
    icon: '🔆',
    era: Era.stellar,
    baseProduction: 100000000.0,
    baseCost: 2000000000000,
    costMultiplier: 1.22,
    unlockRequirement: 100,
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA III - GALACTIC (Kardashev 2.0 - 3.0)
  // ═══════════════════════════════════════════════════════════════
  GeneratorDataV2(
    id: 'neutron_harvester',
    name: 'Neutron Harvester',
    description: 'Extract energy from neutron star rotation.',
    icon: '💫',
    era: Era.galactic,
    baseProduction: 1e12,
    baseCost: 1e16,
    costMultiplier: 1.12,
    unlockRequirement: 0,
  ),
  GeneratorDataV2(
    id: 'penrose_sphere',
    name: 'Penrose Sphere',
    description: 'Harvest rotational energy from black holes.',
    icon: '🕳️',
    era: Era.galactic,
    baseProduction: 5e12,
    baseCost: 1e17,
    costMultiplier: 1.14,
    unlockRequirement: 15,
  ),
  GeneratorDataV2(
    id: 'quasar_tap',
    name: 'Quasar Tap',
    description: 'Channel energy from active galactic nuclei.',
    icon: '💥',
    era: Era.galactic,
    baseProduction: 2.5e13,
    baseCost: 1e18,
    costMultiplier: 1.16,
    unlockRequirement: 35,
  ),
  GeneratorDataV2(
    id: 'stellar_engine',
    name: 'Stellar Engine',
    description: 'Move entire star systems for resource gathering.',
    icon: '🚀',
    era: Era.galactic,
    baseProduction: 1.2e14,
    baseCost: 1e19,
    costMultiplier: 1.18,
    unlockRequirement: 60,
  ),
  GeneratorDataV2(
    id: 'galactic_hub',
    name: 'Galactic Hub',
    description: 'Central nexus connecting all stellar colonies.',
    icon: '🌌',
    era: Era.galactic,
    baseProduction: 6e14,
    baseCost: 1e20,
    costMultiplier: 1.20,
    unlockRequirement: 90,
  ),
  GeneratorDataV2(
    id: 'cosmic_string',
    name: 'Cosmic String Mine',
    description: 'Extract energy from topological defects in spacetime.',
    icon: '〰️',
    era: Era.galactic,
    baseProduction: 3e15,
    baseCost: 1e21,
    costMultiplier: 1.22,
    unlockRequirement: 125,
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA IV - UNIVERSAL (Kardashev 3.0+)
  // ═══════════════════════════════════════════════════════════════
  GeneratorDataV2(
    id: 'vacuum_extractor',
    name: 'Vacuum Extractor',
    description: 'Harvest zero-point energy from quantum vacuum.',
    icon: '🌀',
    era: Era.universal,
    baseProduction: 1e19,
    baseCost: 1e25,
    costMultiplier: 1.12,
    unlockRequirement: 0,
  ),
  GeneratorDataV2(
    id: 'dimensional_rift',
    name: 'Dimensional Rift',
    description: 'Tap energy flowing between parallel universes.',
    icon: '🌈',
    era: Era.universal,
    baseProduction: 5e19,
    baseCost: 1e26,
    costMultiplier: 1.14,
    unlockRequirement: 20,
  ),
  GeneratorDataV2(
    id: 'timeline_harvester',
    name: 'Timeline Harvester',
    description: 'Extract energy from alternate timeline collapse.',
    icon: '⏳',
    era: Era.universal,
    baseProduction: 2.5e20,
    baseCost: 1e27,
    costMultiplier: 1.16,
    unlockRequirement: 50,
  ),
  GeneratorDataV2(
    id: 'reality_engine',
    name: 'Reality Engine',
    description: 'Manipulate fundamental constants for energy.',
    icon: '⚙️',
    era: Era.universal,
    baseProduction: 1.2e21,
    baseCost: 1e28,
    costMultiplier: 1.18,
    unlockRequirement: 85,
  ),
  GeneratorDataV2(
    id: 'entropy_reverser',
    name: 'Entropy Reverser',
    description: 'Locally reverse thermodynamic entropy.',
    icon: '♻️',
    era: Era.universal,
    baseProduction: 6e21,
    baseCost: 1e29,
    costMultiplier: 1.20,
    unlockRequirement: 125,
  ),
  GeneratorDataV2(
    id: 'omniversal_core',
    name: 'Omniversal Core',
    description: 'The ultimate energy source - creation itself.',
    icon: '💎',
    era: Era.universal,
    baseProduction: 1e23,
    baseCost: 1e30,
    costMultiplier: 1.22,
    unlockRequirement: 175,
  ),
];

/// Get generators for a specific era
List<GeneratorDataV2> getGeneratorsForEra(Era era) {
  return allGenerators.where((g) => g.era == era).toList();
}

/// Get generator by ID
GeneratorDataV2? getGeneratorById(String id) {
  try {
    return allGenerators.firstWhere((g) => g.id == id);
  } catch (_) {
    return null;
  }
}

/// Era transition requirements
class EraTransition {
  final Era fromEra;
  final Era toEra;
  final double requiredKardashev;
  final double energyCost;
  final String title;
  final String description;
  final List<String> rewards;
  
  const EraTransition({
    required this.fromEra,
    required this.toEra,
    required this.requiredKardashev,
    required this.energyCost,
    required this.title,
    required this.description,
    required this.rewards,
  });
}

const List<EraTransition> eraTransitions = [
  EraTransition(
    fromEra: Era.planetary,
    toEra: Era.stellar,
    requiredKardashev: 1.0,
    energyCost: 10000000,
    title: 'STELLAR ARK',
    description: 'Launch the Stellar Ark and begin harvesting your star. Your civilization has mastered planetary energy - now reach for the sun itself.',
    rewards: [
      'Unlock 6 Stellar generators',
      'x3 Dark Matter multiplier',
      'x2.5 Prestige bonus',
      'New visual theme: Solar Corona',
    ],
  ),
  EraTransition(
    fromEra: Era.stellar,
    toEra: Era.galactic,
    requiredKardashev: 2.0,
    energyCost: 1e15,
    title: 'GALACTIC EXPANSION',
    description: 'Dispatch colony fleets to neighboring star systems. The Dyson Sphere is complete - now the galaxy awaits.',
    rewards: [
      'Unlock 6 Galactic generators',
      'x15 Dark Matter multiplier',
      'x10 Prestige bonus',
      'New visual theme: Spiral Galaxy',
    ],
  ),
  EraTransition(
    fromEra: Era.galactic,
    toEra: Era.universal,
    requiredKardashev: 3.0,
    energyCost: 1e22,
    title: 'TRANSCENDENCE PROTOCOL',
    description: 'Initiate the Transcendence Protocol. Your civilization spans the galaxy - now reshape reality itself.',
    rewards: [
      'Unlock 6 Universal generators',
      'x100 Dark Matter multiplier',
      'x100 Prestige bonus',
      'New visual theme: Cosmic Web',
    ],
  ),
];

/// Get the transition for moving from current era
EraTransition? getTransitionFromEra(Era currentEra) {
  try {
    return eraTransitions.firstWhere((t) => t.fromEra == currentEra);
  } catch (_) {
    return null;
  }
}

/// Prestige tier bonuses per era
class PrestigeTier {
  final int tier;
  final String name;
  final double requiredKardashev;
  final double productionBonus;
  final double darkMatterReward;
  final String title;
  
  const PrestigeTier({
    required this.tier,
    required this.name,
    required this.requiredKardashev,
    required this.productionBonus,
    required this.darkMatterReward,
    required this.title,
  });
}

const List<PrestigeTier> prestigeTiers = [
  // Era I Prestiges
  PrestigeTier(tier: 1, name: 'Novice Engineer', requiredKardashev: 0.3, productionBonus: 0.05, darkMatterReward: 10, title: 'Novice'),
  PrestigeTier(tier: 2, name: 'Power Architect', requiredKardashev: 0.5, productionBonus: 0.10, darkMatterReward: 25, title: 'Architect'),
  PrestigeTier(tier: 3, name: 'Grid Master', requiredKardashev: 0.7, productionBonus: 0.15, darkMatterReward: 50, title: 'Master'),
  PrestigeTier(tier: 4, name: 'Planetary Lord', requiredKardashev: 0.9, productionBonus: 0.20, darkMatterReward: 100, title: 'Lord'),
  PrestigeTier(tier: 5, name: 'Type I Ascendant', requiredKardashev: 1.0, productionBonus: 0.30, darkMatterReward: 200, title: 'Ascendant'),
  
  // Era II Prestiges
  PrestigeTier(tier: 6, name: 'Solar Pioneer', requiredKardashev: 1.2, productionBonus: 0.40, darkMatterReward: 500, title: 'Pioneer'),
  PrestigeTier(tier: 7, name: 'Dyson Architect', requiredKardashev: 1.5, productionBonus: 0.55, darkMatterReward: 1000, title: 'Architect'),
  PrestigeTier(tier: 8, name: 'Star Forger', requiredKardashev: 1.8, productionBonus: 0.75, darkMatterReward: 2500, title: 'Forger'),
  PrestigeTier(tier: 9, name: 'Type II Ascendant', requiredKardashev: 2.0, productionBonus: 1.00, darkMatterReward: 5000, title: 'Ascendant'),
  
  // Era III Prestiges
  PrestigeTier(tier: 10, name: 'Cosmic Explorer', requiredKardashev: 2.3, productionBonus: 1.50, darkMatterReward: 15000, title: 'Explorer'),
  PrestigeTier(tier: 11, name: 'Singularity Master', requiredKardashev: 2.6, productionBonus: 2.25, darkMatterReward: 50000, title: 'Master'),
  PrestigeTier(tier: 12, name: 'Galactic Emperor', requiredKardashev: 2.9, productionBonus: 3.50, darkMatterReward: 150000, title: 'Emperor'),
  PrestigeTier(tier: 13, name: 'Type III Ascendant', requiredKardashev: 3.0, productionBonus: 5.00, darkMatterReward: 500000, title: 'Ascendant'),
  
  // Era IV Prestiges
  PrestigeTier(tier: 14, name: 'Reality Shaper', requiredKardashev: 3.3, productionBonus: 10.0, darkMatterReward: 2000000, title: 'Shaper'),
  PrestigeTier(tier: 15, name: 'Timeline Weaver', requiredKardashev: 3.6, productionBonus: 25.0, darkMatterReward: 10000000, title: 'Weaver'),
  PrestigeTier(tier: 16, name: 'Entropy Lord', requiredKardashev: 3.9, productionBonus: 50.0, darkMatterReward: 50000000, title: 'Lord'),
  PrestigeTier(tier: 17, name: 'Omniversal God', requiredKardashev: 4.0, productionBonus: 100.0, darkMatterReward: 1000000000, title: 'God'),
];

/// Get the next available prestige tier
PrestigeTier? getNextPrestigeTier(int currentTier, double kardashevLevel) {
  try {
    return prestigeTiers.firstWhere(
      (t) => t.tier > currentTier && kardashevLevel >= t.requiredKardashev,
    );
  } catch (_) {
    return null;
  }
}

/// Get current prestige tier
PrestigeTier? getCurrentPrestigeTier(int tier) {
  try {
    return prestigeTiers.firstWhere((t) => t.tier == tier);
  } catch (_) {
    return null;
  }
}
