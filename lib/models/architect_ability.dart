import 'package:flutter/material.dart';

/// Architect ability effect types
enum AbilityEffectType {
  instantEnergy,        // Tesla Coil, Chain Reaction
  productionMultiplier, // E=mc² 
  offlineBonus,         // Radium Glow
  costReduction,        // Optimize Grid
  instantResearch,      // Eureka
  instantPurchase,      // Quick Build
  unlockGenerator,      // Dyson Vision
}

/// Active ability definition
class ArchitectAbility {
  final String architectId;
  final String name;
  final String description;
  final AbilityEffectType effectType;
  final double effectValue;       // Multiplier or amount
  final int durationMinutes;      // 0 for instant effects
  final int cooldownMinutes;
  final IconData icon;
  final Color color;
  
  const ArchitectAbility({
    required this.architectId,
    required this.name,
    required this.description,
    required this.effectType,
    required this.effectValue,
    required this.durationMinutes,
    required this.cooldownMinutes,
    required this.icon,
    required this.color,
  });
}

/// Active ability cooldown tracking
class AbilityCooldown {
  final String architectId;
  final DateTime lastUsed;
  final int cooldownMinutes;
  
  const AbilityCooldown({
    required this.architectId,
    required this.lastUsed,
    required this.cooldownMinutes,
  });
  
  bool get isOnCooldown {
    final now = DateTime.now();
    final cooldownEnd = lastUsed.add(Duration(minutes: cooldownMinutes));
    return now.isBefore(cooldownEnd);
  }
  
  Duration get remainingCooldown {
    if (!isOnCooldown) return Duration.zero;
    final now = DateTime.now();
    final cooldownEnd = lastUsed.add(Duration(minutes: cooldownMinutes));
    return cooldownEnd.difference(now);
  }
  
  double get cooldownProgress {
    if (!isOnCooldown) return 1.0;
    final now = DateTime.now();
    final elapsed = now.difference(lastUsed);
    return elapsed.inSeconds / (cooldownMinutes * 60);
  }
  
  Map<String, dynamic> toMap() {
    return {
      'architectId': architectId,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
      'cooldownMinutes': cooldownMinutes,
    };
  }
  
