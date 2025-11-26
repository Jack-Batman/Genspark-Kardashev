import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Research Node Status
enum ResearchStatus {
  locked,      // Prerequisites not met
  available,   // Can be researched
  researching, // Currently being researched
  completed,   // Research finished
}

/// Research Node Model
class ResearchNode {
  final String id;
  final String name;
  final String description;
  final String icon;
  final ResearchCategory category;
  final int tier; // 1-4, determines position in tree
  final double energyCost;
  final int researchTimeSeconds;
  final List<String> prerequisites; // IDs of required research
  final ResearchEffect effect;
  
  const ResearchNode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.tier,
    required this.energyCost,
    required this.researchTimeSeconds,
    required this.prerequisites,
    required this.effect,
  });
  
  /// Get category color
  Color get categoryColor {
    switch (category) {
      case ResearchCategory.efficiency:
        return const Color(0xFF4FC3F7); // Cyan
      case ResearchCategory.automation:
        return const Color(0xFF81C784); // Green
      case ResearchCategory.expansion:
        return const Color(0xFFFFB74D); // Orange
      case ResearchCategory.exotic:
        return const Color(0xFFBA68C8); // Purple
    }
  }
  
  /// Get category name
  String get categoryName {
    switch (category) {
      case ResearchCategory.efficiency:
        return 'Efficiency';
      case ResearchCategory.automation:
        return 'Automation';
      case ResearchCategory.expansion:
        return 'Expansion';
      case ResearchCategory.exotic:
        return 'Exotic';
    }
  }
}

/// Research Effect Types
enum ResearchEffectType {
  productionMultiplier,      // Multiply all production
  generatorMultiplier,       // Multiply specific generator
  costReduction,             // Reduce purchase costs
  offlineEfficiency,         // Improve offline earnings
  tapPower,                  // Increase tap power
  unlockGenerator,           // Unlock a new generator
  darkMatterBonus,           // Bonus dark matter
  prestigeBonus,             // Improve prestige rewards
  researchSpeed,             // Faster research
  autoTap,                   // Automatic tapping
}

/// Research Effect
class ResearchEffect {
  final ResearchEffectType type;
  final double value;
  final String? targetGenerator; // For generator-specific effects
  
  const ResearchEffect({
    required this.type,
    required this.value,
    this.targetGenerator,
  });
  
  String get description {
    switch (type) {
      case ResearchEffectType.productionMultiplier:
        return '+${(value * 100).toInt()}% All Production';
      case ResearchEffectType.generatorMultiplier:
        return '+${(value * 100).toInt()}% ${targetGenerator ?? "Generator"} Output';
      case ResearchEffectType.costReduction:
        return '-${(value * 100).toInt()}% Purchase Costs';
      case ResearchEffectType.offlineEfficiency:
        return '+${(value * 100).toInt()}% Offline Earnings';
      case ResearchEffectType.tapPower:
        return '+${(value * 100).toInt()}% Tap Power';
      case ResearchEffectType.unlockGenerator:
        return 'Unlock ${targetGenerator ?? "New Generator"}';
      case ResearchEffectType.darkMatterBonus:
        return '+${(value * 100).toInt()}% Dark Matter';
      case ResearchEffectType.prestigeBonus:
        return '+${(value * 100).toInt()}% Prestige Rewards';
      case ResearchEffectType.researchSpeed:
        return '+${(value * 100).toInt()}% Research Speed';
      case ResearchEffectType.autoTap:
        return '${value.toInt()} Auto-Taps/sec';
    }
  }
}

