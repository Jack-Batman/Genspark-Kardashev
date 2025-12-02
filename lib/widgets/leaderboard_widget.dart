import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../services/leaderboard_service.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

/// Leaderboard display widget
class LeaderboardWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const LeaderboardWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _leaderboardService = LeaderboardService();
  LeaderboardCategory _selectedCategory = LeaderboardCategory.totalEnergy;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeLeaderboard();
  }
  
  Future<void> _initializeLeaderboard() async {
    await _leaderboardService.initialize();
    _updatePlayerStats();
  }
  
  void _updatePlayerStats() {
    final state = widget.gameProvider.state;
    _leaderboardService.updatePlayerStats(
      totalEnergy: state.totalEnergyEarned,
      kardashevLevel: state.kardashevLevel,
      prestigeCount: state.prestigeCount,
      darkMatter: state.darkMatter,
      playTimeSeconds: state.playTimeSeconds,
      expeditionsCompleted: state.completedLegendaryExpeditions.length,
      architectsOwned: state.ownedArchitects.length,
    );
    if (mounted) setState(() {});
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: eraConfig.accentColor,
            labelColor: eraConfig.accentColor,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
            labelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'LEADERBOARDS'),
              Tab(text: 'TOURNAMENT'),
            ],
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardTab(eraConfig),
              _buildTournamentTab(eraConfig),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLeaderboardTab(EraConfig eraConfig) {
    return Column(
      children: [
        // Category selector
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: LeaderboardCategory.values.length,
            itemBuilder: (context, index) {
              final category = LeaderboardCategory.values[index];
              final isSelected = category == _selectedCategory;
              
              return GestureDetector(
                onTap: () {
                  AudioService.playClick();
                  setState(() => _selectedCategory = category);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected 
                        ? eraConfig.accentColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isSelected 
                          ? eraConfig.accentColor 
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? eraConfig.accentColor : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Player's rank card
        _buildPlayerRankCard(eraConfig),
        
        const SizedBox(height: 12),
        
        // Leaderboard list
        Expanded(
          child: _buildLeaderboardList(eraConfig),
        ),
      ],
    );
  }
  
  Widget _buildPlayerRankCard(EraConfig eraConfig) {
    final playerRank = _leaderboardService.getPlayerRank(_selectedCategory);
    final nearbyPlayers = _leaderboardService.getPlayersNearPlayer(_selectedCategory, range: 2);
    final playerEntry = nearbyPlayers.where((e) => e.isCurrentPlayer).firstOrNull;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            eraConfig.accentColor.withValues(alpha: 0.2),
            eraConfig.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: eraConfig.accentColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getRankColor(playerRank),
                  _getRankColor(playerRank).withValues(alpha: 0.5),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#$playerRank',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'RANK',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 8,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR POSITION',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  playerEntry?.formattedValue ?? '0',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: eraConfig.accentColor,
                  ),
                ),
                Text(
                  _selectedCategory.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Next milestone
          if (playerRank > 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TO RANK UP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 8,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_upward,
                  color: Colors.green,
                  size: 20,
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardList(EraConfig eraConfig) {
    final entries = _leaderboardService.getLeaderboard(_selectedCategory, limit: 50);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardEntry(entry, eraConfig);
      },
    );
  }
  
  Widget _buildLeaderboardEntry(LeaderboardEntry entry, EraConfig eraConfig) {
    final isPlayer = entry.isCurrentPlayer;
    final rankColor = _getRankColor(entry.rank);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isPlayer 
            ? eraConfig.accentColor.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        border: isPlayer 
            ? Border.all(color: eraConfig.accentColor.withValues(alpha: 0.5), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.rank <= 3 
                  ? rankColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              border: entry.rank <= 3 
                  ? Border.all(color: rankColor, width: 2)
                  : null,
            ),
            child: Center(
              child: entry.rank <= 3
                  ? Text(
                      _getRankEmoji(entry.rank),
                      style: const TextStyle(fontSize: 18),
                    )
                  : Text(
                      '#${entry.rank}',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPlayer ? eraConfig.accentColor : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (entry.hasLeaderboardCrown)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text('👑', style: TextStyle(fontSize: 14)),
                      ),
                    Expanded(
                      child: Text(
                        isPlayer ? 'You' : entry.odisplayName,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: isPlayer ? FontWeight.bold : FontWeight.w600,
                          color: isPlayer ? eraConfig.accentColor : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Era ${['I', 'II', 'III', 'IV', 'V'][entry.era.clamp(0, 4)]}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    if (entry.title != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.purple.withValues(alpha: 0.3),
                        ),
                        child: Text(
                          entry.title!,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade200,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.formattedValue,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPlayer ? eraConfig.accentColor : Colors.white,
                ),
              ),
              Text(
                _selectedCategory.icon,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTournamentTab(EraConfig eraConfig) {
    final tournament = _leaderboardService.currentTournament;
    if (tournament == null) {
      return Center(
        child: Text(
          'No active tournament',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }
    
    final playerRank = _leaderboardService.getPlayerTournamentRank();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.withValues(alpha: 0.3),
                  Colors.orange.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  tournament.name,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${tournament.category.displayName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                // Time remaining
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Ends in: ${_formatDuration(tournament.remainingTime)}',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Player rank
                Text(
                  'Your Rank: #$playerRank',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: eraConfig.accentColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Rewards
          Text(
            'REWARDS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...tournament.rewards.map((reward) => _buildRewardTier(reward, playerRank)),
          
          const SizedBox(height: 20),
          
          // Top players
          Text(
            'TOP PLAYERS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: eraConfig.accentColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...tournament.topPlayers.map((entry) => _buildLeaderboardEntry(entry, eraConfig)),
        ],
      ),
    );
  }
  
  Widget _buildRewardTier(TournamentReward reward, int playerRank) {
    final isEligible = playerRank >= reward.minRank && playerRank <= reward.maxRank;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isEligible 
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        border: isEligible 
            ? Border.all(color: Colors.amber.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isEligible ? Colors.amber.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
            ),
            child: Text(
              reward.minRank == reward.maxRank 
                  ? '#${reward.minRank}'
                  : '#${reward.minRank}-${reward.maxRank}',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isEligible ? Colors.amber : Colors.white.withValues(alpha: 0.6),
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
                    const Text('🌑', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.darkMatter} Dark Matter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isEligible ? Colors.white : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (reward.exclusiveTitle != null)
                  Text(
                    '+ ${reward.exclusiveTitle}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple.withValues(alpha: isEligible ? 1 : 0.5),
                    ),
                  ),
              ],
            ),
          ),
          if (isEligible)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
  
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange.shade700;
      default:
        return Colors.white.withValues(alpha: 0.5);
    }
  }
  
  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Compact Top 10 widget for home screen
class Top10PlayersWidget extends StatelessWidget {
  final GameProvider gameProvider;
  final VoidCallback? onViewAll;
  
  const Top10PlayersWidget({
    super.key,
    required this.gameProvider,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final leaderboardService = LeaderboardService();
    final top10 = leaderboardService.getTop10(LeaderboardCategory.totalEnergy);
    final eraConfig = gameProvider.state.eraConfig;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'TOP PLAYERS',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      color: eraConfig.accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...top10.take(5).map((entry) => _buildCompactEntry(entry, eraConfig)),
        ],
      ),
    );
  }
  
  Widget _buildCompactEntry(LeaderboardEntry entry, EraConfig eraConfig) {
    final isPlayer = entry.isCurrentPlayer;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isPlayer 
            ? eraConfig.accentColor.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              entry.rank <= 3 ? _getRankEmoji(entry.rank) : '#${entry.rank}',
              style: TextStyle(
                fontFamily: entry.rank > 3 ? 'Orbitron' : null,
                fontSize: entry.rank > 3 ? 10 : 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPlayer ? 'You' : entry.odisplayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                color: isPlayer ? eraConfig.accentColor : Colors.white.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            entry.formattedValue,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPlayer ? eraConfig.accentColor : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }
}
