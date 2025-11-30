import 'dart:async';
import 'package:flutter/foundation.dart';

/// Product types for IAP
enum ProductType {
  consumable,     // Dark Matter packages
  nonConsumable,  // Founder's Pack, cosmetics
  subscription,   // Cosmic Membership
}

/// IAP Product definition
class IAPProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String priceString;
  final ProductType type;
  final Map<String, dynamic> rewards;
  final bool isOneTime; // For founder's pack
  final String? badge; // "BEST VALUE", "POPULAR", etc.
  
  const IAPProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceString,
    required this.type,
    required this.rewards,
    this.isOneTime = false,
    this.badge,
  });
}

/// Dark Matter packages
const List<IAPProduct> darkMatterPackages = [
  IAPProduct(
    id: 'dm_starter',
    name: 'Starter Pack',
    description: '100 Dark Matter + 10% bonus',
    price: 0.99,
    priceString: '\$0.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 110, // 100 + 10% bonus
    },
  ),
  IAPProduct(
    id: 'dm_explorer',
    name: 'Explorer Pack',
    description: '300 Dark Matter + 15% bonus',
    price: 2.99,
    priceString: '\$2.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 345, // 300 + 15% bonus
    },
    badge: 'POPULAR',
  ),
  IAPProduct(
    id: 'dm_ascension',
    name: 'Ascension Pack',
    description: '750 Dark Matter + 20% bonus',
    price: 4.99,
    priceString: '\$4.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 900, // 750 + 20% bonus
    },
  ),
  IAPProduct(
    id: 'dm_cosmic',
    name: 'Cosmic Pack',
    description: '2000 Dark Matter + 25% bonus',
    price: 9.99,
    priceString: '\$9.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 2500, // 2000 + 25% bonus
    },
    badge: 'BEST VALUE',
  ),
  IAPProduct(
    id: 'dm_universal',
    name: 'Universal Pack',
    description: '5000 Dark Matter + 30% bonus',
    price: 19.99,
    priceString: '\$19.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 6500, // 5000 + 30% bonus
    },
  ),
];

/// Founder's Pack (one-time purchase)
const IAPProduct foundersPack = IAPProduct(
  id: 'founders_pack',
  name: "Founder's Pack",
  description: 'Best starter value! One-time only.',
  price: 2.99,
  priceString: '\$2.99',
  type: ProductType.nonConsumable,
  rewards: {
    'darkMatter': 200,
    'guaranteedRareArchitect': true,
    'exclusiveBorder': 'founders_gold',
    'timeWarps': 3, // 3x 1-hour time warps
    'removeOneAdPlacement': true,
  },
  isOneTime: true,
  badge: 'LIMITED',
);

/// Cosmic Membership subscription
const IAPProduct cosmicMembership = IAPProduct(
  id: 'cosmic_membership',
  name: 'Cosmic Membership',
  description: 'Premium benefits renewed monthly',
  price: 4.99,
  priceString: '\$4.99/month',
  type: ProductType.subscription,
  rewards: {
    'dailyRewardMultiplier': 2.0,
    'bonusDailyChallenge': 1,
    'offlineEfficiencyBonus': 0.5, // +50%
    'offlineHoursLimit': 24, // 24 hours vs 3 hours
    'freeTimeWarpPerDay': 1,
    'exclusiveBorder': 'cosmic_member',
    'monthlyDarkMatter': 500,
    'maxExpeditions': 4, // vs 3
  },
);

