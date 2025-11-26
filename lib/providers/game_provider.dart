import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_state.dart';
import '../models/architect.dart';
import '../core/constants.dart';
import '../core/era_data.dart';
import '../models/research_v2.dart';
import '../services/haptic_service.dart';

/// Dynamic prestige information
class PrestigeInfo {
  final double darkMatterReward;
  final double productionBonusGain;
  final double totalDarkMatter;
  final double totalProductionBonus;
  final String tierName;
  final double requiredKardashev;
  
  const PrestigeInfo({
    required this.darkMatterReward,
    required this.productionBonusGain,
    required this.totalDarkMatter,
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
  
  // Getters
  GameState get state => _state;
  bool get isInitialized => _isInitialized;
  double get offlineEarnings => _offlineEarnings;
  bool get showOfflineEarnings => _showOfflineEarnings;
  bool get showEraTransition => _showEraTransition;
  EraTransition? get pendingTransition => _pendingTransition;
  
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
    
    // Start game loops
    _startGameLoop();
    _startSaveTimer();
    _startPlayTimeTimer();
    _startAutoTapTimer();
    
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
  void _startGameLoop() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final energyGain = _state.energyPerSecond / 10; // Per 100ms
      if (energyGain > 0) {
        _state.energy += energyGain;
        _state.totalEnergyEarned += energyGain;
        _state.updateKardashevLevel();
        
        // Check for era transition milestones
        _checkEraTransitionMilestone();
        
        notifyListeners();
      }
    });
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
    
    final transition = _state.nextTransition;
    if (transition == null) return;
    
