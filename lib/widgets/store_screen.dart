import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/ad_service.dart';
import '../services/iap_service.dart';
import '../services/membership_service.dart';
import '../providers/game_provider.dart';
import 'glass_container.dart';

/// Main Store Screen with all monetization options
class StoreScreen extends StatefulWidget {
  final GameProvider gameProvider;
  
  const StoreScreen({
    super.key,
    required this.gameProvider,
  });
  
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IAPService _iapService = IAPService();
  final MembershipService _membershipService = MembershipService();
  final AdService _adService = AdService();
  
  bool _isPurchasing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _purchaseProduct(IAPProduct product) async {
    if (_isPurchasing) return;
    
    setState(() => _isPurchasing = true);
    
    try {
      final result = await _iapService.purchaseProduct(product);
      
      if (result.success && result.rewards != null) {
        // Apply rewards
        if (result.rewards!.containsKey('darkMatter')) {
          widget.gameProvider.addDarkMatter(
            (result.rewards!['darkMatter'] as num).toDouble()
          );
        }
        
        // Handle subscription
        if (product.type == ProductType.subscription) {
          _membershipService.activateMembership();
          widget.gameProvider.state.isMember = true;
          widget.gameProvider.state.membershipExpiresAt = 
              DateTime.now().add(const Duration(days: 30));
          widget.gameProvider.state.membershipStartedAt = DateTime.now();
        }
        
        // Handle founder's pack
        if (product.id == 'founders_pack') {
          widget.gameProvider.state.hasFoundersPack = true;
          widget.gameProvider.state.purchasedProductIds.add(product.id);
          
          // Grant guaranteed rare architect
          if (result.rewards!['guaranteedRareArchitect'] == true) {
            // TODO: Implement guaranteed rare architect grant
          }
          
          // Grant time warps
          if (result.rewards!.containsKey('timeWarps')) {
            final timeWarps = (result.rewards!['timeWarps'] as num).toInt();
            for (int i = 0; i < timeWarps; i++) {
              widget.gameProvider.activateTimeWarp(hours: 1);
            }
          }
        }
        
        // Handle cosmetics
        if (result.rewards!.containsKey('theme')) {
          widget.gameProvider.state.ownedCosmetics.add(result.rewards!['theme'] as String);
        }
        if (result.rewards!.containsKey('border')) {
          widget.gameProvider.state.ownedCosmetics.add(result.rewards!['border'] as String);
        }
        if (result.rewards!.containsKey('particles')) {
          widget.gameProvider.state.ownedCosmetics.add(result.rewards!['particles'] as String);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully purchased ${product.name}!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Purchase failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      setState(() => _isPurchasing = false);
    }
  }
  
  Future<void> _watchDailyDarkMatterAd() async {
    if (!_adService.canWatchAd(AdPlacement.dailyDarkMatter)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily Dark Matter ad already claimed today!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    final result = await _adService.showRewardedAd(AdPlacement.dailyDarkMatter);
    
    if (result.success) {
      widget.gameProvider.addDarkMatter(10);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+10 Dark Matter from ad reward!'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {});
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMedium,
        title: const Text(
          'COSMIC STORE',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldAccent,
          labelColor: AppColors.goldLight,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'DARK MATTER'),
            Tab(text: 'MEMBERSHIP'),
            Tab(text: 'SPECIALS'),
            Tab(text: 'COSMETICS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDarkMatterTab(),
          _buildMembershipTab(),
          _buildSpecialsTab(),
          _buildCosmeticsTab(),
        ],
      ),
    );
  }
  
  Widget _buildDarkMatterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current DM Balance
          _buildBalanceCard(),
          
          const SizedBox(height: 16),
          
          // Free Daily Dark Matter (Ad)
          _buildFreeDarkMatterCard(),
          
          const SizedBox(height: 24),
          
          const Text(
            'DARK MATTER PACKAGES',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Dark Matter Packages
          ...darkMatterPackages.map((product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProductCard(product),
          )),
        ],
      ),
    );
  }
  
  Widget _buildMembershipTab() {
    final isMember = _membershipService.isCosmicMember;
    final comparison = _membershipService.getMembershipComparison();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Membership Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldAccent.withValues(alpha: 0.3),
                  AppColors.goldDark.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.goldAccent.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: AppColors.goldLight,
                ),
                const SizedBox(height: 12),
                const Text(
                  'COSMIC MEMBERSHIP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldLight,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isMember ? 'ACTIVE' : '\$4.99/month',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                    color: isMember ? AppColors.success : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isMember && _membershipService.status.expiresAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expires: ${_membershipService.status.daysRemaining} days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Benefits Comparison
          const Text(
            'MEMBERSHIP BENEFITS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceDark,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'Feature',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Free',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cosmic',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rows
                ...comparison.map((row) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          row['feature'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row['free'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row['cosmic'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subscribe Button
          if (!isMember)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPurchasing 
                    ? null 
                    : () => _purchaseProduct(cosmicMembership),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPurchasing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'SUBSCRIBE NOW',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialsTab() {
    final isFoundersAvailable = _iapService.isFoundersPackAvailable;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Founder's Pack
          if (isFoundersAvailable) ...[
            const Text(
              'LIMITED TIME OFFER',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildFoundersPackCard(),
            const SizedBox(height: 24),
          ],
          
          // Free Rewards Section
          const Text(
            'FREE REWARDS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Free Time Warp (Ad)
          _buildFreeTimeWarpCard(),
          
          const SizedBox(height: 12),
          
          // Free Daily DM (Ad)
          _buildFreeDarkMatterCard(),
          
          const SizedBox(height: 24),
          
          // Time Warp Purchase
          const Text(
            'TIME WARPS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildTimeWarpCard(1, 20),
          const SizedBox(height: 8),
          _buildTimeWarpCard(4, 60),
          const SizedBox(height: 8),
          _buildTimeWarpCard(8, 100),
        ],
      ),
    );
  }
  
  Widget _buildCosmeticsTab() {
    final cosmetics = _iapService.getAvailableCosmetics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cosmetics.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppColors.success.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'All cosmetics owned!',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            const Text(
              'UI THEMES',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            
            ...cosmetics
                .where((c) => c.rewards.containsKey('theme'))
                .map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCosmeticCard(product),
                )),
            
            const SizedBox(height: 16),
            
            const Text(
              'EFFECTS & BORDERS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            
            ...cosmetics
                .where((c) => c.rewards.containsKey('particles') || c.rewards.containsKey('border'))
                .map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCosmeticCard(product),
                )),
          ],
        ],
      ),
    );
  }
  
  Widget _buildBalanceCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.dark_mode,
              color: Colors.purpleAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR BALANCE',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.gameProvider.state.darkMatter.toStringAsFixed(0)} DM',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFreeDarkMatterCard() {
    final canWatch = _adService.canWatchAd(AdPlacement.dailyDarkMatter);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: canWatch 
          ? AppColors.success.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canWatch 
                  ? AppColors.success.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.play_circle_filled,
              color: canWatch ? AppColors.success : AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FREE DAILY DARK MATTER',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canWatch ? 'Watch ad for +10 DM' : 'Come back tomorrow!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canWatch ? _watchDailyDarkMatterAd : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canWatch ? AppColors.success : AppColors.surfaceLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              canWatch ? 'WATCH' : 'CLAIMED',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFreeTimeWarpCard() {
    final canWatch = _adService.canWatchAd(AdPlacement.freeTimeWarp);
    final remaining = _adService.getRemainingWatches(AdPlacement.freeTimeWarp);
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: canWatch 
          ? AppColors.info.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canWatch 
                  ? AppColors.info.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.fast_forward,
              color: canWatch ? AppColors.info : AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FREE TIME WARP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canWatch ? 'Watch ad for 1 hour boost • $remaining/2 remaining' : 'Come back tomorrow!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canWatch ? () async {
              final result = await _adService.showRewardedAd(AdPlacement.freeTimeWarp);
              if (result.success) {
                widget.gameProvider.activateTimeWarp(hours: 1);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Free 1-hour Time Warp activated!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  setState(() {});
                }
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canWatch ? AppColors.info : AppColors.surfaceLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              canWatch ? 'WATCH' : 'CLAIMED',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductCard(IAPProduct product) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: product.badge != null 
          ? AppColors.goldAccent.withValues(alpha: 0.5)
          : null,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.dark_mode,
                    color: Colors.purpleAccent,
                    size: 28,
                  ),
                ),
                if (product.badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.badge == 'BEST VALUE' 
                            ? AppColors.goldAccent 
                            : AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isPurchasing ? null : () => _purchaseProduct(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isPurchasing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    product.priceString,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFoundersPackCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.warning.withValues(alpha: 0.6),
      showGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LIMITED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                foundersPack.priceString,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "FOUNDER'S PACK",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Best starter value! One-time purchase only.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildRewardRow(Icons.dark_mode, '200 Dark Matter'),
          _buildRewardRow(Icons.stars, 'Guaranteed Rare+ Architect'),
          _buildRewardRow(Icons.fast_forward, '3x 1-Hour Time Warps'),
          _buildRewardRow(Icons.border_all, 'Exclusive Founder Border'),
          _buildRewardRow(Icons.block, 'Remove 1 Ad Placement'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPurchasing 
                  ? null 
                  : () => _purchaseProduct(foundersPack),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'PURCHASE NOW',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.goldLight),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeWarpCard(int hours, int cost) {
    final canAfford = widget.gameProvider.state.darkMatter >= cost;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.info.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.fast_forward,
              color: AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$hours Hour${hours > 1 ? 's' : ''} of Production',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${GameProvider.formatNumber(widget.gameProvider.state.energyPerSecond * 3600 * hours)} Energy instantly',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford ? () {
              widget.gameProvider.activateTimeWarp(hours: hours);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$hours-hour Time Warp activated!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford 
                  ? Colors.purpleAccent 
                  : AppColors.surfaceLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dark_mode, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$cost',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCosmeticCard(IAPProduct product) {
    // Get DM cost from priceString (e.g., "50 DM" -> 50)
    final dmCost = int.tryParse(product.priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 50;
    final canAfford = widget.gameProvider.state.darkMatter >= dmCost;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: product.rewards.containsKey('theme')
                    ? [Colors.orange.withValues(alpha: 0.3), Colors.orange.withValues(alpha: 0.1)]
                    : [Colors.blue.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.1)],
              ),
            ),
            child: Icon(
              product.rewards.containsKey('theme') 
                  ? Icons.palette 
                  : product.rewards.containsKey('border')
                      ? Icons.border_all
                      : Icons.auto_awesome,
              color: product.rewards.containsKey('theme')
                  ? Colors.orange
                  : Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford ? () async {
              // Deduct DM and add cosmetic
              widget.gameProvider.state.darkMatter -= dmCost;
              final rewards = product.rewards;
              if (rewards.containsKey('theme')) {
                widget.gameProvider.state.ownedCosmetics.add(rewards['theme'] as String);
              }
              if (rewards.containsKey('border')) {
                widget.gameProvider.state.ownedCosmetics.add(rewards['border'] as String);
              }
              if (rewards.containsKey('particles')) {
                widget.gameProvider.state.ownedCosmetics.add(rewards['particles'] as String);
              }
              _iapService.loadPurchasedProducts([product.id]);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchased ${product.name}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford 
                  ? Colors.purpleAccent 
                  : AppColors.surfaceLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dark_mode, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$dmCost',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
