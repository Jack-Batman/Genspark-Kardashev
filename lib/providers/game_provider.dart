import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_state.dart';
import '../models/architect.dart';
import '../models/achievement.dart';
import '../models/daily_reward.dart';
import '../models/expedition.dart';
import '../models/architect_ability.dart';
import '../models/challenge.dart';
import '../models/artifact.dart';
import '../models/legendary_expedition.dart';
import '../core/constants.dart';
import '../core/era_data.dart';
import '../models/research_v2.dart';
import '../services/haptic_service.dart';
import '../services/audio_service.dart';
import '../widgets/notification_banner.dart';
import '../widgets/tutorial_manager.dart';

/// Dynamic prestige information
class PrestigeInfo {
  final double darkEnergyReward;
  final double productionBonusGain;
  final double totalDarkEnergy;
  final double totalProductionBonus;
  final String tierName;
  final double requiredKardashev;
  
  const PrestigeInfo({
    required this.darkEnergyReward,
    required this.productionBonusGain,
    required this.totalDarkEnergy,
    required this.totalProductionBonus,
    required this.tierName,
    required this.requiredKardashev,
  });
}

class GameProvider extends ChangeNotifier {
  GameState _state = GameState();
  Box<GameState>? _gameBox;
  Timer? _gameLoop;
  Timer? _saveTimer;
  Timer? _playTimeTimer;
  Timer? _autoTapTimer;
  bool _isInitialized = false;
  double _offlineEarnings = 0;
  bool _showOfflineEarnings = false;
  
  // Era transition state
  bool _showEraTransition = false;
  EraTransition? _pendingTransition;
  DateTime? _eraTransitionDismissedAt;  // Track when user dismissed the dialog
  
  // Achievement notification queue
  final List<Achievement> _pendingAchievementNotifications = [];
  Achievement? _currentAchievementNotification;
  
  // Daily login state
  bool _showDailyReward = false;
  DailyReward? _pendingDailyReward;
  bool _dailyRewardClaimed = false;
  
  // Expedition state
  final List<ActiveExpedition> _activeExpeditions = [];
  
  // Production boost state
  double _productionBoostMultiplier = 1.0;
  DateTime? _productionBoostEndTime;
  
  // Ability cooldowns
  final Map<String, AbilityCooldown> _abilityCooldowns = {};
  
  // Temporary ability effects
  double _tempCostReduction = 0.0;
  DateTime? _tempCostReductionEnd;
  double _tempOfflineBonus = 0.0;
  DateTime? _tempOfflineBonusEnd;
  bool _hasFreePurchase = false;
  
  // Challenges system
  List<ActiveChallenge> _dailyChallenges = [];
  List<ActiveChallenge> _weeklyChallenges = [];
  DateTime? _lastDailyChallengeReset;
  DateTime? _lastWeeklyChallengeReset;
  
  // Challenge tracking - Kardashev start for weekly progress calculation
  double _sessionKardashevStart = 0;
  
  // Notification system
  final NotificationBannerController _notificationController = NotificationBannerController();
  
  // Track abilities that were on cooldown to notify when ready
  final Set<String> _abilitiesOnCooldown = {};
  
  // Getters
  GameState get state => _state;
  NotificationBannerController get notificationController => _notificationController;
  bool get showDailyReward => _showDailyReward && !_dailyRewardClaimed;
  DailyReward? get pendingDailyReward => _pendingDailyReward;
  bool get canClaimDailyReward => _showDailyReward && !_dailyRewardClaimed;
  Achievement? get currentAchievementNotification => _currentAchievementNotification;
  bool get hasAchievementNotification => _currentAchievementNotification != null;
  bool get isInitialized => _isInitialized;
  double get offlineEarnings => _offlineEarnings;
  bool get showOfflineEarnings => _showOfflineEarnings;
  bool get showEraTransition => _showEraTransition;
  EraTransition? get pendingTransition => _pendingTransition;
  
  /// Get time away from game (duration since last online)
  Duration get timeAway {
    final now = DateTime.now();
    return now.difference(_state.lastOnlineTime);
  }
  
  /// Get current offline efficiency (base + research bonus)
  double get offlineEfficiency => 0.5 + _state.offlineBonus;
  
  /// Get active expeditions
  List<ActiveExpedition> get activeExpeditions => List.unmodifiable(_activeExpeditions);
  
  /// Get production boost multiplier (for time warp)
  double get productionBoostMultiplier {
    if (_productionBoostEndTime != null && 
        DateTime.now().isBefore(_productionBoostEndTime!)) {
      return _productionBoostMultiplier;
    }
    return 1.0;
  }
  
  /// Check if production boost is active
  bool get hasActiveBoost => 
      _productionBoostEndTime != null && 
      DateTime.now().isBefore(_productionBoostEndTime!);
  
  /// Get remaining boost time
  Duration get boostRemainingTime {
    if (_productionBoostEndTime == null) return Duration.zero;
    final now = DateTime.now();
    if (now.isAfter(_productionBoostEndTime!)) return Duration.zero;
    return _productionBoostEndTime!.difference(now);
  }
  
  /// Get ability cooldown for architect
  AbilityCooldown? getAbilityCooldown(String architectId) {
    return _abilityCooldowns[architectId];
  }
  
  /// Check if ability is available (owned and not on cooldown)
  bool isAbilityAvailable(String architectId) {
    if (!_state.ownedArchitects.contains(architectId)) return false;
    final cooldown = _abilityCooldowns[architectId];
    if (cooldown == null) return true;
    return !cooldown.isOnCooldown;
  }
  
  /// Get current temporary cost reduction
  double get temporaryCostReduction {
    if (_tempCostReductionEnd != null && 
        DateTime.now().isBefore(_tempCostReductionEnd!)) {
      return _tempCostReduction;
    }
    return 0.0;
  }
  
  /// Get current temporary offline bonus
  double get temporaryOfflineBonus {
    if (_tempOfflineBonusEnd != null && 
        DateTime.now().isBefore(_tempOfflineBonusEnd!)) {
      return _tempOfflineBonus;
    }
    return 0.0;
  }
  
  /// Check if free purchase is available
  bool get hasFreePurchase => _hasFreePurchase;
  
  /// Consume free purchase (used by generator buying logic)
  void consumeFreePurchase() {
    _hasFreePurchase = false;
    notifyListeners();
  }
  
  /// Get active challenges by duration
  List<ActiveChallenge> getActiveChallenges(ChallengeDuration duration) {
    _ensureChallengesInitialized();
    if (duration == ChallengeDuration.daily) {
      return List.unmodifiable(_dailyChallenges);
    } else {
      return List.unmodifiable(_weeklyChallenges);
    }
  }
  
  // Tap feedback
  double _tapEnergy = 0;
  double get tapEnergy => _tapEnergy;
  
