import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import 'glass_container.dart';

/// Generator purchase/upgrade card (Legacy wrapper - uses V2 generator system internally)
class GeneratorCard extends StatelessWidget {
  final GeneratorType type;
  final GameProvider gameProvider;
  final VoidCallback onBuy;
  final VoidCallback onUpgrade;
  
  const GeneratorCard({
    super.key,
    required this.type,
    required this.gameProvider,
    required this.onBuy,
    required this.onUpgrade,
  });
  
  @override
  Widget build(BuildContext context) {
    // Map legacy GeneratorType to V2 generator ID
    final genId = _mapTypeToId(type);
    final genData = getGeneratorById(genId);
    
    if (genData == null) {
      return const SizedBox(); // Generator not found
    }
    
    final count = gameProvider.state.getGeneratorCount(genId);
    final level = gameProvider.state.getGeneratorLevel(genId);
    final cost = gameProvider.state.getGeneratorCost(genData);
    final upgradeCost = gameProvider.state.getUpgradeCost(genData);
    final isUnlocked = gameProvider.state.isGeneratorUnlocked(genData);
    final canBuy = gameProvider.state.energy >= cost && isUnlocked;
    final canUpgrade = gameProvider.state.energy >= upgradeCost && count > 0;
    
    // Calculate production
    final production = count > 0
        ? genData.baseProduction * count * (1 + (level - 1) * 0.1)
        : genData.baseProduction;
    
    return AnimatedOpacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderColor: canBuy
            ? AppColors.goldAccent.withValues(alpha: 0.5)
            : AppColors.glassBorder,
        showGlow: canBuy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.goldAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      genData.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Name and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              genData.name,
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (count > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldAccent.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x$count',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldLight,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        genData.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Stats row
            Row(
              children: [
                // Production
                _StatChip(
                  icon: Icons.bolt,
                  label: '${GameProvider.formatNumber(production)}/s',
                  color: AppColors.eraIIEnergy,
                ),
                const SizedBox(width: 8),
                
                // Level
                if (count > 0)
                  _StatChip(
                    icon: Icons.arrow_upward,
                    label: 'Lv.$level',
                    color: AppColors.info,
                  ),
                
                const Spacer(),
                
                // Unlock requirement
                if (!isUnlocked)
                  Text(
                    'Unlock at ${genData.unlockRequirement} generators',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            
            if (isUnlocked) ...[
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  // Buy button
                  Expanded(
                    child: _ActionButton(
                      label: 'BUY',
                      cost: cost,
                      enabled: canBuy,
                      onPressed: onBuy,
                    ),
                  ),
                  
                  if (count > 0) ...[
                    const SizedBox(width: 8),
                    
                    // Upgrade button
                    Expanded(
                      child: _ActionButton(
                        label: 'UPGRADE',
                        cost: upgradeCost,
                        enabled: canUpgrade,
                        onPressed: onUpgrade,
                        isUpgrade: true,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Map legacy GeneratorType to V2 generator ID
  String _mapTypeToId(GeneratorType type) {
    switch (type) {
      case GeneratorType.windTurbine:
        return 'wind_turbine';
      case GeneratorType.solarPanel:
        return 'solar_panel';
      case GeneratorType.nuclearPlant:
        return 'nuclear_plant';
      case GeneratorType.fusionReactor:
        return 'fusion_reactor';
      case GeneratorType.orbitalArray:
        return 'orbital_array';
      case GeneratorType.planetaryGrid:
        return 'planetary_grid';
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final double cost;
  final bool enabled;
  final VoidCallback onPressed;
  final bool isUpgrade;
  
  const _ActionButton({
    required this.label,
    required this.cost,
    required this.enabled,
    required this.onPressed,
    this.isUpgrade = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = isUpgrade ? AppColors.info : AppColors.goldAccent;
    
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.6)
                : Colors.grey.withValues(alpha: 0.3),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: enabled
                ? [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ]
                : [
                    Colors.grey.withValues(alpha: 0.1),
                    Colors.grey.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: enabled ? color : Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bolt,
                  size: 12,
                  color: enabled ? color : Colors.grey,
                ),
                Text(
                  GameProvider.formatNumber(cost),
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    color: enabled ? color : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
