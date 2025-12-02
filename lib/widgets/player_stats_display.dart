import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import '../services/leaderboard_service.dart';

/// Compact player stats display card for showing public profile info
/// Can be embedded in various screens or shown as a standalone widget
class PlayerStatsDisplay extends StatelessWidget {
  final GameProvider gameProvider;
  final bool showLeaderboardRank;
  final bool compact;
  
  const PlayerStatsDisplay({
    super.key,
    required this.gameProvider,
    this.showLeaderboardRank = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = gameProvider.state;
    final eraConfig = state.eraConfig;
    final leaderboardService = LeaderboardService();
    
    // Update leaderboard with current player stats
    leaderboardService.updatePlayerStats(
      totalEnergy: state.totalEnergyEarned,
      kardashevLevel: state.kardashevLevel,
      prestigeCount: state.prestigeCount,
      darkMatter: state.darkMatter,
      playTimeSeconds: state.playTimeSeconds,
      expeditionsCompleted: state.completedLegendaryExpeditions.length,
      architectsOwned: state.ownedArchitects.length,
    );
    
    final energyRank = leaderboardService.getPlayerRank(LeaderboardCategory.totalEnergy);
    final kardashevRank = leaderboardService.getPlayerRank(LeaderboardCategory.kardashevLevel);
    
    if (compact) {
      return _buildCompactDisplay(state, eraConfig, energyRank, kardashevRank);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            eraConfig.primaryColor.withValues(alpha: 0.2),
            eraConfig.accentColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      eraConfig.primaryColor,
                      eraConfig.accentColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: eraConfig.primaryColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getEraSymbol(state.currentEra),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PLAYER PROFILE',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: eraConfig.accentColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        if (showLeaderboardRank) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.amber.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🏆', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '#$energyRank',
                                  style: const TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eraConfig.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.bolt,
                  label: 'Energy/s',
                  value: GameProvider.formatNumber(state.energyPerSecond),
                  color: eraConfig.accentColor,
                  rank: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.show_chart,
                  label: 'Kardashev',
                  value: 'K${state.kardashevLevel.toStringAsFixed(3)}',
                  color: eraConfig.primaryColor,
                  rank: showLeaderboardRank ? kardashevRank : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.auto_awesome,
                  label: 'Prestige',
                  value: '×${state.prestigeCount}',
                  color: Colors.purple,
                  rank: showLeaderboardRank 
                      ? leaderboardService.getPlayerRank(LeaderboardCategory.prestigeCount)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.dark_mode,
                  label: 'Dark Matter',
                  value: GameProvider.formatNumber(state.darkMatter),
                  color: Colors.purpleAccent,
                  rank: showLeaderboardRank 
                      ? leaderboardService.getPlayerRank(LeaderboardCategory.darkMatter)
                      : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.people,
                  label: 'Architects',
                  value: '${state.ownedArchitects.length}',
                  color: Colors.teal,
                  rank: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.timer,
                  label: 'Play Time',
                  value: _formatPlayTime(state.playTimeSeconds),
                  color: Colors.cyan,
                  rank: null,
                ),
              ),
            ],
          ),
          
          // Total Energy Section
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.2),
              border: Border.all(
                color: eraConfig.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: eraConfig.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL ENERGY EARNED',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        GameProvider.formatNumber(state.totalEnergyEarned),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: eraConfig.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showLeaderboardRank)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      'Rank #$energyRank',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactDisplay(dynamic state, EraConfig eraConfig, int energyRank, int kardashevRank) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Era indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [eraConfig.primaryColor, eraConfig.accentColor],
              ),
            ),
            child: Center(
              child: Text(
                _getEraSymbol(state.currentEra),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Quick stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, size: 14, color: eraConfig.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      '${GameProvider.formatNumber(state.energyPerSecond)}/s',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: eraConfig.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'K${state.kardashevLevel.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        color: eraConfig.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  eraConfig.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Rank badge
          if (showLeaderboardRank)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.amber.withValues(alpha: 0.2),
              ),
              child: Text(
                '#$energyRank',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _getEraSymbol(int era) {
    switch (era) {
      case 0: return '🌍';
      case 1: return '⭐';
      case 2: return '🌌';
      case 3: return '🔮';
      case 4: return '✨';
      default: return '🌍';
    }
  }
  
  String _formatPlayTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int? rank;
  
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.2),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              if (rank != null) ...[
                const Spacer(),
                Text(
                  '#$rank',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    color: Colors.amber.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
