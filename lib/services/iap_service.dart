import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  final bool isOneTime;
  final String? badge;
  
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

/// Dark Matter packages - IDs must match Google Play Console
const List<IAPProduct> darkMatterPackages = [
  IAPProduct(
    id: 'dm_starter',
    name: 'Starter Pack',
    description: '100 Dark Matter + 10% bonus',
    price: 0.99,
    priceString: '\$0.99',
    type: ProductType.consumable,
    rewards: {'darkMatter': 110},
  ),
  IAPProduct(
    id: 'dm_explorer',
    name: 'Explorer Pack',
    description: '300 Dark Matter + 15% bonus',
    price: 2.99,
    priceString: '\$2.99',
    type: ProductType.consumable,
    rewards: {'darkMatter': 345},
    badge: 'POPULAR',
  ),
  IAPProduct(
    id: 'dm_ascension',
    name: 'Ascension Pack',
    description: '750 Dark Matter + 20% bonus',
    price: 4.99,
    priceString: '\$4.99',
    type: ProductType.consumable,
    rewards: {'darkMatter': 900},
  ),
  IAPProduct(
    id: 'dm_cosmic',
    name: 'Cosmic Pack',
    description: '2000 Dark Matter + 25% bonus',
    price: 9.99,
    priceString: '\$9.99',
    type: ProductType.consumable,
    rewards: {'darkMatter': 2500},
    badge: 'BEST VALUE',
  ),
  IAPProduct(
    id: 'dm_universal',
    name: 'Universal Pack',
    description: '5000 Dark Matter + 30% bonus',
    price: 19.99,
    priceString: '\$19.99',
    type: ProductType.consumable,
    rewards: {'darkMatter': 6500},
  ),
  IAPProduct(
    id: 'dm_galactic_overlord',
    name: 'Galactic Overlord',
    description: '15000 Dark Matter + 40% bonus + Exclusive Border',
    price: 49.99,
    priceString: '\$49.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 21000,
      'exclusiveBorder': 'galactic_overlord',
      'exclusiveTitle': 'Galactic Overlord',
    },
    badge: 'PREMIUM',
  ),
  IAPProduct(
    id: 'dm_universal_dominator',
    name: 'Universal Dominator',
    description: '40000 Dark Matter + 50% bonus + Title & Avatar',
    price: 99.99,
    priceString: '\$99.99',
    type: ProductType.consumable,
    rewards: {
      'darkMatter': 60000,
      'exclusiveBorder': 'universal_dominator',
      'exclusiveTitle': 'Universal Dominator',
      'exclusiveAvatar': 'dominator_crown',
      'guaranteedLegendaryArchitect': true,
    },
    badge: 'ELITE',
  ),
];

/// AI Nexus - Permanent 2x Energy Production (one-time purchase)
const IAPProduct aiNexus = IAPProduct(
  id: 'ai_nexus',
  name: 'AI Nexus',
  description: 'Advanced AI system that permanently doubles all energy production across all Eras!',
  price: 17.99,
  priceString: '\$17.99',
  type: ProductType.nonConsumable,
  rewards: {
    'aiNexus': true,
    'productionMultiplier': 2.0,
  },
  isOneTime: true,
  badge: 'BEST',
);

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
    'timeWarps': 3,
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
    'offlineEfficiencyBonus': 0.5,
    'offlineHoursLimit': 24,
    'freeTimeWarpPerDay': 1,
    'exclusiveBorder': 'cosmic_member',
    'monthlyDarkMatter': 500,
    'maxExpeditions': 4,
  },
);

