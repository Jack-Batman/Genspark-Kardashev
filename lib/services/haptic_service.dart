import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haptic Feedback Service
/// Provides tactile feedback for game interactions
class HapticService {
  static bool _enabled = true;
  
  static bool get enabled => _enabled;
  static set enabled(bool value) => _enabled = value;
  
  /// Set haptic feedback enabled state
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  /// Light tap - for UI interactions
  static void lightImpact() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.lightImpact();
  }
  
  /// Medium impact - for purchases, upgrades
  static void mediumImpact() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact - for major events, prestige
  static void heavyImpact() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.heavyImpact();
  }
  
  /// Selection feedback - for toggling options
  static void selectionClick() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.selectionClick();
  }
  
  /// Vibrate pattern for collecting energy
  static void collectEnergy() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.lightImpact();
  }
  
  /// Vibrate pattern for unlocking something
  static void unlock() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.heavyImpact();
  }
  
  /// Pattern for error/failure
  static void error() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.vibrate();
  }
}
