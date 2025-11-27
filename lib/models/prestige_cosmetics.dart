import 'package:flutter/material.dart';
import '../core/era_data.dart';

/// Prestige cosmetic types that can be unlocked
enum CosmeticType {
  border,
  badge,
  title,
  background,
  particleEffect,
}

/// Rarity levels for cosmetics
enum CosmeticRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

/// Extension for rarity colors and names
extension CosmeticRarityExt on CosmeticRarity {
  String get displayName {
    switch (this) {
      case CosmeticRarity.common:
        return 'Common';
      case CosmeticRarity.uncommon:
        return 'Uncommon';
      case CosmeticRarity.rare:
        return 'Rare';
      case CosmeticRarity.epic:
        return 'Epic';
      case CosmeticRarity.legendary:
        return 'Legendary';
      case CosmeticRarity.mythic:
        return 'Mythic';
    }
  }

  Color get color {
    switch (this) {
      case CosmeticRarity.common:
        return Colors.grey;
      case CosmeticRarity.uncommon:
        return Colors.green;
      case CosmeticRarity.rare:
        return Colors.blue;
      case CosmeticRarity.epic:
        return Colors.purple;
      case CosmeticRarity.legendary:
        return Colors.orange;
      case CosmeticRarity.mythic:
        return const Color(0xFFFF1493); // Deep pink/magenta
    }
  }
  
  List<Color> get gradientColors {
    switch (this) {
      case CosmeticRarity.common:
        return [Colors.grey.shade600, Colors.grey.shade400];
      case CosmeticRarity.uncommon:
        return [Colors.green.shade700, Colors.green.shade400];
      case CosmeticRarity.rare:
        return [Colors.blue.shade700, Colors.cyan.shade400];
      case CosmeticRarity.epic:
        return [Colors.purple.shade700, Colors.purple.shade400];
      case CosmeticRarity.legendary:
        return [Colors.orange.shade700, Colors.amber.shade400];
      case CosmeticRarity.mythic:
        return [const Color(0xFFFF1493), const Color(0xFFFFD700)];
    }
  }
}

/// A prestige cosmetic item (border, badge, etc.)
class PrestigeCosmetic {
  final String id;
  final String name;
  final String description;
  final CosmeticType type;
  final CosmeticRarity rarity;
  final int requiredPrestigeTier;
  final String? icon; // Emoji or icon code
  final List<Color>? colors; // For gradients/borders
  
  const PrestigeCosmetic({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.requiredPrestigeTier,
    this.icon,
    this.colors,
  });
}

/// Prestige milestone with visual progression
class PrestigeMilestone {
  final int tier;
  final String name;
  final String title; // Short display title
  final String description;
  final double requiredKardashev;
  final List<PrestigeCosmetic> rewards;
  final Color primaryColor;
  final Color accentColor;
  final String emoji;
  final Era era; // Which era this milestone belongs to
  
  const PrestigeMilestone({
    required this.tier,
    required this.name,
    required this.title,
    required this.description,
    required this.requiredKardashev,
    required this.rewards,
    required this.primaryColor,
    required this.accentColor,
    required this.emoji,
    required this.era,
  });
}

// Era enum is imported from era_data.dart

// ═══════════════════════════════════════════════════════════════
// PRESTIGE BORDERS
// ═══════════════════════════════════════════════════════════════

