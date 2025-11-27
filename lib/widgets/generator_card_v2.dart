import 'dart:math';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

/// Buy amount options
enum BuyAmount { x1, x10, x100, max }

/// Generator Card V2 - Supports all eras with bulk buy
class GeneratorCardV2 extends StatefulWidget {
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
  State<GeneratorCardV2> createState() => _GeneratorCardV2State();
}

class _GeneratorCardV2State extends State<GeneratorCardV2> {
  static BuyAmount _selectedAmount = BuyAmount.x1; // Shared across all cards

  int _getBuyCount() {
    switch (_selectedAmount) {
      case BuyAmount.x1:
        return 1;
      case BuyAmount.x10:
        return 10;
      case BuyAmount.x100:
        return 100;
      case BuyAmount.max:
        return _calculateMaxBuy();
    }
  }

  int _calculateMaxBuy() {
    final state = widget.gameProvider.state;
    double available = state.energy;
    int count = state.getGeneratorCount(widget.genData.id);
    int canBuy = 0;
    
    while (canBuy < 1000) { // Cap at 1000 to prevent infinite loops
      final cost = widget.genData.baseCost * 
          pow(widget.genData.costMultiplier, count + canBuy) *
          (1 - state.costReductionBonus);
      if (available >= cost) {
        available -= cost;
        canBuy++;
      } else {
        break;
      }
    }
    
    return max(1, canBuy);
  }

  double _calculateBulkCost(int amount) {
    final state = widget.gameProvider.state;
    int currentCount = state.getGeneratorCount(widget.genData.id);
    double totalCost = 0;
    
    for (int i = 0; i < amount; i++) {
      totalCost += widget.genData.baseCost * 
          pow(widget.genData.costMultiplier, currentCount + i) *
          (1 - state.costReductionBonus);
    }
    
    return totalCost;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.gameProvider.state.getGeneratorCount(widget.genData.id);
    final level = widget.gameProvider.state.getGeneratorLevel(widget.genData.id);
    final buyCount = _getBuyCount();
    final bulkCost = _calculateBulkCost(buyCount);
    final upgradeCost = widget.gameProvider.state.getUpgradeCost(widget.genData);
    final canBuy = widget.gameProvider.state.energy >= bulkCost;
    final canUpgrade = count > 0 && widget.gameProvider.state.energy >= upgradeCost;
    final isUnlocked = widget.gameProvider.state.isGeneratorUnlocked(widget.genData);
    
    // Calculate production for this generator
    final production = widget.genData.baseProduction * 
        count * 
        (1 + (level - 1) * 0.1) * 
        widget.gameProvider.state.energyMultiplier *
        (1 + widget.gameProvider.state.productionBonus) *
        (1 + widget.gameProvider.state.prestigeBonus);

    if (!isUnlocked) {
      return _buildLockedCard();
    }
    
    final eraConfig = widget.eraConfig;
    final genData = widget.genData;

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
                // Bulk buy selector
                _BulkBuySelector(
                  selectedAmount: _selectedAmount,
                  onChanged: (amount) => setState(() => _selectedAmount = amount),
                  color: eraConfig.primaryColor,
                ),
                const SizedBox(height: 6),
                // Buy button with amount
                _ActionButton(
                  text: '${buyCount > 1 ? "x$buyCount " : ""}${GameProvider.formatNumber(bulkCost)}',
                  icon: Icons.add,
                  enabled: canBuy,
                  color: eraConfig.primaryColor,
                  onPressed: canBuy ? () {
                    if (buyCount == 1) {
                      widget.onBuy();
                    } else {
                      widget.gameProvider.buyGeneratorBulkV2(genData, buyCount);
                    }
                    AudioService.playPurchase();
                  } : null,
                ),
                if (count > 0) ...[
                  const SizedBox(height: 6),
                  // Upgrade button
                  _ActionButton(
                    text: GameProvider.formatNumber(upgradeCost),
                    icon: Icons.arrow_upward,
                    enabled: canUpgrade,
                    color: Colors.blue,
                    isSmall: true,
                    onPressed: canUpgrade ? () {
                      widget.onUpgrade();
                      AudioService.playPurchase();
                    } : null,
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
    final genData = widget.genData;
    final eraConfig = widget.eraConfig;
    // Count total generators in this era
    final eraGenerators = getGeneratorsForEra(genData.era);
    int totalInEra = 0;
    for (final gen in eraGenerators) {
      totalInEra += widget.gameProvider.state.generators[gen.id] ?? 0;
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

/// Bulk buy amount selector
class _BulkBuySelector extends StatelessWidget {
  final BuyAmount selectedAmount;
  final ValueChanged<BuyAmount> onChanged;
  final Color color;

  const _BulkBuySelector({
    required this.selectedAmount,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOption(BuyAmount.x1, 'x1'),
        _buildOption(BuyAmount.x10, 'x10'),
        _buildOption(BuyAmount.x100, 'x100'),
        _buildOption(BuyAmount.max, 'MAX'),
      ],
    );
  }

  Widget _buildOption(BuyAmount amount, String label) {
    final isSelected = selectedAmount == amount;
    return GestureDetector(
      onTap: () => onChanged(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isSelected 
              ? color.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 7,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.white.withValues(alpha: 0.4),
          ),
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
          horizontal: isSmall ? 8 : 10,
          vertical: isSmall ? 4 : 6,
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
                fontSize: isSmall ? 8 : 9,
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