  factory AbilityCooldown.fromMap(Map<String, dynamic> map) {
    return AbilityCooldown(
      architectId: map['architectId'] as String,
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] as int),
      cooldownMinutes: map['cooldownMinutes'] as int,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PREDEFINED ABILITIES
// ═══════════════════════════════════════════════════════════════

const Map<String, ArchitectAbility> architectAbilities = {
  'tesla': ArchitectAbility(
    architectId: 'tesla',
    name: 'Tesla Coil',
    description: 'Channel lightning to instantly generate 2 hours worth of energy production.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 7200, // 2 hours in seconds
    durationMinutes: 0,
    cooldownMinutes: 90, // 1.5 hours (reduced from 3)
    icon: Icons.bolt,
    color: Colors.yellow,
  ),
  
  'einstein': ArchitectAbility(
    architectId: 'einstein',
    name: 'E=mc²',
    description: 'Unlock the secrets of mass-energy equivalence. Double all production for 30 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 2.0, // 2x multiplier
    durationMinutes: 30,
    cooldownMinutes: 120, // 2 hours (reduced from 4)
    icon: Icons.auto_awesome,
    color: Colors.amber,
  ),
  
  'curie': ArchitectAbility(
    architectId: 'curie',
    name: 'Radium Glow',
    description: 'Enhance offline energy collection by 100% for the next 8 hours.',
    effectType: AbilityEffectType.offlineBonus,
    effectValue: 1.0, // +100% offline
    durationMinutes: 480,
    cooldownMinutes: 120, // 2 hours (reduced from 4)
    icon: Icons.nightlight,
    color: Colors.green,
  ),
  
  'dyson': ArchitectAbility(
    architectId: 'dyson',
    name: 'Dyson Vision',
    description: 'Envision future technology. Reduce unlock requirements for all generators for 1 hour.',
    effectType: AbilityEffectType.unlockGenerator,
    effectValue: 0.5, // -50% unlock requirements
    durationMinutes: 60,
    cooldownMinutes: 180, // 3 hours (reduced from 6)
    icon: Icons.remove_red_eye,
    color: Colors.purple,
  ),
  
  'oppenheimer': ArchitectAbility(
    architectId: 'oppenheimer',
    name: 'Chain Reaction',
    description: 'Trigger a chain reaction for 1 hour worth of instant energy production.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 3600, // 1 hour in seconds
    durationMinutes: 0,
    cooldownMinutes: 60, // 1 hour (reduced from 2)
    icon: Icons.flash_on,
    color: Colors.orange,
  ),
  
  'lovelace': ArchitectAbility(
    architectId: 'lovelace',
    name: 'Optimize Grid',
    description: 'Algorithmic optimization reduces all upgrade costs by 25% for 1 hour.',
    effectType: AbilityEffectType.costReduction,
    effectValue: 0.25, // -25% costs
    durationMinutes: 60,
    cooldownMinutes: 75, // 1.25 hours (reduced from 2.5)
    icon: Icons.code,
    color: Colors.cyan,
  ),
  
  'engineer_alpha': ArchitectAbility(
    architectId: 'engineer_alpha',
    name: 'Quick Build',
    description: 'Engineering expertise allows instant purchase of the next generator at no cost.',
    effectType: AbilityEffectType.instantPurchase,
    effectValue: 1.0, // 1 free purchase
    durationMinutes: 0,
    cooldownMinutes: 30, // 30 mins (reduced from 1 hour)
    icon: Icons.build,
    color: Colors.grey,
  ),
  
  'scientist_alpha': ArchitectAbility(
    architectId: 'scientist_alpha',
    name: 'Eureka',
    description: 'A breakthrough discovery! Complete the current research instantly.',
    effectType: AbilityEffectType.instantResearch,
    effectValue: 1.0, // Complete 1 research
    durationMinutes: 0,
    cooldownMinutes: 45, // 45 mins (reduced from 1.5 hours)
    icon: Icons.lightbulb,
    color: Colors.yellow,
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA II - STELLAR ABILITIES
  // ═══════════════════════════════════════════════════════════════
  
  'dyson_ii': ArchitectAbility(
    architectId: 'dyson_ii',
    name: 'Solar Embrace',
    description: 'Triple all solar energy collection for 1 hour.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 3.0,
    durationMinutes: 60,
    cooldownMinutes: 360, // 6 hours (reduced from 12)
    icon: Icons.wb_sunny,
    color: Colors.orange,
  ),
  
  'kardashev': ArchitectAbility(
    architectId: 'kardashev',
    name: 'Ascension Boost',
    description: 'Accelerate civilization progress. +50% to all Kardashev gains for 2 hours.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 1.5,
    durationMinutes: 120,
    cooldownMinutes: 480, // 8 hours (reduced from 16)
    icon: Icons.trending_up,
    color: Colors.amber,
  ),
  
  'sagan': ArchitectAbility(
    architectId: 'sagan',
    name: 'Pale Blue Dot',
    description: 'Cosmic perspective grants insight. +40% research speed for 1 hour.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 1.4,
    durationMinutes: 60,
    cooldownMinutes: 240, // 4 hours (reduced from 8)
    icon: Icons.public,
    color: Colors.blue,
  ),
  
  'von_neumann': ArchitectAbility(
    architectId: 'von_neumann',
    name: 'Replication Wave',
    description: 'Self-replicating machines build 4 hours worth of production instantly.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 14400,
    durationMinutes: 0,
    cooldownMinutes: 300, // 5 hours (reduced from 10)
    icon: Icons.copy_all,
    color: Colors.teal,
  ),
  
  'oberth': ArchitectAbility(
    architectId: 'oberth',
    name: 'Orbital Insertion',
    description: 'Perfect trajectory calculations. Next 3 purchases are 50% cheaper.',
    effectType: AbilityEffectType.costReduction,
    effectValue: 0.5,
    durationMinutes: 30,
    cooldownMinutes: 150, // 2.5 hours (reduced from 5)
    icon: Icons.rocket_launch,
    color: Colors.indigo,
  ),
  
  'tsiolkovsky': ArchitectAbility(
    architectId: 'tsiolkovsky',
    name: 'Cosmic Dream',
    description: 'Dream of the stars. +100% offline earnings for 6 hours.',
    effectType: AbilityEffectType.offlineBonus,
    effectValue: 1.0,
    durationMinutes: 360,
    cooldownMinutes: 180, // 3 hours (reduced from 6)
    icon: Icons.nights_stay,
    color: Colors.deepPurple,
  ),
  
  'stellar_engineer': ArchitectAbility(
    architectId: 'stellar_engineer',
    name: 'Solar Flare',
    description: 'Channel a solar flare for 30 minutes of instant production.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 1800,
    durationMinutes: 0,
    cooldownMinutes: 75, // 1.25 hours (reduced from 2.5)
    icon: Icons.flare,
    color: Colors.orangeAccent,
  ),
  
  'swarm_coordinator': ArchitectAbility(
    architectId: 'swarm_coordinator',
    name: 'Sync Pulse',
    description: 'Synchronize all orbital units. +25% production for 30 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 1.25,
    durationMinutes: 30,
    cooldownMinutes: 90, // 1.5 hours (reduced from 3)
    icon: Icons.sync,
    color: Colors.cyan,
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA III - GALACTIC ABILITIES
  // ═══════════════════════════════════════════════════════════════
  
  'hawking': ArchitectAbility(
    architectId: 'hawking',
    name: 'Singularity Tap',
    description: 'Extract energy from the singularity. Instant 6 hours of production.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 21600,
    durationMinutes: 0,
    cooldownMinutes: 540, // 9 hours (reduced from 18)
    icon: Icons.blur_on,
    color: Colors.black87,
  ),
  
  'penrose': ArchitectAbility(
    architectId: 'penrose',
    name: 'Ergosphere Harvest',
    description: 'Extract rotational energy from the ergosphere. x5 black hole output for 1 hour.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 5.0,
    durationMinutes: 60,
    cooldownMinutes: 450, // 7.5 hours (reduced from 15)
    icon: Icons.rotate_right,
    color: Colors.deepOrange,
  ),
  
  'thorne': ArchitectAbility(
    architectId: 'thorne',
    name: 'Warp Gate',
    description: 'Open a wormhole for instant resource transfer. Gain 3 hours of production.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 10800,
    durationMinutes: 0,
    cooldownMinutes: 300, // 5 hours (reduced from 10)
    icon: Icons.radio_button_checked,
    color: Colors.purple,
  ),
  
  'chandrasekhar': ArchitectAbility(
    architectId: 'chandrasekhar',
    name: 'Pulsar Beam',
    description: 'Focus a pulsar beam for massive energy. x4 production for 45 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 4.0,
    durationMinutes: 45,
    cooldownMinutes: 270, // 4.5 hours (reduced from 9)
    icon: Icons.stream,
    color: Colors.lightBlue,
  ),
  
  'vera_rubin': ArchitectAbility(
    architectId: 'vera_rubin',
    name: 'Dark Insight',
    description: 'Perceive the dark matter. Double all dark matter gains for 2 hours.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 2.0,
    durationMinutes: 120,
    cooldownMinutes: 210, // 3.5 hours (reduced from 7)
    icon: Icons.dark_mode,
    color: Colors.indigo,
  ),
  
  'jocelyn_bell': ArchitectAbility(
    architectId: 'jocelyn_bell',
    name: 'Signal Boost',
    description: 'Amplify cosmic signals. +50% all production for 45 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 1.5,
    durationMinutes: 45,
    cooldownMinutes: 180, // 3 hours (reduced from 6)
    icon: Icons.wifi_tethering,
    color: Colors.green,
  ),
  
  'galactic_commander': ArchitectAbility(
    architectId: 'galactic_commander',
    name: 'Rally Fleet',
    description: 'Rally all fleets. +30% production for 30 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 1.3,
    durationMinutes: 30,
    cooldownMinutes: 90, // 1.5 hours (reduced from 3)
    icon: Icons.groups,
    color: Colors.blueGrey,
  ),
  
  'singularity_priest': ArchitectAbility(
    architectId: 'singularity_priest',
    name: 'Void Meditation',
    description: 'Commune with the void. +75% offline earnings for 4 hours.',
    effectType: AbilityEffectType.offlineBonus,
    effectValue: 0.75,
    durationMinutes: 240,
    cooldownMinutes: 100, // 100 mins (reduced from 200)
    icon: Icons.self_improvement,
    color: Colors.deepPurple,
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA IV - UNIVERSAL ABILITIES
  // ═══════════════════════════════════════════════════════════════
  
  'omega': ArchitectAbility(
    architectId: 'omega',
    name: 'Reality Override',
    description: 'Override the laws of physics. x10 all production for 30 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 10.0,
    durationMinutes: 30,
    cooldownMinutes: 720, // 12 hours (reduced from 24)
    icon: Icons.all_inclusive,
    color: Colors.white,
  ),
  
  'eternus': ArchitectAbility(
    architectId: 'eternus',
    name: 'Temporal Fold',
    description: 'Fold time itself. Gain 12 hours of production instantly.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 43200,
    durationMinutes: 0,
    cooldownMinutes: 600, // 10 hours (reduced from 20)
    icon: Icons.hourglass_empty,
    color: Colors.amber,
  ),
  
  'architect_prime': ArchitectAbility(
    architectId: 'architect_prime',
    name: 'Constant Shift',
    description: 'Temporarily improve physics constants. x6 production for 1 hour.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 6.0,
    durationMinutes: 60,
    cooldownMinutes: 360, // 6 hours (reduced from 12)
    icon: Icons.architecture,
    color: Colors.pink,
  ),
  
  'entropy_keeper': ArchitectAbility(
    architectId: 'entropy_keeper',
    name: 'Order Restoration',
    description: 'Reverse local entropy. x8 production for 45 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 8.0,
    durationMinutes: 45,
    cooldownMinutes: 330, // 5.5 hours (reduced from 11)
    icon: Icons.recycling,
    color: Colors.teal,
  ),
  
  'void_walker': ArchitectAbility(
    architectId: 'void_walker',
    name: 'Void Step',
    description: 'Step through the void. Gain 5 hours of production instantly.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 18000,
    durationMinutes: 0,
    cooldownMinutes: 240, // 4 hours (reduced from 8)
    icon: Icons.blur_circular,
    color: Colors.black54,
  ),
  
  'quantum_sage': ArchitectAbility(
    architectId: 'quantum_sage',
    name: 'Probability Collapse',
    description: 'Collapse probability in your favor. -40% costs for 1 hour.',
    effectType: AbilityEffectType.costReduction,
    effectValue: 0.4,
    durationMinutes: 60,
    cooldownMinutes: 210, // 3.5 hours (reduced from 7)
    icon: Icons.casino,
    color: Colors.purple,
  ),
  
  'cosmic_initiate': ArchitectAbility(
    architectId: 'cosmic_initiate',
    name: 'Cosmic Touch',
    description: 'Touch the fabric of reality. +50% production for 20 minutes.',
    effectType: AbilityEffectType.productionMultiplier,
    effectValue: 1.5,
    durationMinutes: 20,
    cooldownMinutes: 90, // 1.5 hours (reduced from 3)
    icon: Icons.touch_app,
    color: Colors.lightBlue,
  ),
  
  'multiverse_scout': ArchitectAbility(
    architectId: 'multiverse_scout',
    name: 'Reality Scan',
    description: 'Scan alternate realities. Gain 1 hour of production from each.',
    effectType: AbilityEffectType.instantEnergy,
    effectValue: 3600,
    durationMinutes: 0,
    cooldownMinutes: 100, // 100 mins (reduced from 200)
    icon: Icons.radar,
    color: Colors.cyan,
  ),
};

/// Get ability for architect
ArchitectAbility? getAbilityForArchitect(String architectId) {
  return architectAbilities[architectId];
}
