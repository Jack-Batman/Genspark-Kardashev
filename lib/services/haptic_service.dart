import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haptic Intensity Levels
enum HapticIntensity {
  off,    // 0 - No haptics
  light,  // 1 - Light haptics (default)
  medium, // 2 - Medium haptics
  heavy,  // 3 - Heavy haptics
}

/// Haptic Feedback Service
/// Provides tactile feedback for game interactions with customizable intensity
class HapticService {
  static bool _enabled = true;
  static HapticIntensity _intensity = HapticIntensity.light;
  
  static bool get enabled => _enabled;
  static set enabled(bool value) => _enabled = value;
  
  static HapticIntensity get intensity => _intensity;
  static set intensity(HapticIntensity value) => _intensity = value;
  
  /// Set haptic feedback enabled state
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  /// Set haptic intensity from int (0-3)
  static void setIntensity(int intensityLevel) {
    if (intensityLevel <= 0) {
      _intensity = HapticIntensity.off;
      _enabled = false;
    } else {
      _enabled = true;
      switch (intensityLevel) {
        case 1:
          _intensity = HapticIntensity.light;
          break;
        case 2:
          _intensity = HapticIntensity.medium;
          break;
        case 3:
        default:
          _intensity = HapticIntensity.heavy;
          break;
      }
    }
  }
  
  /// Get intensity as int (0-3)
  static int getIntensityLevel() {
    if (!_enabled) return 0;
    switch (_intensity) {
      case HapticIntensity.off:
        return 0;
      case HapticIntensity.light:
        return 1;
      case HapticIntensity.medium:
        return 2;
      case HapticIntensity.heavy:
        return 3;
    }
  }
  
  /// Get intensity display name
  static String getIntensityName(int level) {
    switch (level) {
      case 0:
        return 'Off';
      case 1:
        return 'Light';
      case 2:
        return 'Medium';
      case 3:
        return 'Heavy';
      default:
        return 'Light';
    }
  }
  
  /// Apply haptic with current intensity scaling
  static void _applyHaptic(void Function() lightFn, void Function() mediumFn, void Function() heavyFn) {
    if (!_enabled || kIsWeb || _intensity == HapticIntensity.off) return;
    
    switch (_intensity) {
      case HapticIntensity.off:
        break;
      case HapticIntensity.light:
        lightFn();
        break;
      case HapticIntensity.medium:
        mediumFn();
        break;
      case HapticIntensity.heavy:
        heavyFn();
        break;
    }
  }
  
  /// Light tap - for UI interactions
  static void lightImpact() {
    _applyHaptic(
      () => HapticFeedback.selectionClick(),
      () => HapticFeedback.lightImpact(),
      () => HapticFeedback.mediumImpact(),
    );
  }
  
  /// Medium impact - for purchases, upgrades
  static void mediumImpact() {
    _applyHaptic(
      () => HapticFeedback.lightImpact(),
      () => HapticFeedback.mediumImpact(),
      () => HapticFeedback.heavyImpact(),
    );
  }
  
  /// Heavy impact - for major events, prestige
  static void heavyImpact() {
    _applyHaptic(
      () => HapticFeedback.mediumImpact(),
      () => HapticFeedback.heavyImpact(),
      () {
        HapticFeedback.heavyImpact();
        // Double vibration for heavy intensity
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.heavyImpact();
        });
      },
    );
  }
  
  /// Selection feedback - for toggling options
  static void selectionClick() {
    if (!_enabled || kIsWeb || _intensity == HapticIntensity.off) return;
    HapticFeedback.selectionClick();
  }
  
  /// Vibrate pattern for collecting energy
  static void collectEnergy() {
    lightImpact();
  }
  
  /// Vibrate pattern for unlocking something
  static void unlock() {
    heavyImpact();
  }
  
  /// Pattern for error/failure
  static void error() {
    if (!_enabled || kIsWeb || _intensity == HapticIntensity.off) return;
    HapticFeedback.vibrate();
  }
  
  /// Unique pattern for piggy bank break
  static void piggyBankBreak() {
    if (!_enabled || kIsWeb || _intensity == HapticIntensity.off) return;
    // Triple heavy vibration for satisfying break
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.heavyImpact();
      });
    });
  }
  
  /// Coin drop pattern for piggy bank deposits
  static void coinDrop() {
    _applyHaptic(
      () => HapticFeedback.selectionClick(),
      () => HapticFeedback.lightImpact(),
      () => HapticFeedback.mediumImpact(),
    );
  }
}