const List<PrestigeCosmetic> prestigeBorders = [
  // Era I Borders
  PrestigeCosmetic(
    id: 'border_novice',
    name: 'Copper Frame',
    description: 'A simple copper border for beginners',
    type: CosmeticType.border,
    rarity: CosmeticRarity.common,
    requiredPrestigeTier: 1,
    colors: [Color(0xFFB87333), Color(0xFFCD7F32)],
  ),
  PrestigeCosmetic(
    id: 'border_architect',
    name: 'Bronze Frame',
    description: 'A sturdy bronze border',
    type: CosmeticType.border,
    rarity: CosmeticRarity.common,
    requiredPrestigeTier: 2,
    colors: [Color(0xFFCD7F32), Color(0xFFD4A574)],
  ),
  PrestigeCosmetic(
    id: 'border_master',
    name: 'Silver Frame',
    description: 'A polished silver border',
    type: CosmeticType.border,
    rarity: CosmeticRarity.uncommon,
    requiredPrestigeTier: 3,
    colors: [Color(0xFFC0C0C0), Color(0xFFE8E8E8)],
  ),
  PrestigeCosmetic(
    id: 'border_lord',
    name: 'Gold Frame',
    description: 'A prestigious gold border',
    type: CosmeticType.border,
    rarity: CosmeticRarity.uncommon,
    requiredPrestigeTier: 4,
    colors: [Color(0xFFFFD700), Color(0xFFFFC125)],
  ),
  PrestigeCosmetic(
    id: 'border_ascendant_i',
    name: 'Planetary Aura',
    description: 'A glowing border infused with planetary energy',
    type: CosmeticType.border,
    rarity: CosmeticRarity.rare,
    requiredPrestigeTier: 5,
    colors: [Color(0xFF4169E1), Color(0xFF00CED1)],
  ),
  
  // Era II Borders
  PrestigeCosmetic(
    id: 'border_pioneer',
    name: 'Solar Halo',
    description: 'A border radiating solar energy',
    type: CosmeticType.border,
    rarity: CosmeticRarity.rare,
    requiredPrestigeTier: 6,
    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
  ),
  PrestigeCosmetic(
    id: 'border_dyson',
    name: 'Dyson Ring',
    description: 'A border resembling a Dyson structure',
    type: CosmeticType.border,
    rarity: CosmeticRarity.epic,
    requiredPrestigeTier: 7,
    colors: [Color(0xFFFF6347), Color(0xFFFF8C00)],
  ),
  PrestigeCosmetic(
    id: 'border_forger',
    name: 'Stellar Corona',
    description: 'A border pulsing with stellar fire',
    type: CosmeticType.border,
    rarity: CosmeticRarity.epic,
    requiredPrestigeTier: 8,
    colors: [Color(0xFFFFFF00), Color(0xFFFF4500)],
  ),
  PrestigeCosmetic(
    id: 'border_ascendant_ii',
    name: 'Type II Ascension',
    description: 'A border of pure stellar energy',
    type: CosmeticType.border,
    rarity: CosmeticRarity.legendary,
    requiredPrestigeTier: 9,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
  ),
  
  // Era III Borders
  PrestigeCosmetic(
    id: 'border_explorer',
    name: 'Cosmic Nebula',
    description: 'A border swirling with cosmic dust',
    type: CosmeticType.border,
    rarity: CosmeticRarity.legendary,
    requiredPrestigeTier: 10,
    colors: [Color(0xFF9400D3), Color(0xFF4B0082)],
  ),
  PrestigeCosmetic(
    id: 'border_singularity',
    name: 'Event Horizon',
    description: 'A border at the edge of a black hole',
    type: CosmeticType.border,
    rarity: CosmeticRarity.legendary,
    requiredPrestigeTier: 11,
    colors: [Color(0xFF000000), Color(0xFF8A2BE2)],
  ),
  PrestigeCosmetic(
    id: 'border_emperor',
    name: 'Galactic Crown',
    description: 'A border worthy of a galactic ruler',
    type: CosmeticType.border,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 12,
    colors: [Color(0xFFDA70D6), Color(0xFFFFD700)],
  ),
  PrestigeCosmetic(
    id: 'border_ascendant_iii',
    name: 'Type III Transcendence',
    description: 'A border of galactic consciousness',
    type: CosmeticType.border,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 13,
    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
  ),
  
  // Era IV Borders
  PrestigeCosmetic(
    id: 'border_shaper',
    name: 'Reality Distortion',
    description: 'A border that bends reality itself',
    type: CosmeticType.border,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 14,
    colors: [Color(0xFF7B68EE), Color(0xFF00FA9A)],
  ),
  PrestigeCosmetic(
    id: 'border_weaver',
    name: 'Timeline Threads',
    description: 'A border woven from time itself',
    type: CosmeticType.border,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 15,
    colors: [Color(0xFF20B2AA), Color(0xFFFFD700)],
  ),
  PrestigeCosmetic(
    id: 'border_entropy',
    name: 'Entropy Shield',
    description: 'A border that defies the laws of thermodynamics',
    type: CosmeticType.border,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 16,
    colors: [Color(0xFF2F4F4F), Color(0xFFE0FFFF)],
  ),
  PrestigeCosmetic(
    id: 'border_god',
    name: 'Omniversal Radiance',
    description: 'The ultimate border, transcending all existence',
    type: CosmeticType.border,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 17,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFD700), Color(0xFFFF1493)],
  ),
];

// ═══════════════════════════════════════════════════════════════
// PRESTIGE BADGES
// ═══════════════════════════════════════════════════════════════