/// Cosmetic items
const List<IAPProduct> cosmeticItems = [
  IAPProduct(
    id: 'theme_stellar',
    name: 'Stellar Theme',
    description: 'Golden UI accent colors',
    price: 0.99,
    priceString: '50 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'stellar_gold'},
  ),
  IAPProduct(
    id: 'theme_void',
    name: 'Void Theme',
    description: 'Dark purple UI accents',
    price: 0.99,
    priceString: '50 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'void_purple'},
  ),
  IAPProduct(
    id: 'particles_cosmic',
    name: 'Cosmic Particles',
    description: 'Special tap particle effects',
    price: 1.99,
    priceString: '100 DM',
    type: ProductType.nonConsumable,
    rewards: {'particles': 'cosmic_burst'},
  ),
  IAPProduct(
    id: 'border_legendary',
    name: 'Legendary Border',
    description: 'Animated profile border',
    price: 1.99,
    priceString: '100 DM',
    type: ProductType.nonConsumable,
    rewards: {'border': 'legendary_animated'},
  ),
];

/// Purchase result
class PurchaseResult {
  final bool success;
  final String? error;
  final IAPProduct? product;
  final Map<String, dynamic>? rewards;
  
  const PurchaseResult({
    required this.success,
    this.error,
    this.product,
    this.rewards,
  });
}

/// Service for managing in-app purchases
/// Note: In production, integrate with in_app_purchase package
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();
  
  // Track purchases
  final Set<String> _purchasedProducts = {};
  bool _isInitialized = false;
  
  // Callbacks
  Function(PurchaseResult)? onPurchaseCompleted;
  
  /// Initialize IAP service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // In production: Initialize in_app_purchase
    // final available = await InAppPurchase.instance.isAvailable();
    
    _isInitialized = true;
    
    if (kDebugMode) {
      debugPrint('IAPService initialized (simulation mode)');
    }
  }
  
  /// Check if a product has been purchased (for non-consumables)
  bool isPurchased(String productId) {
    return _purchasedProducts.contains(productId);
  }
  
  /// Check if founder's pack is available (not yet purchased)
  bool get isFoundersPackAvailable => !isPurchased(foundersPack.id);
  
  /// Get all available products
  List<IAPProduct> getAllProducts() {
    return [
      ...darkMatterPackages,
      if (isFoundersPackAvailable) foundersPack,
      cosmicMembership,
      ...cosmeticItems.where((c) => !isPurchased(c.id)),
    ];
  }
  
  /// Get dark matter packages
  List<IAPProduct> getDarkMatterPackages() => darkMatterPackages;
  
  /// Get cosmetic items (unpurchased only)
  List<IAPProduct> getAvailableCosmetics() {
    return cosmeticItems.where((c) => !isPurchased(c.id)).toList();
  }
  
  /// Purchase a product
  Future<PurchaseResult> purchaseProduct(IAPProduct product) async {
    // In production: Use actual IAP flow
    // final purchaseParam = PurchaseParam(productDetails: productDetails);
    // await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    
    // Simulation for development
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Simulate 90% success rate
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final success = random < 90;
    
    if (success) {
      // Mark non-consumables as purchased
      if (product.type == ProductType.nonConsumable || product.isOneTime) {
        _purchasedProducts.add(product.id);
      }
      
      final result = PurchaseResult(
        success: true,
        product: product,
        rewards: product.rewards,
      );
      
      onPurchaseCompleted?.call(result);
      
      if (kDebugMode) {
        debugPrint('Purchase successful: ${product.name}');
      }
      
      return result;
    } else {
      return PurchaseResult(
        success: false,
        error: 'Purchase failed. Please try again.',
        product: product,
      );
    }
  }
  
  /// Restore purchases (for non-consumables)
  Future<List<String>> restorePurchases() async {
    // In production: Query past purchases
    // await InAppPurchase.instance.restorePurchases();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) {
      debugPrint('Purchases restored: ${_purchasedProducts.length} items');
    }
    
    return _purchasedProducts.toList();
  }
  
  /// Load purchased products from storage
  void loadPurchasedProducts(List<String> productIds) {
    _purchasedProducts.addAll(productIds);
  }
  
  /// Get list of purchased product IDs
  List<String> getPurchasedProductIds() {
    return _purchasedProducts.toList();
  }
  
  /// Dispose resources
  void dispose() {
    // In production: Cancel subscriptions
  }
}
