import 'package:flutter/material.dart';
import '../core/era_data.dart';

/// Research categories
enum ResearchCategory {
  efficiency,
  automation,
  expansion,
  exotic,
}

/// Research effect types
enum ResearchEffectType {
  productionMultiplier,
  generatorBoost,
  costReduction,
  offlineBonus,
  tapPower,
  autoTap,
  darkMatterBonus,
  prestigeBonus,
  researchSpeed,
  eraUnlock,
}

/// Research effect
class ResearchEffect {
  final ResearchEffectType type;
  final double value;
  final String? targetId;
  
  const ResearchEffect({
    required this.type,
    required this.value,
    this.targetId,
  });
  
  String get description {
    switch (type) {
      case ResearchEffectType.productionMultiplier:
        return '+${(value * 100).toInt()}% All Production';
      case ResearchEffectType.generatorBoost:
        return '+${(value * 100).toInt()}% ${targetId ?? "Generator"}';
      case ResearchEffectType.costReduction:
        return '-${(value * 100).toInt()}% Costs';
      case ResearchEffectType.offlineBonus:
        return '+${(value * 100).toInt()}% Offline Earnings';
      case ResearchEffectType.tapPower:
        return '+${(value * 100).toInt()}% Tap Power';
      case ResearchEffectType.autoTap:
        return '${value.toInt()} Auto-Taps/sec';
      case ResearchEffectType.darkMatterBonus:
        return '+${(value * 100).toInt()}% Dark Matter';
      case ResearchEffectType.prestigeBonus:
        return '+${(value * 100).toInt()}% Prestige Rewards';
      case ResearchEffectType.researchSpeed:
        return '+${(value * 100).toInt()}% Research Speed';
      case ResearchEffectType.eraUnlock:
        return 'Unlocks Era Transition';
    }
  }
}

/// Research node
class ResearchNode {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Era era;
  final ResearchCategory category;
  final int tier;
  final double energyCost;
  final int timeSeconds;
  final List<String> prerequisites;
  final ResearchEffect effect;
  
  const ResearchNode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.era,
    required this.category,
    required this.tier,
    required this.energyCost,
    required this.timeSeconds,
    required this.prerequisites,
    required this.effect,
  });
  
  Color get categoryColor {
    switch (category) {
      case ResearchCategory.efficiency:
        return const Color(0xFF4FC3F7);
      case ResearchCategory.automation:
        return const Color(0xFF81C784);
      case ResearchCategory.expansion:
        return const Color(0xFFFFB74D);
      case ResearchCategory.exotic:
        return const Color(0xFFBA68C8);
    }
  }
}

