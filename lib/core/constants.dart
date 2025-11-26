import 'package:flutter/material.dart';

/// Kardashev Scale Constants
class KardashevConstants {
  // Era Thresholds (Kardashev Scale Values)
  static const double eraIPlanetaryMax = 1.0;
  static const double eraIIStellarMax = 2.0;
  static const double eraIIIGalacticMax = 3.0;
  
  // Energy Units (Watts equivalent, scaled for gameplay)
  static const double typeIEnergy = 1.74e16; // ~17.4 Petawatts (Earth's solar input)
  static const double typeIIEnergy = 3.86e26; // Sun's total output
  static const double typeIIIEnergy = 4e37; // Milky Way output
  
  // Game Balance
  static const double baseEnergyPerSecond = 1.0;
  static const double offlineEfficiencyMultiplier = 0.5;
  static const int maxOfflineHours = 24;
  static const double wakeUpBonus = 1.5; // 50% bonus after being away
}

/// App Color Scheme - Cinematic Interstellar Style
class AppColors {
  // Primary Energy Colors by Era
  static const Color eraIEnergy = Color(0xFF00D9FF); // Cyan
  static const Color eraIIEnergy = Color(0xFFFFB347); // Golden/Amber
  static const Color eraIIIEnergy = Color(0xFFAA77FF); // Violet
  static const Color eraIVEnergy = Color(0xFFFF6B9D); // Cosmic Pink
  
  // UI Colors - Premium Dark Theme
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundMedium = Color(0xFF12121A);
  static const Color surfaceDark = Color(0xFF1A1A24);
  static const Color surfaceLight = Color(0xFF252532);
  
  // Accent Colors
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  
  // Glass Morphism
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x4DFFD700);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textAccent = Color(0xFFFFD700);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

/// Text Styles
class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 1,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textAccent,
    letterSpacing: 1,
  );
  
  static const TextStyle statValue = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.goldLight,
    letterSpacing: 1,
  );
}

/// Generator Types for Era I
enum GeneratorType {
  windTurbine,
  solarPanel,
  nuclearPlant,
  fusionReactor,
  orbitalArray,
  planetaryGrid,
}

/// Generator Data
class GeneratorData {
  final String name;
  final String description;
  final String icon;
  final double baseProduction;
  final double baseCost;
  final double costMultiplier;
  final double productionMultiplier;
  final int unlockLevel;
  
  const GeneratorData({
    required this.name,
    required this.description,
    required this.icon,
    required this.baseProduction,
    required this.baseCost,
    required this.costMultiplier,
    required this.productionMultiplier,
    required this.unlockLevel,
  });
}

/// Era I Generators
const Map<GeneratorType, GeneratorData> eraIGenerators = {
  GeneratorType.windTurbine: GeneratorData(
    name: 'Wind Turbine',
    description: 'Harness atmospheric currents',
    icon: '🌀',
    baseProduction: 1.0,
    baseCost: 10,
    costMultiplier: 1.15,
    productionMultiplier: 1.0,
    unlockLevel: 0,
  ),
  GeneratorType.solarPanel: GeneratorData(
    name: 'Solar Array',
    description: 'Convert stellar radiation',
    icon: '☀️',
    baseProduction: 5.0,
    baseCost: 100,
    costMultiplier: 1.18,
    productionMultiplier: 1.2,
    unlockLevel: 5,
  ),
  GeneratorType.nuclearPlant: GeneratorData(
    name: 'Fission Reactor',
    description: 'Split atoms for energy',
    icon: '⚛️',
    baseProduction: 25.0,
    baseCost: 1000,
    costMultiplier: 1.20,
    productionMultiplier: 1.5,
    unlockLevel: 15,
  ),
  GeneratorType.fusionReactor: GeneratorData(
    name: 'Fusion Core',
    description: 'Stellar fire contained',
    icon: '🔥',
    baseProduction: 150.0,
    baseCost: 15000,
    costMultiplier: 1.22,
    productionMultiplier: 2.0,
    unlockLevel: 30,
  ),
  GeneratorType.orbitalArray: GeneratorData(
    name: 'Orbital Collector',
    description: 'Space-based solar harvesting',
    icon: '🛰️',
    baseProduction: 1000.0,
    baseCost: 200000,
    costMultiplier: 1.25,
    productionMultiplier: 2.5,
    unlockLevel: 50,
  ),
  GeneratorType.planetaryGrid: GeneratorData(
    name: 'Planetary Grid',
    description: 'Global energy network',
    icon: '🌐',
    baseProduction: 10000.0,
    baseCost: 5000000,
    costMultiplier: 1.30,
    productionMultiplier: 3.0,
    unlockLevel: 75,
  ),
};

/// Research/Tech Tree Categories
enum ResearchCategory {
  efficiency,
  automation,
  expansion,
  exotic,
}

/// Architect Rarity
enum ArchitectRarity {
  common,
  rare,
  epic,
  legendary,
}
