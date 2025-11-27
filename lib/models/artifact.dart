import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'artifact.g.dart';

/// Artifact rarity tiers
enum ArtifactRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

/// Extension for artifact rarity properties
extension ArtifactRarityExtension on ArtifactRarity {
  String get displayName {
    switch (this) {
      case ArtifactRarity.common:
        return 'Common';
      case ArtifactRarity.uncommon:
        return 'Uncommon';
      case ArtifactRarity.rare:
        return 'Rare';
      case ArtifactRarity.epic:
        return 'Epic';
      case ArtifactRarity.legendary:
        return 'Legendary';
      case ArtifactRarity.mythic:
        return 'Mythic';
    }
  }
  
  Color get color {
    switch (this) {
      case ArtifactRarity.common:
        return Colors.grey;
      case ArtifactRarity.uncommon:
        return Colors.green;
      case ArtifactRarity.rare:
        return Colors.blue;
      case ArtifactRarity.epic:
        return Colors.purple;
      case ArtifactRarity.legendary:
        return Colors.orange;
      case ArtifactRarity.mythic:
        return Colors.red;
    }
  }
  
  Color get glowColor {
    switch (this) {
      case ArtifactRarity.common:
        return Colors.grey.withValues(alpha: 0.3);
      case ArtifactRarity.uncommon:
        return Colors.green.withValues(alpha: 0.4);
      case ArtifactRarity.rare:
        return Colors.blue.withValues(alpha: 0.5);
      case ArtifactRarity.epic:
        return Colors.purple.withValues(alpha: 0.6);
      case ArtifactRarity.legendary:
        return Colors.orange.withValues(alpha: 0.7);
      case ArtifactRarity.mythic:
        return Colors.red.withValues(alpha: 0.8);
    }
  }
  
  double get dropChance {
    switch (this) {
      case ArtifactRarity.common:
        return 0.40;
      case ArtifactRarity.uncommon:
        return 0.30;
      case ArtifactRarity.rare:
        return 0.15;
      case ArtifactRarity.epic:
        return 0.10;
      case ArtifactRarity.legendary:
        return 0.04;
      case ArtifactRarity.mythic:
        return 0.01;
    }
  }
}

/// Artifact bonus types
enum ArtifactBonusType {
  productionMultiplier,
  tapMultiplier,
  researchSpeed,
  offlineProduction,
  darkMatterBonus,
  expeditionSuccess,
  architectBonus,
  costReduction,
  prestigeBonus,
  energyCapacity,
}

/// Extension for bonus type properties
extension ArtifactBonusTypeExtension on ArtifactBonusType {
  String get displayName {
    switch (this) {
      case ArtifactBonusType.productionMultiplier:
        return 'Production';
      case ArtifactBonusType.tapMultiplier:
        return 'Tap Power';
      case ArtifactBonusType.researchSpeed:
        return 'Research Speed';
      case ArtifactBonusType.offlineProduction:
        return 'Offline Production';
      case ArtifactBonusType.darkMatterBonus:
        return 'Dark Matter';
      case ArtifactBonusType.expeditionSuccess:
        return 'Expedition Success';
      case ArtifactBonusType.architectBonus:
        return 'Architect Power';
      case ArtifactBonusType.costReduction:
        return 'Cost Reduction';
      case ArtifactBonusType.prestigeBonus:
        return 'Prestige Rewards';
      case ArtifactBonusType.energyCapacity:
        return 'Energy Capacity';
    }
  }
  
  IconData get icon {
    switch (this) {
      case ArtifactBonusType.productionMultiplier:
        return Icons.bolt;
      case ArtifactBonusType.tapMultiplier:
        return Icons.touch_app;
      case ArtifactBonusType.researchSpeed:
        return Icons.science;
      case ArtifactBonusType.offlineProduction:
        return Icons.cloud_download;
      case ArtifactBonusType.darkMatterBonus:
        return Icons.dark_mode;
      case ArtifactBonusType.expeditionSuccess:
        return Icons.rocket_launch;
      case ArtifactBonusType.architectBonus:
        return Icons.person;
      case ArtifactBonusType.costReduction:
        return Icons.savings;
      case ArtifactBonusType.prestigeBonus:
        return Icons.auto_awesome;
      case ArtifactBonusType.energyCapacity:
        return Icons.battery_charging_full;
    }
  }
  
