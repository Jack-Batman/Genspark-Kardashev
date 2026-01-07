import 'dart:math';
import 'package:flutter/foundation.dart';

/// Leaderboard categories
enum LeaderboardCategory {
  totalEnergy,
  kardashevLevel,
  prestigeCount,
  darkMatter,
  playTime,
  expeditionsCompleted,
  architectsOwned,
}

extension LeaderboardCategoryExtension on LeaderboardCategory {
  String get displayName {
    switch (this) {
      case LeaderboardCategory.totalEnergy:
        return 'Total Energy';
      case LeaderboardCategory.kardashevLevel:
        return 'Kardashev Level';
      case LeaderboardCategory.prestigeCount:
        return 'Prestige Count';
      case LeaderboardCategory.darkMatter:
        return 'Dark Matter';
      case LeaderboardCategory.playTime:
        return 'Play Time';
      case LeaderboardCategory.expeditionsCompleted:
        return 'Expeditions';
      case LeaderboardCategory.architectsOwned:
        return 'Architects';
    }
  }
  
  String get icon {
    switch (this) {
      case LeaderboardCategory.totalEnergy:
        return '⚡';
      case LeaderboardCategory.kardashevLevel:
        return '🌌';
      case LeaderboardCategory.prestigeCount:
        return '🔄';
      case LeaderboardCategory.darkMatter:
        return '🌑';
      case LeaderboardCategory.playTime:
        return '⏱️';
      case LeaderboardCategory.expeditionsCompleted:
        return '🚀';
      case LeaderboardCategory.architectsOwned:
        return '👨‍🔬';
    }
  }
}

/// Player entry in leaderboard
class LeaderboardEntry {
  final String odeName;
  final String odisplayName;
  final int rank;
  final double value;
  final String formattedValue;
  final int era; // 0-4
  final int prestigeTier;
  final String? title;
  final String? border;
  final bool hasLeaderboardCrown;
  final bool isCurrentPlayer;
  final DateTime lastUpdated;
  
  const LeaderboardEntry({
    required this.odeName,
    required this.odisplayName,
    required this.rank,
    required this.value,
    required this.formattedValue,
    required this.era,
    required this.prestigeTier,
    this.title,
    this.border,
    this.hasLeaderboardCrown = false,
    this.isCurrentPlayer = false,
    required this.lastUpdated,
  });
}

/// Weekly tournament data
class WeeklyTournament {
  final String id;
  final String name;
  final LeaderboardCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final List<TournamentReward> rewards;
  final List<LeaderboardEntry> topPlayers;
  
  const WeeklyTournament({
    required this.id,
    required this.name,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.rewards,
    required this.topPlayers,
  });
  
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }
  
  bool get isActive => DateTime.now().isBefore(endTime) && DateTime.now().isAfter(startTime);
}

/// Tournament reward tiers
class TournamentReward {
  final int minRank;
  final int maxRank;
  final int darkMatter;
  final String? exclusiveTitle;
  final String? exclusiveBorder;
  
  const TournamentReward({
    required this.minRank,
    required this.maxRank,
    required this.darkMatter,
    this.exclusiveTitle,
    this.exclusiveBorder,
  });
}

