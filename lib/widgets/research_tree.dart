import 'package:flutter/material.dart';
import '../core/constants.dart' hide ResearchCategory;
import '../models/research_v2.dart';
import '../providers/game_provider.dart';
import 'glass_container.dart';

/// Research Tree Widget - Visual tech tree display (V2 wrapper)
class ResearchTreeWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const ResearchTreeWidget({
    super.key,
    required this.gameProvider,
  });
  
  @override
  State<ResearchTreeWidget> createState() => _ResearchTreeWidgetState();
}

class _ResearchTreeWidgetState extends State<ResearchTreeWidget>
    with SingleTickerProviderStateMixin {
  ResearchCategory _selectedCategory = ResearchCategory.efficiency;
  String? _selectedResearchId;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category tabs
        _buildCategoryTabs(),
        
        const SizedBox(height: 8),
        
        // Research tree content
        Expanded(
          child: _selectedResearchId != null
              ? _buildResearchDetail()
              : _buildResearchGrid(),
        ),
      ],
    );
  }
  
  Widget _buildCategoryTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: ResearchCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          final color = _getCategoryColor(category);
          
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = category;
                _selectedResearchId = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected
                      ? color.withValues(alpha: 0.3)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 14,
                        color: isSelected ? color : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getCategoryName(category),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildResearchGrid() {
    final research = widget.gameProvider.getCurrentEraResearch()
        .where((r) => r.category == _selectedCategory)
        .toList();
    
    // Group by tier
    final byTier = <int, List<ResearchNode>>{};
    for (final r in research) {
      byTier.putIfAbsent(r.tier, () => []).add(r);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: byTier.length,
      itemBuilder: (context, index) {
        final tier = index + 1;
        final tierResearch = byTier[tier] ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tier header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'TIER $tier',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
              ),
            ),
            // Research cards
            ...tierResearch.map((r) => _buildResearchCard(r)),
          ],
        );
      },
    );
  }
  
  Widget _buildResearchCard(ResearchNode research) {
    final isCompleted = widget.gameProvider.isResearchCompleted(research.id);
    final isAvailable = widget.gameProvider.isResearchAvailable(research);
    final isResearching = widget.gameProvider.currentResearchId == research.id;
    final canAfford = widget.gameProvider.state.energy >= research.energyCost;
    
    final categoryColor = _getCategoryColor(research.category);
    
    return GestureDetector(
      onTap: () {
        if (isAvailable && !isResearching && canAfford) {
          widget.gameProvider.startResearchV2(research);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.3),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.5)
                : isAvailable
                    ? categoryColor.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : categoryColor.withValues(alpha: 0.2),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.green, size: 20)
                    : Text(research.icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    research.name,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.green
                          : isAvailable
                              ? categoryColor
                              : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    research.effect.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Cost/Status
            if (!isCompleted && isAvailable)
              Column(
                children: [
                  Text(
                    GameProvider.formatNumber(research.energyCost),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      color: canAfford ? categoryColor : Colors.red,
                    ),
                  ),
                  Text(
                    GameProvider.formatTime(research.timeSeconds),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            if (isResearching)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: widget.gameProvider.researchProgress,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(categoryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResearchDetail() {
    final research = getResearchNodeById(_selectedResearchId!);
    if (research == null) {
      return const Center(child: Text('Research not found'));
    }
    
    final isCompleted = widget.gameProvider.isResearchCompleted(research.id);
    final categoryColor = _getCategoryColor(research.category);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedResearchId = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                research.name,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Research info
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  research.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  research.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: categoryColor.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    research.effect.description,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!isCompleted)
            GlassButton(
              text: isCompleted ? 'COMPLETED' : 'RESEARCH',
              icon: isCompleted ? Icons.check : Icons.science,
              accentColor: isCompleted ? Colors.green : categoryColor,
              enabled: !isCompleted && widget.gameProvider.isResearchAvailable(research),
              onPressed: () {
                widget.gameProvider.startResearchV2(research);
                setState(() => _selectedResearchId = null);
              },
            ),
        ],
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
