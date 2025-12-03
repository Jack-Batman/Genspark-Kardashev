import '../core/constants.dart';

/// Architect (Gacha Character) Model
class Architect {
  final String id;
  final String name;
  final String title;
  final String description;
  final String imageAsset;
  final ArchitectRarity rarity;
  final String passiveAbility;
  final double passiveBonus;
  final String activeAbility;
  final int activeCooldownMinutes;
  final String era;
  
  const Architect({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.rarity,
    required this.passiveAbility,
    required this.passiveBonus,
    required this.activeAbility,
    required this.activeCooldownMinutes,
    required this.era,
  });
  
  /// Get color based on rarity
  int get rarityColor {
    switch (rarity) {
      case ArchitectRarity.common:
        return 0xFF808080;
      case ArchitectRarity.rare:
        return 0xFF4FC3F7;
      case ArchitectRarity.epic:
        return 0xFFAB47BC;
      case ArchitectRarity.legendary:
        return 0xFFFFD700;
    }
  }
  
  /// Get rarity display name
  String get rarityName {
    switch (rarity) {
      case ArchitectRarity.common:
        return 'Common';
      case ArchitectRarity.rare:
        return 'Rare';
      case ArchitectRarity.epic:
        return 'Epic';
      case ArchitectRarity.legendary:
        return 'Legendary';
    }
  }
}

/// Predefined Architects for Era I
const List<Architect> eraIArchitects = [
  Architect(
    id: 'tesla',
    name: 'Nikolai Teslov',
    title: 'The Lightning Master',
    description: 'Pioneer of alternating current and wireless energy transmission.',
    imageAsset: 'tesla',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'All energy production +25%',
    passiveBonus: 0.25,
    activeAbility: 'Tesla Coil: Instant 2-hour production',
    activeCooldownMinutes: 480,
    era: 'I',
  ),
  Architect(
    id: 'einstein',
    name: 'Dr. Albrecht Einfeld',
    title: 'The Relativity Sage',
    description: 'Unlocked the secrets of mass-energy equivalence.',
    imageAsset: 'einstein',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'Fusion Reactor output +50%',
    passiveBonus: 0.50,
    activeAbility: 'E=mc²: Double all production for 30 min',
    activeCooldownMinutes: 720,
    era: 'I',
  ),
  Architect(
    id: 'curie',
    name: 'Dr. Maria Curien',
    title: 'The Radiant Pioneer',
    description: 'Discovered radioactivity and pioneered nuclear science.',
    imageAsset: 'curie',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Fission Reactor output +35%',
    passiveBonus: 0.35,
    activeAbility: 'Radium Glow: +100% offline earnings for 8 hours',
    activeCooldownMinutes: 480,
    era: 'I',
  ),
  Architect(
    id: 'dyson',
    name: 'Dr. Franklin Dysen',
    title: 'The Sphere Dreamer',
    description: 'Conceptualized megastructures to harness stellar energy.',
    imageAsset: 'dyson',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Orbital Collector output +40%',
    passiveBonus: 0.40,
    activeAbility: 'Dyson Vision: Unlock next generator early',
    activeCooldownMinutes: 1440,
    era: 'I',
  ),
  Architect(
    id: 'oppenheimer',
    name: 'Dr. J.R. Oppenfield',
    title: 'The Atom Splitter',
    description: 'Led the development of nuclear energy applications.',
    imageAsset: 'oppenheimer',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'All reactor types +20%',
    passiveBonus: 0.20,
    activeAbility: 'Chain Reaction: Burst of 1-hour production',
    activeCooldownMinutes: 240,
    era: 'I',
  ),
  Architect(
    id: 'lovelace',
    name: 'Lady Ada Lovell',
    title: 'The Algorithm Weaver',
    description: 'First computer programmer, optimizes energy distribution.',
    imageAsset: 'lovelace',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Automation efficiency +30%',
    passiveBonus: 0.30,
    activeAbility: 'Optimize Grid: -20% upgrade costs for 1 hour',
    activeCooldownMinutes: 360,
    era: 'I',
  ),
  Architect(
    id: 'engineer_alpha',
    name: 'Chief Engineer',
    title: 'The Builder',
    description: 'A skilled engineer with broad expertise.',
    imageAsset: 'engineer',
    rarity: ArchitectRarity.common,
    passiveAbility: 'All production +10%',
    passiveBonus: 0.10,
    activeAbility: 'Quick Build: Instant generator purchase',
    activeCooldownMinutes: 120,
    era: 'I',
  ),
  Architect(
    id: 'scientist_alpha',
    name: 'Research Lead',
    title: 'The Scholar',
    description: 'A dedicated scientist pushing boundaries.',
    imageAsset: 'scientist',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Research speed +15%',
    passiveBonus: 0.15,
    activeAbility: 'Eureka: Complete current research instantly',
    activeCooldownMinutes: 180,
    era: 'I',
  ),
];

