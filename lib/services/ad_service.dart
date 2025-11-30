import 'dart:async';
import 'package:flutter/foundation.dart';

/// Rewarded ad placement types
enum AdPlacement {
  offlineEarningsDouble,    // Double offline earnings
  dailyDarkMatter,          // Daily free dark matter
  expeditionBoost,          // +25% expedition success
  expeditionRetry,          // Retry failed expedition
  freeTimeWarp,             // Free 1-hour time warp
  challengeExtension,       // Extend challenge time
}

/// Ad placement configuration
class AdPlacementConfig {
  final String name;
  final String description;
  final int dailyLimit;
  final Duration cooldown;
  
  const AdPlacementConfig({
    required this.name,
    required this.description,
    required this.dailyLimit,
    this.cooldown = Duration.zero,
  });
}

/// Ad placement configurations
const Map<AdPlacement, AdPlacementConfig> adPlacements = {
  AdPlacement.offlineEarningsDouble: AdPlacementConfig(
    name: 'Double Offline Earnings',
    description: 'Watch an ad to double your offline earnings',
    dailyLimit: 3,
  ),
  AdPlacement.dailyDarkMatter: AdPlacementConfig(
    name: 'Daily Dark Matter',
    description: 'Watch an ad to receive bonus Dark Matter',
    dailyLimit: 1,
  ),
  AdPlacement.expeditionBoost: AdPlacementConfig(
    name: 'Expedition Boost',
    description: 'Watch an ad to boost expedition success rate',
    dailyLimit: 5,
  ),
  AdPlacement.expeditionRetry: AdPlacementConfig(
    name: 'Expedition Retry',
    description: 'Watch an ad to retry a failed expedition',
    dailyLimit: 3,
  ),
  AdPlacement.freeTimeWarp: AdPlacementConfig(
    name: 'Free Time Warp',
    description: 'Watch an ad for 1 hour of instant production',
    dailyLimit: 2,
  ),
  AdPlacement.challengeExtension: AdPlacementConfig(
    name: 'Challenge Extension',
    description: 'Watch an ad to extend challenge deadline',
    dailyLimit: 2,
  ),
};

/// Result of attempting to show an ad
class AdResult {
  final bool success;
  final String? error;
  final AdPlacement placement;
  
  const AdResult({
    required this.success,
    this.error,
    required this.placement,
  });
}

/// Service for managing rewarded video ads
/// Note: In production, integrate with google_mobile_ads package
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();
  
  // Track ad watches per day
  final Map<AdPlacement, List<DateTime>> _adWatches = {};
  DateTime? _lastResetDate;
  
  // Callbacks
  Function(AdPlacement, bool)? onAdCompleted;
  
  // Ad unit IDs (replace with real IDs in production)
  static const String _rewardedAdUnitId = 'ca-app-pub-xxxxx/yyyyy';
  
  // Simulated ad state (in production, use actual ad SDK)
  bool _isAdLoaded = true;
  bool _isAdLoading = false;
  
  /// Initialize ad service
  Future<void> initialize() async {
    _resetDailyCountsIfNeeded();
    
    // In production: Initialize MobileAds
    // await MobileAds.instance.initialize();
    // _loadRewardedAd();
    
    if (kDebugMode) {
      debugPrint('AdService initialized (simulation mode)');
    }
  }
  
  /// Check if ads are available
  bool get isAdAvailable => _isAdLoaded && !_isAdLoading;
  
  /// Check if player can watch ad for placement
  bool canWatchAd(AdPlacement placement) {
    _resetDailyCountsIfNeeded();
    
    final config = adPlacements[placement]!;
    final watches = _adWatches[placement] ?? [];
    
    // Check daily limit
    final todayWatches = watches.where((w) => _isToday(w)).length;
    if (todayWatches >= config.dailyLimit) {
      return false;
    }
    
    // Check cooldown
    if (watches.isNotEmpty && config.cooldown > Duration.zero) {
      final lastWatch = watches.last;
      if (DateTime.now().difference(lastWatch) < config.cooldown) {
        return false;
      }
    }
    
    return isAdAvailable;
  }
  
  /// Get remaining ad watches for placement today
  int getRemainingWatches(AdPlacement placement) {
    _resetDailyCountsIfNeeded();
    
    final config = adPlacements[placement]!;
    final watches = _adWatches[placement] ?? [];
    final todayWatches = watches.where((w) => _isToday(w)).length;
    
    return (config.dailyLimit - todayWatches).clamp(0, config.dailyLimit);
  }
  
  /// Show rewarded ad for placement
  /// Returns AdResult with success status
  Future<AdResult> showRewardedAd(AdPlacement placement) async {
    if (!canWatchAd(placement)) {
      return AdResult(
        success: false,
        error: 'Daily limit reached or ad not available',
        placement: placement,
      );
    }
    
    // In production: Show actual ad
    // This is a simulation for development
    _isAdLoading = true;
    
    try {
      // Simulate ad loading/showing delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate 95% success rate (ads sometimes fail)
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      final success = random < 95;
      
      if (success) {
        // Record the watch
        _adWatches[placement] ??= [];
        _adWatches[placement]!.add(DateTime.now());
        
        if (kDebugMode) {
          debugPrint('Ad watched successfully: ${placement.name}');
        }
        
        onAdCompleted?.call(placement, true);
        
        return AdResult(
          success: true,
          placement: placement,
        );
      } else {
        return AdResult(
          success: false,
          error: 'Ad failed to load',
          placement: placement,
        );
      }
    } finally {
      _isAdLoading = false;
      // In production: Load next ad
      // _loadRewardedAd();
    }
  }
  
  /// Reset daily counts at midnight
  void _resetDailyCountsIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      // Clear old watches (keep only today's)
      for (final placement in AdPlacement.values) {
        _adWatches[placement] = (_adWatches[placement] ?? [])
            .where((w) => _isToday(w))
            .toList();
      }
      _lastResetDate = today;
    }
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Get reward amount for placement
  static double getRewardAmount(AdPlacement placement, {double baseValue = 0}) {
    switch (placement) {
      case AdPlacement.offlineEarningsDouble:
        return baseValue * 2; // Double the offline earnings
      case AdPlacement.dailyDarkMatter:
        return 10; // 10 Dark Matter
      case AdPlacement.expeditionBoost:
        return 0.25; // +25% success rate
      case AdPlacement.expeditionRetry:
        return 1; // 1 retry
      case AdPlacement.freeTimeWarp:
        return 1; // 1 hour of production
      case AdPlacement.challengeExtension:
        return 2; // 2 hours extension
    }
  }
  
  /// Dispose resources
  void dispose() {
    // In production: Dispose ad instances
  }
}