const List<PrestigeCosmetic> prestigeBadges = [
  // Era I Badges
  PrestigeCosmetic(
    id: 'badge_novice',
    name: 'Apprentice Badge',
    description: 'Your first step on the cosmic journey',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.common,
    requiredPrestigeTier: 1,
    icon: '⚙️',
  ),
  PrestigeCosmetic(
    id: 'badge_architect',
    name: 'Builder Badge',
    description: 'Proof of your engineering prowess',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.common,
    requiredPrestigeTier: 2,
    icon: '🔧',
  ),
  PrestigeCosmetic(
    id: 'badge_master',
    name: 'Master Badge',
    description: 'Recognition of mastery',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.uncommon,
    requiredPrestigeTier: 3,
    icon: '🏆',
  ),
  PrestigeCosmetic(
    id: 'badge_lord',
    name: 'Planetary Seal',
    description: 'Ruler of your world',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.uncommon,
    requiredPrestigeTier: 4,
    icon: '🌍',
  ),
  PrestigeCosmetic(
    id: 'badge_ascendant_i',
    name: 'Type I Emblem',
    description: 'You have mastered planetary energy',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.rare,
    requiredPrestigeTier: 5,
    icon: '⚡',
  ),
  
  // Era II Badges
  PrestigeCosmetic(
    id: 'badge_pioneer',
    name: 'Solar Pioneer',
    description: 'First to reach for the stars',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.rare,
    requiredPrestigeTier: 6,
    icon: '🚀',
  ),
  PrestigeCosmetic(
    id: 'badge_dyson',
    name: 'Dyson Badge',
    description: 'Architect of megastructures',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.epic,
    requiredPrestigeTier: 7,
    icon: '☀️',
  ),
  PrestigeCosmetic(
    id: 'badge_forger',
    name: 'Star Forger Crest',
    description: 'Creator of stellar energy',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.epic,
    requiredPrestigeTier: 8,
    icon: '🔥',
  ),
  PrestigeCosmetic(
    id: 'badge_ascendant_ii',
    name: 'Type II Emblem',
    description: 'Master of stellar energy',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.legendary,
    requiredPrestigeTier: 9,
    icon: '⭐',
  ),
  
  // Era III Badges
  PrestigeCosmetic(
    id: 'badge_explorer',
    name: 'Cosmic Explorer',
    description: 'Traveler of the cosmos',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.legendary,
    requiredPrestigeTier: 10,
    icon: '🌌',
  ),
  PrestigeCosmetic(
    id: 'badge_singularity',
    name: 'Singularity Mark',
    description: 'Touched the event horizon',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.legendary,
    requiredPrestigeTier: 11,
    icon: '🕳️',
  ),
  PrestigeCosmetic(
    id: 'badge_emperor',
    name: 'Imperial Crown',
    description: 'Emperor of the galaxy',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 12,
    icon: '👑',
  ),
  PrestigeCosmetic(
    id: 'badge_ascendant_iii',
    name: 'Type III Emblem',
    description: 'Controller of galactic energy',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 13,
    icon: '🌠',
  ),
  
  // Era IV Badges
  PrestigeCosmetic(
    id: 'badge_shaper',
    name: 'Reality Shaper',
    description: 'Bender of existence',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 14,
    icon: '🔮',
  ),
  PrestigeCosmetic(
    id: 'badge_weaver',
    name: 'Timeline Weaver',
    description: 'Master of temporal threads',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 15,
    icon: '⏳',
  ),
  PrestigeCosmetic(
    id: 'badge_entropy',
    name: 'Entropy Seal',
    description: 'Defier of cosmic decay',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 16,
    icon: '♾️',
  ),
  PrestigeCosmetic(
    id: 'badge_god',
    name: 'Omniversal Sigil',
    description: 'Beyond all existence',
    type: CosmeticType.badge,
    rarity: CosmeticRarity.mythic,
    requiredPrestigeTier: 17,
    icon: '✨',
  ),
];

// ═══════════════════════════════════════════════════════════════
// PRESTIGE MILESTONES (with all rewards)
// ═══════════════════════════════════════════════════════════════

