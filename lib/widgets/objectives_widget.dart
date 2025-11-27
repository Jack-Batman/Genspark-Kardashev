import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import 'achievements_widget.dart';
import 'challenges_widget.dart';

/// Objectives tab combining Achievements and Challenges
class ObjectivesWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const ObjectivesWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<ObjectivesWidget> createState() => _ObjectivesWidgetState();
}

class _ObjectivesWidgetState extends State<ObjectivesWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final unclaimedAchievements = widget.gameProvider.unclaimedAchievementCount;
    final unclaimedChallenges = widget.gameProvider.unclaimedChallengeCount;

    return Column(
      children: [
        // Sub-tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: eraConfig.primaryColor.withValues(alpha: 0.3),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: eraConfig.accentColor,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
            labelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 12),
                    const SizedBox(width: 4),
                    const Text('ACHIEVE'),
                    if (unclaimedAchievements > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          unclaimedAchievements > 9 ? '9+' : '$unclaimedAchievements',
                          style: const TextStyle(fontSize: 7, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment, size: 12),
                    const SizedBox(width: 4),
                    const Text('CONTRACTS'),
                    if (unclaimedChallenges > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          unclaimedChallenges > 9 ? '9+' : '$unclaimedChallenges',
                          style: const TextStyle(fontSize: 7, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AchievementsWidget(gameProvider: widget.gameProvider),
              ChallengesWidget(gameProvider: widget.gameProvider),
            ],
          ),
        ),
      ],
    );
  }
}