/// Leaderboard service - simulates server-side leaderboard
/// In production, this would connect to Firebase/backend
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();
  
  // Simulated leaderboard data
  final Map<LeaderboardCategory, List<LeaderboardEntry>> _leaderboards = {};
  WeeklyTournament? _currentTournament;
  
  // Player's current stats for comparison
  double _playerTotalEnergy = 0;
  double _playerKardashev = 0;
  int _playerPrestige = 0;
  double _playerDarkMatter = 0;
  int _playerPlayTime = 0;
  int _playerExpeditions = 0;
  int _playerArchitects = 0;
  String _playerName = 'You';
  
  /// Initialize leaderboard service
  Future<void> initialize() async {
    _generateSimulatedLeaderboards();
    _generateWeeklyTournament();
    
    if (kDebugMode) {
      debugPrint('LeaderboardService initialized with simulated data');
    }
  }
  
  /// Update player stats for leaderboard
  void updatePlayerStats({
    required double totalEnergy,
    required double kardashevLevel,
    required int prestigeCount,
    required double darkMatter,
    required int playTimeSeconds,
    required int expeditionsCompleted,
    required int architectsOwned,
    String? playerName,
  }) {
    _playerTotalEnergy = totalEnergy;
    _playerKardashev = kardashevLevel;
    _playerPrestige = prestigeCount;
    _playerDarkMatter = darkMatter;
    _playerPlayTime = playTimeSeconds;
    _playerExpeditions = expeditionsCompleted;
    _playerArchitects = architectsOwned;
    if (playerName != null) _playerName = playerName;
    
    // Regenerate leaderboards with updated player position
    _generateSimulatedLeaderboards();
  }
  
  /// Get leaderboard for category
  List<LeaderboardEntry> getLeaderboard(LeaderboardCategory category, {int limit = 100}) {
    return _leaderboards[category]?.take(limit).toList() ?? [];
  }
  
  /// Get top 10 for quick display
  List<LeaderboardEntry> getTop10(LeaderboardCategory category) {
    return getLeaderboard(category, limit: 10);
  }
  
  /// Get player's rank in category
  int getPlayerRank(LeaderboardCategory category) {
    final leaderboard = _leaderboards[category] ?? [];
    final playerEntry = leaderboard.where((e) => e.isCurrentPlayer).firstOrNull;
    return playerEntry?.rank ?? leaderboard.length + 1;
  }
  
  /// Get current weekly tournament
  WeeklyTournament? get currentTournament => _currentTournament;
  
  /// Get player's tournament rank
  int getPlayerTournamentRank() {
    if (_currentTournament == null) return 0;
    final entry = _currentTournament!.topPlayers.where((e) => e.isCurrentPlayer).firstOrNull;
    return entry?.rank ?? _currentTournament!.topPlayers.length + 1;
  }
  
  /// Generate simulated leaderboard data
  void _generateSimulatedLeaderboards() {
    final random = Random(42); // Fixed seed for consistent fake players
    
    // Generate fake players
    final fakeNames = [
      'CosmicWhale99', 'DarkMatterKing', 'EnergyLord', 'GalacticMaster',
      'StarForger', 'VoidWalker', 'QuantumSage', 'NebulaPrime',
      'StellarPhoenix', 'OmegaAscended', 'InfinitySeeker', 'CosmosRuler',
      'DimensionBreaker', 'TimeLordX', 'EntropyMaster', 'PrimevalForce',
      'CelestialOne', 'EternalFlame', 'VoidEmperor', 'CosmicTitan',
      'StarWeaver', 'GalaxyShaper', 'UniverseArch', 'RealityBender',
      'SpaceConqueror', 'EnergyTycoon', 'MatterMaster', 'PrestigeLord',
      'AscensionKing', 'EraChampion', 'DimensionKing', 'CosmicElite',
    ];
    
    final titles = [null, null, null, 'Galactic Overlord', 'Universal Dominator', 'Omega Ascendant'];
    final borders = [null, null, null, 'galactic_overlord', 'universal_dominator', 'omega_whale_animated'];
    
    for (final category in LeaderboardCategory.values) {
      final entries = <LeaderboardEntry>[];
      
      // Generate top players based on category
      for (int i = 0; i < 50; i++) {
        final isWhale = i < 5;
        final titleIndex = isWhale ? random.nextInt(titles.length) : random.nextInt(3);
        
        double value;
        String formattedValue;
        
        switch (category) {
          case LeaderboardCategory.totalEnergy:
            // Top players have exponentially more energy
            value = _generateTopValue(i, 1e30, 1e15, random);
            formattedValue = _formatLargeNumber(value);
            break;
          case LeaderboardCategory.kardashevLevel:
            value = 4.0 - (i * 0.05) + random.nextDouble() * 0.02;
            value = value.clamp(0.0, 4.0);
            formattedValue = value.toStringAsFixed(3);
            break;
          case LeaderboardCategory.prestigeCount:
            value = (100 - i * 1.5 + random.nextInt(5)).toDouble();
            value = value.clamp(1, 100);
            formattedValue = value.toInt().toString();
            break;
          case LeaderboardCategory.darkMatter:
            value = _generateTopValue(i, 500000, 1000, random);
            formattedValue = _formatLargeNumber(value);
            break;
          case LeaderboardCategory.playTime:
            value = (1000 - i * 15 + random.nextInt(10)) * 3600.0; // In seconds
            formattedValue = '${(value / 3600).toInt()}h';
            break;
          case LeaderboardCategory.expeditionsCompleted:
            value = (500 - i * 8 + random.nextInt(5)).toDouble();
            formattedValue = value.toInt().toString();
            break;
          case LeaderboardCategory.architectsOwned:
            value = (20 - (i * 0.3) + random.nextDouble()).clamp(1, 20);
            formattedValue = value.toInt().toString();
            break;
        }
        
        entries.add(LeaderboardEntry(
          odeName: 'player_${i}_$category',
          odisplayName: fakeNames[i % fakeNames.length],
          rank: i + 1,
          value: value,
          formattedValue: formattedValue,
          era: (4 - (i ~/ 10)).clamp(0, 4),
          prestigeTier: (50 - i).clamp(1, 50),
          title: titles[titleIndex],
          border: borders[titleIndex],
          hasLeaderboardCrown: i == 0,
          isCurrentPlayer: false,
          lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
        ));
      }
      
      // Insert current player at appropriate position
      double playerValue;
      String playerFormattedValue;
      
      switch (category) {
        case LeaderboardCategory.totalEnergy:
          playerValue = _playerTotalEnergy;
          playerFormattedValue = _formatLargeNumber(playerValue);
          break;
        case LeaderboardCategory.kardashevLevel:
          playerValue = _playerKardashev;
          playerFormattedValue = playerValue.toStringAsFixed(3);
          break;
        case LeaderboardCategory.prestigeCount:
          playerValue = _playerPrestige.toDouble();
          playerFormattedValue = _playerPrestige.toString();
          break;
        case LeaderboardCategory.darkMatter:
          playerValue = _playerDarkMatter;
          playerFormattedValue = _formatLargeNumber(playerValue);
          break;
        case LeaderboardCategory.playTime:
          playerValue = _playerPlayTime.toDouble();
          playerFormattedValue = '${(_playerPlayTime / 3600).toInt()}h';
          break;
        case LeaderboardCategory.expeditionsCompleted:
          playerValue = _playerExpeditions.toDouble();
          playerFormattedValue = _playerExpeditions.toString();
          break;
        case LeaderboardCategory.architectsOwned:
          playerValue = _playerArchitects.toDouble();
          playerFormattedValue = _playerArchitects.toString();
          break;
      }
      
      // Find player's rank
      int playerRank = entries.length + 1;
      for (int i = 0; i < entries.length; i++) {
        if (playerValue >= entries[i].value) {
          playerRank = i + 1;
          break;
        }
      }
      
      final playerEntry = LeaderboardEntry(
        odeName: 'current_player',
        odisplayName: _playerName,
        rank: playerRank,
        value: playerValue,
        formattedValue: playerFormattedValue,
        era: 0, // Will be set from game state
        prestigeTier: _playerPrestige,
        title: null,
        border: null,
        hasLeaderboardCrown: playerRank == 1,
        isCurrentPlayer: true,
        lastUpdated: DateTime.now(),
      );
      
      // Insert player and adjust ranks
      entries.insert(playerRank - 1, playerEntry);
      for (int i = playerRank; i < entries.length; i++) {
        final entry = entries[i];
        entries[i] = LeaderboardEntry(
          odeName: entry.odeName,
          odisplayName: entry.odisplayName,
          rank: i + 1,
          value: entry.value,
          formattedValue: entry.formattedValue,
          era: entry.era,
          prestigeTier: entry.prestigeTier,
          title: entry.title,
          border: entry.border,
          hasLeaderboardCrown: false,
          isCurrentPlayer: entry.isCurrentPlayer,
          lastUpdated: entry.lastUpdated,
        );
      }
      
      _leaderboards[category] = entries;
    }
  }
  
  double _generateTopValue(int rank, double maxValue, double minValue, Random random) {
    // Exponential decay for realistic distribution
    final factor = exp(-rank * 0.1);
    return minValue + (maxValue - minValue) * factor * (0.8 + random.nextDouble() * 0.4);
  }
  
  String _formatLargeNumber(double value) {
    if (value >= 1e30) return '${(value / 1e30).toStringAsFixed(1)}No';
    if (value >= 1e27) return '${(value / 1e27).toStringAsFixed(1)}Oc';
    if (value >= 1e24) return '${(value / 1e24).toStringAsFixed(1)}Sp';
    if (value >= 1e21) return '${(value / 1e21).toStringAsFixed(1)}Sx';
    if (value >= 1e18) return '${(value / 1e18).toStringAsFixed(1)}Qi';
    if (value >= 1e15) return '${(value / 1e15).toStringAsFixed(1)}Q';
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(1)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
  
  void _generateWeeklyTournament() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    _currentTournament = WeeklyTournament(
      id: 'tournament_${weekStart.millisecondsSinceEpoch}',
      name: 'Energy Surge Championship',
      category: LeaderboardCategory.totalEnergy,
      startTime: weekStart,
      endTime: weekEnd,
      rewards: const [
        TournamentReward(minRank: 1, maxRank: 1, darkMatter: 5000, exclusiveTitle: 'Weekly Champion', exclusiveBorder: 'champion_gold'),
        TournamentReward(minRank: 2, maxRank: 3, darkMatter: 2500, exclusiveTitle: 'Tournament Elite'),
        TournamentReward(minRank: 4, maxRank: 10, darkMatter: 1000),
        TournamentReward(minRank: 11, maxRank: 50, darkMatter: 500),
        TournamentReward(minRank: 51, maxRank: 100, darkMatter: 250),
      ],
      topPlayers: _leaderboards[LeaderboardCategory.totalEnergy]?.take(10).toList() ?? [],
    );
  }
  
  /// Get players near current player's rank
  List<LeaderboardEntry> getPlayersNearPlayer(LeaderboardCategory category, {int range = 5}) {
    final leaderboard = _leaderboards[category] ?? [];
    final playerIndex = leaderboard.indexWhere((e) => e.isCurrentPlayer);
    if (playerIndex == -1) return [];
    
    final start = (playerIndex - range).clamp(0, leaderboard.length);
    final end = (playerIndex + range + 1).clamp(0, leaderboard.length);
    
    return leaderboard.sublist(start, end);
  }
}