  /// Initialize game and load save
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(GameStateAdapter());
      }
      
      // Try to open game box with timeout
      _gameBox = await Hive.openBox<GameState>('game_state')
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Failed to open game data');
      });
      
      // Load or create new game
      bool loadedSuccessfully = false;
      if (_gameBox!.isNotEmpty) {
        try {
          final loadedState = _gameBox!.getAt(0);
          if (loadedState != null) {
            _state = loadedState;
            loadedSuccessfully = true;
            
            // Calculate offline earnings
            _offlineEarnings = _state.calculateOfflineEarnings();
            if (_offlineEarnings > 0) {
              _showOfflineEarnings = true;
            }
            
            // Check for offline research progress
            _checkOfflineResearch();
          }
        } catch (e) {
          // If loading fails due to schema mismatch, clear and start fresh
          if (kDebugMode) {
            debugPrint('Failed to load save data, starting fresh: $e');
          }
          await _gameBox!.clear();
          loadedSuccessfully = false;
        }
      }
      
      if (!loadedSuccessfully) {
        // New game - start with wind turbine
        _state = GameState(
          energy: 50,
          generators: {'wind_turbine': 1},
          generatorLevels: {'wind_turbine': 1},
          unlockedEras: [0], // Start with Era I
        );
        await _saveGame();
      }
    } catch (e) {
      // If anything fails during Hive init, start fresh without persistence
      if (kDebugMode) {
        debugPrint('Hive initialization failed: $e');
      }
      _state = GameState(
        energy: 50,
        generators: {'wind_turbine': 1},
        generatorLevels: {'wind_turbine': 1},
        unlockedEras: [0],
      );
    }
    
    _state.lastOnlineTime = DateTime.now();
    _isInitialized = true;
    
    // Check daily login reward
    _checkDailyLogin();
    
    // Start game loops
    _startGameLoop();
    _startSaveTimer();
    _startPlayTimeTimer();
    _startAutoTapTimer();
    
    notifyListeners();
  }
  
  /// Check if player is eligible for daily login reward
  void _checkDailyLogin() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_state.lastLoginDate == null) {
      // First ever login
      _state.loginStreak = 1;
      _state.totalLoginDays = 1;
      _state.lastLoginDate = today;
      _pendingDailyReward = getRewardForDay(1);
      _showDailyReward = true;
      _dailyRewardClaimed = false;
    } else {
      final lastLogin = DateTime(
        _state.lastLoginDate!.year,
        _state.lastLoginDate!.month,
        _state.lastLoginDate!.day,
      );
      final daysSinceLastLogin = today.difference(lastLogin).inDays;
      
      if (daysSinceLastLogin == 0) {
        // Already logged in today - no reward
        _showDailyReward = false;
        _dailyRewardClaimed = true;
      } else if (daysSinceLastLogin == 1) {
        // Consecutive day - increase streak!
        _state.loginStreak++;
        _state.totalLoginDays++;
        _state.lastLoginDate = today;
        _pendingDailyReward = getRewardForDay(_state.loginStreak);
        _showDailyReward = true;
        _dailyRewardClaimed = false;
      } else {
        // Streak broken - reset to day 1
        _state.loginStreak = 1;
        _state.totalLoginDays++;
        _state.lastLoginDate = today;
        _pendingDailyReward = getRewardForDay(1);
        _showDailyReward = true;
        _dailyRewardClaimed = false;
      }
    }
  }
  
  /// Claim daily login reward
  void claimDailyReward() {
    if (!_showDailyReward || _dailyRewardClaimed || _pendingDailyReward == null) return;
    
    final reward = _pendingDailyReward!;
    final multiplier = getStreakMultiplier(_state.totalLoginDays);
    
    // Apply rewards with streak multiplier
    if (reward.energyReward > 0) {
      final energyGain = reward.energyReward * multiplier;
      _state.energy += energyGain;
      _state.totalEnergyEarned += energyGain;
    }
    if (reward.darkMatterReward > 0) {
      final dmGain = reward.darkMatterReward * multiplier;
      _state.darkMatter += dmGain;
    }
    
    _dailyRewardClaimed = true;
    _showDailyReward = false;
    
    AudioService.playAchievement();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
  }
  
  /// Dismiss daily reward without claiming (still marks as seen)
  void dismissDailyReward() {
    _showDailyReward = false;
    notifyListeners();
  }
  
  /// Complete the tutorial
  void completeTutorial() {
    _state.tutorialCompleted = true;
    // Also mark intro completed in tutorial manager
    TutorialManager.instance.markIntroCompleted();
    _saveGame();
    notifyListeners();
  }
  
  /// Reset tutorial (for testing or replay)
  void resetTutorial() {
    _state.tutorialCompleted = false;
    // Also reset tutorials in tutorial manager
    TutorialManager.instance.resetAllTutorials();
    _saveGame();
    notifyListeners();
  }
  
  /// Collect offline earnings
  void collectOfflineEarnings() {
    if (_offlineEarnings > 0) {
      _state.energy += _offlineEarnings;
      _state.totalEnergyEarned += _offlineEarnings;
      _offlineEarnings = 0;
      _showOfflineEarnings = false;
      HapticService.heavyImpact();
      notifyListeners();
    }
  }
  
  /// Dismiss offline earnings popup
  void dismissOfflineEarnings() {
    _showOfflineEarnings = false;
    notifyListeners();
  }
  
  /// Main game loop - updates energy every 100ms for smooth animation
  /// Optimized: Only notify listeners every 200ms to reduce excessive rebuilds
  int _achievementCheckCounter = 0;
  int _challengeCheckCounter = 0;
  int _notifyCounter = 0; // Throttle UI updates
  double _accumulatedEnergyForChallenge = 0;
  
  void _startGameLoop() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Apply production boost multiplier if active
      final boostMultiplier = productionBoostMultiplier;
      final energyGain = (_state.energyPerSecond * boostMultiplier) / 10; // Per 100ms
      
      if (energyGain > 0) {
        _state.energy += energyGain;
        _state.totalEnergyEarned += energyGain;
        _accumulatedEnergyForChallenge += energyGain;
        _state.updateKardashevLevel();
        
        // Check for era transition milestones every second
        _achievementCheckCounter++;
        if (_achievementCheckCounter >= 10) {
          _achievementCheckCounter = 0;
          _checkEraTransitionMilestone();
          checkAchievements();
        }
        
        // Update challenge progress every 2 seconds (reduced frequency)
        _challengeCheckCounter++;
        if (_challengeCheckCounter >= 20) {
          _challengeCheckCounter = 0;
          _updateChallengeProgress(ChallengeObjective.produceEnergy, _accumulatedEnergyForChallenge);
          _updateChallengeProgress(ChallengeObjective.reachKardashev, 0);
          _updateChallengeProgress(ChallengeObjective.playTime, 0);
          _accumulatedEnergyForChallenge = 0;
          
          // Check for abilities coming off cooldown
          _checkAbilityCooldowns();
        }
        
        // Throttle UI updates to every 200ms (2 ticks) for better performance
        _notifyCounter++;
        if (_notifyCounter >= 2) {
          _notifyCounter = 0;
          notifyListeners();
        }
      }
    });
  }
  
  /// Check if any abilities have come off cooldown and send notifications
  void _checkAbilityCooldowns() {
    final toNotify = <String>[];
    
    for (final architectId in _abilitiesOnCooldown.toList()) {
      final cooldown = _abilityCooldowns[architectId];
      if (cooldown == null || !cooldown.isOnCooldown) {
        // Ability is ready!
        toNotify.add(architectId);
        _abilitiesOnCooldown.remove(architectId);
      }
    }
    
    // Send notifications for abilities that are ready
    for (final architectId in toNotify) {
      final architect = getArchitectById(architectId);
      final ability = getAbilityForArchitect(architectId);
      if (architect != null && ability != null) {
        _notificationController.showAbilityReady(
          architect.name,
          ability.name,
          () {}, // Navigation handled by UI
        );
      }
    }
  }
  
  /// Auto-tap timer based on research
  void _startAutoTapTimer() {
    _autoTapTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.autoTapPerSecond > 0) {
        final autoTapEnergy = _state.autoTapPerSecond * 
            (1 + _state.productionBonus) * 
            (1 + _state.prestigeBonus);
        _state.energy += autoTapEnergy;
        _state.totalEnergyEarned += autoTapEnergy;
        // Don't notify here to avoid excessive rebuilds
      }
    });
  }
  
  /// Check if player has reached an era transition milestone
  void _checkEraTransitionMilestone() {
    if (_showEraTransition) return; // Already showing
    
    // Don't re-show dialog for 30 seconds after user dismisses it
    if (_eraTransitionDismissedAt != null) {
      final timeSinceDismiss = DateTime.now().difference(_eraTransitionDismissedAt!);
      if (timeSinceDismiss.inSeconds < 30) return;
    }
    
    final transition = _state.nextTransition;
    if (transition == null) return;
    
    // Check if reached required Kardashev level (with small epsilon for floating point)
    final hasReachedLevel = _state.kardashevLevel >= (transition.requiredKardashev - 0.001);
    final hasNotTransitioned = !_state.unlockedEras.contains(transition.toEra.index);
    
    if (hasReachedLevel && hasNotTransitioned) {
      _pendingTransition = transition;
      _showEraTransition = true;
      notifyListeners();
    }
  }
  
  /// Dismiss era transition dialog without transitioning
  void dismissEraTransition() {
    _showEraTransition = false;
    _eraTransitionDismissedAt = DateTime.now();  // Track dismissal time
    notifyListeners();
  }
  
  /// Add energy (used by ad rewards, bonuses, etc.)
  void addEnergy(double amount) {
    if (amount <= 0) return;
    _state.energy += amount;
    _state.totalEnergyEarned += amount;
    _state.updateKardashevLevel();
    _saveGame();
    notifyListeners();
  }
  
  /// Set pending transition (called when banner is tapped)
  void setPendingTransition(EraTransition transition) {
    _pendingTransition = transition;
    _showEraTransition = true;
    notifyListeners();
  }
  
  /// Execute era transition
  bool executeEraTransition() {
    final transition = _pendingTransition;
    if (transition == null) return false;
    
    // Check requirements (with small epsilon for floating point comparison)
    // Allow 0.001 tolerance since K 1.000 might be stored as 0.9999...
    if (_state.kardashevLevel < (transition.requiredKardashev - 0.001)) return false;
    if (_state.energy < transition.energyCost) return false;
    
    // Pay energy cost
    _state.energy -= transition.energyCost;
    
    // Unlock new era
    if (!_state.unlockedEras.contains(transition.toEra.index)) {
      _state.unlockedEras.add(transition.toEra.index);
    }
    
    // Update current era
    _state.currentEra = transition.toEra.index;
    
    // Award dark matter bonus
    final eraConfig = eraConfigs[transition.toEra]!;
    _state.darkMatter += 100 * eraConfig.darkMatterMultiplier;
    
    // Clear transition state
    _showEraTransition = false;
    _pendingTransition = null;
    
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
    
    return true;
  }
  
  /// Switch to a different unlocked era
  void switchEra(Era era) {
    if (!_state.unlockedEras.contains(era.index)) return;
    _state.currentEra = era.index;
    notifyListeners();
  }
  
  /// Auto-save every 30 seconds
  void _startSaveTimer() {
    _saveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveGame();
    });
  }
  
  /// Track play time
  void _startPlayTimeTimer() {
    _playTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _state.playTimeSeconds++;
    });
  }
  
  /// Save game to Hive
  Future<void> _saveGame() async {
    _state.lastOnlineTime = DateTime.now();
    if (_gameBox != null) {
      if (_gameBox!.isEmpty) {
        await _gameBox!.add(_state);
      } else {
        await _gameBox!.putAt(0, _state);
      }
    }
  }
  
  /// Manual tap for energy
  void tap() {
    // Base tap gives 1 energy + bonus based on production
    final tapBonus = 1.0 + (_state.energyPerSecond * 0.1);
    _state.energy += tapBonus;
    _state.totalEnergyEarned += tapBonus;
    _state.totalTaps++;
    _tapEnergy = tapBonus;
    
    // Track challenge progress
    _updateChallengeProgress(ChallengeObjective.tapCount, 1);
    _updateChallengeProgress(ChallengeObjective.produceEnergy, tapBonus);
    
    AudioService.playTap();
    HapticService.lightImpact();
    notifyListeners();
    
    // Clear tap feedback after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _tapEnergy = 0;
      notifyListeners();
    });
  }
  
  /// Purchase a generator (V2 system)
  bool buyGeneratorV2(GeneratorDataV2 genData) {
    if (!_state.isGeneratorUnlocked(genData)) return false;
    
    final cost = _state.getGeneratorCost(genData);
    if (_state.energy < cost) return false;
    
    _state.energy -= cost;
    _state.generators[genData.id] = (_state.generators[genData.id] ?? 0) + 1;
    
    // Initialize level if first purchase
    if (_state.generatorLevels[genData.id] == null) {
      _state.generatorLevels[genData.id] = 1;
    }
    
    // Track challenge progress
    _updateChallengeProgress(ChallengeObjective.purchaseGenerators, 1);
    
    _state.updateKardashevLevel();
    AudioService.playPurchase();
    HapticService.mediumImpact();
    notifyListeners();
    return true;
  }
  
  /// Buy multiple generators at once (V2 system)
  bool buyGeneratorBulkV2(GeneratorDataV2 genData, int count) {
    if (!_state.isGeneratorUnlocked(genData)) return false;
    
    // Calculate total cost for bulk purchase
    double totalCost = 0;
    int currentCount = _state.getGeneratorCount(genData.id);
    
    for (int i = 0; i < count; i++) {
      totalCost += genData.baseCost * 
                   pow(genData.costMultiplier, currentCount + i) *
                   (1 - _state.costReductionBonus);
    }
    
    if (_state.energy < totalCost) return false;
    
    _state.energy -= totalCost;
    _state.generators[genData.id] = currentCount + count;
    
    if (_state.generatorLevels[genData.id] == null) {
      _state.generatorLevels[genData.id] = 1;
    }
    
    // Track challenge progress
    _updateChallengeProgress(ChallengeObjective.purchaseGenerators, count.toDouble());
    
    _state.updateKardashevLevel();
    AudioService.playPurchase();
    HapticService.heavyImpact();
    notifyListeners();
    return true;
  }
  
  /// Upgrade a generator (V2 system)
  bool upgradeGeneratorV2(GeneratorDataV2 genData) {
    final cost = _state.getUpgradeCost(genData);
    if (_state.energy < cost) return false;
    if (_state.getGeneratorCount(genData.id) == 0) return false;
    
    _state.energy -= cost;
    _state.generatorLevels[genData.id] = (_state.generatorLevels[genData.id] ?? 1) + 1;
    
    _state.updateKardashevLevel();
    AudioService.playPurchase();
    HapticService.mediumImpact();
    notifyListeners();
    return true;
  }
  
  /// Get generators for current era
  List<GeneratorDataV2> getCurrentEraGenerators() {
    return _state.currentEraGenerators;
  }
  
  /// Get all unlocked generators
  List<GeneratorDataV2> getAllUnlockedGenerators() {
    return _state.allUnlockedGenerators;
  }
  
  /// Assign architect to a generator type
  void assignArchitect(String architectId, String? generatorId) {
    // Remove from current assignment
    _state.assignedArchitects.removeWhere((key, value) => value == architectId);
    
    if (generatorId != null) {
      _state.assignedArchitects[generatorId] = architectId;
    }
    
    _recalculateBonuses();
    notifyListeners();
  }
  
  /// Recalculate all bonuses from architects
  void _recalculateBonuses() {
    double totalBonus = 0;
    
    for (var entry in _state.assignedArchitects.entries) {
      final architect = getArchitectById(entry.value);
      if (architect != null) {
        totalBonus += architect.passiveBonus;
      }
    }
    
    _state.productionBonus = totalBonus;
  }
  
  /// Get current synthesis cost (starts at 50, +50 per owned architect)
  double getSynthesisCost() {
    return 50.0 + (_state.ownedArchitects.length * 50.0);
  }
  
  /// Synthesize (unlock) a new architect using dark matter
  /// [eraArchitects] - the list of architects available for the current era
  bool synthesizeArchitect(List<Architect> eraArchitects) {
    final cost = getSynthesisCost();
    if (_state.darkMatter < cost) return false;
    
    // Get available architects not yet owned from the provided era pool
    final available = eraArchitects
        .where((a) => !_state.ownedArchitects.contains(a.id))
        .toList();
    
    if (available.isEmpty) return false;
    
    _state.darkMatter -= cost;
    
    // Weighted random selection based on rarity
    final weights = available.map((a) {
      switch (a.rarity) {
        case ArchitectRarity.common:
          return 50.0;
        case ArchitectRarity.rare:
          return 30.0;
        case ArchitectRarity.epic:
          return 15.0;
        case ArchitectRarity.legendary:
          return 5.0;
      }
    }).toList();
    
    final totalWeight = weights.reduce((a, b) => a + b);
    double random = DateTime.now().millisecondsSinceEpoch % totalWeight.toInt() / 1.0;
    
    int selectedIndex = 0;
    for (int i = 0; i < weights.length; i++) {
      random -= weights[i];
      if (random <= 0) {
        selectedIndex = i;
        break;
      }
    }
    
    _state.ownedArchitects.add(available[selectedIndex].id);
    HapticService.heavyImpact();
    notifyListeners();
    return true;
  }
  
  /// Add dark matter (from expeditions, ads, etc.)
  void addDarkMatter(double amount) {
    final bonusAmount = amount * (1 + _state.darkMatterBonus);
    _state.darkMatter += bonusAmount;
    notifyListeners();
  }
  
  // ═══════════════════════════════════════════════════════════════
  // EXPEDITION SYSTEM
  // ═══════════════════════════════════════════════════════════════
  
  /// Start an expedition with assigned architects
  bool startExpedition(String expeditionId, List<String> architectIds) {
    final expedition = getExpeditionById(expeditionId);
    if (expedition == null) return false;
    
    // Validate architect count
    if (architectIds.length < expedition.minArchitects ||
        architectIds.length > expedition.maxArchitects) {
      return false;
    }
    
    // Check if expedition is already active
    if (_activeExpeditions.any((a) => a.expeditionId == expeditionId)) {
      return false;
    }
    
    // Check if architects are available
    final onExpedition = <String>{};
    for (final active in _activeExpeditions) {
      onExpedition.addAll(active.assignedArchitectIds);
    }
    for (final id in architectIds) {
      if (onExpedition.contains(id)) return false;
      if (!_state.ownedArchitects.contains(id)) return false;
    }
    
    // Start expedition
    final now = DateTime.now();
    final active = ActiveExpedition(
      expeditionId: expeditionId,
      assignedArchitectIds: architectIds,
      startTime: now,
      endTime: now.add(Duration(minutes: expedition.durationMinutes)),
    );
    
    _activeExpeditions.add(active);
    _saveGame();
    notifyListeners();
    return true;
  }
  
  /// Complete an expedition and collect rewards
  ExpeditionResult? completeExpedition(String expeditionId) {
    final activeIndex = _activeExpeditions.indexWhere(
      (a) => a.expeditionId == expeditionId,
    );
    if (activeIndex == -1) return null;
    
    final active = _activeExpeditions[activeIndex];
    if (!active.canCollect) return null;
    
    final expedition = getExpeditionById(expeditionId);
    if (expedition == null) return null;
    
    // Calculate success rate
    double successRate = expedition.successRateBase;
    for (final architectId in active.assignedArchitectIds) {
      final architect = getArchitectById(architectId);
      if (architect == null) continue;
      
      // Rarity bonus
      switch (architect.rarity) {
        case ArchitectRarity.common:
          successRate += 0.05;
        case ArchitectRarity.rare:
          successRate += 0.10;
        case ArchitectRarity.epic:
          successRate += 0.15;
        case ArchitectRarity.legendary:
          successRate += 0.20;
      }
      
      // Preferred architect bonus
      if (expedition.preferredArchitectId == architectId) {
        successRate += 0.25;
      }
      
      // Preferred rarity bonus
      if (expedition.preferredRarity == architect.rarity) {
        successRate += 0.10;
      }
    }
    successRate = successRate.clamp(0.0, 0.99);
    
    // Determine success
    final random = Random();
    final success = random.nextDouble() < successRate;
    
    // Calculate rewards
    final rewards = <ExpeditionReward>[];
    String message;
    
    if (success) {
      // Add base rewards
      rewards.addAll(expedition.baseRewards);
      
      // Chance for bonus rewards
      if (expedition.bonusRewards.isNotEmpty && random.nextDouble() < 0.3) {
        rewards.addAll(expedition.bonusRewards);
        message = 'Mission completed with bonus rewards!';
      } else {
        message = 'Mission completed successfully!';
      }
      
      // Apply rewards
      for (final reward in rewards) {
        switch (reward.type) {
          case ExpeditionRewardType.energy:
            _state.energy += reward.amount;
            _state.totalEnergyEarned += reward.amount;
          case ExpeditionRewardType.darkMatter:
            _state.darkMatter += reward.amount * (1 + _state.darkMatterBonus);
          case ExpeditionRewardType.researchBoost:
            _state.researchSpeedBonus += reward.amount;
            // TODO: Make temporary
          case ExpeditionRewardType.productionBoost:
            _applyProductionBoost(1 + reward.amount, const Duration(hours: 1));
          case ExpeditionRewardType.architectXP:
            // TODO: Implement architect XP system
            break;
        }
      }
    } else {
      // Mission failed - partial rewards
      if (random.nextDouble() < 0.5) {
        // 50% chance to get partial rewards
        final partialReward = ExpeditionReward(
          type: ExpeditionRewardType.energy,
          amount: expedition.baseRewards
              .where((r) => r.type == ExpeditionRewardType.energy)
              .fold(0.0, (a, b) => a + b.amount) * 0.25,
          description: 'Partial energy recovered',
        );
        rewards.add(partialReward);
        _state.energy += partialReward.amount;
        _state.totalEnergyEarned += partialReward.amount;
        message = 'Mission failed, but recovered some resources.';
      } else {
        message = 'Mission failed. The team returns empty-handed.';
      }
    }
    
    // Remove expedition
    _activeExpeditions.removeAt(activeIndex);
    
    // Track challenge progress
    _updateChallengeProgress(ChallengeObjective.completeExpedition, 1);
    
    // Send notification
    if (success) {
      final rewardSummary = rewards.isNotEmpty 
          ? 'Rewards: ${rewards.map((r) => r.description).join(', ')}'
          : '';
      _notificationController.showExpeditionComplete(
        expedition.name,
        rewardSummary,
        () {}, // Navigation handled by caller
      );
    } else {
      _notificationController.showExpeditionFailed(
        expedition.name,
        () {},
      );
    }
    
    _saveGame();
    notifyListeners();
    
    return ExpeditionResult(
      success: success,
      rewards: rewards,
      successRate: successRate,
      message: message,
    );
  }
  
  /// Cancel an active expedition (forfeits all progress)
  void cancelExpedition(String expeditionId) {
    _activeExpeditions.removeWhere((a) => a.expeditionId == expeditionId);
    _saveGame();
    notifyListeners();
  }
  
  // ═══════════════════════════════════════════════════════════════
  // PRODUCTION BOOST / TIME WARP
  // ═══════════════════════════════════════════════════════════════
  
  /// Apply a temporary production boost
  void _applyProductionBoost(double multiplier, Duration duration) {
    _productionBoostMultiplier = multiplier;
    _productionBoostEndTime = DateTime.now().add(duration);
    notifyListeners();
  }
  
  /// Advance research timer by specified hours (used by time warp effects)
  void _advanceResearchByTime(int hours) {
    if (_currentResearchId == null || _researchTotal <= 0) return;
    
    final secondsToAdvance = hours * 3600; // Convert hours to seconds
    _researchProgress += secondsToAdvance;
    
    // Check if research completed
    if (_researchProgress >= _researchTotal) {
      final research = getResearchNodeById(_currentResearchId!);
      if (research != null) {
        _researchProgress = _researchTotal;
        _completeResearchV2(research);
        _researchTimer?.cancel();
      }
    } else {
      // Update the persisted start time to reflect the time warp
      // This ensures offline calculation remains accurate
      if (_state.researchStartTime != null) {
        _state.researchStartTime = _state.researchStartTime!.subtract(Duration(hours: hours));
      }
    }
  }
  
  /// Activate time warp (costs dark matter)
  bool activateTimeWarp({int hours = 1}) {
    final cost = hours * 20.0; // 20 DM per hour
    if (_state.darkMatter < cost) return false;
    
    _state.darkMatter -= cost;
    
    // Calculate energy gain
    final energyGain = _state.energyPerSecond * 3600 * hours;
    _state.energy += energyGain;
    _state.totalEnergyEarned += energyGain;
    
    // Advance research timer if research is in progress
    _advanceResearchByTime(hours);
    
    HapticService.heavyImpact();
    AudioService.playPurchase();
    _saveGame();
    notifyListeners();
    return true;
  }
  
  /// Activate production boost (from ads or purchase)
  void activateProductionBoost(double multiplier, Duration duration) {
    _applyProductionBoost(multiplier, duration);
    HapticService.mediumImpact();
    _saveGame();
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ARCHITECT ACTIVE ABILITIES
  // ═══════════════════════════════════════════════════════════════
  
  /// Activate an architect's special ability
  /// Returns a message describing the result, or null if failed
  String? activateAbility(String architectId) {
    // Check if architect is owned
    if (!_state.ownedArchitects.contains(architectId)) {
      return null;
    }
    
    // Check if ability exists
    final ability = getAbilityForArchitect(architectId);
    if (ability == null) {
      return null;
    }
    
    // Check cooldown
    final existingCooldown = _abilityCooldowns[architectId];
    if (existingCooldown != null && existingCooldown.isOnCooldown) {
      final remaining = existingCooldown.remainingCooldown;
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      return 'Ability on cooldown: ${hours}h ${minutes}m remaining';
    }
    
    // Apply the ability effect
    String resultMessage;
    switch (ability.effectType) {
      case AbilityEffectType.instantEnergy:
        // Give instant energy based on current production rate
        final energyGain = _state.energyPerSecond * ability.effectValue;
        _state.energy += energyGain;
        _state.totalEnergyEarned += energyGain;
        resultMessage = '${ability.name} activated! +${GameProvider.formatNumber(energyGain)} energy!';
        
      case AbilityEffectType.productionMultiplier:
        // Apply production multiplier for duration
        _applyProductionBoost(ability.effectValue, Duration(minutes: ability.durationMinutes));
        resultMessage = '${ability.name} activated! ${ability.effectValue}x production for ${ability.durationMinutes} minutes!';
        
      case AbilityEffectType.offlineBonus:
        // Apply temporary offline bonus
        _tempOfflineBonus = ability.effectValue;
        _tempOfflineBonusEnd = DateTime.now().add(Duration(minutes: ability.durationMinutes));
        resultMessage = '${ability.name} activated! +${(ability.effectValue * 100).toInt()}% offline earnings for ${ability.durationMinutes ~/ 60} hours!';
        
      case AbilityEffectType.costReduction:
        // Apply temporary cost reduction
        _tempCostReduction = ability.effectValue;
        _tempCostReductionEnd = DateTime.now().add(Duration(minutes: ability.durationMinutes));
        resultMessage = '${ability.name} activated! -${(ability.effectValue * 100).toInt()}% costs for ${ability.durationMinutes} minutes!';
        
      case AbilityEffectType.instantResearch:
        // Complete current research instantly
        if (_currentResearchId == null) {
          // Refund - no research in progress
          return 'No research in progress! Ability not activated.';
        }
        // Fast-forward research progress
        _researchProgress = _researchTotal;
        resultMessage = '${ability.name} activated! Research completed instantly!';
        
      case AbilityEffectType.instantPurchase:
        // Grant a free purchase
        _hasFreePurchase = true;
        resultMessage = '${ability.name} activated! Your next generator purchase is FREE!';
        
      case AbilityEffectType.unlockGenerator:
        // Reduce unlock requirements temporarily
        // This is handled by checking temporaryUnlockReduction in generator unlock logic
        _tempCostReduction = ability.effectValue; // Reuse for unlock reduction
        _tempCostReductionEnd = DateTime.now().add(Duration(minutes: ability.durationMinutes));
        resultMessage = '${ability.name} activated! Generator unlock requirements reduced by ${(ability.effectValue * 100).toInt()}% for ${ability.durationMinutes} minutes!';
    }
    
    // Record cooldown
    _abilityCooldowns[architectId] = AbilityCooldown(
      architectId: architectId,
      lastUsed: DateTime.now(),
      cooldownMinutes: ability.cooldownMinutes,
    );
    
    // Track that this ability is on cooldown for notification when ready
    _abilitiesOnCooldown.add(architectId);
    
    // Track challenge progress
    _updateChallengeProgress(ChallengeObjective.useAbility, 1);
    
    // Play effects
    HapticService.heavyImpact();
    AudioService.playPurchase();
    
    _saveGame();
    notifyListeners();
    
    return resultMessage;
  }
  
  /// Get formatted cooldown time for an architect's ability
  String getAbilityCooldownText(String architectId) {
    final cooldown = _abilityCooldowns[architectId];
    if (cooldown == null || !cooldown.isOnCooldown) {
      return 'Ready';
    }
    
    final remaining = cooldown.remainingCooldown;
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
    } else {
      return '${remaining.inSeconds}s';
    }
  }
  
  /// Get cooldown progress (0.0 = just used, 1.0 = ready)
  double getAbilityCooldownProgress(String architectId) {
    final cooldown = _abilityCooldowns[architectId];
    if (cooldown == null) return 1.0;
    return cooldown.cooldownProgress.clamp(0.0, 1.0);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // CHALLENGES/CONTRACTS SYSTEM
  // ═══════════════════════════════════════════════════════════════
  
  /// Ensure challenges are initialized and not expired
  void _ensureChallengesInitialized() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if daily challenges need reset
    if (_lastDailyChallengeReset == null || 
        _lastDailyChallengeReset!.isBefore(today)) {
      _initializeDailyChallenges();
      _lastDailyChallengeReset = today;
    }
    
    // Check if weekly challenges need reset (Monday)
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    if (_lastWeeklyChallengeReset == null ||
        _lastWeeklyChallengeReset!.isBefore(thisWeekStart)) {
      _initializeWeeklyChallenges();
      _lastWeeklyChallengeReset = thisWeekStart;
    }
  }
  
  /// Initialize daily challenges
  void _initializeDailyChallenges() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day + 1);
    final seed = _state.prestigeCount;
    
    final challenges = generateDailyChallenges(seed);
    _dailyChallenges = challenges.map((c) => ActiveChallenge(
      challenge: c,
      startTime: now,
      endTime: endOfDay,
    )).toList();
    
    // Reset session counters
    _resetSessionCounters();
    
    // Send notification about new daily challenges
    if (_isInitialized) {
      _notificationController.showDailyChallengeReset(
        _dailyChallenges.length,
        () {},
      );
    }
  }
  
  /// Initialize weekly challenges
  void _initializeWeeklyChallenges() {
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    final nextMonday = DateTime(now.year, now.month, now.day + (daysUntilMonday == 0 ? 7 : daysUntilMonday));
    final seed = _state.prestigeCount;
    
    final challenges = generateWeeklyChallenges(seed);
    _weeklyChallenges = challenges.map((c) => ActiveChallenge(
      challenge: c,
      startTime: now,
      endTime: nextMonday,
    )).toList();
    
    // Store starting Kardashev for weekly progress
    _sessionKardashevStart = _state.kardashevLevel;
    
    // Send notification about new weekly challenges
    if (_isInitialized) {
      _notificationController.showWeeklyChallengeReset(
        _weeklyChallenges.length,
        () {},
      );
    }
  }
  
  /// Reset session counters for challenge tracking
  void _resetSessionCounters() {
    // Reset Kardashev start point for weekly challenge tracking
    _sessionKardashevStart = _state.kardashevLevel;
  }
  
  /// Update challenge progress based on objective type
  void _updateChallengeProgress(ChallengeObjective objective, double amount) {
    _ensureChallengesInitialized();
    
    // Update daily challenges
    for (final challenge in _dailyChallenges) {
      if (challenge.challenge.objective == objective && !challenge.isClaimed) {
        _applyChallengeProgress(challenge, objective, amount);
      }
    }
    
    // Update weekly challenges
    for (final challenge in _weeklyChallenges) {
      if (challenge.challenge.objective == objective && !challenge.isClaimed) {
        _applyChallengeProgress(challenge, objective, amount);
      }
    }
  }
  
  /// Apply progress to a specific challenge
  void _applyChallengeProgress(ActiveChallenge challenge, ChallengeObjective objective, double amount) {
    switch (objective) {
      case ChallengeObjective.produceEnergy:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.purchaseGenerators:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.earnDarkMatter:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.completeResearch:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.tapCount:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.reachKardashev:
        // For Kardashev, track increase from session start
        final increase = _state.kardashevLevel - _sessionKardashevStart;
        challenge.updateProgress(increase);
      case ChallengeObjective.completeExpedition:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.useAbility:
        challenge.updateProgress(challenge.currentProgress + amount);
      case ChallengeObjective.playTime:
        challenge.updateProgress(_state.playTimeSeconds / 60);
    }
  }
  
  /// Claim a completed challenge reward
  bool claimChallengeReward(ActiveChallenge activeChallenge) {
    if (!activeChallenge.isCompleted || activeChallenge.isClaimed) {
      return false;
    }
    
    // Apply rewards
    for (final reward in activeChallenge.challenge.rewards) {
      switch (reward.type) {
        case ChallengeRewardType.energy:
          _state.energy += reward.amount;
          _state.totalEnergyEarned += reward.amount;
        case ChallengeRewardType.darkMatter:
          _state.darkMatter += reward.amount * (1 + _state.darkMatterBonus);
        case ChallengeRewardType.productionBoost:
          _applyProductionBoost(reward.amount, const Duration(minutes: 30));
        case ChallengeRewardType.timeWarp:
          // Give instant energy equivalent to X hours of production
          final energyGain = _state.energyPerSecond * 3600 * reward.amount;
          _state.energy += energyGain;
          _state.totalEnergyEarned += energyGain;
          // Also advance research timer
          _advanceResearchByTime(reward.amount.toInt());
      }
    }
    
    activeChallenge.isClaimed = true;
    
    // Send notification
    final rewardDesc = activeChallenge.challenge.rewards
        .map((r) => r.type.name)
        .join(', ');
    _notificationController.showChallengeComplete(
      activeChallenge.challenge.name,
      rewardDesc,
      () {},
    );
    
    AudioService.playAchievement();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
    
    return true;
  }
  
  /// Get count of unclaimed completed challenges
  int get unclaimedChallengeCount {
    _ensureChallengesInitialized();
    int count = 0;
    for (final c in _dailyChallenges) {
      if (c.isCompleted && !c.isClaimed) count++;
    }
    for (final c in _weeklyChallenges) {
      if (c.isCompleted && !c.isClaimed) count++;
    }
    return count;
  }
  
  // Research System V2
  Timer? _researchTimer;
  String? _currentResearchId;
  int _researchProgress = 0;
  int _researchTotal = 0;
  
  String? get currentResearchId => _currentResearchId;
  double get researchProgress => _researchTotal > 0 
      ? _researchProgress / _researchTotal 
      : 0.0;
  int get researchTimeRemaining => _researchTotal - _researchProgress;
  
  /// Check for offline research progress and resume/complete
  void _checkOfflineResearch() {
    // Check if there was research in progress
    if (_state.currentResearchIdPersisted == null || 
        _state.researchStartTime == null ||
        _state.researchTotalPersisted <= 0) {
      return;
    }
    
    final research = getResearchNodeById(_state.currentResearchIdPersisted!);
    if (research == null) {
      // Clear invalid research state
      _clearResearchState();
      return;
    }
    
    // Calculate elapsed time
    final now = DateTime.now();
    final elapsed = now.difference(_state.researchStartTime!).inSeconds;
    final total = _state.researchTotalPersisted;
    
    if (elapsed >= total) {
      // Research completed while offline!
      _currentResearchId = research.id;
      _researchTotal = total;
      _researchProgress = total;
      _completeResearchV2(research);
    } else {
      // Research still in progress - resume with updated progress
      _currentResearchId = research.id;
      _researchTotal = total;
      _researchProgress = elapsed;
      
      // Resume the timer
      _researchTimer?.cancel();
      _researchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _researchProgress++;
        
        if (_researchProgress >= _researchTotal) {
          _completeResearchV2(research);
          timer.cancel();
        }
        notifyListeners();
      });
    }
  }
  
  /// Clear research state
  void _clearResearchState() {
    _state.currentResearchIdPersisted = null;
    _state.researchStartTime = null;
    _state.researchTotalPersisted = 0;
    _currentResearchId = null;
    _researchProgress = 0;
    _researchTotal = 0;
  }

  /// Start researching a technology (V2)
  void startResearchV2(ResearchNode research) {
    if (_state.energy < research.energyCost) return;
    if (_currentResearchId != null) return; // Already researching
    if (_state.unlockedResearch.contains(research.id)) return; // Already completed
    
    // Check prerequisites
    for (final prereq in research.prerequisites) {
      if (!_state.unlockedResearch.contains(prereq)) return;
    }
    
    _state.energy -= research.energyCost;
    _currentResearchId = research.id;
    _researchProgress = 0;
    
    // Apply research speed bonus
    final adjustedTime = (research.timeSeconds / (1 + _state.researchSpeedBonus)).round();
    _researchTotal = adjustedTime;
    
    // Mark as researching in state
    _state.unlockedResearch.add('researching_${research.id}');
    
    // Store research start time for offline progress tracking
    _state.researchStartTime = DateTime.now();
    _state.currentResearchIdPersisted = research.id;
    _state.researchTotalPersisted = adjustedTime;
    
    // Start research timer
    _researchTimer?.cancel();
    _researchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _researchProgress++;
      
      if (_researchProgress >= _researchTotal) {
        _completeResearchV2(research);
        timer.cancel();
      }
      notifyListeners();
    });
    
    HapticService.mediumImpact();
    _saveGame();
    notifyListeners();
  }
  
  /// Complete research and apply effects (V2)
  void _completeResearchV2(ResearchNode research) {
    // Remove researching marker
    _state.unlockedResearch.remove('researching_${research.id}');
    
    // Add completed research
    _state.unlockedResearch.add(research.id);
    
    // Apply research effects
    _applyResearchEffectV2(research.effect);
    
    // Track challenge progress
    _updateChallengeProgress(ChallengeObjective.completeResearch, 1);
    
    // Clear research state
    _clearResearchState();
    
    AudioService.playResearchComplete();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
  }
  
  /// Apply research effect to game state (V2)
  void _applyResearchEffectV2(ResearchEffect effect) {
    switch (effect.type) {
      case ResearchEffectType.productionMultiplier:
        _state.energyMultiplier *= (1 + effect.value);
        break;
      case ResearchEffectType.generatorBoost:
        // Apply to specific generator through multiplier
        _state.energyMultiplier *= (1 + effect.value * 0.5);
        break;
      case ResearchEffectType.costReduction:
        _state.costReductionBonus += effect.value;
        _state.costReductionBonus = _state.costReductionBonus.clamp(0.0, 0.75);
        break;
      case ResearchEffectType.offlineBonus:
        _state.offlineBonus += effect.value;
        break;
      case ResearchEffectType.tapPower:
        // Increase tap power through multiplier
        _state.energyMultiplier *= (1 + effect.value * 0.3);
        break;
      case ResearchEffectType.autoTap:
        _state.autoTapPerSecond += effect.value;
        break;
      case ResearchEffectType.darkMatterBonus:
        _state.darkMatterBonus += effect.value;
        _state.darkMatter += 25 * (1 + _state.darkMatterBonus); // Bonus DM on research
        break;
      case ResearchEffectType.prestigeBonus:
        _state.prestigeBonus += effect.value;
        break;
      case ResearchEffectType.researchSpeed:
        _state.researchSpeedBonus += effect.value;
        break;
      case ResearchEffectType.eraUnlock:
        // Era unlock is handled through transitions now
        break;
    }
  }
  
  /// Cancel current research (forfeit cost)
  void cancelResearch() {
    if (_currentResearchId == null) return;
    
    _state.unlockedResearch.remove('researching_$_currentResearchId');
    _researchTimer?.cancel();
    _clearResearchState();
    _saveGame();
    
    notifyListeners();
  }
  
  /// Check if research is completed
  bool isResearchCompleted(String researchId) {
    return _state.unlockedResearch.contains(researchId);
  }
  
  /// Check if research is available (prerequisites met)
  bool isResearchAvailable(ResearchNode research) {
    if (_state.unlockedResearch.contains(research.id)) return false;
    if (_currentResearchId == research.id) return false;
    
    // Check era is unlocked
    if (!_state.unlockedEras.contains(research.era.index)) return false;
    
    // Check prerequisites
    for (final prereq in research.prerequisites) {
      if (!_state.unlockedResearch.contains(prereq)) return false;
    }
    
    return true;
  }
  
  /// Get research for current era
  List<ResearchNode> getCurrentEraResearch() {
    return getResearchForEra(_state.era);
  }
  
  /// Get all unlocked era research
  List<ResearchNode> getAllUnlockedResearch() {
    final research = <ResearchNode>[];
    for (final eraIndex in _state.unlockedEras) {
      final era = Era.values[eraIndex.clamp(0, Era.values.length - 1)];
      research.addAll(getResearchForEra(era));
    }
    return research;
  }
  
  /// Calculate Dark Energy reward based on progress
  /// Uses cube root formula for diminishing returns
  double calculateDarkEnergyReward() {
    // Base calculation on total energy earned this run
    final currentRunEnergy = _state.totalEnergyEarned;
    
    // Edge case: No energy earned
    if (currentRunEnergy <= 0) return 0;
    
    // Cube root formula for diminishing returns (like Soul Eggs in Egg Inc)
    // Scale factor adjusts for game balance - optimized for Dark Energy
    final scaleFactor = _state.kardashevLevel < 1.0 ? 1.0 :
                       _state.kardashevLevel < 2.0 ? 5.0 :
                       _state.kardashevLevel < 3.0 ? 25.0 : 100.0;
    
    final reward = pow(currentRunEnergy / 1000000, 1/3) * scaleFactor;
    
    // Ensure minimum reward based on Kardashev level reached
    final minReward = _state.kardashevLevel * 5;
    
    // Guard against NaN/Infinity
    final finalReward = max(reward, minReward);
    if (finalReward.isNaN || finalReward.isInfinite) return minReward;
    
    return finalReward;
  }
  
  /// Calculate production bonus from Dark Energy
  /// Each Dark Energy gives meaningful bonus
  double calculateProductionBonusFromDarkEnergy(double darkEnergy) {
    if (darkEnergy <= 0) return 0;
    
    // Linear formula: Each Dark Energy gives +10% production bonus
    // This prevents diminishing returns and keeps prestige rewarding at higher levels
    return darkEnergy * 0.10; 
  }
  
  /// Prestige - Reset progress for permanent bonus
  bool prestige() {
    // Require certain Kardashev level to prestige
    if (_state.kardashevLevel < 0.3) return false;
    
    // Calculate dynamic rewards based on progress
    final darkEnergyReward = calculateDarkEnergyReward();
    final totalDarkEnergy = _state.darkEnergy + darkEnergyReward;
    
    // Calculate new production bonus from total Dark Energy
    final newProductionBonus = calculateProductionBonusFromDarkEnergy(totalDarkEnergy);
    
    // Preserve important data
    final preservedArchitects = List<String>.from(_state.ownedArchitects);
    final newPrestigeCount = _state.prestigeCount + 1;
    // NOTE: unlockedEras is NOT preserved - player must re-ascend to higher eras after prestige
    final preservedUnlockedAchievements = List<String>.from(_state.unlockedAchievements); // Keep unlocked achievements (prevent re-notification)
    final preservedClaimedAchievements = List<String>.from(_state.claimedAchievements); // Keep claimed achievements
    final preservedArtifactIds = List<String>.from(_state.ownedArtifactIds); // Keep artifacts
    final preservedArtifactAcquiredAt = Map<String, int>.from(_state.artifactAcquiredAt);
    final preservedArtifactSources = Map<String, String>.from(_state.artifactSources);
    final preservedDarkMatter = _state.darkMatter; // Dark Matter is preserved but no longer gives bonus
    
    // Preserve daily login data (prevent re-claiming daily rewards after prestige)
    final preservedLastLoginDate = _state.lastLoginDate;
    final preservedLoginStreak = _state.loginStreak;
    final preservedTotalLoginDays = _state.totalLoginDays;
    
    // Determine prestige tier based on total prestiges (for display/achievements)
    final newPrestigeTier = min(_state.prestigeTier + 1, prestigeTiers.length);
    
    // Reset to new game state but keep prestige rewards
    _state = GameState(
      energy: 50,
      darkMatter: preservedDarkMatter, // Keep existing Dark Matter (spending currency)
      darkEnergy: totalDarkEnergy, // New Dark Energy total
      generators: {'wind_turbine': 1},
      generatorLevels: {'wind_turbine': 1},
      ownedArchitects: preservedArchitects,
      prestigeCount: newPrestigeCount,
      prestigeBonus: newProductionBonus, // Bonus comes from Dark Energy now
      prestigeTier: newPrestigeTier,
      tutorialCompleted: true,
      unlockedEras: [0], // Reset to Era I only - player must re-ascend after prestige
      unlockedAchievements: preservedUnlockedAchievements, // Keep unlocked achievements (prevent re-notification)
      claimedAchievements: preservedClaimedAchievements, // Keep claimed achievements (no double rewards)
      ownedArtifactIds: preservedArtifactIds, // Keep artifacts
      artifactAcquiredAt: preservedArtifactAcquiredAt,
      artifactSources: preservedArtifactSources,
      // Preserve daily login data (prevent re-claiming daily rewards after prestige)
      lastLoginDate: preservedLastLoginDate,
      loginStreak: preservedLoginStreak,
      totalLoginDays: preservedTotalLoginDays,
    );
    
    // Clear any pending achievement notifications to prevent stale popups
    _pendingAchievementNotifications.clear();
    _currentAchievementNotification = null;
    
    AudioService.playPrestige();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
    return true;
  }
  
  /// Get next prestige info (dynamic calculation)
  PrestigeInfo? getNextPrestigeInfo() {
    if (_state.kardashevLevel < 0.3) return null;
    
    final darkEnergyReward = calculateDarkEnergyReward();
    final totalDarkEnergy = _state.darkEnergy + darkEnergyReward;
    
    // Calculate production bonus from dark energy only
    // Current bonus from current dark energy
    final currentBonus = calculateProductionBonusFromDarkEnergy(_state.darkEnergy);
    // New bonus from total dark energy after prestige
    final newBonus = calculateProductionBonusFromDarkEnergy(totalDarkEnergy);
    // The gain is the difference
    final bonusGain = newBonus - currentBonus;
    
    // Get tier name for display
    final nextTierIndex = min(_state.prestigeTier + 1, prestigeTiers.length - 1);
    final tierName = prestigeTiers[nextTierIndex].name;
    
    return PrestigeInfo(
      darkEnergyReward: darkEnergyReward,
      productionBonusGain: bonusGain,
      totalDarkEnergy: totalDarkEnergy,
      totalProductionBonus: newBonus,
      tierName: tierName,
      requiredKardashev: 0.3,
    );
  }
  
  /// Get current prestige tier info
  PrestigeTier? getCurrentPrestigeInfo() {
    return getCurrentPrestigeTier(_state.prestigeTier);
  }
  
  /// Format large numbers with edge case handling
  static String formatNumber(double value) {
    // Edge case handling for NaN, Infinity, and negative values
    if (value.isNaN || value.isInfinite) return '0';
    if (value < 0) return '-${formatNumber(-value)}';
    if (value == 0) return '0';
    
    if (value < 1000) return value.toStringAsFixed(1);
    if (value < 999.995e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    if (value < 999.995e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value < 999.995e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value < 999.995e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value < 999.995e15) return '${(value / 1e15).toStringAsFixed(2)}Q';
    if (value < 999.995e18) return '${(value / 1e18).toStringAsFixed(2)}Qi';
    if (value < 999.995e21) return '${(value / 1e21).toStringAsFixed(2)}Sx';
    if (value < 999.995e24) return '${(value / 1e24).toStringAsFixed(2)}Sp';
    if (value < 999.995e27) return '${(value / 1e27).toStringAsFixed(2)}Oc';
    if (value < 999.995e30) return '${(value / 1e30).toStringAsFixed(2)}No';
    if (value < 999.995e33) return '${(value / 1e33).toStringAsFixed(2)}Dc';
    if (value < 999.995e36) return '${(value / 1e36).toStringAsFixed(2)}Ud';
    if (value < 999.995e39) return '${(value / 1e39).toStringAsFixed(2)}Dd';
    if (value < 999.995e42) return '${(value / 1e42).toStringAsFixed(2)}Td';
    if (value < 999.995e45) return '${(value / 1e45).toStringAsFixed(2)}Qd';
    if (value < 999.995e48) return '${(value / 1e48).toStringAsFixed(2)}Qn';
    if (value < 999.995e51) return '${(value / 1e51).toStringAsFixed(2)}Sd';
    if (value < 999.995e54) return '${(value / 1e54).toStringAsFixed(2)}Spd';
    if (value < 999.995e57) return '${(value / 1e57).toStringAsFixed(2)}Od';
    if (value < 999.995e60) return '${(value / 1e60).toStringAsFixed(2)}Nd';
    if (value < 999.995e63) return '${(value / 1e63).toStringAsFixed(2)}Vg';
    if (value < 999.995e66) return '${(value / 1e66).toStringAsFixed(2)}Uvg';
    if (value < 999.995e69) return '${(value / 1e69).toStringAsFixed(2)}Dvg';
    if (value < 999.995e72) return '${(value / 1e72).toStringAsFixed(2)}Tvg';
    if (value < 999.995e75) return '${(value / 1e75).toStringAsFixed(2)}Qvg';
    if (value < 999.995e78) return '${(value / 1e78).toStringAsFixed(2)}Qnv';
    if (value < 999.995e81) return '${(value / 1e81).toStringAsFixed(2)}Svg';
    if (value < 999.995e84) return '${(value / 1e84).toStringAsFixed(2)}Spv';
    if (value < 999.995e87) return '${(value / 1e87).toStringAsFixed(2)}Ovg';
    if (value < 999.995e90) return '${(value / 1e90).toStringAsFixed(2)}Nvg';
    if (value < 999.995e93) return '${(value / 1e93).toStringAsFixed(2)}Tg';
    if (value < 999.995e96) return '${(value / 1e96).toStringAsFixed(2)}Utg';
    if (value < 999.995e99) return '${(value / 1e99).toStringAsFixed(2)}Dtg';
    if (value < 999.995e102) return '${(value / 1e102).toStringAsFixed(2)}Ttg';
    if (value < 999.995e105) return '${(value / 1e105).toStringAsFixed(2)}Qtg';
    if (value < 999.995e108) return '${(value / 1e108).toStringAsFixed(2)}Qnt';
    if (value < 999.995e111) return '${(value / 1e111).toStringAsFixed(2)}Stg';
    if (value < 999.995e114) return '${(value / 1e114).toStringAsFixed(2)}Spt';
    if (value < 999.995e117) return '${(value / 1e117).toStringAsFixed(2)}Otg';
    if (value < 999.995e120) return '${(value / 1e120).toStringAsFixed(2)}Ntg';
    return value.toStringAsExponential(2);
  }
  
  /// Format time duration
  static String formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m ${seconds % 60}s';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ACHIEVEMENTS SYSTEM
  // ═══════════════════════════════════════════════════════════════
  
  /// Check all achievements and unlock newly earned ones
  void checkAchievements() {
    for (final achievement in allAchievements) {
      // Skip if already unlocked OR already claimed (claimed = already shown before)
      if (_state.unlockedAchievements.contains(achievement.id)) continue;
      if (_state.claimedAchievements.contains(achievement.id)) continue;
      
      if (_checkAchievementCondition(achievement.condition)) {
        _unlockAchievement(achievement);
      }
    }
  }
  
  /// Check if a specific achievement condition is met
  bool _checkAchievementCondition(AchievementCondition condition) {
    switch (condition.type) {
      case ConditionType.totalEnergy:
        return _state.totalEnergyEarned >= condition.targetValue;
      case ConditionType.energyPerSecond:
        return _state.energyPerSecond >= condition.targetValue;
      case ConditionType.totalGenerators:
        return _state.totalGenerators >= condition.targetValue;
      case ConditionType.specificGenerator:
        return (_state.generators[condition.targetId] ?? 0) >= condition.targetValue;
      case ConditionType.kardashevLevel:
        return _state.kardashevLevel >= condition.targetValue;
      case ConditionType.totalTaps:
        return _state.totalTaps >= condition.targetValue;
      case ConditionType.researchCompleted:
        return _state.completedResearchCount >= condition.targetValue;
      case ConditionType.prestigeCount:
        return _state.prestigeCount >= condition.targetValue;
      case ConditionType.darkMatter:
        return _state.darkMatter >= condition.targetValue;
      case ConditionType.playTime:
        return _state.playTimeSeconds >= condition.targetValue;
      case ConditionType.eraUnlocked:
        return _state.unlockedEras.length > condition.targetValue;
      case ConditionType.architectOwned:
        return _state.ownedArchitects.length >= condition.targetValue;
    }
  }
  
  /// Unlock an achievement
  void _unlockAchievement(Achievement achievement) {
    // Don't unlock if already unlocked or claimed
    if (_state.unlockedAchievements.contains(achievement.id)) return;
    if (_state.claimedAchievements.contains(achievement.id)) return;
    
    _state.unlockedAchievements.add(achievement.id);
    _pendingAchievementNotifications.add(achievement);
    
    // Show next notification if none is showing
    if (_currentAchievementNotification == null) {
      _showNextAchievementNotification();
    }
    
    // Play sound
    AudioService.playAchievement();
    HapticService.heavyImpact();
    
    notifyListeners();
  }
  
  /// Show next achievement notification
  void _showNextAchievementNotification() {
    if (_pendingAchievementNotifications.isNotEmpty) {
      _currentAchievementNotification = _pendingAchievementNotifications.removeAt(0);
      notifyListeners();
    }
  }
  
  /// Dismiss current achievement notification
  void dismissAchievementNotification() {
    _currentAchievementNotification = null;
    notifyListeners();
    
    // Show next after a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _showNextAchievementNotification();
    });
  }
  
  /// Claim achievement rewards
  bool claimAchievement(String achievementId) {
    if (!_state.unlockedAchievements.contains(achievementId)) return false;
    if (_state.claimedAchievements.contains(achievementId)) return false;
    
    final achievement = getAchievementById(achievementId);
    if (achievement == null) return false;
    
    // Grant rewards
    if (achievement.energyReward > 0) {
      _state.energy += achievement.energyReward;
      _state.totalEnergyEarned += achievement.energyReward;
    }
    if (achievement.darkMatterReward > 0) {
      _state.darkMatter += achievement.darkMatterReward;
    }
    
    _state.claimedAchievements.add(achievementId);
    
    AudioService.playPurchase();
    HapticService.mediumImpact();
    _saveGame();
    notifyListeners();
    return true;
  }
  
  /// Get achievement progress (0.0 - 1.0)
  double getAchievementProgress(Achievement achievement) {
    if (_state.unlockedAchievements.contains(achievement.id)) return 1.0;
    
    final condition = achievement.condition;
    double currentValue = 0;
    
    switch (condition.type) {
      case ConditionType.totalEnergy:
        currentValue = _state.totalEnergyEarned;
        break;
      case ConditionType.energyPerSecond:
        currentValue = _state.energyPerSecond;
        break;
      case ConditionType.totalGenerators:
        currentValue = _state.totalGenerators.toDouble();
        break;
      case ConditionType.specificGenerator:
        currentValue = (_state.generators[condition.targetId] ?? 0).toDouble();
        break;
      case ConditionType.kardashevLevel:
        currentValue = _state.kardashevLevel;
        break;
      case ConditionType.totalTaps:
        currentValue = _state.totalTaps.toDouble();
        break;
      case ConditionType.researchCompleted:
        currentValue = _state.completedResearchCount.toDouble();
        break;
      case ConditionType.prestigeCount:
        currentValue = _state.prestigeCount.toDouble();
        break;
      case ConditionType.darkMatter:
        currentValue = _state.darkMatter;
        break;
      case ConditionType.playTime:
        currentValue = _state.playTimeSeconds.toDouble();
        break;
      case ConditionType.eraUnlocked:
        currentValue = (_state.unlockedEras.length - 1).toDouble();
        break;
      case ConditionType.architectOwned:
        currentValue = _state.ownedArchitects.length.toDouble();
        break;
    }
    
    return (currentValue / condition.targetValue).clamp(0.0, 1.0);
  }
  
  /// Check if achievement is claimed
  bool isAchievementClaimed(String achievementId) {
    return _state.claimedAchievements.contains(achievementId);
  }
  
  /// Check if achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    return _state.unlockedAchievements.contains(achievementId);
  }
  
  /// Get count of unlocked achievements
  int get unlockedAchievementCount => _state.unlockedAchievements.length;
  
  /// Get count of claimed achievements
  int get claimedAchievementCount => _state.claimedAchievements.length;
  
  /// Get unclaimed achievement count (never negative)
  int get unclaimedAchievementCount {
    // Count achievements that are unlocked but not yet claimed
    // Use set difference to handle edge cases correctly
    final unclaimedCount = _state.unlockedAchievements
        .where((id) => !_state.claimedAchievements.contains(id))
        .length;
    return unclaimedCount;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════════
  
  void toggleSound() {
    _state.soundEnabled = !_state.soundEnabled;
    AudioService.setEnabled(_state.soundEnabled);
    _saveGame();
    notifyListeners();
  }
  
  void toggleHaptics() {
    _state.hapticsEnabled = !_state.hapticsEnabled;
    HapticService.setEnabled(_state.hapticsEnabled);
    _saveGame();
    notifyListeners();
  }
  
  void toggleNotifications() {
    _state.notificationsEnabled = !_state.notificationsEnabled;
    _saveGame();
    notifyListeners();
  }
  
  /// Reset game progress
  Future<void> resetProgress() async {
    // Cancel all timers
    _gameLoop?.cancel();
    _saveTimer?.cancel();
    _playTimeTimer?.cancel();
    _autoTapTimer?.cancel();
    _researchTimer?.cancel();
    
    // Clear state
    _state = GameState(
      energy: 50,
      generators: {'wind_turbine': 1},
      generatorLevels: {'wind_turbine': 1},
      unlockedEras: [0],
      soundEnabled: _state.soundEnabled,
      hapticsEnabled: _state.hapticsEnabled,
      notificationsEnabled: _state.notificationsEnabled,
    );
    
    // Clear and save
    if (_gameBox != null) {
      await _gameBox!.clear();
      await _gameBox!.add(_state);
    }
    
    // Restart timers
    _startGameLoop();
    _startSaveTimer();
    _startPlayTimeTimer();
    _startAutoTapTimer();
    
    notifyListeners();
  }
  
  // ═══════════════════════════════════════════════════════════════
  // LEGENDARY EXPEDITION SYSTEM
  // ═══════════════════════════════════════════════════════════════
  
  /// Get active legendary expedition
  ActiveLegendaryExpedition? get activeLegendaryExpedition => _state.activeLegendary;
  
  /// Check if a legendary expedition is active
  bool get hasActiveLegendaryExpedition => _state.activeLegendary != null;
  
  /// Get architects currently on any expedition (regular or legendary)
  Set<String> get architectsOnAnyExpedition {
    final onRegular = <String>{};
    for (final active in _activeExpeditions) {
      onRegular.addAll(active.assignedArchitectIds);
    }
    final onLegendary = _state.architectsOnLegendaryExpedition;
    return {...onRegular, ...onLegendary};
  }
  
  /// Check if an architect is available for expeditions
  bool isArchitectAvailable(String architectId) {
    if (!_state.ownedArchitects.contains(architectId)) return false;
    return !architectsOnAnyExpedition.contains(architectId);
  }
  
  /// Start a legendary expedition
  bool startLegendaryExpedition(String expeditionId, List<String> architectIds) {
    final expedition = getLegendaryExpeditionById(expeditionId);
    if (expedition == null) return false;
    
    // Check if already have an active legendary expedition
    if (hasActiveLegendaryExpedition) return false;
    
    // Check if expedition is on cooldown
    if (_state.isLegendaryOnCooldown(expeditionId)) return false;
    
    // Validate architect count
    if (architectIds.length < expedition.minArchitects ||
        architectIds.length > expedition.maxArchitects) {
      return false;
    }
    
    // Check if architects are available (not on any expedition)
    final unavailable = architectsOnAnyExpedition;
    for (final id in architectIds) {
      if (unavailable.contains(id)) return false;
      if (!_state.ownedArchitects.contains(id)) return false;
    }
    
    // Create active legendary expedition
    final active = ActiveLegendaryExpedition(
      expeditionId: expeditionId,
      assignedArchitectIds: architectIds,
      startTime: DateTime.now(),
      currentStage: 0,
      stageResults: [],
      collectedRewards: [],
    );
    
    // Store in game state
    _state.activeLegendaryExpedition = active.toMap();
    
    AudioService.playPurchase();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
    return true;
  }
  
  /// Resolve the current stage of legendary expedition
  LegendaryStageResult? resolveLegendaryStage() {
    final active = _state.activeLegendary;
    if (active == null) return null;
    if (!active.canResolveCurrentStage) return null;
    
    final expedition = active.expedition;
    if (expedition == null) return null;
    
    final stage = active.currentStageInfo;
    if (stage == null) return null;
    
    // Calculate success rate with artifact bonuses
    final baseBonus = calculateArtifactBonus(ArtifactBonusType.expeditionSuccess);
    final result = rollStageSuccess(
      expedition,
      stage,
      active.assignedArchitectIds,
      baseBonus,
    );
    
    // Update active expedition state
    final newStageResults = [...active.stageResults, result.success];
    final newCollectedRewards = [...active.collectedRewards, result.rewards];
    
    if (result.expeditionFailed) {
      // Expedition failed - end it
      _state.activeLegendaryExpedition = active.copyWith(
        stageResults: newStageResults,
        collectedRewards: newCollectedRewards,
        failed: true,
        isCompleted: true,
      ).toMap();
      
      // Apply partial rewards
      _applyExpeditionRewards(result.rewards);
      
      _notificationController.showExpeditionFailed(
        expedition.name,
        () {},
      );
    } else if (result.expeditionCompleted) {
      // All stages complete - success!
      _state.activeLegendaryExpedition = active.copyWith(
        stageResults: newStageResults,
        collectedRewards: newCollectedRewards,
        currentStage: active.currentStage + 1,
        isCompleted: true,
      ).toMap();
      
      // Apply stage rewards
      _applyExpeditionRewards(result.rewards);
      
      // Apply completion rewards
      _applyExpeditionRewards(expedition.completionRewards);
      
      // Try to drop the legendary artifact
      _tryDropLegendaryArtifact(expeditionId: expedition.id);
      
      _notificationController.showExpeditionComplete(
        expedition.name,
        'Legendary expedition completed!',
        () {},
      );
    } else {
      // Move to next stage
      _state.activeLegendaryExpedition = active.copyWith(
        stageResults: newStageResults,
        collectedRewards: newCollectedRewards,
        currentStage: active.currentStage + 1,
      ).toMap();
      
      // Apply stage rewards
      _applyExpeditionRewards(result.rewards);
    }
    
    AudioService.playAchievement();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
    
    return result;
  }
  
  /// Collect rewards and end legendary expedition
  void collectLegendaryExpedition() {
    final active = _state.activeLegendary;
    if (active == null || !active.isCompleted) return;
    
    final expedition = active.expedition;
    if (expedition == null) return;
    
    // Mark as collected
    _state.activeLegendaryExpedition = active.copyWith(isCollected: true).toMap();
    
    // Add to completed list if successful
    if (!active.failed) {
      if (!_state.completedLegendaryExpeditions.contains(expedition.id)) {
        _state.completedLegendaryExpeditions.add(expedition.id);
      }
      
      // Set cooldown
      final cooldownEnd = DateTime.now().add(expedition.cooldownAfterCompletion);
      _state.legendaryExpeditionCooldowns[expedition.id] = 
          cooldownEnd.millisecondsSinceEpoch;
    }
    
    // Clear active expedition
    _state.activeLegendaryExpedition = null;
    
    _saveGame();
    notifyListeners();
  }
  
  /// Cancel an active legendary expedition (forfeits progress)
  void cancelLegendaryExpedition() {
    if (!hasActiveLegendaryExpedition) return;
    _state.activeLegendaryExpedition = null;
    _saveGame();
    notifyListeners();
  }
  
  /// Apply expedition rewards to game state
  void _applyExpeditionRewards(List<ExpeditionReward> rewards) {
    for (final reward in rewards) {
      switch (reward.type) {
        case ExpeditionRewardType.energy:
          _state.energy += reward.amount;
          _state.totalEnergyEarned += reward.amount;
        case ExpeditionRewardType.darkMatter:
          _state.darkMatter += reward.amount * (1 + _state.darkMatterBonus);
        case ExpeditionRewardType.researchBoost:
          _state.researchSpeedBonus += reward.amount;
        case ExpeditionRewardType.productionBoost:
          _applyProductionBoost(1 + reward.amount, const Duration(hours: 2));
        case ExpeditionRewardType.architectXP:
          // TODO: Implement architect XP system
          break;
      }
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ARTIFACT SYSTEM
  // ═══════════════════════════════════════════════════════════════
  
  /// Get list of owned artifacts
  List<Artifact> get ownedArtifacts {
    return _state.ownedArtifactIds
        .map((id) => getArtifactById(id))
        .where((a) => a != null)
        .cast<Artifact>()
        .toList();
  }
  
  /// Get owned artifacts count
  int get ownedArtifactCount => _state.ownedArtifactIds.length;
  
  /// Check if player owns an artifact
  bool hasArtifact(String artifactId) => _state.hasArtifact(artifactId);
  
  /// Add an artifact to player's collection
  void addArtifact(String artifactId, {String? source}) {
    if (_state.ownedArtifactIds.contains(artifactId)) return; // Already owned
    
    final artifact = getArtifactById(artifactId);
    if (artifact == null) return;
    
    _state.ownedArtifactIds.add(artifactId);
    _state.artifactAcquiredAt[artifactId] = DateTime.now().millisecondsSinceEpoch;
    if (source != null) {
      _state.artifactSources[artifactId] = source;
    }
    
    // Show notification
    _notificationController.showArtifactFound(
      artifact.name,
      artifact.rarity.displayName,
      () {},
    );
    
    AudioService.playAchievement();
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
  }
  
  /// Calculate total bonus from artifacts for a specific type
  double calculateArtifactBonus(ArtifactBonusType bonusType) {
    double total = 0.0;
    for (final artifactId in _state.ownedArtifactIds) {
      final artifact = getArtifactById(artifactId);
      if (artifact != null && artifact.bonusType == bonusType) {
        total += artifact.bonusValue;
      }
    }
    return total;
  }
  
  /// Try to drop an artifact from regular expedition
  void _tryDropArtifactFromExpedition(String expeditionId) {
    final dropped = rollArtifactDrop(expeditionId, _state.currentEra);
    if (dropped != null && !_state.ownedArtifactIds.contains(dropped.id)) {
      addArtifact(dropped.id, source: expeditionId);
    }
  }
  
  /// Try to drop the specific artifact from legendary expedition
  void _tryDropLegendaryArtifact({required String expeditionId}) {
    // Find artifacts that have this expedition as their source
    final sourceArtifacts = allArtifacts
        .where((a) => a.sourceExpedition == expeditionId)
        .toList();
    
    if (sourceArtifacts.isEmpty) return;
    
    // Guaranteed drop of source artifact from legendary expedition
    for (final artifact in sourceArtifacts) {
      if (!_state.ownedArtifactIds.contains(artifact.id)) {
        addArtifact(artifact.id, source: 'legendary:$expeditionId');
        break; // Only drop one artifact per completion
      }
    }
  }
  
  /// Get artifact bonuses summary for UI display
  Map<ArtifactBonusType, double> getArtifactBonusesSummary() {
    final summary = <ArtifactBonusType, double>{};
    for (final type in ArtifactBonusType.values) {
      final bonus = calculateArtifactBonus(type);
      if (bonus > 0) {
        summary[type] = bonus;
      }
    }
    return summary;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // UPDATED EXPEDITION COMPLETION WITH ARTIFACTS
  // ═══════════════════════════════════════════════════════════════
  
  /// Complete an expedition and try to drop an artifact
  ExpeditionResult? completeExpeditionWithArtifact(String expeditionId) {
    final result = completeExpedition(expeditionId);
    
    if (result != null && result.success) {
      // Try to drop an artifact
      _tryDropArtifactFromExpedition(expeditionId);
    }
    
    return result;
  }

  /// Cleanup
  @override
  void dispose() {
    _gameLoop?.cancel();
    _saveTimer?.cancel();
    _playTimeTimer?.cancel();
    _autoTapTimer?.cancel();
    _researchTimer?.cancel();
    _saveGame();
    super.dispose();
  }
}
