import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

/// Cloud save status
enum CloudSaveStatus {
  notSignedIn,
  syncing,
  synced,
  conflict,
  error,
}

/// Cloud save conflict resolution
enum ConflictResolution {
  useLocal,
  useCloud,
  useMostProgress,
}

/// Cloud save result
class CloudSaveResult {
  final bool success;
  final String? message;
  final CloudSaveStatus status;
  final GameState? cloudState;

  const CloudSaveResult({
    required this.success,
    this.message,
    required this.status,
    this.cloudState,
  });
}

/// Cloud save service using Firebase Auth + Firestore
/// Enables cross-device save synchronization
class CloudSaveService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collectionName = 'game_saves';
  static const String _saveDocId = 'current_save';

  static CloudSaveStatus _status = CloudSaveStatus.notSignedIn;
  static DateTime? _lastSyncTime;

  /// Get current status
  static CloudSaveStatus get status => _status;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if signed in
  static bool get isSignedIn => _auth.currentUser != null;

  /// Get last sync time
  static DateTime? get lastSyncTime => _lastSyncTime;

  // ═══════════════════════════════════════════════════════════════
  // AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════

  /// Sign in with Google
  static Future<CloudSaveResult> signInWithGoogle() async {
    try {
      // Note: For web, you'd use GoogleAuthProvider
      // For mobile, you'd use google_sign_in package
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);

      if (userCredential.user != null) {
        _status = CloudSaveStatus.synced;
        _log('Signed in as ${userCredential.user!.email}');
        return CloudSaveResult(
          success: true,
          message: 'Signed in successfully',
          status: CloudSaveStatus.synced,
        );
      }

      return const CloudSaveResult(
        success: false,
        message: 'Sign in failed',
        status: CloudSaveStatus.error,
      );
    } catch (e) {
      _log('Sign in error: $e');
      return CloudSaveResult(
        success: false,
        message: 'Sign in failed: $e',
        status: CloudSaveStatus.error,
      );
    }
  }

  /// Sign in anonymously (for testing or guest mode)
  static Future<CloudSaveResult> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        _status = CloudSaveStatus.synced;
        _log('Signed in anonymously: ${userCredential.user!.uid}');
        return CloudSaveResult(
          success: true,
          message: 'Signed in as guest',
          status: CloudSaveStatus.synced,
        );
      }

      return const CloudSaveResult(
        success: false,
        message: 'Anonymous sign in failed',
        status: CloudSaveStatus.error,
      );
    } catch (e) {
      _log('Anonymous sign in error: $e');
      return CloudSaveResult(
        success: false,
        message: 'Sign in failed: $e',
        status: CloudSaveStatus.error,
      );
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      _status = CloudSaveStatus.notSignedIn;
      _log('Signed out');
    } catch (e) {
      _log('Sign out error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CLOUD SAVE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Save game state to cloud
  static Future<CloudSaveResult> saveToCloud(GameState state) async {
    if (!isSignedIn) {
      return const CloudSaveResult(
        success: false,
        message: 'Not signed in',
        status: CloudSaveStatus.notSignedIn,
      );
    }

    try {
      _status = CloudSaveStatus.syncing;

      final saveData = _gameStateToMap(state);
      saveData['lastModified'] = FieldValue.serverTimestamp();
      saveData['deviceId'] = _getDeviceId();

      await _firestore
          .collection(_collectionName)
          .doc(currentUser!.uid)
          .collection('saves')
          .doc(_saveDocId)
          .set(saveData, SetOptions(merge: false));

      _lastSyncTime = DateTime.now();
      _status = CloudSaveStatus.synced;
      _log('Saved to cloud successfully');

      return CloudSaveResult(
        success: true,
        message: 'Game saved to cloud',
        status: CloudSaveStatus.synced,
      );
    } catch (e) {
      _status = CloudSaveStatus.error;
      _log('Save to cloud error: $e');
      return CloudSaveResult(
        success: false,
        message: 'Failed to save: $e',
        status: CloudSaveStatus.error,
      );
    }
  }

  /// Load game state from cloud
  static Future<CloudSaveResult> loadFromCloud() async {
    if (!isSignedIn) {
      return const CloudSaveResult(
        success: false,
        message: 'Not signed in',
        status: CloudSaveStatus.notSignedIn,
      );
    }

    try {
      _status = CloudSaveStatus.syncing;

      final doc = await _firestore
          .collection(_collectionName)
          .doc(currentUser!.uid)
          .collection('saves')
          .doc(_saveDocId)
          .get();

      if (!doc.exists || doc.data() == null) {
        _status = CloudSaveStatus.synced;
        return const CloudSaveResult(
          success: true,
          message: 'No cloud save found',
          status: CloudSaveStatus.synced,
        );
      }

      final cloudState = _mapToGameState(doc.data()!);
      _lastSyncTime = DateTime.now();
      _status = CloudSaveStatus.synced;
      _log('Loaded from cloud successfully');

      return CloudSaveResult(
        success: true,
        message: 'Game loaded from cloud',
        status: CloudSaveStatus.synced,
        cloudState: cloudState,
      );
    } catch (e) {
      _status = CloudSaveStatus.error;
      _log('Load from cloud error: $e');
      return CloudSaveResult(
        success: false,
        message: 'Failed to load: $e',
        status: CloudSaveStatus.error,
      );
    }
  }

  /// Sync local and cloud saves (detect conflicts)
  static Future<CloudSaveResult> syncSaves(GameState localState) async {
    if (!isSignedIn) {
      return const CloudSaveResult(
        success: false,
        message: 'Not signed in',
        status: CloudSaveStatus.notSignedIn,
      );
    }

    try {
      final loadResult = await loadFromCloud();

      if (!loadResult.success) {
        return loadResult;
      }

      if (loadResult.cloudState == null) {
        // No cloud save, upload local
        return await saveToCloud(localState);
      }

      final cloudState = loadResult.cloudState!;

      // Check for conflict
      if (_hasConflict(localState, cloudState)) {
        _status = CloudSaveStatus.conflict;
        return CloudSaveResult(
          success: false,
          message: 'Save conflict detected',
          status: CloudSaveStatus.conflict,
          cloudState: cloudState,
        );
      }

      // Determine which save is newer/better
      if (_shouldUseCloudSave(localState, cloudState)) {
        return CloudSaveResult(
          success: true,
          message: 'Using cloud save (more progress)',
          status: CloudSaveStatus.synced,
          cloudState: cloudState,
        );
      } else {
        return await saveToCloud(localState);
      }
    } catch (e) {
      _status = CloudSaveStatus.error;
      _log('Sync error: $e');
      return CloudSaveResult(
        success: false,
        message: 'Sync failed: $e',
        status: CloudSaveStatus.error,
      );
    }
  }

  /// Resolve a save conflict
  static Future<CloudSaveResult> resolveConflict(
    GameState localState,
    GameState cloudState,
    ConflictResolution resolution,
  ) async {
    switch (resolution) {
      case ConflictResolution.useLocal:
        return await saveToCloud(localState);
      case ConflictResolution.useCloud:
        return CloudSaveResult(
          success: true,
          message: 'Using cloud save',
          status: CloudSaveStatus.synced,
          cloudState: cloudState,
        );
      case ConflictResolution.useMostProgress:
        if (_shouldUseCloudSave(localState, cloudState)) {
          return CloudSaveResult(
            success: true,
            message: 'Using cloud save (more progress)',
            status: CloudSaveStatus.synced,
            cloudState: cloudState,
          );
        } else {
          return await saveToCloud(localState);
        }
    }
  }

  /// Delete cloud save
  static Future<CloudSaveResult> deleteCloudSave() async {
    if (!isSignedIn) {
      return const CloudSaveResult(
        success: false,
        message: 'Not signed in',
        status: CloudSaveStatus.notSignedIn,
      );
    }

    try {
      await _firestore
          .collection(_collectionName)
          .doc(currentUser!.uid)
          .collection('saves')
          .doc(_saveDocId)
          .delete();

      _log('Cloud save deleted');
      return const CloudSaveResult(
        success: true,
        message: 'Cloud save deleted',
        status: CloudSaveStatus.synced,
      );
    } catch (e) {
      _log('Delete error: $e');
      return CloudSaveResult(
        success: false,
        message: 'Failed to delete: $e',
        status: CloudSaveStatus.error,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  static bool _hasConflict(GameState local, GameState cloud) {
    // Conflict if both have significant progress and different last online times
    // that are more than 5 minutes apart
    final localTime = local.lastOnlineTime;
    final cloudTime = cloud.lastOnlineTime;

    if (localTime.difference(cloudTime).abs().inMinutes > 5) {
      // Both have meaningful progress
      if (local.totalEnergyEarned > 1000 && cloud.totalEnergyEarned > 1000) {
        // And they're significantly different
        final energyDiff =
            (local.totalEnergyEarned - cloud.totalEnergyEarned).abs();
        if (energyDiff > local.totalEnergyEarned * 0.1) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _shouldUseCloudSave(GameState local, GameState cloud) {
    // Use cloud if it has more progress
    // Compare: prestige count, kardashev level, total energy
    if (cloud.prestigeCount > local.prestigeCount) return true;
    if (cloud.prestigeCount < local.prestigeCount) return false;

    if (cloud.kardashevLevel > local.kardashevLevel) return true;
    if (cloud.kardashevLevel < local.kardashevLevel) return false;

    return cloud.totalEnergyEarned > local.totalEnergyEarned;
  }

  static String _getDeviceId() {
    // In production, use device_info_plus package
    return 'web_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Map<String, dynamic> _gameStateToMap(GameState state) {
    // Serialize GameState to JSON-compatible map
    return {
      'energy': state.energy,
      'totalEnergyEarned': state.totalEnergyEarned,
      'darkMatter': state.darkMatter,
      'darkEnergy': state.darkEnergy,
      'kardashevLevel': state.kardashevLevel,
      'currentEra': state.currentEra,
      'unlockedEras': state.unlockedEras,
      'prestigeCount': state.prestigeCount,
      'generators': state.generators,
      'generatorLevels': state.generatorLevels,
      'unlockedResearch': state.unlockedResearch,
      'ownedArchitects': state.ownedArchitects,
      'assignedArchitects': state.assignedArchitects,
      'unlockedAchievements': state.unlockedAchievements,
      'loginStreak': state.loginStreak,
      'totalLoginDays': state.totalLoginDays,
      'playTimeSeconds': state.playTimeSeconds,
      'totalTaps': state.totalTaps,
      'lastOnlineTime': state.lastOnlineTime.toIso8601String(),
    };
  }

  static GameState _mapToGameState(Map<String, dynamic> data) {
    // Deserialize map to GameState
    final state = GameState();
    state.energy = (data['energy'] as num?)?.toDouble() ?? 0;
    state.totalEnergyEarned =
        (data['totalEnergyEarned'] as num?)?.toDouble() ?? 0;
    state.darkMatter = (data['darkMatter'] as num?)?.toDouble() ?? 0;
    state.darkEnergy = (data['darkEnergy'] as num?)?.toDouble() ?? 0;
    state.kardashevLevel = (data['kardashevLevel'] as num?)?.toDouble() ?? 0;
    state.currentEra = (data['currentEra'] as int?) ?? 0;
    state.prestigeCount = (data['prestigeCount'] as int?) ?? 0;
    state.loginStreak = (data['loginStreak'] as int?) ?? 0;
    state.totalLoginDays = (data['totalLoginDays'] as int?) ?? 0;
    state.playTimeSeconds = (data['playTimeSeconds'] as int?) ?? 0;
    state.totalTaps = (data['totalTaps'] as int?) ?? 0;

    if (data['unlockedEras'] != null) {
      state.unlockedEras = List<int>.from(data['unlockedEras']);
    }
    if (data['generators'] != null) {
      state.generators = Map<String, int>.from(data['generators']);
    }
    if (data['generatorLevels'] != null) {
      state.generatorLevels = Map<String, int>.from(data['generatorLevels']);
    }
    if (data['unlockedResearch'] != null) {
      state.unlockedResearch = List<String>.from(data['unlockedResearch']);
    }
    if (data['ownedArchitects'] != null) {
      state.ownedArchitects = List<String>.from(data['ownedArchitects']);
    }
    if (data['assignedArchitects'] != null) {
      state.assignedArchitects =
          Map<String, String>.from(data['assignedArchitects']);
    }
    if (data['unlockedAchievements'] != null) {
      state.unlockedAchievements =
          List<String>.from(data['unlockedAchievements']);
    }
    if (data['lastOnlineTime'] != null) {
      state.lastOnlineTime = DateTime.parse(data['lastOnlineTime']);
    }

    return state;
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[CloudSaveService] $message');
    }
  }
}
