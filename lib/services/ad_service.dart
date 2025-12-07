import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Rewarded ad placement types
enum AdPlacement {
  offlineEarningsDouble,    // Double offline earnings
  dailyDarkMatter,          // Daily free dark matter
  expeditionBoost,          // +25% expedition success
  expeditionRetry,          // Retry failed expedition
  freeTimeWarp,             // Free 1-hour time warp
  challengeExtension,       // Extend challenge time
  timedBonusReward,         // Timed popup bonus (5-10 min intervals)
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
  AdPlacement.timedBonusReward: AdPlacementConfig(
    name: 'Bonus Reward',
    description: 'Watch an ad for 5 minutes worth of Energy or Dark Matter',
    dailyLimit: 10,
    cooldown: Duration(minutes: 5),
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

/// Service for managing rewarded video ads using Google Mobile Ads SDK
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();
  
  // Track ad watches per day
  final Map<AdPlacement, List<DateTime>> _adWatches = {};
  DateTime? _lastResetDate;
  
  // Callbacks
  Function(AdPlacement, bool)? onAdCompleted;
  
  // ═══════════════════════════════════════════════════════════════
  // AD UNIT IDs - REPLACE WITH YOUR ACTUAL AD UNIT IDs
  // ═══════════════════════════════════════════════════════════════
  
  /// Test Ad Unit IDs (use these during development)
  static String get _testRewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android test rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS test rewarded
    }
    return '';
  }
  
  /// Production Ad Unit IDs - REPLACE THESE WITH YOUR REAL AD UNIT IDs
  /// Get these from your AdMob dashboard: https://admob.google.com/
  static String get _productionRewardedAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Replace with your Android Rewarded Ad Unit ID
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS Rewarded Ad Unit ID
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
    }
    return '';
  }
  
  /// Get the appropriate ad unit ID based on build mode
  static String get rewardedAdUnitId {
    // Use test ads in debug mode, production ads in release
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    }
    return _productionRewardedAdUnitId;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // REWARDED AD MANAGEMENT
  // ═══════════════════════════════════════════════════════════════
  
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;
  int _rewardedLoadAttempts = 0;
  static const int _maxFailedLoadAttempts = 3;
  
  /// Check if rewarded ad is available
  bool get isAdAvailable => _rewardedAd != null;
  
  /// Check if an ad is currently loading
  bool get isAdLoading => _isRewardedAdLoading;
  
  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════
  
  bool _isInitialized = false;
  
  /// Initialize the ad service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Skip initialization on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('AdService: Skipping initialization on web platform');
      }
      _isInitialized = true;
      return;
    }
    
    try {
      // Initialize the Mobile Ads SDK
      await MobileAds.instance.initialize();
      
      // Configure test devices (add your test device IDs here)
      if (kDebugMode) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: [
              // Add your test device IDs here
              // You can find your device ID in logcat when running on a device
            ],
          ),
        );
      }
      
      _isInitialized = true;
      _resetDailyCountsIfNeeded();
      
      // Pre-load the first rewarded ad
      _loadRewardedAd();
      
      if (kDebugMode) {
        debugPrint('AdService: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdService: Initialization failed - $e');
      }
    }
  }
  
  /// Load a rewarded ad
  void _loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    if (kIsWeb) return; // Skip on web
    
    _isRewardedAdLoading = true;
    
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _rewardedLoadAttempts = 0;
          
          // Set up full screen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewardedAd(); // Pre-load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                debugPrint('AdService: Failed to show ad - ${error.message}');
              }
              ad.dispose();
              _rewardedAd = null;
              _loadRewardedAd(); // Try to load another
            },
          );
          
          if (kDebugMode) {
            debugPrint('AdService: Rewarded ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          _rewardedLoadAttempts++;
          _rewardedAd = null;
          
          if (kDebugMode) {
            debugPrint('AdService: Failed to load rewarded ad - ${error.message}');
          }
          
          // Retry with exponential backoff
          if (_rewardedLoadAttempts < _maxFailedLoadAttempts) {
            final delay = Duration(seconds: _rewardedLoadAttempts * 2);
            Future.delayed(delay, _loadRewardedAd);
          }
        },
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // AD DISPLAY & REWARDS
  // ═══════════════════════════════════════════════════════════════
  
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
    
    // On web, always return false (ads not supported)
    if (kIsWeb) return false;
    
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
  
  /// Get cooldown remaining for placement
  Duration getCooldownRemaining(AdPlacement placement) {
    final config = adPlacements[placement]!;
    if (config.cooldown == Duration.zero) return Duration.zero;
    
    final watches = _adWatches[placement] ?? [];
    if (watches.isEmpty) return Duration.zero;
    
    final lastWatch = watches.last;
    final elapsed = DateTime.now().difference(lastWatch);
    final remaining = config.cooldown - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
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
    
    // Web platform fallback - simulate success for testing
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
      _recordAdWatch(placement);
      onAdCompleted?.call(placement, true);
      return AdResult(success: true, placement: placement);
    }
    
    if (_rewardedAd == null) {
      // Try to load an ad if none available
      _loadRewardedAd();
      return AdResult(
        success: false,
        error: 'Ad not ready. Please try again in a moment.',
        placement: placement,
      );
    }
    
    // Use a Completer to handle the async ad result
    final completer = Completer<AdResult>();
    
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // User earned the reward
        _recordAdWatch(placement);
        
        if (kDebugMode) {
          debugPrint('AdService: User earned reward - ${reward.amount} ${reward.type}');
        }
        
        onAdCompleted?.call(placement, true);
        
        if (!completer.isCompleted) {
          completer.complete(AdResult(success: true, placement: placement));
        }
      },
    );
    
    // Set a timeout in case the callback doesn't fire
    Future.delayed(const Duration(seconds: 60), () {
      if (!completer.isCompleted) {
        completer.complete(AdResult(
          success: false,
          error: 'Ad timed out',
          placement: placement,
        ));
      }
    });
    
    return completer.future;
  }
  
  /// Record an ad watch
  void _recordAdWatch(AdPlacement placement) {
    _adWatches[placement] ??= [];
    _adWatches[placement]!.add(DateTime.now());
  }
  
  // ═══════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════
  
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
        return baseValue * 2;
      case AdPlacement.dailyDarkMatter:
        return 10;
      case AdPlacement.expeditionBoost:
        return 0.25;
      case AdPlacement.expeditionRetry:
        return 1;
      case AdPlacement.freeTimeWarp:
        return 1;
      case AdPlacement.challengeExtension:
        return 2;
      case AdPlacement.timedBonusReward:
        return baseValue;
    }
  }
  
  /// Load ad watch data from storage
  void loadAdWatchData(Map<String, dynamic>? data) {
    if (data == null) return;
    
    for (final placement in AdPlacement.values) {
      final key = placement.name;
      if (data.containsKey(key)) {
        final timestamps = (data[key] as List<dynamic>?)
            ?.map((e) => DateTime.fromMillisecondsSinceEpoch(e as int))
            .toList();
        if (timestamps != null) {
          _adWatches[placement] = timestamps;
        }
      }
    }
  }
  
  /// Get ad watch data for storage
  Map<String, dynamic> getAdWatchData() {
    final data = <String, dynamic>{};
    for (final entry in _adWatches.entries) {
      data[entry.key.name] = entry.value
          .map((e) => e.millisecondsSinceEpoch)
          .toList();
    }
    return data;
  }
  
  /// Dispose resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
