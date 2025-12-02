import 'dart:math';
import 'package:flutter/foundation.dart';
import 'iap_service.dart';

/// Daily deal types
enum DealType {
  darkMatterDiscount,    // Discounted DM pack
  bundleDeal,            // Special bundle
  flashSale,             // Limited time (2 hours)
  prestigeWelcomeBack,   // After prestige
  eraUnlockBundle,       // When unlocking new era
  weekendWarrior,        // Weekend special
}

/// A daily deal offer
class DailyDeal {
  final String id;
  final DealType type;
  final String title;
  final String description;
  final IAPProduct? discountedProduct;
  final double originalPrice;
  final double salePrice;
  final int discountPercent;
  final Map<String, dynamic> rewards;
  final DateTime expiresAt;
  final bool isPurchased;
  final String? badge;
  
  const DailyDeal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.discountedProduct,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.rewards,
    required this.expiresAt,
    this.isPurchased = false,
    this.badge,
  });
  
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get priceString => '\$${salePrice.toStringAsFixed(2)}';
  String get originalPriceString => '\$${originalPrice.toStringAsFixed(2)}';
  
  DailyDeal copyWith({bool? isPurchased}) {
    return DailyDeal(
      id: id,
      type: type,
      title: title,
      description: description,
      discountedProduct: discountedProduct,
      originalPrice: originalPrice,
      salePrice: salePrice,
      discountPercent: discountPercent,
      rewards: rewards,
      expiresAt: expiresAt,
      isPurchased: isPurchased ?? this.isPurchased,
      badge: badge,
    );
  }
}

/// Prestige welcome back bundle
class PrestigeBundle {
  final String id;
  final int prestigeLevel;
  final String title;
  final String description;
  final double price;
  final Map<String, dynamic> rewards;
  final DateTime expiresAt;
  final bool isPurchased;
  
  const PrestigeBundle({
    required this.id,
    required this.prestigeLevel,
    required this.title,
    required this.description,
    required this.price,
    required this.rewards,
    required this.expiresAt,
    this.isPurchased = false,
  });
  
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get priceString => '\$${price.toStringAsFixed(2)}';
}

/// Service for managing daily deals and special offers
class DailyDealsService {
  static final DailyDealsService _instance = DailyDealsService._internal();
  factory DailyDealsService() => _instance;
  DailyDealsService._internal();
  
  // Current deals
  DailyDeal? _currentDailyDeal;
  DailyDeal? _currentFlashSale;
  PrestigeBundle? _prestigeBundle;
  DailyDeal? _weekendDeal;
  
  // Tracking
  DateTime? _lastDailyDealDate;
  final Set<String> _purchasedDealIds = {};
  
  // Callbacks
  Function(DailyDeal)? onNewDealAvailable;
  Function(PrestigeBundle)? onPrestigeBundleAvailable;
  
  /// Initialize service
  Future<void> initialize() async {
    _generateDailyDeal();
    _checkWeekendDeal();
    _checkFlashSale();
    
    if (kDebugMode) {
      debugPrint('DailyDealsService initialized');
    }
  }
  
  /// Get current daily deal
  DailyDeal? get currentDailyDeal {
    if (_currentDailyDeal?.isExpired ?? true) {
      _generateDailyDeal();
    }
    return _currentDailyDeal;
  }
  
  /// Get current flash sale (if active)
  DailyDeal? get currentFlashSale {
    if (_currentFlashSale?.isExpired ?? true) {
      return null;
    }
    return _currentFlashSale;
  }
  
  /// Get prestige welcome back bundle (if available)
  PrestigeBundle? get prestigeBundle {
    if (_prestigeBundle?.isExpired ?? true) {
      return null;
    }
    return _prestigeBundle;
  }
  
  /// Get weekend deal (if it's weekend)
  DailyDeal? get weekendDeal {
    if (_weekendDeal?.isExpired ?? true) {
      _checkWeekendDeal();
    }
    return _weekendDeal;
  }
  
  /// Get all active deals
  List<DailyDeal> getAllActiveDeals() {
    final deals = <DailyDeal>[];
    
    if (currentDailyDeal != null && !currentDailyDeal!.isPurchased) {
      deals.add(currentDailyDeal!);
    }
    if (currentFlashSale != null && !currentFlashSale!.isPurchased) {
      deals.add(currentFlashSale!);
    }
    if (weekendDeal != null && !weekendDeal!.isPurchased) {
      deals.add(weekendDeal!);
    }
    
    return deals;
  }
  