  String formatBonus(double value) {
    switch (this) {
      case ArtifactBonusType.productionMultiplier:
      case ArtifactBonusType.tapMultiplier:
      case ArtifactBonusType.researchSpeed:
      case ArtifactBonusType.offlineProduction:
      case ArtifactBonusType.darkMatterBonus:
      case ArtifactBonusType.expeditionSuccess:
      case ArtifactBonusType.architectBonus:
      case ArtifactBonusType.prestigeBonus:
        return '+${(value * 100).toStringAsFixed(1)}%';
      case ArtifactBonusType.costReduction:
        return '-${(value * 100).toStringAsFixed(1)}%';
      case ArtifactBonusType.energyCapacity:
        return '+${(value * 100).toStringAsFixed(0)}%';
    }
  }
}

/// Artifact definition
class Artifact {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String lore;
  final ArtifactRarity rarity;
  final ArtifactBonusType bonusType;
  final double bonusValue;
  final int requiredEra; // 0=I, 1=II, 2=III, 3=IV
  final String? sourceExpedition; // ID of expedition that can drop this
  
  const Artifact({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.lore,
    required this.rarity,
    required this.bonusType,
    required this.bonusValue,
    required this.requiredEra,
    this.sourceExpedition,
  });
  
  /// Get formatted bonus string
  String get bonusDisplay => bonusType.formatBonus(bonusValue);
}

/// Owned artifact instance (with persistence)
@HiveType(typeId: 21)
class OwnedArtifact extends HiveObject {
  @HiveField(0)
  String artifactId;
  
  @HiveField(1)
  DateTime acquiredAt;
  
  @HiveField(2)
  String? acquiredFrom; // Expedition ID or 'prestige' or 'legendary'
  
  @HiveField(3)
  int level; // For upgradeable artifacts (future feature)
  
  @HiveField(4)
  bool isEquipped;
  
  OwnedArtifact({
    required this.artifactId,
    required this.acquiredAt,
    this.acquiredFrom,
    this.level = 1,
    this.isEquipped = true,
  });
  
  /// Get the artifact definition
  Artifact? get artifact => getArtifactById(artifactId);
  
  /// Get effective bonus value (considering level)
  double get effectiveBonusValue {
    final art = artifact;
    if (art == null) return 0;
    return art.bonusValue * (1 + (level - 1) * 0.1); // 10% increase per level
  }
}

// ═══════════════════════════════════════════════════════════════
// ARTIFACT DEFINITIONS - ERA I (Planetary)
// ═══════════════════════════════════════════════════════════════

