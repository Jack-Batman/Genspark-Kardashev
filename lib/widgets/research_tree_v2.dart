import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/research_v2.dart';
import '../providers/game_provider.dart';

/// Research Tree Widget V2 - Supports all eras
class ResearchTreeWidgetV2 extends StatefulWidget {
  final GameProvider gameProvider;

  const ResearchTreeWidgetV2({
    super.key,
    required this.gameProvider,
  });

  @override
  State<ResearchTreeWidgetV2> createState() => _ResearchTreeWidgetV2State();
}

class _ResearchTreeWidgetV2State extends State<ResearchTreeWidgetV2> {
  ResearchCategory _selectedCategory = ResearchCategory.efficiency;

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final currentResearch = widget.gameProvider.getCurrentEraResearch();

    return Column(
      children: [
        // Category tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: ResearchCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? _getCategoryColor(category).withValues(alpha: 0.3)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? _getCategoryColor(category).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 16,
                          color: isSelected
                              ? _getCategoryColor(category)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryName(category),
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 8,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? _getCategoryColor(category)
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Research progress indicator
        if (widget.gameProvider.currentResearchId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildResearchProgress(eraConfig),
          ),

        // Research list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: currentResearch
                .where((r) => r.category == _selectedCategory)
                .length,
            itemBuilder: (context, index) {
              final research = currentResearch
                  .where((r) => r.category == _selectedCategory)
                  .toList()[index];
              return _buildResearchCard(research, eraConfig);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResearchProgress(EraConfig eraConfig) {
    final currentResearchId = widget.gameProvider.currentResearchId;
    if (currentResearchId == null) return const SizedBox();

    final research = getResearchNodeById(currentResearchId);
    if (research == null) return const SizedBox();

    final progress = widget.gameProvider.researchProgress;
    final timeRemaining = widget.gameProvider.researchTimeRemaining;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: research.categoryColor.withValues(alpha: 0.2),
        border: Border.all(
          color: research.categoryColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                research.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Researching: ${research.name}',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: research.categoryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      GameProvider.formatTime(timeRemaining),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, size: 20),
                color: Colors.red.withValues(alpha: 0.7),
                onPressed: () => widget.gameProvider.cancelResearch(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(research.categoryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchCard(ResearchNode research, EraConfig eraConfig) {
    final isCompleted = widget.gameProvider.isResearchCompleted(research.id);
    final isAvailable = widget.gameProvider.isResearchAvailable(research);
    final isResearching = widget.gameProvider.currentResearchId == research.id;
    final canAfford = widget.gameProvider.state.energy >= research.energyCost;

    // Check prerequisites
    final missingPrereqs = research.prerequisites
        .where((prereq) => !widget.gameProvider.isResearchCompleted(prereq))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: isCompleted ? 0.1 : 0.3),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : isAvailable
                  ? research.categoryColor.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : research.categoryColor.withValues(alpha: 0.2),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.5)
                      : research.categoryColor.withValues(alpha: 0.5),
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.green, size: 24)
                    : Text(research.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          research.name,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green
                                : isAvailable
                                    ? research.categoryColor
                                    : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'T${research.tier}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    research.effect.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  if (!isCompleted && missingPrereqs.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Requires: ${missingPrereqs.map((p) => getResearchNodeById(p)?.name ?? p).join(", ")}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.orange.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action button
            if (!isCompleted && isAvailable && !isResearching)
              GestureDetector(
                onTap: canAfford && widget.gameProvider.currentResearchId == null
                    ? () => widget.gameProvider.startResearchV2(research)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: canAfford
                        ? research.categoryColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: canAfford
                          ? research.categoryColor.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        GameProvider.formatNumber(research.energyCost),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: canAfford
                              ? research.categoryColor
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        GameProvider.formatTime(research.timeSeconds),
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white.withValues(alpha: canAfford ? 0.6 : 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isResearching)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: research.categoryColor.withValues(alpha: 0.2),
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ResearchCategory category) {
    switch (category) {
      case ResearchCategory.efficiency:
        return const Color(0xFF4FC3F7);
      case ResearchCategory.automation:
        return const Color(0xFF81C784);
      case ResearchCategory.expansion:
        return const Color(0xFFFFB74D);
      case ResearchCategory.exotic:
        return const Color(0xFFBA68C8);
    }
  }

  IconData _getCategoryIcon(ResearchCategory category) {
    switch (category) {
      case ResearchCategory.efficiency:
        return Icons.bolt;
      case ResearchCategory.automation:
        return Icons.smart_toy;
      case ResearchCategory.expansion:
        return Icons.expand;
      case ResearchCategory.exotic:
        return Icons.auto_awesome;
    }
  }

  String _getCategoryName(ResearchCategory category) {
    switch (category) {
      case ResearchCategory.efficiency:
        return 'EFFICIENCY';
      case ResearchCategory.automation:
        return 'AUTO';
      case ResearchCategory.expansion:
        return 'EXPAND';
      case ResearchCategory.exotic:
        return 'EXOTIC';
    }
  }
}