  /// Generate daily deal
  void _generateDailyDeal() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if we need a new deal
    if (_lastDailyDealDate != null && !today.isAfter(_lastDailyDealDate!)) {
      if (_currentDailyDeal != null && !_currentDailyDeal!.isExpired) {
        return; // Current deal still valid
      }
    }
    
    _lastDailyDealDate = today;
    
    // Use day of year as seed for consistent daily rotation
    final seed = today.difference(DateTime(today.year, 1, 1)).inDays;
    final random = Random(seed);
    
    // Select a random DM pack to discount
    final packIndex = random.nextInt(darkMatterPackages.length);
    final selectedPack = darkMatterPackages[packIndex];
    
    // Generate discount (15-30%)
    final discountPercent = 15 + random.nextInt(16);
    final salePrice = selectedPack.price * (1 - discountPercent / 100);
    
    // Calculate bonus DM
    final baseDM = (selectedPack.rewards['darkMatter'] as num).toDouble();
    final bonusDM = (baseDM * 0.1).round(); // 10% bonus on top of discount
    
    _currentDailyDeal = DailyDeal(
      id: 'daily_deal_$seed',
      type: DealType.darkMatterDiscount,
      title: 'DAILY DEAL',
      description: '${selectedPack.name} + ${bonusDM} Bonus DM',
      discountedProduct: selectedPack,
      originalPrice: selectedPack.price,
      salePrice: double.parse(salePrice.toStringAsFixed(2)),
      discountPercent: discountPercent,
      rewards: {
        'darkMatter': baseDM + bonusDM,
        'originalProduct': selectedPack.id,
      },
      expiresAt: today.add(const Duration(days: 1)),
      isPurchased: _purchasedDealIds.contains('daily_deal_$seed'),
      badge: '$discountPercent% OFF',
    );
    