const List<Artifact> eraIArtifacts = [
  // Common
  Artifact(
    id: 'art_fossil_crystal',
    name: 'Fossil Crystal',
    description: 'An ancient crystalline formation containing preserved energy.',
    emoji: '💎',
    lore: 'Found deep within geological formations, these crystals captured the energy of primordial Earth.',
    rarity: ArtifactRarity.common,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.05, // +5%
    requiredEra: 0,
  ),
  Artifact(
    id: 'art_lightning_rod',
    name: 'Lightning Rod Fragment',
    description: 'A piece of the first lightning rod that captured atmospheric energy.',
    emoji: '⚡',
    lore: 'Benjamin Franklin\'s original experiment led to this breakthrough in energy capture.',
    rarity: ArtifactRarity.common,
    bonusType: ArtifactBonusType.tapMultiplier,
    bonusValue: 0.08, // +8%
    requiredEra: 0,
  ),
  
  // Uncommon
  Artifact(
    id: 'art_geothermal_core',
    name: 'Geothermal Core Sample',
    description: 'A sample from deep within the Earth\'s mantle.',
    emoji: '🌋',
    lore: 'Extracted from volcanic vents, this sample holds immense thermal energy.',
    rarity: ArtifactRarity.uncommon,
    bonusType: ArtifactBonusType.offlineProduction,
    bonusValue: 0.10, // +10%
    requiredEra: 0,
  ),
  Artifact(
    id: 'art_tesla_coil',
    name: 'Tesla Coil Resonator',
    description: 'A component from Tesla\'s wireless energy experiments.',
    emoji: '🔌',
    lore: 'Tesla dreamed of wireless energy transmission. This artifact carries that dream.',
    rarity: ArtifactRarity.uncommon,
    bonusType: ArtifactBonusType.researchSpeed,
    bonusValue: 0.08, // +8%
    requiredEra: 0,
  ),
  
  // Rare
  Artifact(
    id: 'art_nuclear_fragment',
    name: 'Fission Core Fragment',
    description: 'A stabilized fragment from the first nuclear reactor.',
    emoji: '☢️',
    lore: 'From the Chicago Pile-1, humanity\'s first step into the atomic age.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.15, // +15%
    requiredEra: 0,
  ),
  Artifact(
    id: 'art_solar_prism',
    name: 'Solar Prism',
    description: 'A crystalline lens that focuses solar energy.',
    emoji: '🔆',
    lore: 'Ancient civilizations used similar prisms to harness the sun\'s power.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.energyCapacity,
    bonusValue: 0.20, // +20%
    requiredEra: 0,
  ),
  
  // Epic
  Artifact(
    id: 'art_fusion_seed',
    name: 'Fusion Seed',
    description: 'A miniaturized fusion reaction contained in a magnetic bottle.',
    emoji: '💠',
    lore: 'The first successful sustained fusion reaction, captured forever.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.25, // +25%
    requiredEra: 0,
  ),
  Artifact(
    id: 'art_antimatter_vial',
    name: 'Antimatter Vial',
    description: 'A microscopic amount of antimatter in magnetic containment.',
    emoji: '🧪',
    lore: 'The most energy-dense substance known to science, carefully preserved.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.darkMatterBonus,
    bonusValue: 0.15, // +15%
    requiredEra: 0,
  ),
  
  // Legendary
  Artifact(
    id: 'art_kardashev_theorem',
    name: 'Kardashev\'s Theorem',
    description: 'The original manuscript proposing the civilization scale.',
    emoji: '📜',
    lore: 'Nikolai Kardashev\'s vision of cosmic civilizations, a roadmap to ascension.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.prestigeBonus,
    bonusValue: 0.20, // +20%
    requiredEra: 0,
  ),
  Artifact(
    id: 'art_primordial_spark',
    name: 'Primordial Spark',
    description: 'Energy from the moment life first appeared on Earth.',
    emoji: '✨',
    lore: 'The first spark of consciousness, captured in crystalline form.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.40, // +40%
    requiredEra: 0,
    sourceExpedition: 'leg_primordial_engine',
  ),
];

// ═══════════════════════════════════════════════════════════════
// ARTIFACT DEFINITIONS - ERA II (Stellar)
// ═══════════════════════════════════════════════════════════════