final List<PrestigeMilestone> prestigeMilestones = [
  // Era I Milestones
  PrestigeMilestone(
    tier: 1,
    name: 'Novice Engineer',
    title: 'Novice',
    description: 'Begin your journey to cosmic power',
    requiredKardashev: 0.3,
    rewards: [prestigeBorders[0], prestigeBadges[0]],
    primaryColor: const Color(0xFFB87333),
    accentColor: const Color(0xFFCD7F32),
    emoji: '⚙️',
    era: Era.planetary,
  ),
  PrestigeMilestone(
    tier: 2,
    name: 'Power Architect',
    title: 'Architect',
    description: 'Design the infrastructure of tomorrow',
    requiredKardashev: 0.5,
    rewards: [prestigeBorders[1], prestigeBadges[1]],
    primaryColor: const Color(0xFFCD7F32),
    accentColor: const Color(0xFFD4A574),
    emoji: '🔧',
    era: Era.planetary,
  ),
  PrestigeMilestone(
    tier: 3,
    name: 'Grid Master',
    title: 'Master',
    description: 'Command the power grid of nations',
    requiredKardashev: 0.7,
    rewards: [prestigeBorders[2], prestigeBadges[2]],
    primaryColor: const Color(0xFFC0C0C0),
    accentColor: const Color(0xFFE8E8E8),
    emoji: '🏆',
    era: Era.planetary,
  ),
  PrestigeMilestone(
    tier: 4,
    name: 'Planetary Lord',
    title: 'Lord',
    description: 'Rule the energy of your world',
    requiredKardashev: 0.9,
    rewards: [prestigeBorders[3], prestigeBadges[3]],
    primaryColor: const Color(0xFFFFD700),
    accentColor: const Color(0xFFFFC125),
    emoji: '🌍',
    era: Era.planetary,
  ),
  PrestigeMilestone(
    tier: 5,
    name: 'Type I Ascendant',
    title: 'Ascendant',
    description: 'Achieve planetary civilization status',
    requiredKardashev: 1.0,
    rewards: [prestigeBorders[4], prestigeBadges[4]],
    primaryColor: const Color(0xFF4169E1),
    accentColor: const Color(0xFF00CED1),
    emoji: '⚡',
    era: Era.planetary,
  ),
  
  // Era II Milestones
  PrestigeMilestone(
    tier: 6,
    name: 'Solar Pioneer',
    title: 'Pioneer',
    description: 'First steps into stellar energy',
    requiredKardashev: 1.2,
    rewards: [prestigeBorders[5], prestigeBadges[5]],
    primaryColor: const Color(0xFFFF8C00),
    accentColor: const Color(0xFFFFD700),
    emoji: '🚀',
    era: Era.stellar,
  ),
  PrestigeMilestone(
    tier: 7,
    name: 'Dyson Architect',
    title: 'Dyson',
    description: 'Build structures around stars',
    requiredKardashev: 1.5,
    rewards: [prestigeBorders[6], prestigeBadges[6]],
    primaryColor: const Color(0xFFFF6347),
    accentColor: const Color(0xFFFF8C00),
    emoji: '☀️',
    era: Era.stellar,
  ),
  PrestigeMilestone(
    tier: 8,
    name: 'Star Forger',
    title: 'Forger',
    description: 'Harness the full power of stars',
    requiredKardashev: 1.8,
    rewards: [prestigeBorders[7], prestigeBadges[7]],
    primaryColor: const Color(0xFFFFFF00),
    accentColor: const Color(0xFFFF4500),
    emoji: '🔥',
    era: Era.stellar,
  ),
  PrestigeMilestone(
    tier: 9,
    name: 'Type II Ascendant',
    title: 'Stellar',
    description: 'Achieve stellar civilization status',
    requiredKardashev: 2.0,
    rewards: [prestigeBorders[8], prestigeBadges[8]],
    primaryColor: const Color(0xFFFF6B6B),
    accentColor: const Color(0xFFFFE66D),
    emoji: '⭐',
    era: Era.stellar,
  ),
  
  // Era III Milestones
  PrestigeMilestone(
    tier: 10,
    name: 'Cosmic Explorer',
    title: 'Explorer',
    description: 'Navigate the vastness of space',
    requiredKardashev: 2.3,
    rewards: [prestigeBorders[9], prestigeBadges[9]],
    primaryColor: const Color(0xFF9400D3),
    accentColor: const Color(0xFF4B0082),
    emoji: '🌌',
    era: Era.galactic,
  ),
  PrestigeMilestone(
    tier: 11,
    name: 'Singularity Master',
    title: 'Singularity',
    description: 'Command the power of black holes',
    requiredKardashev: 2.6,
    rewards: [prestigeBorders[10], prestigeBadges[10]],
    primaryColor: const Color(0xFF000000),
    accentColor: const Color(0xFF8A2BE2),
    emoji: '🕳️',
    era: Era.galactic,
  ),
  PrestigeMilestone(
    tier: 12,
    name: 'Galactic Emperor',
    title: 'Emperor',
    description: 'Rule an entire galaxy',
    requiredKardashev: 2.9,
    rewards: [prestigeBorders[11], prestigeBadges[11]],
    primaryColor: const Color(0xFFDA70D6),
    accentColor: const Color(0xFFFFD700),
    emoji: '👑',
    era: Era.galactic,
  ),
  PrestigeMilestone(
    tier: 13,
    name: 'Type III Ascendant',
    title: 'Galactic',
    description: 'Achieve galactic civilization status',
    requiredKardashev: 3.0,
    rewards: [prestigeBorders[12], prestigeBadges[12]],
    primaryColor: const Color(0xFF00FFFF),
    accentColor: const Color(0xFFFF00FF),
    emoji: '🌠',
    era: Era.galactic,
  ),
  
  // Era IV Milestones
  PrestigeMilestone(
    tier: 14,
    name: 'Reality Shaper',
    title: 'Shaper',
    description: 'Bend the fabric of reality',
    requiredKardashev: 3.3,
    rewards: [prestigeBorders[13], prestigeBadges[13]],
    primaryColor: const Color(0xFF7B68EE),
    accentColor: const Color(0xFF00FA9A),
    emoji: '🔮',
    era: Era.universal,
  ),
  PrestigeMilestone(
    tier: 15,
    name: 'Timeline Weaver',
    title: 'Weaver',
    description: 'Manipulate the flow of time',
    requiredKardashev: 3.6,
    rewards: [prestigeBorders[14], prestigeBadges[14]],
    primaryColor: const Color(0xFF20B2AA),
    accentColor: const Color(0xFFFFD700),
    emoji: '⏳',
    era: Era.universal,
  ),
  PrestigeMilestone(
    tier: 16,
    name: 'Entropy Lord',
    title: 'Entropy',
    description: 'Defy the heat death of the universe',
    requiredKardashev: 3.9,
    rewards: [prestigeBorders[15], prestigeBadges[15]],
    primaryColor: const Color(0xFF2F4F4F),
    accentColor: const Color(0xFFE0FFFF),
    emoji: '♾️',
    era: Era.universal,
  ),
  PrestigeMilestone(
    tier: 17,
    name: 'Omniversal God',
    title: 'God',
    description: 'Transcend all existence',
    requiredKardashev: 4.0,
    rewards: [prestigeBorders[16], prestigeBadges[16]],
    primaryColor: const Color(0xFFFFFFFF),
    accentColor: const Color(0xFFFFD700),
    emoji: '✨',
    era: Era.universal,
  ),
];

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