/// Era I Research Tree
const List<ResearchNode> eraIResearchTree = [
  // TIER 1 - Basic Research
  ResearchNode(
    id: 'basic_efficiency',
    name: 'Energy Optimization',
    description: 'Improve basic energy collection methods.',
    icon: '⚡',
    category: ResearchCategory.efficiency,
    tier: 1,
    energyCost: 500,
    researchTimeSeconds: 60,
    prerequisites: [],
    effect: ResearchEffect(
      type: ResearchEffectType.productionMultiplier,
      value: 0.10,
    ),
  ),
  ResearchNode(
    id: 'basic_automation',
    name: 'Basic Automation',
    description: 'Implement simple automated systems.',
    icon: '🔧',
    category: ResearchCategory.automation,
    tier: 1,
    energyCost: 750,
    researchTimeSeconds: 90,
    prerequisites: [],
    effect: ResearchEffect(
      type: ResearchEffectType.autoTap,
      value: 1,
    ),
  ),
  ResearchNode(
    id: 'grid_expansion',
    name: 'Grid Expansion',
    description: 'Expand the energy distribution network.',
    icon: '🌐',
    category: ResearchCategory.expansion,
    tier: 1,
    energyCost: 600,
    researchTimeSeconds: 75,
    prerequisites: [],
    effect: ResearchEffect(
      type: ResearchEffectType.generatorMultiplier,
      value: 0.15,
      targetGenerator: 'Wind Turbine',
    ),
  ),
  
  // TIER 2 - Intermediate Research
  ResearchNode(
    id: 'solar_efficiency',
    name: 'Photovoltaic Enhancement',
    description: 'Advanced solar cell technology.',
    icon: '☀️',
    category: ResearchCategory.efficiency,
    tier: 2,
    energyCost: 2500,
    researchTimeSeconds: 180,
    prerequisites: ['basic_efficiency'],
    effect: ResearchEffect(
      type: ResearchEffectType.generatorMultiplier,
      value: 0.25,
      targetGenerator: 'Solar Array',
    ),
  ),
  ResearchNode(
    id: 'smart_grid',
    name: 'Smart Grid AI',
    description: 'AI-managed power distribution.',
    icon: '🤖',
    category: ResearchCategory.automation,
    tier: 2,
    energyCost: 3000,
    researchTimeSeconds: 240,
    prerequisites: ['basic_automation'],
    effect: ResearchEffect(
      type: ResearchEffectType.autoTap,
      value: 3,
    ),
  ),
  ResearchNode(
    id: 'cost_optimization',
    name: 'Cost Optimization',
    description: 'Reduce construction and maintenance costs.',
    icon: '💰',
    category: ResearchCategory.expansion,
    tier: 2,
    energyCost: 2000,
    researchTimeSeconds: 150,
    prerequisites: ['grid_expansion'],
    effect: ResearchEffect(
      type: ResearchEffectType.costReduction,
      value: 0.10,
    ),
  ),
  ResearchNode(
    id: 'quantum_theory',
    name: 'Quantum Theory',
    description: 'Begin exploring quantum mechanics.',
    icon: '🔮',
    category: ResearchCategory.exotic,
    tier: 2,
    energyCost: 5000,
    researchTimeSeconds: 300,
    prerequisites: ['basic_efficiency'],
    effect: ResearchEffect(
      type: ResearchEffectType.researchSpeed,
      value: 0.15,
    ),
  ),
  
  // TIER 3 - Advanced Research
  ResearchNode(
    id: 'fusion_theory',
    name: 'Fusion Theory',
    description: 'Theoretical foundations of fusion power.',
    icon: '🔥',
    category: ResearchCategory.efficiency,
    tier: 3,
    energyCost: 15000,
    researchTimeSeconds: 600,
    prerequisites: ['solar_efficiency'],
    effect: ResearchEffect(
      type: ResearchEffectType.generatorMultiplier,
      value: 0.30,
      targetGenerator: 'Fusion Core',
    ),
  ),
  ResearchNode(
    id: 'neural_network',
    name: 'Neural Networks',
    description: 'Advanced AI for energy management.',
    icon: '🧠',
    category: ResearchCategory.automation,
    tier: 3,
    energyCost: 12000,
    researchTimeSeconds: 480,
    prerequisites: ['smart_grid'],
    effect: ResearchEffect(
      type: ResearchEffectType.autoTap,
      value: 5,
    ),
  ),
  ResearchNode(
    id: 'orbital_construction',
    name: 'Orbital Construction',
    description: 'Build structures in space.',
    icon: '🛰️',
    category: ResearchCategory.expansion,
    tier: 3,
    energyCost: 20000,
    researchTimeSeconds: 720,
    prerequisites: ['cost_optimization'],
    effect: ResearchEffect(
      type: ResearchEffectType.generatorMultiplier,
      value: 0.35,
      targetGenerator: 'Orbital Collector',
    ),
  ),
  ResearchNode(
    id: 'dark_matter_theory',
    name: 'Dark Matter Theory',
    description: 'Understand the nature of dark matter.',
    icon: '🌌',
    category: ResearchCategory.exotic,
    tier: 3,
    energyCost: 25000,
    researchTimeSeconds: 900,
    prerequisites: ['quantum_theory'],
    effect: ResearchEffect(
      type: ResearchEffectType.darkMatterBonus,
      value: 0.25,
    ),
  ),
  
  // TIER 4 - Mastery Research
  ResearchNode(
    id: 'zero_point_energy',
    name: 'Zero-Point Energy',
    description: 'Harness quantum vacuum fluctuations.',
    icon: '✨',
    category: ResearchCategory.efficiency,
    tier: 4,
    energyCost: 100000,
    researchTimeSeconds: 1800,
    prerequisites: ['fusion_theory', 'quantum_theory'],
    effect: ResearchEffect(
      type: ResearchEffectType.productionMultiplier,
      value: 0.50,
    ),
  ),
  ResearchNode(
    id: 'planetary_ai',
    name: 'Planetary AI',
    description: 'Global artificial superintelligence.',
    icon: '🌍',
    category: ResearchCategory.automation,
    tier: 4,
    energyCost: 80000,
    researchTimeSeconds: 1500,
    prerequisites: ['neural_network'],
    effect: ResearchEffect(
      type: ResearchEffectType.autoTap,
      value: 10,
    ),
  ),
  ResearchNode(
    id: 'dyson_swarm_theory',
    name: 'Dyson Swarm Theory',
    description: 'Theoretical basis for stellar megastructures.',
    icon: '🔆',
    category: ResearchCategory.expansion,
    tier: 4,
    energyCost: 150000,
    researchTimeSeconds: 2400,
    prerequisites: ['orbital_construction'],
    effect: ResearchEffect(
      type: ResearchEffectType.generatorMultiplier,
      value: 0.50,
      targetGenerator: 'Planetary Grid',
    ),
  ),
  ResearchNode(
    id: 'transcendence',
    name: 'Transcendence Protocol',
    description: 'Prepare civilization for the next era.',
    icon: '🚀',
    category: ResearchCategory.exotic,
    tier: 4,
    energyCost: 200000,
    researchTimeSeconds: 3600,
    prerequisites: ['dark_matter_theory', 'zero_point_energy'],
    effect: ResearchEffect(
      type: ResearchEffectType.prestigeBonus,
      value: 0.50,
    ),
  ),
  ResearchNode(
    id: 'offline_quantum',
    name: 'Quantum Persistence',
    description: 'Maintain energy flow across time.',
    icon: '⏳',
    category: ResearchCategory.efficiency,
    tier: 4,
    energyCost: 75000,
    researchTimeSeconds: 1200,
    prerequisites: ['fusion_theory'],
    effect: ResearchEffect(
      type: ResearchEffectType.offlineEfficiency,
      value: 0.30,
    ),
  ),
];

/// Get research node by ID
ResearchNode? getResearchById(String id) {
  try {
    return eraIResearchTree.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
}

/// Get all research in a category
List<ResearchNode> getResearchByCategory(ResearchCategory category) {
  return eraIResearchTree.where((r) => r.category == category).toList();
}

/// Get all research in a tier
List<ResearchNode> getResearchByTier(int tier) {
  return eraIResearchTree.where((r) => r.tier == tier).toList();
}