    onNewDealAvailable?.call(_currentDailyDeal!);
  }
  
  /// Check and generate weekend deal
  void _checkWeekendDeal() {
    final now = DateTime.now();
    
    // Weekend is Saturday (6) and Sunday (7)
    if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
      _weekendDeal = null;
      return;
    }
    
    // Calculate weekend end (Monday 00:00)
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final weekendEnd = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));
    
    final weekId = '${now.year}_${(now.difference(DateTime(now.year, 1, 1)).inDays / 7).floor()}';
    
    _weekendDeal = DailyDeal(
      id: 'weekend_warrior_$weekId',
      type: DealType.weekendWarrior,
      title: 'WEEKEND WARRIOR',
      description: 'Massive DM Bundle + Exclusive Border',
      discountedProduct: null,
      originalPrice: 14.99,
      salePrice: 9.99,
      discountPercent: 33,
      rewards: {
        'darkMatter': 1500,
        'timeWarps': 3,
        'exclusiveBorder': 'weekend_warrior',
        'productionBoost': 2.0, // 2x production for 4 hours
        'productionBoostDuration': 4,
      },
      expiresAt: weekendEnd,
      isPurchased: _purchasedDealIds.contains('weekend_warrior_$weekId'),
      badge: 'WEEKEND',
    );
  }
  
  /// Generate flash sale (random chance)
  void _checkFlashSale() {
    final now = DateTime.now();
    
    // 10% chance of flash sale each hour
    final hourSeed = now.hour + now.day * 24 + now.month * 720;
    final random = Random(hourSeed);
    
    if (random.nextInt(100) < 10) {
      final packIndex = random.nextInt(darkMatterPackages.length);
      final selectedPack = darkMatterPackages[packIndex];
      
      // Flash sales are 40-50% off
      final discountPercent = 40 + random.nextInt(11);
      final salePrice = selectedPack.price * (1 - discountPercent / 100);
      
      _currentFlashSale = DailyDeal(
        id: 'flash_sale_$hourSeed',
        type: DealType.flashSale,
        title: '⚡ FLASH SALE ⚡',
        description: '${selectedPack.name} - LIMITED TIME!',
        discountedProduct: selectedPack,
        originalPrice: selectedPack.price,
        salePrice: double.parse(salePrice.toStringAsFixed(2)),
        discountPercent: discountPercent,
        rewards: selectedPack.rewards,
        expiresAt: now.add(const Duration(hours: 2)),
        isPurchased: _purchasedDealIds.contains('flash_sale_$hourSeed'),
        badge: '2 HOURS ONLY',
      );
    }
  }
  
  /// Trigger prestige welcome back bundle
  void triggerPrestigeBundle(int prestigeLevel) {
    final now = DateTime.now();
    final bundleId = 'prestige_bundle_${prestigeLevel}_${now.millisecondsSinceEpoch}';
    
    // Scale rewards with prestige level
    final baseDM = 100 + (prestigeLevel * 50);
    final timeWarps = 1 + (prestigeLevel ~/ 5);
    final productionBoost = 1.0 + (prestigeLevel * 0.1);
    
    // Scale price with prestige level (higher prestige = better value)
    final basePrice = 2.99;
    final scaledPrice = basePrice + (prestigeLevel * 0.5).clamp(0, 5);
    
    _prestigeBundle = PrestigeBundle(
      id: bundleId,
      prestigeLevel: prestigeLevel,
      title: 'WELCOME BACK, ASCENDANT!',
      description: 'Prestige ${prestigeLevel} Celebration Bundle',
      price: double.parse(scaledPrice.toStringAsFixed(2)),
      rewards: {
        'darkMatter': baseDM,
        'timeWarps': timeWarps,
        'productionBoost': productionBoost,
        'productionBoostDuration': 2, // 2 hours
        'energyMultiplier': 1.5, // 50% more energy for 1 hour
        'energyMultiplierDuration': 1,
      },
      expiresAt: now.add(const Duration(hours: 24)),
      isPurchased: _purchasedDealIds.contains(bundleId),
    );
    
    onPrestigeBundleAvailable?.call(_prestigeBundle!);
  }
  
  /// Trigger era unlock bundle
  DailyDeal triggerEraUnlockBundle(int eraIndex) {
    final now = DateTime.now();
    final eraNames = ['Planetary', 'Stellar', 'Galactic', 'Universal', 'Transcendent'];
    final bundleId = 'era_unlock_${eraIndex}_${now.millisecondsSinceEpoch}';
    
    // Scale rewards with era
    final baseDM = 200 * (eraIndex + 1);
    final timeWarps = 2 + eraIndex;
    
    // Era-specific pricing
    final prices = [2.99, 4.99, 7.99, 9.99, 14.99];
    final price = prices[eraIndex.clamp(0, prices.length - 1)];
    
    return DailyDeal(
      id: bundleId,
      type: DealType.eraUnlockBundle,
      title: 'ERA ${eraNames[eraIndex.clamp(0, eraNames.length - 1)].toUpperCase()} UNLOCKED!',
      description: 'Celebration Bundle - Limited Time!',
      discountedProduct: null,
      originalPrice: price * 1.5,
      salePrice: price,
      discountPercent: 33,
      rewards: {
        'darkMatter': baseDM,
        'timeWarps': timeWarps,
        'productionBoost': 2.0,
        'productionBoostDuration': 4,
        'eraTheme': 'era_${eraIndex}_celebration',
      },
      expiresAt: now.add(const Duration(hours: 48)),
      isPurchased: _purchasedDealIds.contains(bundleId),
      badge: 'NEW ERA',
    );
  }
  
  /// Mark deal as purchased
  void markDealPurchased(String dealId) {
    _purchasedDealIds.add(dealId);
    
    // Update deal states
    if (_currentDailyDeal?.id == dealId) {
      _currentDailyDeal = _currentDailyDeal!.copyWith(isPurchased: true);
    }
    if (_currentFlashSale?.id == dealId) {
      _currentFlashSale = _currentFlashSale!.copyWith(isPurchased: true);
    }
    if (_weekendDeal?.id == dealId) {
      _weekendDeal = _weekendDeal!.copyWith(isPurchased: true);
    }
  }
  
  /// Mark prestige bundle as purchased
  void markPrestigeBundlePurchased(String bundleId) {
    _purchasedDealIds.add(bundleId);
    _prestigeBundle = null;
  }
  
  /// Load purchased deal IDs from storage
  void loadPurchasedDeals(List<String> dealIds) {
    _purchasedDealIds.addAll(dealIds);
  }
  
  /// Get list of purchased deal IDs
  List<String> getPurchasedDealIds() {
    return _purchasedDealIds.toList();
  }
}
