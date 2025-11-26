import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';

/// Generator Card V2 - Supports all eras
class GeneratorCardV2 extends StatelessWidget {
  final GeneratorDataV2 genData;
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  final VoidCallback onBuy;
  final VoidCallback onUpgrade;

  const GeneratorCardV2({
    super.key,
    required this.genData,
    required this.gameProvider,
    required this.eraConfig,
    required this.onBuy,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final count = gameProvider.state.getGeneratorCount(genData.id);
    final level = gameProvider.state.getGeneratorLevel(genData.id);
    final cost = gameProvider.state.getGeneratorCost(genData);
    final upgradeCost = gameProvider.state.getUpgradeCost(genData);
    final canBuy = gameProvider.state.energy >= cost;
    final canUpgrade = count > 0 && gameProvider.state.energy >= upgradeCost;
    final isUnlocked = gameProvider.state.isGeneratorUnlocked(genData);
    
    // Calculate production for this generator
    final production = genData.baseProduction * 
        count * 
        (1 + (level - 1) * 0.1) * 
        gameProvider.state.energyMultiplier *
        (1 + gameProvider.state.productionBonus) *
        (1 + gameProvider.state.prestigeBonus);

    if (!isUnlocked) {
      return _buildLockedCard();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: count > 0 ? 0.4 : 0.2),
          width: count > 0 ? 2 : 1,
        ),
        boxShadow: count > 0
            ? [
                BoxShadow(
                  color: eraConfig.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: eraConfig.primaryColor.withValues(alpha: 0.2),
                border: Border.all(
                  color: eraConfig.primaryColor.withValues(alpha: 0.5),
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

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          genData.name,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: count > 0 
                                ? eraConfig.accentColor 
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      if (count > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: eraConfig.primaryColor.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            'x$count',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: eraConfig.accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    genData.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Production
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: eraConfig.primaryColor.withValues(alpha: 0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 12,
                              color: eraConfig.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              count > 0
                                  ? '${GameProvider.formatNumber(production)}/s'
                                  : '+${GameProvider.formatNumber(genData.baseProduction)}/s',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 10,
                                color: eraConfig.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.blue.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            'Lv.$level',
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 10,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Buttons
            Column(
              children: [
                // Buy button
                _ActionButton(
                  text: GameProvider.formatNumber(cost),
                  icon: Icons.add,
                  enabled: canBuy,
                  color: eraConfig.primaryColor,
                  onPressed: canBuy ? onBuy : null,
                ),
                if (count > 0) ...[
                  const SizedBox(height: 8),
                  // Upgrade button
                  _ActionButton(
                    text: GameProvider.formatNumber(upgradeCost),
                    icon: Icons.arrow_upward,
                    enabled: canUpgrade,
                    color: Colors.blue,
                    isSmall: true,
                    onPressed: canUpgrade ? onUpgrade : null,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedCard() {
    // Count total generators in this era
    final eraGenerators = getGeneratorsForEra(genData.era);
    int totalInEra = 0;
    for (final gen in eraGenerators) {
      totalInEra += gameProvider.state.generators[gen.id] ?? 0;
    }
    final remaining = genData.unlockRequirement - totalInEra;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Locked icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Colors.white.withValues(alpha: 0.3),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    genData.name,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build $remaining more generators to unlock',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (totalInEra / genData.unlockRequirement).clamp(0, 1),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: eraConfig.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool enabled;
  final Color color;
  final bool isSmall;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.enabled,
    required this.color,
    this.isSmall = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: enabled 
              ? color.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmall ? 12 : 14,
              color: enabled ? color : Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: isSmall ? 9 : 10,
                fontWeight: FontWeight.bold,
                color: enabled ? color : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