/// Predefined Architects for Era II (Stellar)
const List<Architect> eraIIArchitects = [
  Architect(
    id: 'dyson_ii',
    name: 'Franklin Dysen II',
    title: 'The Sphere Builder',
    description: 'Evolved beyond theory to construct the first complete stellar sphere.',
    imageAsset: 'dyson_ii',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'Dyson structures +50%',
    passiveBonus: 0.50,
    activeAbility: 'Solar Embrace: Triple solar collection for 1 hour',
    activeCooldownMinutes: 720,
    era: 'II',
  ),
  Architect(
    id: 'kardashev',
    name: 'Dr. Nikolai Kardash',
    title: 'The Scale Maker',
    description: 'His vision guides civilizations to stellar mastery.',
    imageAsset: 'kardashev',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'All stellar production +35%',
    passiveBonus: 0.35,
    activeAbility: 'Ascension Boost: +50% Kardashev progress for 2 hours',
    activeCooldownMinutes: 960,
    era: 'II',
  ),
  Architect(
    id: 'sagan',
    name: 'Dr. Karl Saganov',
    title: 'The Cosmic Visionary',
    description: 'Inspired billions to look to the stars.',
    imageAsset: 'sagan',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Research speed +40%',
    passiveBonus: 0.40,
    activeAbility: 'Pale Blue Dot: Reveal all hidden bonuses for 1 hour',
    activeCooldownMinutes: 480,
    era: 'II',
  ),
  Architect(
    id: 'von_neumann',
    name: 'Dr. Johann Neuman',
    title: 'The Self-Replicator',
    description: 'Pioneer of self-replicating machines and automation.',
    imageAsset: 'von_neumann',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Swarm units +45%',
    passiveBonus: 0.45,
    activeAbility: 'Replication Wave: Free x10 swarm satellites',
    activeCooldownMinutes: 600,
    era: 'II',
  ),
  Architect(
    id: 'oberth',
    name: 'Dr. Herman Oberlin',
    title: 'The Rocket Pioneer',
    description: 'Father of astronautics and space propulsion.',
    imageAsset: 'oberth',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Launch costs -25%',
    passiveBonus: 0.25,
    activeAbility: 'Orbital Insertion: Instant satellite deployment',
    activeCooldownMinutes: 300,
    era: 'II',
  ),
  Architect(
    id: 'tsiolkovsky',
    name: 'Dr. Konstantine Tsiolkov',
    title: 'The Space Prophet',
    description: 'Dreamed of humanity among the stars.',
    imageAsset: 'tsiolkovsky',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Stellar efficiency +30%',
    passiveBonus: 0.30,
    activeAbility: 'Cosmic Dream: +100% offline stellar earnings for 6 hours',
    activeCooldownMinutes: 360,
    era: 'II',
  ),
  Architect(
    id: 'stellar_engineer',
    name: 'Stellar Engineer',
    title: 'The Sun Tamer',
    description: 'Expert in harnessing solar energy at massive scales.',
    imageAsset: 'stellar_eng',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Solar collectors +15%',
    passiveBonus: 0.15,
    activeAbility: 'Solar Flare: Burst of stellar energy',
    activeCooldownMinutes: 150,
    era: 'II',
  ),
  Architect(
    id: 'swarm_coordinator',
    name: 'Swarm Coordinator',
    title: 'The Hive Mind',
    description: 'Manages millions of orbital units in perfect harmony.',
    imageAsset: 'swarm_coord',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Automation +12%',
    passiveBonus: 0.12,
    activeAbility: 'Sync Pulse: Optimize all swarms for 30 minutes',
    activeCooldownMinutes: 180,
    era: 'II',
  ),
];

