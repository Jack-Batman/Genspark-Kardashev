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
    name: 'Nikola Tesla',
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
    name: 'Albert Einstein',
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
    name: 'Marie Curie',
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
    name: 'Freeman Dyson',
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
    name: 'J.R. Oppenheimer',
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
    name: 'Ada Lovelace',
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

/// Get architect by ID
Architect? getArchitectById(String id) {
  try {
    return eraIArchitects.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