const List<Artifact> eraIIArtifacts = [
  // Common
  Artifact(
    id: 'art_solar_flare_essence',
    name: 'Solar Flare Essence',
    description: 'Captured energy from a solar flare event.',
    emoji: '🌞',
    lore: 'The raw power of our star, condensed into portable form.',
    rarity: ArtifactRarity.common,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.08, // +8%
    requiredEra: 1,
  ),
  Artifact(
    id: 'art_stellar_dust',
    name: 'Stellar Dust',
    description: 'Particles from the birth of stars.',
    emoji: '✴️',
    lore: 'Every atom of this dust was forged in the hearts of ancient stars.',
    rarity: ArtifactRarity.common,
    bonusType: ArtifactBonusType.expeditionSuccess,
    bonusValue: 0.05, // +5%
    requiredEra: 1,
  ),
  
  // Uncommon
  Artifact(
    id: 'art_corona_fragment',
    name: 'Corona Fragment',
    description: 'A piece of solidified solar corona.',
    emoji: '👑',
    lore: 'The outermost layer of a star, impossibly contained.',
    rarity: ArtifactRarity.uncommon,
    bonusType: ArtifactBonusType.offlineProduction,
    bonusValue: 0.15, // +15%
    requiredEra: 1,
  ),
  Artifact(
    id: 'art_photon_crystal',
    name: 'Photon Crystal',
    description: 'Light particles crystallized into solid form.',
    emoji: '💡',
    lore: 'Pure photonic energy, frozen in time and space.',
    rarity: ArtifactRarity.uncommon,
    bonusType: ArtifactBonusType.researchSpeed,
    bonusValue: 0.12, // +12%
    requiredEra: 1,
  ),
  
  // Rare
  Artifact(
    id: 'art_dyson_blueprint',
    name: 'Dyson Sphere Blueprint',
    description: 'Original designs for stellar energy collection.',
    emoji: '📐',
    lore: 'Freeman Dyson\'s ambitious plans for capturing a star\'s total output.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.20, // +20%
    requiredEra: 1,
  ),
  Artifact(
    id: 'art_helium_heart',
    name: 'Helium Heart',
    description: 'The fused helium core of a dying star.',
    emoji: '💛',
    lore: 'When hydrogen runs out, stars burn helium. This is that fire.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.architectBonus,
    bonusValue: 0.15, // +15%
    requiredEra: 1,
  ),
  
  // Epic
  Artifact(
    id: 'art_stellar_compass',
    name: 'Stellar Compass',
    description: 'Navigation device aligned to galactic coordinates.',
    emoji: '🧭',
    lore: 'Point to any star, and this compass will guide you there.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.expeditionSuccess,
    bonusValue: 0.20, // +20%
    requiredEra: 1,
  ),
  Artifact(
    id: 'art_plasma_conduit',
    name: 'Plasma Conduit',
    description: 'A channel for directing stellar plasma flows.',
    emoji: '🔥',
    lore: 'Through this conduit flows the lifeblood of stars.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.35, // +35%
    requiredEra: 1,
  ),
  
  // Legendary
  Artifact(
    id: 'art_leviathan_scale',
    name: 'Stellar Leviathan Scale',
    description: 'A scale from the legendary stellar creature.',
    emoji: '🐉',
    lore: 'Proof that the cosmos holds life beyond our imagination.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.50, // +50%
    requiredEra: 1,
    sourceExpedition: 'leg_stellar_leviathan',
  ),
  Artifact(
    id: 'art_stellar_seed',
    name: 'Stellar Seed',
    description: 'The embryonic form of a newborn star.',
    emoji: '🌟',
    lore: 'Given time and gravity, this seed will grow into a sun.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.darkMatterBonus,
    bonusValue: 0.25, // +25%
    requiredEra: 1,
  ),
];

// ═══════════════════════════════════════════════════════════════
// ARTIFACT DEFINITIONS - ERA III (Galactic)
// ═══════════════════════════════════════════════════════════════

const List<Artifact> eraIIIArtifacts = [
  // Common
  Artifact(
    id: 'art_black_hole_dust',
    name: 'Event Horizon Dust',
    description: 'Particles that escaped a black hole\'s grasp.',
    emoji: '🕳️',
    lore: 'Against all odds, these particles resisted oblivion.',
    rarity: ArtifactRarity.common,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.12, // +12%
    requiredEra: 2,
  ),
  
  // Uncommon
  Artifact(
    id: 'art_graviton_cluster',
    name: 'Graviton Cluster',
    description: 'A collection of gravitational force carriers.',
    emoji: '⬛',
    lore: 'The fabric of spacetime, woven into tangible form.',
    rarity: ArtifactRarity.uncommon,
    bonusType: ArtifactBonusType.costReduction,
    bonusValue: 0.10, // -10%
    requiredEra: 2,
  ),
  
  // Rare
  Artifact(
    id: 'art_hawking_radiation',
    name: 'Hawking Radiation Sample',
    description: 'Captured emissions from black hole evaporation.',
    emoji: '🌈',
    lore: 'Stephen Hawking predicted this. Now we hold it.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.researchSpeed,
    bonusValue: 0.20, // +20%
    requiredEra: 2,
  ),
  Artifact(
    id: 'art_dark_matter_shard',
    name: 'Dark Matter Shard',
    description: 'A fragment of the universe\'s invisible mass.',
    emoji: '🌑',
    lore: 'It doesn\'t interact with light, yet here it is, solid in your hand.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.darkMatterBonus,
    bonusValue: 0.20, // +20%
    requiredEra: 2,
  ),
  
  // Epic
  Artifact(
    id: 'art_wormhole_key',
    name: 'Wormhole Key',
    description: 'A device that can stabilize traversable wormholes.',
    emoji: '🔑',
    lore: 'The key to traveling across the galaxy in an instant.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.expeditionSuccess,
    bonusValue: 0.25, // +25%
    requiredEra: 2,
  ),
  Artifact(
    id: 'art_quasar_lens',
    name: 'Quasar Lens',
    description: 'A lens ground from quasar-hardened material.',
    emoji: '🔭',
    lore: 'Through this lens, see the brightest objects in the universe.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.45, // +45%
    requiredEra: 2,
  ),
  
  // Legendary
  Artifact(
    id: 'art_singularity_heart',
    name: 'Singularity Heart',
    description: 'The core of a black hole, impossibly extracted.',
    emoji: '💜',
    lore: 'Where spacetime curves to infinity, this was born.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.60, // +60%
    requiredEra: 2,
    sourceExpedition: 'leg_black_hole_heart',
  ),
  Artifact(
    id: 'art_galactic_map',
    name: 'Complete Galactic Map',
    description: 'A map of every star, planet, and anomaly in the galaxy.',
    emoji: '🗺️',
    lore: 'Knowledge is power, and this is all the knowledge of the galaxy.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.expeditionSuccess,
    bonusValue: 0.30, // +30%
    requiredEra: 2,
  ),
  
  // Mythic (Era III only)
  Artifact(
    id: 'art_sagittarius_tear',
    name: 'Sagittarius A* Tear',
    description: 'A tear in spacetime from the galactic center.',
    emoji: '💎',
    lore: 'The supermassive black hole wept, and we collected its tears.',
    rarity: ArtifactRarity.mythic,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 1.0, // +100%
    requiredEra: 2,
    sourceExpedition: 'exp_sagittarius_approach',
  ),
];

