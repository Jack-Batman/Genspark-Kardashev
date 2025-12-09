import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crash reporting service using Firebase Crashlytics
/// Captures crashes, errors, and provides debugging context
class CrashService {
  static bool _isInitialized = false;

  /// Initialize crash reporting
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Disable crash collection in debug mode
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      _isInitialized = true;
      _log('CrashService initialized (collection: ${!kDebugMode})');
    } catch (e) {
      _log('CrashService initialization failed: $e');
    }
  }

  /// Set user identifier for crash reports
  static Future<void> setUserId(String userId) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      _log('User ID set: $userId');
    } catch (e) {
      _log('Failed to set user ID: $e');
    }
  }

  /// Set custom key-value for crash context
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    } catch (e) {
      _log('Failed to set custom key: $e');
    }
  }

  /// Log a message to be included in crash reports
  static void log(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      _log('Failed to log message: $e');
    }
  }

  /// Record a non-fatal error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
      _log('Error recorded: $exception');
    } catch (e) {
      _log('Failed to record error: $e');
    }
  }

  /// Set game-specific context for debugging
  static Future<void> setGameContext({
    required double kardashevLevel,
    required int currentEra,
    required int prestigeCount,
    required double energy,
  }) async {
    await setCustomKey('kardashev_level', kardashevLevel.toStringAsFixed(3));
    await setCustomKey('current_era', currentEra);
    await setCustomKey('prestige_count', prestigeCount);
    await setCustomKey('energy', energy.toStringAsExponential(2));
  }

  /// Force a test crash (only in debug mode)
  static void testCrash() {
    if (kDebugMode) {
      FirebaseCrashlytics.instance.crash();
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[CrashService] $message');
    }
  }
}
