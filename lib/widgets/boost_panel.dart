import 'package:flutter/material.dart';
import 'dart:async';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';

/// Compact boost panel for the main game screen
/// Provides quick access to production boosts and time warps
class BoostPanel extends StatefulWidget {
  final GameProvider gameProvider;
  final VoidCallback? onOpenStore;
  
  const BoostPanel({
    super.key,
    required this.gameProvider,
    this.onOpenStore,
  });
  
  @override
  State<BoostPanel> createState() => _BoostPanelState();
}

class _BoostPanelState extends State<BoostPanel> {
  final AdService _adService = AdService();
  Timer? _updateTimer;
  
  @override
  void initState() {
    super.initState();
    // Update UI every second for active boost timers
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final hasActiveBoost = widget.gameProvider.hasActiveBoost;
    final boostRemaining = widget.gameProvider.boostRemainingTime;
    final darkMatter = widget.gameProvider.state.darkMatter;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Boost Status (if any)
          if (hasActiveBoost)
            _buildActiveBoostBanner(boostRemaining),
          
          if (hasActiveBoost)
            const SizedBox(height: 16),
          
          // Quick Boosts Section
          _buildSectionHeader('QUICK BOOSTS', Icons.flash_on, const Color(0xFFFFD700)),
          const SizedBox(height: 12),
          _buildQuickBoostGrid(darkMatter),
          
          const SizedBox(height: 20),
          
          // Power Surge Section (the 100x boost, balanced)
          _buildSectionHeader('POWER SURGE', Icons.offline_bolt, const Color(0xFFFF6B6B)),
          const SizedBox(height: 8),
          _buildPowerSurgeInfo(),
          const SizedBox(height: 12),
          _buildPowerSurgeOptions(darkMatter),
          
          const SizedBox(height: 20),
          
          // Free Boost (Ad-based)
          _buildSectionHeader('FREE BOOST', Icons.play_circle, const Color(0xFF4CAF50)),
          const SizedBox(height: 12),
          _buildFreeBoostCard(),
          
          const SizedBox(height: 20),
          
          // Dark Matter Balance
          _buildDarkMatterBalance(darkMatter),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActiveBoostBanner(Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final multiplier = widget.gameProvider.productionBoostMultiplier;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.3),
            const Color(0xFFFF6B00).withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
            child: const Icon(
              Icons.flash_on,
              color: Color(0xFFFFD700),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOOST ACTIVE: ${multiplier.toStringAsFixed(0)}X',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${minutes}m ${seconds}s remaining',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: remaining.inSeconds / 3600, // Assume max 1 hour
              strokeWidth: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickBoostGrid(double darkMatter) {
    return Row(
      children: [
        Expanded(child: _buildTimeWarpButton(1, 100, darkMatter)),
        const SizedBox(width: 8),
        Expanded(child: _buildTimeWarpButton(4, 300, darkMatter)),
        const SizedBox(width: 8),
        Expanded(child: _buildTimeWarpButton(8, 500, darkMatter)),
      ],
    );
  }
  
  Widget _buildTimeWarpButton(int hours, int cost, double darkMatter) {
    final canAfford = darkMatter >= cost;
    final label = hours == 1 ? '1 HR' : '$hours HRS';
    
    return GestureDetector(
      onTap: canAfford ? () => _activateTimeWarp(hours, cost) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: canAfford 
              ? const Color(0xFF2196F3).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: canAfford 
                ? const Color(0xFF2196F3).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fast_forward,
              color: canAfford ? const Color(0xFF2196F3) : Colors.white.withValues(alpha: 0.3),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: canAfford ? Colors.white : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.blur_circular,
                  color: canAfford ? const Color(0xFFCE93D8) : Colors.white.withValues(alpha: 0.3),
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  '$cost',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: canAfford ? const Color(0xFFCE93D8) : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPowerSurgeInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Massive temporary boost! Use strategically for big purchases.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPowerSurgeOptions(double darkMatter) {
    // Power Surge options - balanced with high cost and cooldown considerations
    // 10x for 2 min (200 DM) - Safe, moderate boost
    // 25x for 1 min (400 DM) - Powerful but short
    // 50x for 30 sec (600 DM) - Very powerful, very short
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPowerSurgeButton(10, 2, 200, darkMatter, const Color(0xFFFFB74D))),
            const SizedBox(width: 8),
            Expanded(child: _buildPowerSurgeButton(25, 1, 400, darkMatter, const Color(0xFFFF8A65))),
          ],
        ),
        const SizedBox(height: 8),
        _buildPowerSurgeButton(50, 0.5, 600, darkMatter, const Color(0xFFFF6B6B), fullWidth: true),
      ],
    );
  }
  
  Widget _buildPowerSurgeButton(double multiplier, double minutes, int cost, double darkMatter, Color color, {bool fullWidth = false}) {
    final canAfford = darkMatter >= cost;
    final hasActiveBoost = widget.gameProvider.hasActiveBoost;
    final isDisabled = !canAfford || hasActiveBoost;
    
    final durationText = minutes >= 1 
        ? '${minutes.toInt()} MIN' 
        : '${(minutes * 60).toInt()} SEC';
    
    return GestureDetector(
      onTap: isDisabled ? null : () => _activatePowerSurge(multiplier, minutes, cost),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: fullWidth ? 14 : 12,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isDisabled ? null : LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
            ],
          ),
          color: isDisabled ? Colors.white.withValues(alpha: 0.05) : null,
          border: Border.all(
            color: isDisabled 
                ? Colors.white.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.offline_bolt,
              color: isDisabled ? Colors.white.withValues(alpha: 0.3) : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${multiplier.toInt()}X SURGE',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.white.withValues(alpha: 0.4) : Colors.white,
                  ),
                ),
                Text(
                  durationText,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDisabled ? Colors.white.withValues(alpha: 0.3) : color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isDisabled 
                    ? Colors.white.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.blur_circular,
                    color: isDisabled 
                        ? Colors.white.withValues(alpha: 0.3) 
                        : const Color(0xFFCE93D8),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$cost',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDisabled 
                          ? Colors.white.withValues(alpha: 0.4) 
                          : const Color(0xFFCE93D8),
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
  
  Widget _buildFreeBoostCard() {
    final canWatch = _adService.canWatchAd(AdPlacement.freeTimeWarp);
    final remaining = _adService.getRemainingWatches(AdPlacement.freeTimeWarp);
    
    return GestureDetector(
      onTap: canWatch ? _watchAdForBoost : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: canWatch 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: canWatch 
                ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: canWatch 
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.play_circle_fill,
                color: canWatch ? const Color(0xFF4CAF50) : Colors.white.withValues(alpha: 0.3),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WATCH AD FOR 1HR BOOST',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: canWatch ? Colors.white : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canWatch ? '$remaining/2 available today' : 'Come back tomorrow!',
                    style: TextStyle(
                      fontSize: 11,
                      color: canWatch 
                          ? const Color(0xFF4CAF50)
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: canWatch 
                    ? const Color(0xFF4CAF50)
                    : Colors.white.withValues(alpha: 0.1),
              ),
              child: Text(
                'FREE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: canWatch ? Colors.white : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDarkMatterBalance(double darkMatter) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9C27B0).withValues(alpha: 0.2),
            const Color(0xFF7B1FA2).withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.blur_circular,
            color: const Color(0xFFCE93D8),
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DARK MATTER',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
              Text(
                GameProvider.formatNumber(darkMatter),
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCE93D8),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _openStore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Color(0xFFCE93D8), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'GET MORE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCE93D8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _activateTimeWarp(int hours, int cost) {
    if (widget.gameProvider.state.darkMatter >= cost) {
      widget.gameProvider.state.darkMatter -= cost;
      // Use activateFreeTimeWarp since we already deducted DM manually
      widget.gameProvider.activateFreeTimeWarp(hours: hours);
      AudioService.playPurchase();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$hours-hour Time Warp activated!'),
            backgroundColor: const Color(0xFF2196F3),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _activatePowerSurge(double multiplier, double minutes, int cost) {
    if (widget.gameProvider.state.darkMatter >= cost && !widget.gameProvider.hasActiveBoost) {
      widget.gameProvider.state.darkMatter -= cost;
      widget.gameProvider.activateProductionBoost(
        multiplier,
        Duration(seconds: (minutes * 60).toInt()),
      );
      AudioService.playPurchase();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${multiplier.toInt()}X Power Surge activated!'),
            backgroundColor: const Color(0xFFFF6B6B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _watchAdForBoost() async {
    final result = await _adService.showRewardedAd(AdPlacement.freeTimeWarp);
    if (result.success) {
      widget.gameProvider.activateFreeTimeWarp(hours: 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free 1-hour boost activated!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {});
      }
    }
  }
  
  void _openStore() {
    // Navigate to store - handled by parent
    widget.onOpenStore?.call();
  }
}