// ═══════════════════════════════════════════════════════════════
// ARTIFACT DEFINITIONS - ERA IV (Universal)
// ═══════════════════════════════════════════════════════════════

const List<Artifact> eraIVArtifacts = [
  // Uncommon
  Artifact(
    id: 'art_void_essence',
    name: 'Void Essence',
    description: 'The substance of empty space between dimensions.',
    emoji: '⚫',
    lore: 'There is no true emptiness. This is proof.',
    rarity: ArtifactRarity.uncommon,
    bonusType: ArtifactBonusType.offlineProduction,
    bonusValue: 0.30, // +30%
    requiredEra: 3,
  ),
  
  // Rare
  Artifact(
    id: 'art_timeline_splinter',
    name: 'Timeline Splinter',
    description: 'A fragment of an alternate timeline.',
    emoji: '⏰',
    lore: 'In another universe, things went differently. This is that difference.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.researchSpeed,
    bonusValue: 0.30, // +30%
    requiredEra: 3,
  ),
  Artifact(
    id: 'art_entropy_crystal',
    name: 'Entropy Crystal',
    description: 'Crystallized entropy, frozen in perpetual decay.',
    emoji: '❄️',
    lore: 'The universe moves toward disorder. This crystal remembers order.',
    rarity: ArtifactRarity.rare,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.35, // +35%
    requiredEra: 3,
  ),
  
  // Epic
  Artifact(
    id: 'art_dimension_key',
    name: 'Dimension Key',
    description: 'Opens doors between parallel universes.',
    emoji: '🗝️',
    lore: 'Turn the key, step through, and find yourself somewhere else entirely.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.expeditionSuccess,
    bonusValue: 0.30, // +30%
    requiredEra: 3,
  ),
  Artifact(
    id: 'art_reality_anchor',
    name: 'Reality Anchor',
    description: 'Maintains coherence across dimensional shifts.',
    emoji: '⚓',
    lore: 'Without this, you might forget which universe is home.',
    rarity: ArtifactRarity.epic,
    bonusType: ArtifactBonusType.prestigeBonus,
    bonusValue: 0.35, // +35%
    requiredEra: 3,
  ),
  
  // Legendary
  Artifact(
    id: 'art_omega_fragment',
    name: 'Omega Fragment',
    description: 'A piece of the final moment of the universe.',
    emoji: 'Ω',
    lore: 'From the end of time, brought back to the present.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 0.75, // +75%
    requiredEra: 3,
    sourceExpedition: 'leg_omega_confrontation',
  ),
  Artifact(
    id: 'art_universal_constant',
    name: 'Universal Constant',
    description: 'The mathematical constant that defines all reality.',
    emoji: '∞',
    lore: 'Some call it God\'s signature. Others call it the cosmic code.',
    rarity: ArtifactRarity.legendary,
    bonusType: ArtifactBonusType.darkMatterBonus,
    bonusValue: 0.40, // +40%
    requiredEra: 3,
  ),
  
  // Mythic
  Artifact(
    id: 'art_creators_eye',
    name: 'Creator\'s Eye',
    description: 'An artifact that sees across all of existence.',
    emoji: '👁️',
    lore: 'To look through this eye is to understand everything, and nothing.',
    rarity: ArtifactRarity.mythic,
    bonusType: ArtifactBonusType.productionMultiplier,
    bonusValue: 1.5, // +150%
    requiredEra: 3,
    sourceExpedition: 'leg_omega_confrontation',
  ),
  Artifact(
    id: 'art_ascension_spark',
    name: 'Ascension Spark',
    description: 'The final piece needed to transcend physical existence.',
    emoji: '🌌',
    lore: 'With this, a civilization becomes something more than matter.',
    rarity: ArtifactRarity.mythic,
    bonusType: ArtifactBonusType.prestigeBonus,
    bonusValue: 0.50, // +50%
    requiredEra: 3,
  ),
];

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

