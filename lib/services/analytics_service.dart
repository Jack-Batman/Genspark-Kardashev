import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics service using Firebase Analytics
/// Tracks player behavior, progression, and monetization events
class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;
  static bool _isInitialized = false;

  /// Get analytics observer for navigation tracking
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Initialize analytics
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // Disable analytics in debug mode if desired
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);

      _isInitialized = true;
      _log('AnalyticsService initialized');
    } catch (e) {
      _log('AnalyticsService initialization failed: $e');
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userId,
    int? prestigeCount,
    int? currentEra,
    bool? isPremium,
  }) async {
    if (_analytics == null) return;

    try {
      if (userId != null) {
        await _analytics!.setUserId(id: userId);
      }
      if (prestigeCount != null) {
        await _analytics!.setUserProperty(
          name: 'prestige_count',
          value: prestigeCount.toString(),
        );
      }
      if (currentEra != null) {
        await _analytics!.setUserProperty(
          name: 'current_era',
          value: currentEra.toString(),
        );
      }
      if (isPremium != null) {
        await _analytics!.setUserProperty(
          name: 'is_premium',
          value: isPremium.toString(),
        );
      }
    } catch (e) {
      _log('Failed to set user properties: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PROGRESSION EVENTS
  // ═══════════════════════════════════════════════════════════════

  /// Track tutorial completion
  static Future<void> logTutorialComplete() async {
    await _logEvent('tutorial_complete');
  }

  /// Track era unlock
  static Future<void> logEraUnlock(int eraIndex, String eraName) async {
    await _logEvent('era_unlock', {
      'era_index': eraIndex,
      'era_name': eraName,
    });
  }

  /// Track prestige
  static Future<void> logPrestige({
    required int prestigeCount,
    required double darkMatterEarned,
    required double kardashevLevel,
  }) async {
    await _logEvent('prestige', {
      'prestige_count': prestigeCount,
      'dark_matter_earned': darkMatterEarned,
      'kardashev_level': kardashevLevel,
    });
  }

  /// Track Kardashev milestone
  static Future<void> logKardashevMilestone(double level) async {
    await _logEvent('kardashev_milestone', {
      'level': level,
    });
  }

  /// Track generator purchase
  static Future<void> logGeneratorPurchase({
    required String generatorId,
    required int count,
    required double cost,
  }) async {
    await _logEvent('generator_purchase', {
      'generator_id': generatorId,
      'count': count,
      'cost': cost,
    });
  }

  /// Track research completion
  static Future<void> logResearchComplete(String researchId) async {
    await _logEvent('research_complete', {
      'research_id': researchId,
    });
  }

  /// Track architect unlock
  static Future<void> logArchitectUnlock({
    required String architectId,
    required String rarity,
  }) async {
    await _logEvent('architect_unlock', {
      'architect_id': architectId,
      'rarity': rarity,
    });
  }

  /// Track expedition completion
  static Future<void> logExpeditionComplete({
    required String expeditionId,
    required bool success,
  }) async {
    await _logEvent('expedition_complete', {
      'expedition_id': expeditionId,
      'success': success,
    });
  }

  /// Track achievement unlock
  static Future<void> logAchievementUnlock(String achievementId) async {
    await _analytics?.logUnlockAchievement(id: achievementId);
  }

  // ═══════════════════════════════════════════════════════════════
  // MONETIZATION EVENTS
  // ═══════════════════════════════════════════════════════════════

  /// Track ad watched
  static Future<void> logAdWatched({
    required String adType,
    required String rewardType,
  }) async {
    await _logEvent('ad_reward_claimed', {
      'ad_type': adType,
      'reward_type': rewardType,
    });
  }

  /// Track in-app purchase
  static Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
  }) async {
    await _analytics?.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
          price: price,
        ),
      ],
    );
  }

  /// Track store opened
  static Future<void> logStoreOpened() async {
    await _logEvent('store_opened');
  }

  // ═══════════════════════════════════════════════════════════════
  // ENGAGEMENT EVENTS
  // ═══════════════════════════════════════════════════════════════

  /// Track daily login
  static Future<void> logDailyLogin(int streak) async {
    await _logEvent('daily_login', {
      'streak': streak,
    });
  }

  /// Track challenge completion
  static Future<void> logChallengeComplete({
    required String challengeId,
    required String duration, // 'daily' or 'weekly'
  }) async {
    await _logEvent('challenge_complete', {
      'challenge_id': challengeId,
      'duration': duration,
    });
  }

  /// Track session start
  static Future<void> logSessionStart() async {
    await _logEvent('session_start');
  }

  /// Track offline earnings collected
  static Future<void> logOfflineEarningsCollected(double amount) async {
    await _logEvent('offline_earnings_collected', {
      'amount': amount,
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // SCREEN TRACKING
  // ═══════════════════════════════════════════════════════════════

  /// Track screen view
  static Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  static Future<void> _logEvent(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {
    if (_analytics == null) return;

    try {
      // Convert parameters to correct type for Firebase Analytics
      Map<String, Object>? convertedParams;
      if (parameters != null) {
        convertedParams = {};
        parameters.forEach((key, value) {
          if (value != null) {
            convertedParams![key] = value is String ? value : value.toString();
          }
        });
      }
      
      await _analytics!.logEvent(
        name: name,
        parameters: convertedParams,
      );
      _log('Event logged: $name');
    } catch (e) {
      _log('Failed to log event $name: $e');
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AnalyticsService] $message');
    }
  }
}