/// Get milestone by tier
PrestigeMilestone? getMilestoneByTier(int tier) {
  try {
    return prestigeMilestones.firstWhere((m) => m.tier == tier);
  } catch (_) {
    return null;
  }
}

/// Get all unlocked cosmetics for a player
List<PrestigeCosmetic> getUnlockedCosmetics(int currentTier) {
  final cosmetics = <PrestigeCosmetic>[];
  
  for (final border in prestigeBorders) {
    if (border.requiredPrestigeTier <= currentTier) {
      cosmetics.add(border);
    }
  }
  
  for (final badge in prestigeBadges) {
    if (badge.requiredPrestigeTier <= currentTier) {
      cosmetics.add(badge);
    }
  }
  
  return cosmetics;
}

/// Get next available milestone
PrestigeMilestone? getNextMilestone(int currentTier) {
  try {
    return prestigeMilestones.firstWhere((m) => m.tier > currentTier);
  } catch (_) {
    return null;
  }
}

/// Get milestones for a specific era
List<PrestigeMilestone> getMilestonesForEra(Era era) {
  return prestigeMilestones.where((m) => m.era == era).toList();
}

/// Get border cosmetic by tier
PrestigeCosmetic? getBorderByTier(int tier) {
  try {
    return prestigeBorders.firstWhere((b) => b.requiredPrestigeTier == tier);
  } catch (_) {
    return null;
  }
}

/// Get badge cosmetic by tier
PrestigeCosmetic? getBadgeByTier(int tier) {
  try {
    return prestigeBadges.firstWhere((b) => b.requiredPrestigeTier == tier);
  } catch (_) {
    return null;
  }
}

/// Get the highest unlocked border
PrestigeCosmetic? getHighestUnlockedBorder(int currentTier) {
  PrestigeCosmetic? highest;
  for (final border in prestigeBorders) {
    if (border.requiredPrestigeTier <= currentTier) {
      if (highest == null || border.requiredPrestigeTier > highest.requiredPrestigeTier) {
        highest = border;
      }
    }
  }
  return highest;
}

/// Get the highest unlocked badge
PrestigeCosmetic? getHighestUnlockedBadge(int currentTier) {
  PrestigeCosmetic? highest;
  for (final badge in prestigeBadges) {
    if (badge.requiredPrestigeTier <= currentTier) {
      if (highest == null || badge.requiredPrestigeTier > highest.requiredPrestigeTier) {
        highest = badge;
      }
    }
  }
  return highest;
}