/// Get all artifacts
List<Artifact> get allArtifacts => [
  ...eraIArtifacts,
  ...eraIIArtifacts,
  ...eraIIIArtifacts,
  ...eraIVArtifacts,
];

/// Get artifact by ID
Artifact? getArtifactById(String id) {
  try {
    return allArtifacts.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}

/// Get artifacts for an era
List<Artifact> getArtifactsForEra(int eraIndex) {
  return allArtifacts.where((a) => a.requiredEra <= eraIndex).toList();
}

/// Get artifacts by rarity
List<Artifact> getArtifactsByRarity(ArtifactRarity rarity) {
  return allArtifacts.where((a) => a.rarity == rarity).toList();
}

/// Get artifacts by bonus type
List<Artifact> getArtifactsByBonusType(ArtifactBonusType bonusType) {
  return allArtifacts.where((a) => a.bonusType == bonusType).toList();
}

/// Get artifacts that can drop from an expedition
List<Artifact> getArtifactsForExpedition(String expeditionId, int eraIndex) {
  return allArtifacts.where((a) {
    if (a.requiredEra > eraIndex) return false;
    if (a.sourceExpedition != null) {
      return a.sourceExpedition == expeditionId;
    }
    return true; // General artifacts can drop from any expedition
  }).toList();
}

/// Calculate total bonus from owned artifacts
double calculateTotalBonus(
  List<OwnedArtifact> ownedArtifacts,
  ArtifactBonusType bonusType,
) {
  return ownedArtifacts
      .where((oa) => oa.isEquipped && oa.artifact?.bonusType == bonusType)
      .fold(0.0, (sum, oa) => sum + oa.effectiveBonusValue);
}

/// Roll for artifact drop from expedition
Artifact? rollArtifactDrop(String expeditionId, int eraIndex) {
  final availableArtifacts = getArtifactsForExpedition(expeditionId, eraIndex);
  if (availableArtifacts.isEmpty) return null;
  
  // Calculate total drop chance weight
  final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000.0;
  
  // 30% base chance to get an artifact from expedition
  if (random > 0.30) return null;
  
  // Roll for rarity
  final rarityRoll = (DateTime.now().millisecondsSinceEpoch % 10000) / 10000.0;
  
  ArtifactRarity targetRarity;
  if (rarityRoll < 0.01) {
    targetRarity = ArtifactRarity.mythic;
  } else if (rarityRoll < 0.05) {
    targetRarity = ArtifactRarity.legendary;
  } else if (rarityRoll < 0.15) {
    targetRarity = ArtifactRarity.epic;
  } else if (rarityRoll < 0.30) {
    targetRarity = ArtifactRarity.rare;
  } else if (rarityRoll < 0.55) {
    targetRarity = ArtifactRarity.uncommon;
  } else {
    targetRarity = ArtifactRarity.common;
  }
  
  // Get artifacts of that rarity
  final rarityArtifacts = availableArtifacts
      .where((a) => a.rarity == targetRarity)
      .toList();
  
  if (rarityArtifacts.isEmpty) {
    // Fall back to any available artifact
    final index = DateTime.now().millisecondsSinceEpoch % availableArtifacts.length;
    return availableArtifacts[index];
  }
  
  // Pick random artifact of that rarity
  final index = DateTime.now().millisecondsSinceEpoch % rarityArtifacts.length;
  return rarityArtifacts[index];
}