/// Predefined Architects for Era III (Galactic)
const List<Architect> eraIIIArchitects = [
  Architect(
    id: 'hawking',
    name: 'Dr. Stefan Hawkins',
    title: 'The Black Hole Whisperer',
    description: 'Unlocked the secrets of singularity radiation and black holes.',
    imageAsset: 'hawking',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'Black hole energy +60%',
    passiveBonus: 0.60,
    activeAbility: 'Singularity Tap: Instant 6-hour production',
    activeCooldownMinutes: 1080,
    era: 'III',
  ),
  Architect(
    id: 'penrose',
    name: 'Dr. Roland Penrow',
    title: 'The Geometry Master',
    description: 'Proved black holes could be used as energy sources.',
    imageAsset: 'penrose',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'Penrose process +55%',
    passiveBonus: 0.55,
    activeAbility: 'Ergosphere Harvest: x5 black hole output for 1 hour',
    activeCooldownMinutes: 900,
    era: 'III',
  ),
  Architect(
    id: 'thorne',
    name: 'Dr. Kiran Thornwell',
    title: 'The Wormhole Architect',
    description: 'Pioneer of traversable wormhole theory.',
    imageAsset: 'thorne',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Wormhole efficiency +45%',
    passiveBonus: 0.45,
    activeAbility: 'Warp Gate: Instant resource transfer across galaxy',
    activeCooldownMinutes: 600,
    era: 'III',
  ),
  Architect(
    id: 'chandrasekhar',
    name: 'Dr. Subram Chandra',
    title: 'The Stellar Corpse Expert',
    description: 'Understood the ultimate fate of massive stars.',
    imageAsset: 'chandra',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Neutron star harvesting +50%',
    passiveBonus: 0.50,
    activeAbility: 'Pulsar Beam: Concentrated energy burst',
    activeCooldownMinutes: 540,
    era: 'III',
  ),
  Architect(
    id: 'vera_rubin',
    name: 'Dr. Vera Ruben',
    title: 'The Dark Matter Seer',
    description: 'Discovered the influence of dark matter on galaxies.',
    imageAsset: 'rubin',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Dark matter gains +35%',
    passiveBonus: 0.35,
    activeAbility: 'Dark Insight: Double dark matter for 2 hours',
    activeCooldownMinutes: 420,
    era: 'III',
  ),
  Architect(
    id: 'jocelyn_bell',
    name: 'Dr. Joceline Burnette',
    title: 'The Pulsar Finder',
    description: 'Discovered the first pulsars, opening new energy frontiers.',
    imageAsset: 'bell',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Exotic star output +30%',
    passiveBonus: 0.30,
    activeAbility: 'Signal Boost: +50% all production for 45 minutes',
    activeCooldownMinutes: 360,
    era: 'III',
  ),
  Architect(
    id: 'galactic_commander',
    name: 'Galactic Commander',
    title: 'The Fleet Admiral',
    description: 'Coordinates civilization across thousands of star systems.',
    imageAsset: 'gal_commander',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Fleet efficiency +15%',
    passiveBonus: 0.15,
    activeAbility: 'Rally Fleet: Speed boost to all operations',
    activeCooldownMinutes: 180,
    era: 'III',
  ),
  Architect(
    id: 'singularity_priest',
    name: 'Singularity Priest',
    title: 'The Void Walker',
    description: 'Devoted to understanding the nature of black holes.',
    imageAsset: 'void_priest',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Singularity output +12%',
    passiveBonus: 0.12,
    activeAbility: 'Void Meditation: Enhanced offline gains',
    activeCooldownMinutes: 200,
    era: 'III',
  ),
];

