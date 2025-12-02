import 'dart:async';
import 'package:flutter/material.dart';
import '../services/daily_deals_service.dart';
import '../services/audio_service.dart';
import '../providers/game_provider.dart';

/// Daily deals carousel widget for store
class DailyDealsWidget extends StatefulWidget {
  final GameProvider gameProvider;
  final Function(DailyDeal)? onPurchase;
  
  const DailyDealsWidget({
    super.key,
    required this.gameProvider,
    this.onPurchase,
  });

  @override
  State<DailyDealsWidget> createState() => _DailyDealsWidgetState();
}

class _DailyDealsWidgetState extends State<DailyDealsWidget> {
  final DailyDealsService _dealsService = DailyDealsService();
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _dealsService.initialize();
    
    // Refresh every minute to update timers
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deals = _dealsService.getAllActiveDeals();
    final prestigeBundle = _dealsService.prestigeBundle;
    
    if (deals.isEmpty && prestigeBundle == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'SPECIAL OFFERS',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red.withValues(alpha: 0.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 12, color: Colors.red.shade300),
                    const SizedBox(width: 4),
                    Text(
                      'LIMITED',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // Prestige bundle first (highest priority)
              if (prestigeBundle != null)
                _buildPrestigeBundleCard(prestigeBundle),
              
              // Then other deals
              ...deals.map((deal) => _buildDealCard(deal)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDealCard(DailyDeal deal) {
    Color borderColor;
    Color bgColor;
    String emoji;
    
    switch (deal.type) {
      case DealType.flashSale:
        borderColor = Colors.yellow;
        bgColor = Colors.yellow.withValues(alpha: 0.1);
        emoji = '⚡';
        break;
      case DealType.weekendWarrior:
        borderColor = Colors.purple;
        bgColor = Colors.purple.withValues(alpha: 0.1);
        emoji = '🎉';
        break;
      case DealType.eraUnlockBundle:
        borderColor = Colors.cyan;
        bgColor = Colors.cyan.withValues(alpha: 0.1);
        emoji = '🌟';
        break;
      default:
        borderColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        emoji = '💰';
    }
    
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              gradient: LinearGradient(
                colors: [
                  borderColor.withValues(alpha: 0.4),
                  borderColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.title,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
                      ),
                      if (deal.badge != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: borderColor,
                          ),
                          child: Text(
                            deal.badge!,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Timer
                  Row(
                    children: [
                      Icon(Icons.timer, size: 12, color: Colors.red.shade300),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(deal.remainingTime),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        deal.originalPriceString,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deal.priceString,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Buy button
          GestureDetector(
            onTap: deal.isPurchased ? null : () {
              AudioService.playClick();
              widget.onPurchase?.call(deal);
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: deal.isPurchased 
                    ? Colors.grey.withValues(alpha: 0.3)
                    : borderColor,
              ),
              child: Center(
                child: Text(
                  deal.isPurchased ? 'PURCHASED' : 'BUY NOW',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: deal.isPurchased ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrestigeBundleCard(PrestigeBundle bundle) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withValues(alpha: 0.3),
            Colors.deepPurple.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.5),
                  Colors.deepPurple.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Row(
              children: [
                const Text('🎊', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.title,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.amber,
                        ),
                        child: Text(
                          'PRESTIGE ${bundle.prestigeLevel}',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Rewards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRewardRow('🌑', '${bundle.rewards['darkMatter']} DM'),
                  _buildRewardRow('⏩', '${bundle.rewards['timeWarps']}x Time Warp'),
                  _buildRewardRow('📈', '${((bundle.rewards['productionBoost'] as double) * 100).toInt()}% Boost'),
                  const Spacer(),
                  
                  // Timer
                  Row(
                    children: [
                      Icon(Icons.timer, size: 12, color: Colors.red.shade300),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(bundle.remainingTime),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Buy button
          GestureDetector(
            onTap: bundle.isPurchased ? null : () {
              AudioService.playClick();
              // Handle prestige bundle purchase
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: bundle.isPurchased ? null : const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                color: bundle.isPurchased ? Colors.grey.withValues(alpha: 0.3) : null,
              ),
              child: Center(
                child: Text(
                  bundle.isPurchased ? 'PURCHASED' : bundle.priceString,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: bundle.isPurchased ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Expiring!';
    }
  }
}

/// Compact deal banner for home screen
class DealBannerWidget extends StatelessWidget {
  final DailyDeal? deal;
  final VoidCallback? onTap;
  
  const DealBannerWidget({
    super.key,
    this.deal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (deal == null || deal!.isPurchased) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.orange.withValues(alpha: 0.3),
              Colors.red.withValues(alpha: 0.2),
            ],
          ),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal!.title,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    '${deal!.discountPercent}% OFF - ${deal!.priceString}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.orange,
              ),
              child: const Text(
                'VIEW',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