/// Cosmetic items
const List<IAPProduct> cosmeticItems = [
  // === THEMES ===
  IAPProduct(
    id: 'theme_stellar',
    name: 'Stellar Theme',
    description: 'Golden UI accent colors',
    price: 0.99,
    priceString: '150 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'stellar_gold'},
  ),
  IAPProduct(
    id: 'theme_void',
    name: 'Void Theme',
    description: 'Dark purple UI accents',
    price: 0.99,
    priceString: '150 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'void_purple'},
  ),
  IAPProduct(
    id: 'theme_nebula',
    name: 'Nebula Theme',
    description: 'Cosmic pink and blue gradients',
    price: 1.99,
    priceString: '250 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'nebula_pink'},
  ),
  IAPProduct(
    id: 'theme_plasma',
    name: 'Plasma Theme',
    description: 'Electric cyan energy accents',
    price: 1.99,
    priceString: '250 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'plasma_cyan'},
  ),
  IAPProduct(
    id: 'theme_supernova',
    name: 'Supernova Theme',
    description: 'Explosive orange and red colors',
    price: 2.99,
    priceString: '400 DM',
    type: ProductType.nonConsumable,
    rewards: {'theme': 'supernova_red'},
    badge: 'HOT',
  ),
  
  // === BORDERS ===
  IAPProduct(
    id: 'border_neon',
    name: 'Neon Glow Border',
    description: 'Animated glowing neon frame',
    price: 1.99,
    priceString: '200 DM',
    type: ProductType.nonConsumable,
    rewards: {'border': 'neon_glow'},
  ),
  IAPProduct(
    id: 'border_hologram',
    name: 'Holographic Border',
    description: 'Shifting rainbow holographic edge',
    price: 2.99,
    priceString: '350 DM',
    type: ProductType.nonConsumable,
    rewards: {'border': 'hologram'},
  ),
  IAPProduct(
    id: 'border_quantum',
    name: 'Quantum Border',
    description: 'Flickering reality-bending frame',
    price: 3.99,
    priceString: '500 DM',
    type: ProductType.nonConsumable,
    rewards: {'border': 'quantum'},
    badge: 'RARE',
  ),
  IAPProduct(
    id: 'border_celestial',
    name: 'Celestial Border',
    description: 'Starfield animated border',
    price: 4.99,
    priceString: '650 DM',
    type: ProductType.nonConsumable,
    rewards: {'border': 'celestial'},
    badge: 'EPIC',
  ),
  
  // === PARTICLE EFFECTS ===
  IAPProduct(
    id: 'particles_stardust',
    name: 'Stardust Particles',
    description: 'Gentle floating star particles',
    price: 1.99,
    priceString: '200 DM',
    type: ProductType.nonConsumable,
    rewards: {'particles': 'stardust'},
  ),
  IAPProduct(
    id: 'particles_energy',
    name: 'Energy Surge',
    description: 'Electric energy bolts effect',
    price: 2.99,
    priceString: '350 DM',
    type: ProductType.nonConsumable,
    rewards: {'particles': 'energy_surge'},
  ),
  IAPProduct(
    id: 'particles_cosmic',
    name: 'Cosmic Swirl',
    description: 'Swirling galaxy particles',
    price: 3.99,
    priceString: '500 DM',
    type: ProductType.nonConsumable,
    rewards: {'particles': 'cosmic_swirl'},
    badge: 'RARE',
  ),
  IAPProduct(
    id: 'particles_singularity',
    name: 'Singularity Effect',
    description: 'Black hole gravity particles',
    price: 5.99,
    priceString: '800 DM',
    type: ProductType.nonConsumable,
    rewards: {'particles': 'singularity'},
    badge: 'LEGENDARY',
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

/// Service for managing in-app purchases using Google Play Billing
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();
  
  // In-App Purchase instance
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  // Track purchases
  final Set<String> _purchasedProducts = {};
  bool _isInitialized = false;
  bool _isAvailable = false;
  
  // Product details from store
  final Map<String, ProductDetails> _productDetails = {};
  
  // Stream subscription for purchase updates
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Callbacks
  Function(PurchaseResult)? onPurchaseCompleted;
  Function(String)? onPurchaseError;
  Function()? onPurchasePending;
  
  // ═══════════════════════════════════════════════════════════════
  // PRODUCT IDs - These must match your Google Play Console products
  // ═══════════════════════════════════════════════════════════════
  
  /// All product IDs that should be loaded from the store
  static Set<String> get allProductIds => {
    // Consumables (Dark Matter)
    'dm_starter',
    'dm_explorer',
    'dm_ascension',
    'dm_cosmic',
    'dm_universal',
    'dm_galactic_overlord',
    'dm_universal_dominator',
    // Non-consumables
    'founders_pack',
    'ai_nexus',
    // Themes
    'theme_stellar',
    'theme_void',
    'theme_nebula',
    'theme_plasma',
    'theme_supernova',
    // Borders
    'border_neon',
    'border_hologram',
    'border_quantum',
    'border_celestial',
    // Particle Effects
    'particles_stardust',
    'particles_energy',
    'particles_cosmic',
    'particles_singularity',
    // Subscriptions
    'cosmic_membership',
  };
  
  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════
  
  /// Check if IAP is available
  bool get isAvailable => _isAvailable;
  
  /// Check if founder's pack is available (not yet purchased)
  bool get isFoundersPackAvailable => !isPurchased(foundersPack.id);
  
  /// Initialize IAP service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Skip on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('IAPService: Skipping initialization on web platform');
      }
      _isInitialized = true;
      return;
    }
    
    try {
      // Check if IAP is available
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        if (kDebugMode) {
          debugPrint('IAPService: Store not available');
        }
        _isInitialized = true;
        return;
      }
      
      // Note: Pending purchases are automatically enabled in recent versions
      // The enablePendingPurchases() method is deprecated and no longer required
      
      // Listen for purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          if (kDebugMode) {
            debugPrint('IAPService: Purchase stream error - $error');
          }
        },
      );
      
      // Load product details from store
      await _loadProducts();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('IAPService: Initialized successfully');
        debugPrint('IAPService: Loaded ${_productDetails.length} products');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IAPService: Initialization failed - $e');
      }
      _isInitialized = true;
    }
  }
  
  /// Load products from the store
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(allProductIds);
      
      if (response.error != null) {
        if (kDebugMode) {
          debugPrint('IAPService: Error loading products - ${response.error}');
        }
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('IAPService: Products not found - ${response.notFoundIDs}');
        }
      }
      
      // Store product details
      for (final product in response.productDetails) {
        _productDetails[product.id] = product;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IAPService: Failed to load products - $e');
      }
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // PURCHASE HANDLING
  // ═══════════════════════════════════════════════════════════════
  
  /// Handle purchase updates from the stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }
  
  /// Handle a single purchase update
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      // Purchase is pending (e.g., waiting for payment)
      onPurchasePending?.call();
      if (kDebugMode) {
        debugPrint('IAPService: Purchase pending - ${purchase.productID}');
      }
    } else if (purchase.status == PurchaseStatus.error) {
      // Purchase failed
      onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');
      if (kDebugMode) {
        debugPrint('IAPService: Purchase error - ${purchase.error?.message}');
      }
    } else if (purchase.status == PurchaseStatus.purchased ||
               purchase.status == PurchaseStatus.restored) {
      // Purchase successful
      await _verifyAndDeliverPurchase(purchase);
    } else if (purchase.status == PurchaseStatus.canceled) {
      if (kDebugMode) {
        debugPrint('IAPService: Purchase canceled - ${purchase.productID}');
      }
    }
    
    // Complete the purchase (required for Android)
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }
  
  /// Verify and deliver the purchase
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    // In production, you should verify the purchase with your backend server
    // For now, we'll trust the purchase and deliver the content
    
    final product = _findProductById(purchase.productID);
    if (product == null) {
      if (kDebugMode) {
        debugPrint('IAPService: Unknown product - ${purchase.productID}');
      }
      return;
    }
    
    // Mark non-consumables as purchased
    if (product.type == ProductType.nonConsumable || product.isOneTime) {
      _purchasedProducts.add(product.id);
    }
    
    // Notify about successful purchase
    final result = PurchaseResult(
      success: true,
      product: product,
      rewards: product.rewards,
    );
    onPurchaseCompleted?.call(result);
    
    if (kDebugMode) {
      debugPrint('IAPService: Purchase delivered - ${product.name}');
    }
  }
  
  /// Find a product by ID
  IAPProduct? _findProductById(String id) {
    // Check dark matter packages
    for (final product in darkMatterPackages) {
      if (product.id == id) return product;
    }
    // Check founder's pack
    if (foundersPack.id == id) return foundersPack;
    // Check AI Nexus
    if (aiNexus.id == id) return aiNexus;
    // Check cosmic membership
    if (cosmicMembership.id == id) return cosmicMembership;
    // Check cosmetics
    for (final product in cosmeticItems) {
      if (product.id == id) return product;
    }
    return null;
  }
  
  /// Check if AI Nexus is available (not yet purchased)
  bool get isAINexusAvailable => !isPurchased(aiNexus.id);
  
  // ═══════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════
  
  /// Check if a product has been purchased (for non-consumables)
  bool isPurchased(String productId) {
    return _purchasedProducts.contains(productId);
  }
  
  /// Get store price for a product (returns null if not loaded)
  String? getStorePrice(String productId) {
    return _productDetails[productId]?.price;
  }
  
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
    // Web platform fallback
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (product.type == ProductType.nonConsumable || product.isOneTime) {
        _purchasedProducts.add(product.id);
      }
      final result = PurchaseResult(
        success: true,
        product: product,
        rewards: product.rewards,
      );
      onPurchaseCompleted?.call(result);
      return result;
    }
    
    if (!_isAvailable) {
      return PurchaseResult(
        success: false,
        error: 'Store not available',
        product: product,
      );
    }
    
    // Get product details from store
    final productDetails = _productDetails[product.id];
    if (productDetails == null) {
      return PurchaseResult(
        success: false,
        error: 'Product not found in store. Please try again later.',
        product: product,
      );
    }
    
    // Create purchase param
    late PurchaseParam purchaseParam;
    
    if (product.type == ProductType.consumable) {
      purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else {
      purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
    
    // The actual result will come through the purchase stream
    // Return a pending result for now
    return PurchaseResult(
      success: true,
      product: product,
    );
  }
  
  /// Restore purchases (for non-consumables)
  Future<List<String>> restorePurchases() async {
    if (kIsWeb) {
      return _purchasedProducts.toList();
    }
    
    if (!_isAvailable) {
      return [];
    }
    
    try {
      await _inAppPurchase.restorePurchases();
      
      if (kDebugMode) {
        debugPrint('IAPService: Restore purchases initiated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('IAPService: Restore purchases failed - $e');
      }
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
    _subscription?.cancel();
  }
}