/// Predefined Architects for Era IV (Universal)
const List<Architect> eraIVArchitects = [
  Architect(
    id: 'omega',
    name: 'The Omega',
    title: 'The Final Intelligence',
    description: 'An AI that has transcended physical form to manipulate reality.',
    imageAsset: 'omega',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'All universal production +75%',
    passiveBonus: 0.75,
    activeAbility: 'Reality Override: x10 production for 30 minutes',
    activeCooldownMinutes: 1440,
    era: 'IV',
  ),
  Architect(
    id: 'eternus',
    name: 'Eternus Prime',
    title: 'The Time Lord',
    description: 'Exists simultaneously across all timelines.',
    imageAsset: 'eternus',
    rarity: ArchitectRarity.legendary,
    passiveAbility: 'Timeline harvesting +70%',
    passiveBonus: 0.70,
    activeAbility: 'Temporal Fold: Gain 12 hours of production instantly',
    activeCooldownMinutes: 1200,
    era: 'IV',
  ),
  Architect(
    id: 'architect_prime',
    name: 'The Architect',
    title: 'The Reality Weaver',
    description: 'Can reshape the fundamental constants of reality.',
    imageAsset: 'architect_prime',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Reality engine output +55%',
    passiveBonus: 0.55,
    activeAbility: 'Constant Shift: Temporarily improve physics for production',
    activeCooldownMinutes: 720,
    era: 'IV',
  ),
  Architect(
    id: 'entropy_keeper',
    name: 'Entropy Keeper',
    title: 'The Order Bringer',
    description: 'Maintains pockets of reversed entropy throughout the cosmos.',
    imageAsset: 'entropy_keeper',
    rarity: ArchitectRarity.epic,
    passiveAbility: 'Entropy reversal +50%',
    passiveBonus: 0.50,
    activeAbility: 'Order Restoration: Reverse local entropy for massive gains',
    activeCooldownMinutes: 660,
    era: 'IV',
  ),
  Architect(
    id: 'void_walker',
    name: 'Void Walker',
    title: 'The Nothing Traveler',
    description: 'Traverses the space between universes.',
    imageAsset: 'void_walker',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Dimensional rift output +40%',
    passiveBonus: 0.40,
    activeAbility: 'Void Step: Access hidden energy reserves',
    activeCooldownMinutes: 480,
    era: 'IV',
  ),
  Architect(
    id: 'quantum_sage',
    name: 'Quantum Sage',
    title: 'The Probability Master',
    description: 'Manipulates quantum probability for favorable outcomes.',
    imageAsset: 'quantum_sage',
    rarity: ArchitectRarity.rare,
    passiveAbility: 'Vacuum extraction +35%',
    passiveBonus: 0.35,
    activeAbility: 'Probability Collapse: Guarantee success on next action',
    activeCooldownMinutes: 420,
    era: 'IV',
  ),
  Architect(
    id: 'cosmic_initiate',
    name: 'Cosmic Initiate',
    title: 'The Apprentice',
    description: 'A being learning to manipulate universal forces.',
    imageAsset: 'cosmic_init',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Universal production +15%',
    passiveBonus: 0.15,
    activeAbility: 'Cosmic Touch: Brief production boost',
    activeCooldownMinutes: 180,
    era: 'IV',
  ),
  Architect(
    id: 'multiverse_scout',
    name: 'Multiverse Scout',
    title: 'The Explorer',
    description: 'Maps the infinite branches of reality.',
    imageAsset: 'multi_scout',
    rarity: ArchitectRarity.common,
    passiveAbility: 'Exploration bonus +12%',
    passiveBonus: 0.12,
    activeAbility: 'Reality Scan: Discover bonus resources',
    activeCooldownMinutes: 200,
    era: 'IV',
  ),
];

/// All architects across all eras
List<Architect> get allArchitects => [
  ...eraIArchitects,
  ...eraIIArchitects,
  ...eraIIIArchitects,
  ...eraIVArchitects,
];

/// Get architects for a specific era
List<Architect> getArchitectsForEra(String era) {
  switch (era) {
    case 'I':
      return eraIArchitects;
    case 'II':
      return eraIIArchitects;
    case 'III':
      return eraIIIArchitects;
    case 'IV':
      return eraIVArchitects;
    default:
      return eraIArchitects;
  }
}

/// Get architect by ID (searches all eras)
Architect? getArchitectById(String id) {
  try {
    return allArchitects.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