    // Check if reached required Kardashev level
    if (_state.kardashevLevel >= transition.requiredKardashev &&
        !_state.unlockedEras.contains(transition.toEra.index)) {
      _pendingTransition = transition;
      _showEraTransition = true;
    }
  }
  
  /// Dismiss era transition dialog without transitioning
  void dismissEraTransition() {
    _showEraTransition = false;
    notifyListeners();
  }
  
  /// Execute era transition
  bool executeEraTransition() {
    final transition = _pendingTransition;
    if (transition == null) return false;
    
    // Check requirements
    if (_state.kardashevLevel < transition.requiredKardashev) return false;
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
    
    _state.updateKardashevLevel();
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
    
    _state.updateKardashevLevel();
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
  
  /// Synthesize (unlock) a new architect using dark matter
  bool synthesizeArchitect() {
    const cost = 100.0; // Dark matter cost
    if (_state.darkMatter < cost) return false;
    
    // Get available architects not yet owned
    final available = eraIArchitects
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
    
    // Clear research state
    _clearResearchState();
    
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
  
  /// Calculate Dark Matter reward based on progress (Egg Inc style)
  /// Uses cube root formula for diminishing returns
  double calculateDarkMatterReward() {
    // Base calculation on total energy earned this run
    final currentRunEnergy = _state.totalEnergyEarned;
    
    // Cube root formula for diminishing returns (like Soul Eggs in Egg Inc)
    // Scale factor adjusts for game balance
    final scaleFactor = _state.kardashevLevel < 1.0 ? 0.5 :
                       _state.kardashevLevel < 2.0 ? 2.0 :
                       _state.kardashevLevel < 3.0 ? 10.0 : 50.0;
    
    final reward = pow(currentRunEnergy / 1000000, 1/3) * scaleFactor;
    
    // Ensure minimum reward based on Kardashev level reached
    final minReward = _state.kardashevLevel * 10;
    
    return max(reward, minReward);
  }
  
  /// Calculate production bonus from Dark Matter
  /// Each Dark Matter gives diminishing bonus (logarithmic scaling)
  double calculateProductionBonusFromDarkMatter(double darkMatter) {
    if (darkMatter <= 0) return 0;
    
    // Logarithmic bonus: more Dark Matter = smaller incremental gains
    // Formula: bonus = log10(darkMatter + 1) * 0.1
    // Examples: 10 DM = 10% bonus, 100 DM = 20% bonus, 1000 DM = 30% bonus
    return log(darkMatter + 1) / ln10 * 0.1;
  }
  
  /// Prestige - Reset progress for permanent bonus
  bool prestige() {
    // Require certain Kardashev level to prestige
    if (_state.kardashevLevel < 0.3) return false;
    
    // Calculate dynamic rewards based on progress
    final darkMatterReward = calculateDarkMatterReward();
    final totalDarkMatter = _state.darkMatter + darkMatterReward;
    
    // Calculate new production bonus from total Dark Matter
    final newProductionBonus = calculateProductionBonusFromDarkMatter(totalDarkMatter);
    
    // Preserve important data
    final preservedArchitects = List<String>.from(_state.ownedArchitects);
    final newPrestigeCount = _state.prestigeCount + 1;
    final preservedUnlockedEras = List<int>.from(_state.unlockedEras);
    
    // Determine prestige tier based on total prestiges (for display/achievements)
    final newPrestigeTier = min(_state.prestigeTier + 1, prestigeTiers.length);
    
    // Reset to new game state but keep prestige rewards
    _state = GameState(
      energy: 50,
      darkMatter: totalDarkMatter,
      generators: {'wind_turbine': 1},
      generatorLevels: {'wind_turbine': 1},
      ownedArchitects: preservedArchitects,
      prestigeCount: newPrestigeCount,
      prestigeBonus: newProductionBonus,
      prestigeTier: newPrestigeTier,
      tutorialCompleted: true,
      unlockedEras: preservedUnlockedEras, // Keep eras unlocked
    );
    
    HapticService.heavyImpact();
    _saveGame();
    notifyListeners();
    return true;
  }
  
  /// Get next prestige info (dynamic calculation)
  PrestigeInfo? getNextPrestigeInfo() {
    if (_state.kardashevLevel < 0.3) return null;
    
    final darkMatterReward = calculateDarkMatterReward();
    final totalDarkMatter = _state.darkMatter + darkMatterReward;
    final newProductionBonus = calculateProductionBonusFromDarkMatter(totalDarkMatter);
    final bonusGain = newProductionBonus - _state.prestigeBonus;
    
    // Get tier name for display
    final tierIndex = min(_state.prestigeTier, prestigeTiers.length - 1);
    final nextTierIndex = min(_state.prestigeTier + 1, prestigeTiers.length - 1);
    final tierName = prestigeTiers[nextTierIndex].name;
    
    return PrestigeInfo(
      darkMatterReward: darkMatterReward,
      productionBonusGain: bonusGain,
      totalDarkMatter: totalDarkMatter,
      totalProductionBonus: newProductionBonus,
      tierName: tierName,
      requiredKardashev: 0.3,
    );
  }
  
  /// Get current prestige tier info
  PrestigeTier? getCurrentPrestigeInfo() {
    return getCurrentPrestigeTier(_state.prestigeTier);
  }
  
  /// Format large numbers
  static String formatNumber(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    if (value < 1000) return value.toStringAsFixed(1);
    if (value < 1000000) return '${(value / 1000).toStringAsFixed(2)}K';
    if (value < 1000000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value < 1e12) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value < 1e15) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value < 1e18) return '${(value / 1e15).toStringAsFixed(2)}Q';
    if (value < 1e21) return '${(value / 1e18).toStringAsFixed(2)}Qi';
    if (value < 1e24) return '${(value / 1e21).toStringAsFixed(2)}Sx';
    if (value < 1e27) return '${(value / 1e24).toStringAsFixed(2)}Sp';
    if (value < 1e30) return '${(value / 1e27).toStringAsFixed(2)}Oc';
    return '${(value / 1e30).toStringAsFixed(2)}No';
  }
  
  /// Format time duration
  static String formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m ${seconds % 60}s';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
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