/// All research nodes across all Eras
const List<ResearchNode> allResearch = [
  // ═══════════════════════════════════════════════════════════════
  // ERA I - PLANETARY RESEARCH
  // ═══════════════════════════════════════════════════════════════
  
  // Tier 1
  ResearchNode(
    id: 'p_efficiency_1', name: 'Energy Optimization', description: 'Improve basic energy collection.',
    icon: '⚡', era: Era.planetary, category: ResearchCategory.efficiency, tier: 1,
    energyCost: 500, timeSeconds: 60, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.10),
  ),
  ResearchNode(
    id: 'p_automation_1', name: 'Basic Automation', description: 'Simple automated systems.',
    icon: '🔧', era: Era.planetary, category: ResearchCategory.automation, tier: 1,
    energyCost: 750, timeSeconds: 90, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 1),
  ),
  ResearchNode(
    id: 'p_expansion_1', name: 'Grid Expansion', description: 'Expand energy distribution.',
    icon: '🌐', era: Era.planetary, category: ResearchCategory.expansion, tier: 1,
    energyCost: 600, timeSeconds: 75, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.15, targetId: 'Wind Turbine'),
  ),
  
  // Tier 2
  ResearchNode(
    id: 'p_efficiency_2', name: 'Photovoltaic Enhancement', description: 'Advanced solar technology.',
    icon: '☀️', era: Era.planetary, category: ResearchCategory.efficiency, tier: 2,
    energyCost: 2500, timeSeconds: 180, prerequisites: ['p_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.25, targetId: 'Solar Array'),
  ),
  ResearchNode(
    id: 'p_automation_2', name: 'Smart Grid AI', description: 'AI power distribution.',
    icon: '🤖', era: Era.planetary, category: ResearchCategory.automation, tier: 2,
    energyCost: 3000, timeSeconds: 240, prerequisites: ['p_automation_1'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 3),
  ),
  ResearchNode(
    id: 'p_expansion_2', name: 'Cost Optimization', description: 'Reduce construction costs.',
    icon: '💰', era: Era.planetary, category: ResearchCategory.expansion, tier: 2,
    energyCost: 2000, timeSeconds: 150, prerequisites: ['p_expansion_1'],
    effect: ResearchEffect(type: ResearchEffectType.costReduction, value: 0.10),
  ),
  ResearchNode(
    id: 'p_exotic_1', name: 'Quantum Theory', description: 'Explore quantum mechanics.',
    icon: '🔮', era: Era.planetary, category: ResearchCategory.exotic, tier: 2,
    energyCost: 5000, timeSeconds: 300, prerequisites: ['p_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.researchSpeed, value: 0.15),
  ),
  
  // Tier 3
  ResearchNode(
    id: 'p_efficiency_3', name: 'Fusion Theory', description: 'Foundations of fusion power.',
    icon: '🔥', era: Era.planetary, category: ResearchCategory.efficiency, tier: 3,
    energyCost: 15000, timeSeconds: 600, prerequisites: ['p_efficiency_2'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.30, targetId: 'Fusion Core'),
  ),
  ResearchNode(
    id: 'p_automation_3', name: 'Neural Networks', description: 'Advanced AI systems.',
    icon: '🧠', era: Era.planetary, category: ResearchCategory.automation, tier: 3,
    energyCost: 12000, timeSeconds: 480, prerequisites: ['p_automation_2'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 5),
  ),
  ResearchNode(
    id: 'p_expansion_3', name: 'Orbital Construction', description: 'Build in space.',
    icon: '🛰️', era: Era.planetary, category: ResearchCategory.expansion, tier: 3,
    energyCost: 20000, timeSeconds: 720, prerequisites: ['p_expansion_2'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.35, targetId: 'Orbital Collector'),
  ),
  ResearchNode(
    id: 'p_exotic_2', name: 'Dark Matter Theory', description: 'Understand dark matter.',
    icon: '🌌', era: Era.planetary, category: ResearchCategory.exotic, tier: 3,
    energyCost: 25000, timeSeconds: 900, prerequisites: ['p_exotic_1'],
    effect: ResearchEffect(type: ResearchEffectType.darkMatterBonus, value: 0.25),
  ),
  
  // Tier 4
  ResearchNode(
    id: 'p_efficiency_4', name: 'Zero-Point Energy', description: 'Quantum vacuum energy.',
    icon: '✨', era: Era.planetary, category: ResearchCategory.efficiency, tier: 4,
    energyCost: 100000, timeSeconds: 1800, prerequisites: ['p_efficiency_3', 'p_exotic_1'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.50),
  ),
  ResearchNode(
    id: 'p_automation_4', name: 'Planetary AI', description: 'Global superintelligence.',
    icon: '🌍', era: Era.planetary, category: ResearchCategory.automation, tier: 4,
    energyCost: 80000, timeSeconds: 1500, prerequisites: ['p_automation_3'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 10),
  ),
  ResearchNode(
    id: 'p_expansion_4', name: 'Stellar Preparation', description: 'Prepare for the stars.',
    icon: '🚀', era: Era.planetary, category: ResearchCategory.expansion, tier: 4,
    energyCost: 150000, timeSeconds: 2400, prerequisites: ['p_expansion_3'],
    effect: ResearchEffect(type: ResearchEffectType.eraUnlock, value: 1),
  ),
  ResearchNode(
    id: 'p_exotic_3', name: 'Transcendence I', description: 'First step beyond.',
    icon: '🔆', era: Era.planetary, category: ResearchCategory.exotic, tier: 4,
    energyCost: 200000, timeSeconds: 3600, prerequisites: ['p_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.prestigeBonus, value: 0.50),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA II - STELLAR RESEARCH
  // ═══════════════════════════════════════════════════════════════
  
  // Tier 1 - Entry level for Stellar Era (50M-100M range)
  ResearchNode(
    id: 's_efficiency_1', name: 'Solar Proximity', description: 'Harvest energy closer to the star.',
    icon: '☀️', era: Era.stellar, category: ResearchCategory.efficiency, tier: 1,
    energyCost: 5e7, timeSeconds: 120, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.15),
  ),
  ResearchNode(
    id: 's_automation_1', name: 'Swarm Intelligence', description: 'Coordinate satellite swarms.',
    icon: '🐝', era: Era.stellar, category: ResearchCategory.automation, tier: 1,
    energyCost: 7.5e7, timeSeconds: 150, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 15),
  ),
  ResearchNode(
    id: 's_expansion_1', name: 'Mass Production', description: 'Automated mirror construction.',
    icon: '🏭', era: Era.stellar, category: ResearchCategory.expansion, tier: 1,
    energyCost: 6e7, timeSeconds: 130, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.costReduction, value: 0.15),
  ),
  
  // Tier 2 - Mid-early Stellar (1T-5T range - 1e12 to 5e12)
  ResearchNode(
    id: 's_efficiency_2', name: 'Coronal Harvesting', description: 'Extract plasma from corona.',
    icon: '🔥', era: Era.stellar, category: ResearchCategory.efficiency, tier: 2,
    energyCost: 2e12, timeSeconds: 300, prerequisites: ['s_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.30, targetId: 'Star Lifter'),
  ),
  ResearchNode(
    id: 's_automation_2', name: 'Stellar Network', description: 'System-wide coordination.',
    icon: '🌐', era: Era.stellar, category: ResearchCategory.automation, tier: 2,
    energyCost: 3e12, timeSeconds: 360, prerequisites: ['s_automation_1'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 30),
  ),
  ResearchNode(
    id: 's_expansion_2', name: 'Dyson Architecture', description: 'Advanced structural design.',
    icon: '📐', era: Era.stellar, category: ResearchCategory.expansion, tier: 2,
    energyCost: 1.5e12, timeSeconds: 280, prerequisites: ['s_expansion_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.25, targetId: 'Dyson Swarm'),
  ),
  ResearchNode(
    id: 's_exotic_1', name: 'Stellar Alchemy', description: 'Transmute elements in stellar cores.',
    icon: '⚗️', era: Era.stellar, category: ResearchCategory.exotic, tier: 2,
    energyCost: 5e12, timeSeconds: 450, prerequisites: ['s_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.darkMatterBonus, value: 0.40),
  ),
  
  // Tier 3 - Mid-late Stellar (100T-500T range - 1e14 to 5e14)
  ResearchNode(
    id: 's_efficiency_3', name: 'Total Stellar Capture', description: 'Maximum energy extraction.',
    icon: '💯', era: Era.stellar, category: ResearchCategory.efficiency, tier: 3,
    energyCost: 2e14, timeSeconds: 720, prerequisites: ['s_efficiency_2'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.40, targetId: 'Dyson Sphere'),
  ),
  ResearchNode(
    id: 's_automation_3', name: 'Von Neumann Probes', description: 'Self-replicating constructors.',
    icon: '🔄', era: Era.stellar, category: ResearchCategory.automation, tier: 3,
    energyCost: 1.5e14, timeSeconds: 600, prerequisites: ['s_automation_2'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 50),
  ),
  ResearchNode(
    id: 's_expansion_3', name: 'Stellar Engineering', description: 'Modify the star itself.',
    icon: '⭐', era: Era.stellar, category: ResearchCategory.expansion, tier: 3,
    energyCost: 3e14, timeSeconds: 900, prerequisites: ['s_expansion_2'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.35),
  ),
  ResearchNode(
    id: 's_exotic_2', name: 'Hawking Radiation', description: 'Understand black hole emissions.',
    icon: '🕳️', era: Era.stellar, category: ResearchCategory.exotic, tier: 3,
    energyCost: 5e14, timeSeconds: 1200, prerequisites: ['s_exotic_1'],
    effect: ResearchEffect(type: ResearchEffectType.researchSpeed, value: 0.30),
  ),
  
  // Tier 4 - End of Stellar Era (10Q-100Q range - 1e16 to 1e17)
  ResearchNode(
    id: 's_efficiency_4', name: 'Perfect Efficiency', description: 'Near-total energy conversion.',
    icon: '💎', era: Era.stellar, category: ResearchCategory.efficiency, tier: 4,
    energyCost: 2e16, timeSeconds: 2400, prerequisites: ['s_efficiency_3'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.75),
  ),
  ResearchNode(
    id: 's_automation_4', name: 'Stellar Mind', description: 'AI spanning the solar system.',
    icon: '🧠', era: Era.stellar, category: ResearchCategory.automation, tier: 4,
    energyCost: 1.5e16, timeSeconds: 2100, prerequisites: ['s_automation_3'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 100),
  ),
  ResearchNode(
    id: 's_expansion_4', name: 'Galactic Preparation', description: 'Ready for interstellar expansion.',
    icon: '🌌', era: Era.stellar, category: ResearchCategory.expansion, tier: 4,
    energyCost: 5e16, timeSeconds: 3600, prerequisites: ['s_expansion_3', 's_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.eraUnlock, value: 2),
  ),
  ResearchNode(
    id: 's_exotic_3', name: 'Transcendence II', description: 'Second step beyond.',
    icon: '🔆', era: Era.stellar, category: ResearchCategory.exotic, tier: 4,
    energyCost: 3e16, timeSeconds: 3000, prerequisites: ['s_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.prestigeBonus, value: 1.00),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA III - GALACTIC RESEARCH
  // ═══════════════════════════════════════════════════════════════
  
  // Tier 1 - Entry level for Galactic Era (100Q-500Q range - 1e17 to 5e17)
  ResearchNode(
    id: 'g_efficiency_1', name: 'Interstellar Logistics', description: 'Efficient energy transmission across light-years.',
    icon: '🚀', era: Era.galactic, category: ResearchCategory.efficiency, tier: 1,
    energyCost: 1e17, timeSeconds: 180, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.20),
  ),
  ResearchNode(
    id: 'g_automation_1', name: 'Galactic Network', description: 'Coordinate systems across the galaxy.',
    icon: '🌐', era: Era.galactic, category: ResearchCategory.automation, tier: 1,
    energyCost: 1.5e17, timeSeconds: 200, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 200),
  ),
  ResearchNode(
    id: 'g_expansion_1', name: 'Colony Ships', description: 'Rapid interstellar colonization.',
    icon: '🛸', era: Era.galactic, category: ResearchCategory.expansion, tier: 1,
    energyCost: 1.2e17, timeSeconds: 190, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.costReduction, value: 0.20),
  ),
  
  // Tier 2 - Mid-early Galactic (10Qi-50Qi range - 1e19 to 5e19)
  ResearchNode(
    id: 'g_efficiency_2', name: 'Neutron Star Mining', description: 'Extract degenerate matter.',
    icon: '💫', era: Era.galactic, category: ResearchCategory.efficiency, tier: 2,
    energyCost: 2e19, timeSeconds: 400, prerequisites: ['g_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.35, targetId: 'Neutron Harvester'),
  ),
  ResearchNode(
    id: 'g_automation_2', name: 'Hive Mind', description: 'Unified galactic consciousness.',
    icon: '🐝', era: Era.galactic, category: ResearchCategory.automation, tier: 2,
    energyCost: 3e19, timeSeconds: 450, prerequisites: ['g_automation_1'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 500),
  ),
  ResearchNode(
    id: 'g_expansion_2', name: 'Warp Technology', description: 'Faster-than-light travel.',
    icon: '⚡', era: Era.galactic, category: ResearchCategory.expansion, tier: 2,
    energyCost: 1.5e19, timeSeconds: 380, prerequisites: ['g_expansion_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.30, targetId: 'Stellar Engine'),
  ),
  ResearchNode(
    id: 'g_exotic_1', name: 'Singularity Physics', description: 'Master black hole mechanics.',
    icon: '🕳️', era: Era.galactic, category: ResearchCategory.exotic, tier: 2,
    energyCost: 5e19, timeSeconds: 600, prerequisites: ['g_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.40, targetId: 'Penrose Sphere'),
  ),
  
  // Tier 3 - Mid-late Galactic (1Sx-10Sx range - 1e21 to 1e22)
  ResearchNode(
    id: 'g_efficiency_3', name: 'Quasar Manipulation', description: 'Control active galactic nuclei.',
    icon: '💥', era: Era.galactic, category: ResearchCategory.efficiency, tier: 3,
    energyCost: 2e21, timeSeconds: 900, prerequisites: ['g_efficiency_2'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.45, targetId: 'Quasar Tap'),
  ),
  ResearchNode(
    id: 'g_automation_3', name: 'Galactic Overmind', description: 'Supreme coordinating intelligence.',
    icon: '👁️', era: Era.galactic, category: ResearchCategory.automation, tier: 3,
    energyCost: 1.5e21, timeSeconds: 800, prerequisites: ['g_automation_2'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 1000),
  ),
  ResearchNode(
    id: 'g_expansion_3', name: 'Wormhole Network', description: 'Instant galactic transportation.',
    icon: '🌀', era: Era.galactic, category: ResearchCategory.expansion, tier: 3,
    energyCost: 3e21, timeSeconds: 1200, prerequisites: ['g_expansion_2'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.50),
  ),
  ResearchNode(
    id: 'g_exotic_2', name: 'Cosmic String Theory', description: 'Understand spacetime defects.',
    icon: '〰️', era: Era.galactic, category: ResearchCategory.exotic, tier: 3,
    energyCost: 5e21, timeSeconds: 1500, prerequisites: ['g_exotic_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.50, targetId: 'Cosmic String Mine'),
  ),
  
  // Tier 4 - End of Galactic Era (100Sx-1Sp range - 1e23 to 1e24)
  ResearchNode(
    id: 'g_efficiency_4', name: 'Galactic Harvesting', description: 'Extract energy from the entire galaxy.',
    icon: '🌌', era: Era.galactic, category: ResearchCategory.efficiency, tier: 4,
    energyCost: 2e23, timeSeconds: 3000, prerequisites: ['g_efficiency_3'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 1.00),
  ),
  ResearchNode(
    id: 'g_automation_4', name: 'Universal Compute', description: 'Galaxy-spanning computation.',
    icon: '💻', era: Era.galactic, category: ResearchCategory.automation, tier: 4,
    energyCost: 1.5e23, timeSeconds: 2700, prerequisites: ['g_automation_3'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 2500),
  ),
  ResearchNode(
    id: 'g_expansion_4', name: 'Universal Preparation', description: 'Ready to transcend the galaxy.',
    icon: '🔮', era: Era.galactic, category: ResearchCategory.expansion, tier: 4,
    energyCost: 5e23, timeSeconds: 5400, prerequisites: ['g_expansion_3', 'g_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.eraUnlock, value: 3),
  ),
  ResearchNode(
    id: 'g_exotic_3', name: 'Transcendence III', description: 'Third step beyond.',
    icon: '🔆', era: Era.galactic, category: ResearchCategory.exotic, tier: 4,
    energyCost: 3e23, timeSeconds: 4500, prerequisites: ['g_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.prestigeBonus, value: 2.50),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA IV - UNIVERSAL RESEARCH
  // ═══════════════════════════════════════════════════════════════
  
  // Tier 1
  ResearchNode(
    id: 'u_efficiency_1', name: 'Vacuum Energy Mastery', description: 'Perfect zero-point extraction.',
    icon: '✨', era: Era.universal, category: ResearchCategory.efficiency, tier: 1,
    energyCost: 1e26, timeSeconds: 240, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.25),
  ),
  ResearchNode(
    id: 'u_automation_1', name: 'Omniscient Network', description: 'Universe-spanning awareness.',
    icon: '👁️', era: Era.universal, category: ResearchCategory.automation, tier: 1,
    energyCost: 1.5e26, timeSeconds: 280, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 5000),
  ),
  ResearchNode(
    id: 'u_expansion_1', name: 'Dimensional Gates', description: 'Access parallel dimensions.',
    icon: '🌈', era: Era.universal, category: ResearchCategory.expansion, tier: 1,
    energyCost: 1.2e26, timeSeconds: 260, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.30, targetId: 'Dimensional Rift'),
  ),
  
  // Tier 2
  ResearchNode(
    id: 'u_efficiency_2', name: 'Timeline Exploitation', description: 'Extract energy from time itself.',
    icon: '⏳', era: Era.universal, category: ResearchCategory.efficiency, tier: 2,
    energyCost: 1e27, timeSeconds: 500, prerequisites: ['u_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.40, targetId: 'Timeline Harvester'),
  ),
  ResearchNode(
    id: 'u_automation_2', name: 'Temporal Loops', description: 'Use time loops for computation.',
    icon: '🔄', era: Era.universal, category: ResearchCategory.automation, tier: 2,
    energyCost: 1.2e27, timeSeconds: 550, prerequisites: ['u_automation_1'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 15000),
  ),
  ResearchNode(
    id: 'u_expansion_2', name: 'Reality Manipulation', description: 'Alter fundamental constants.',
    icon: '⚙️', era: Era.universal, category: ResearchCategory.expansion, tier: 2,
    energyCost: 8e26, timeSeconds: 480, prerequisites: ['u_expansion_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.35, targetId: 'Reality Engine'),
  ),
  ResearchNode(
    id: 'u_exotic_1', name: 'Entropy Reversal Theory', description: 'Understand thermodynamic reversal.',
    icon: '♻️', era: Era.universal, category: ResearchCategory.exotic, tier: 2,
    energyCost: 2e27, timeSeconds: 720, prerequisites: ['u_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.45, targetId: 'Entropy Reverser'),
  ),
  
  // Tier 3
  ResearchNode(
    id: 'u_efficiency_3', name: 'Creation Energy', description: 'Tap the energy of universe creation.',
    icon: '💥', era: Era.universal, category: ResearchCategory.efficiency, tier: 3,
    energyCost: 1e28, timeSeconds: 1200, prerequisites: ['u_efficiency_2'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 1.00),
  ),
  ResearchNode(
    id: 'u_automation_3', name: 'Omnipresent Mind', description: 'Exist in all places simultaneously.',
    icon: '🧠', era: Era.universal, category: ResearchCategory.automation, tier: 3,
    energyCost: 8e27, timeSeconds: 1100, prerequisites: ['u_automation_2'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 50000),
  ),
  ResearchNode(
    id: 'u_expansion_3', name: 'Multiverse Access', description: 'Reach alternate universes.',
    icon: '🌌', era: Era.universal, category: ResearchCategory.expansion, tier: 3,
    energyCost: 1.5e28, timeSeconds: 1500, prerequisites: ['u_expansion_2'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.75),
  ),
  ResearchNode(
    id: 'u_exotic_2', name: 'Omniversal Theory', description: 'Understand all possible realities.',
    icon: '💎', era: Era.universal, category: ResearchCategory.exotic, tier: 3,
    energyCost: 2.5e28, timeSeconds: 1800, prerequisites: ['u_exotic_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.60, targetId: 'Omniversal Core'),
  ),
  
  // Tier 4
  ResearchNode(
    id: 'u_efficiency_4', name: 'Infinite Energy', description: 'Truly unlimited power.',
    icon: '♾️', era: Era.universal, category: ResearchCategory.efficiency, tier: 4,
    energyCost: 1e29, timeSeconds: 3600, prerequisites: ['u_efficiency_3'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 2.00),
  ),
  ResearchNode(
    id: 'u_automation_4', name: 'Godlike Intelligence', description: 'Computation beyond comprehension.',
    icon: '✨', era: Era.universal, category: ResearchCategory.automation, tier: 4,
    energyCost: 8e28, timeSeconds: 3300, prerequisites: ['u_automation_3'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 200000),
  ),
  ResearchNode(
    id: 'u_expansion_4', name: 'Universe Creation', description: 'Create new universes.',
    icon: '🌟', era: Era.universal, category: ResearchCategory.expansion, tier: 4,
    energyCost: 5e29, timeSeconds: 7200, prerequisites: ['u_expansion_3', 'u_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 5.00),
  ),
  ResearchNode(
    id: 'u_exotic_3', name: 'Final Transcendence', description: 'Become one with everything.',
    icon: '🔆', era: Era.universal, category: ResearchCategory.exotic, tier: 4,
    energyCost: 1e30, timeSeconds: 10800, prerequisites: ['u_exotic_2', 'u_efficiency_4'],
    effect: ResearchEffect(type: ResearchEffectType.prestigeBonus, value: 10.00),
  ),
  
  // ═══════════════════════════════════════════════════════════════
  // ERA V - MULTIVERSAL RESEARCH
  // The ultimate endgame research - extremely expensive and powerful
  // Costs scale from 1e32 to 1e58 (matching Era V generator costs)
  // ═══════════════════════════════════════════════════════════════
  
  // Tier 1 - Entry level multiversal research (costs ~1e32-1e33)
  ResearchNode(
    id: 'm_efficiency_1', name: 'Quantum Foam Dynamics', description: 'Master the fabric of spacetime itself.',
    icon: '🫧', era: Era.multiversal, category: ResearchCategory.efficiency, tier: 1,
    energyCost: 5e32, timeSeconds: 600, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 0.50),
  ),
  ResearchNode(
    id: 'm_automation_1', name: 'Multiversal Consciousness', description: 'Awareness spanning infinite realities.',
    icon: '🧿', era: Era.multiversal, category: ResearchCategory.automation, tier: 1,
    energyCost: 8e32, timeSeconds: 720, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 500000),
  ),
  ResearchNode(
    id: 'm_expansion_1', name: 'Brane Manipulation', description: 'Control the membranes between universes.',
    icon: '🌊', era: Era.multiversal, category: ResearchCategory.expansion, tier: 1,
    energyCost: 6e32, timeSeconds: 660, prerequisites: [],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.40, targetId: 'Quantum Foam Siphon'),
  ),
  
  // Tier 2 - Mid-early research (costs ~1e35-1e37)
  ResearchNode(
    id: 'm_efficiency_2', name: 'Brane Collision Theory', description: 'Harness energy from colliding universes.',
    icon: '💥', era: Era.multiversal, category: ResearchCategory.efficiency, tier: 2,
    energyCost: 5e35, timeSeconds: 1200, prerequisites: ['m_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.50, targetId: 'Brane Collider'),
  ),
  ResearchNode(
    id: 'm_automation_2', name: 'Infinite Parallel Processing', description: 'Compute across infinite timelines simultaneously.',
    icon: '🔀', era: Era.multiversal, category: ResearchCategory.automation, tier: 2,
    energyCost: 8e35, timeSeconds: 1400, prerequisites: ['m_automation_1'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 2000000),
  ),
  ResearchNode(
    id: 'm_expansion_2', name: 'Entropic Mastery', description: 'Command the forces of decay and renewal.',
    icon: '♻️', era: Era.multiversal, category: ResearchCategory.expansion, tier: 2,
    energyCost: 3e36, timeSeconds: 1100, prerequisites: ['m_expansion_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.55, targetId: 'Entropy Deleter'),
  ),
  ResearchNode(
    id: 'm_exotic_1', name: 'Causality Loops', description: 'Create stable paradoxes for energy extraction.',
    icon: '🔄', era: Era.multiversal, category: ResearchCategory.exotic, tier: 2,
    energyCost: 1e37, timeSeconds: 1800, prerequisites: ['m_efficiency_1'],
    effect: ResearchEffect(type: ResearchEffectType.offlineBonus, value: 1.00),
  ),
  
  // Tier 3 - Mid-late research (costs ~1e40-1e45)
  ResearchNode(
    id: 'm_efficiency_3', name: 'Timeline Synthesis', description: 'Weave favorable outcomes into existence.',
    icon: '🧶', era: Era.multiversal, category: ResearchCategory.efficiency, tier: 3,
    energyCost: 5e40, timeSeconds: 2400, prerequisites: ['m_efficiency_2'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.65, targetId: 'Timeline Weaver'),
  ),
  ResearchNode(
    id: 'm_automation_3', name: 'Omniversal Hivemind', description: 'Unite all intelligent beings across realities.',
    icon: '🐝', era: Era.multiversal, category: ResearchCategory.automation, tier: 3,
    energyCost: 8e41, timeSeconds: 2800, prerequisites: ['m_automation_2'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 10000000),
  ),
  ResearchNode(
    id: 'm_expansion_3', name: 'Reality Compiler', description: 'Program the source code of existence.',
    icon: '💻', era: Era.multiversal, category: ResearchCategory.expansion, tier: 3,
    energyCost: 2e42, timeSeconds: 3000, prerequisites: ['m_expansion_2'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 2.00),
  ),
  ResearchNode(
    id: 'm_exotic_2', name: 'Logic Transcendence', description: 'Operate beyond mathematical constraints.',
    icon: '📐', era: Era.multiversal, category: ResearchCategory.exotic, tier: 3,
    energyCost: 5e43, timeSeconds: 3600, prerequisites: ['m_exotic_1'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 0.75, targetId: 'Logic Rewriter'),
  ),
  
  // Tier 4 - Endgame research (costs ~1e48-1e55)
  ResearchNode(
    id: 'm_efficiency_4', name: 'Void Energy Extraction', description: 'Draw power from the space between realities.',
    icon: '🕳️', era: Era.multiversal, category: ResearchCategory.efficiency, tier: 4,
    energyCost: 1e48, timeSeconds: 5400, prerequisites: ['m_efficiency_3'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 5.00),
  ),
  ResearchNode(
    id: 'm_automation_4', name: 'Absolute Omniscience', description: 'Know everything that ever was or will be.',
    icon: '👁️‍🗨️', era: Era.multiversal, category: ResearchCategory.automation, tier: 4,
    energyCost: 5e49, timeSeconds: 6000, prerequisites: ['m_automation_3'],
    effect: ResearchEffect(type: ResearchEffectType.autoTap, value: 50000000),
  ),
  ResearchNode(
    id: 'm_expansion_4', name: 'Omniversal Sovereignty', description: 'Claim dominion over all that exists.',
    icon: '👑', era: Era.multiversal, category: ResearchCategory.expansion, tier: 4,
    energyCost: 1e52, timeSeconds: 7200, prerequisites: ['m_expansion_3', 'm_exotic_2'],
    effect: ResearchEffect(type: ResearchEffectType.generatorBoost, value: 1.00, targetId: 'Omniversal Throne'),
  ),
  ResearchNode(
    id: 'm_exotic_3', name: 'The Final Understanding', description: 'Comprehend the ultimate truth of all existence.',
    icon: '🌟', era: Era.multiversal, category: ResearchCategory.exotic, tier: 4,
    energyCost: 5e53, timeSeconds: 9000, prerequisites: ['m_exotic_2', 'm_efficiency_4'],
    effect: ResearchEffect(type: ResearchEffectType.prestigeBonus, value: 25.00),
  ),
  
  // Tier 5 - Ultimate endgame (costs ~1e55-1e58) - The final frontier
  ResearchNode(
    id: 'm_ultimate_1', name: 'Infinite Regression', description: 'Create universes that create universes forever.',
    icon: '∞', era: Era.multiversal, category: ResearchCategory.efficiency, tier: 5,
    energyCost: 1e55, timeSeconds: 14400, prerequisites: ['m_efficiency_4', 'm_expansion_4'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 10.00),
  ),
  ResearchNode(
    id: 'm_ultimate_2', name: 'The Omega Point', description: 'Converge all timelines into a single perfect moment.',
    icon: 'Ω', era: Era.multiversal, category: ResearchCategory.exotic, tier: 5,
    energyCost: 5e56, timeSeconds: 21600, prerequisites: ['m_exotic_3', 'm_automation_4'],
    effect: ResearchEffect(type: ResearchEffectType.productionMultiplier, value: 25.00),
  ),
  ResearchNode(
    id: 'm_ultimate_3', name: 'Absolute Ascension', description: 'Transcend existence itself. Become everything and nothing.',
    icon: '✴️', era: Era.multiversal, category: ResearchCategory.exotic, tier: 5,
    energyCost: 1e58, timeSeconds: 43200, prerequisites: ['m_ultimate_1', 'm_ultimate_2'],
    effect: ResearchEffect(type: ResearchEffectType.prestigeBonus, value: 100.00),
  ),
];

/// Get research for a specific era
List<ResearchNode> getResearchForEra(Era era) {
  return allResearch.where((r) => r.era == era).toList();
}

/// Get research by ID
ResearchNode? getResearchNodeById(String id) {
  try {
    return allResearch.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
}

/// Get research by category and era
List<ResearchNode> getResearchByCategoryAndEra(ResearchCategory category, Era era) {
  return allResearch.where((r) => r.category == category && r.era == era).toList();
}
