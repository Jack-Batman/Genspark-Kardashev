import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/research_v2.dart';
import '../providers/game_provider.dart';

/// Polished Visual Research Tree - Responsive skill tree with blur effect
class VisualResearchTree extends StatefulWidget {
  final GameProvider gameProvider;

  const VisualResearchTree({
    super.key,
    required this.gameProvider,
  });

  @override
  State<VisualResearchTree> createState() => _VisualResearchTreeState();
}

class _VisualResearchTreeState extends State<VisualResearchTree>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  ResearchNode? _selectedNode;
  bool _showDetails = false;

  // Tree layout configuration
  static const double nodeSize = 52.0;
  static const double verticalSpacing = 100.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Build tree structure for current era - responsive layout
  List<_TreeNode> _buildTreeStructure(List<ResearchNode> research, double availableWidth) {
    final nodes = <_TreeNode>[];
    
    // Group by tier
    final tier1 = research.where((r) => r.tier == 1).toList();
    final tier2 = research.where((r) => r.tier == 2).toList();
    final tier3 = research.where((r) => r.tier == 3).toList();
    final tier4 = research.where((r) => r.tier == 4).toList();
    final tier5 = research.where((r) => r.tier == 5).toList();

    // Start below the header
    double yOffset = 20;

    // Position each tier centered within available width
    _positionTierNodes(nodes, tier1, yOffset, availableWidth);
    yOffset += verticalSpacing;

    _positionTierNodes(nodes, tier2, yOffset, availableWidth);
    yOffset += verticalSpacing;

    _positionTierNodes(nodes, tier3, yOffset, availableWidth);
    yOffset += verticalSpacing;

    _positionTierNodes(nodes, tier4, yOffset, availableWidth);
    yOffset += verticalSpacing;

    if (tier5.isNotEmpty) {
      _positionTierNodes(nodes, tier5, yOffset, availableWidth);
    }

    return nodes;
  }

  void _positionTierNodes(List<_TreeNode> nodes, List<ResearchNode> tierNodes, double y, double availableWidth) {
    if (tierNodes.isEmpty) return;
    
    // Calculate spacing based on available width and number of nodes
    // Use padding to ensure nodes don't touch edges
    const horizontalPadding = 30.0;
    final usableWidth = availableWidth - (horizontalPadding * 2);
    
    double spacing;
    if (tierNodes.length == 1) {
      // Single node - center it
      spacing = 0;
    } else {
      // Multiple nodes - spread them evenly
      spacing = usableWidth / (tierNodes.length - 1);
      // Limit spacing to avoid overly spread trees
      spacing = math.min(spacing, 100.0);
    }
    
    // Calculate total width of this tier
    final totalWidth = (tierNodes.length - 1) * spacing;
    // Center the tier within available width
    final startX = (availableWidth - totalWidth) / 2;
    
    for (int i = 0; i < tierNodes.length; i++) {
      final node = tierNodes[i];
      nodes.add(_TreeNode(
        research: node,
        position: Offset(startX + i * spacing, y),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final currentResearch = widget.gameProvider.getCurrentEraResearch();
    
    // Calculate tree height based on number of tiers
    final maxTier = currentResearch.isEmpty ? 1 : currentResearch.map((r) => r.tier).reduce(math.max);
    final treeHeight = (maxTier * verticalSpacing) + 100;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final treeNodes = _buildTreeStructure(currentResearch, availableWidth);
        
        return Stack(
          children: [
            // Blurred background effect
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            
            // Subtle gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      eraConfig.primaryColor.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Scrollable tree area
            Padding(
              padding: const EdgeInsets.only(top: 85), // Space for header
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: availableWidth,
                  height: treeHeight,
                  child: Stack(
                    children: [
                      // Connection lines
                      CustomPaint(
                        size: Size(availableWidth, treeHeight),
                        painter: _ConnectionPainter(
                          nodes: treeNodes,
                          gameProvider: widget.gameProvider,
                          eraConfig: eraConfig,
                          animation: _glowController,
                        ),
                      ),
                      // Research nodes
                      ...treeNodes.map((treeNode) => _buildNode(treeNode, eraConfig)),
                    ],
                  ),
                ),
              ),
            ),

            // Top HUD - Progress bar (fixed at top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildProgressHUD(currentResearch, eraConfig),
            ),

            // Legend (top right, below header)
            Positioned(
              top: 80,
              right: 8,
              child: _buildLegend(eraConfig),
            ),

            // Current research indicator
            if (widget.gameProvider.currentResearchId != null)
              Positioned(
                bottom: _showDetails ? 260 : 12,
                left: 12,
                right: 12,
                child: _buildCurrentResearchCard(eraConfig),
              ),

            // Node details panel
            if (_showDetails && _selectedNode != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildDetailsPanel(_selectedNode!, eraConfig),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProgressHUD(List<ResearchNode> research, EraConfig eraConfig) {
    final completed = research.where((r) => 
      widget.gameProvider.isResearchCompleted(r.id)
    ).length;
    final total = research.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.85),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.science,
                  size: 16,
                  color: eraConfig.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ERA ${widget.gameProvider.state.eraName} RESEARCH',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: eraConfig.primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: eraConfig.accentColor.withValues(alpha: 0.2),
                ),
                child: Text(
                  '$completed / $total',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: eraConfig.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(eraConfig.primaryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(_TreeNode treeNode, EraConfig eraConfig) {
    final node = treeNode.research;
    final isCompleted = widget.gameProvider.isResearchCompleted(node.id);
    final isAvailable = widget.gameProvider.isResearchAvailable(node);
    final isResearching = widget.gameProvider.currentResearchId == node.id;
    final canAfford = widget.gameProvider.state.energy >= node.energyCost;
    final isSelected = _selectedNode?.id == node.id;

    return Positioned(
      left: treeNode.position.dx - nodeSize / 2,
      top: treeNode.position.dy - nodeSize / 2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected && _showDetails) {
              _showDetails = false;
              _selectedNode = null;
            } else {
              _selectedNode = node;
              _showDetails = true;
            }
          });
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final shouldPulse = isAvailable && canAfford && !isCompleted && !isResearching;
            final pulseValue = shouldPulse ? _pulseController.value : 0.0;

            return Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _getNodeGradient(node, isCompleted, isAvailable, isResearching),
                border: Border.all(
                  color: _getNodeBorderColor(node, isCompleted, isAvailable, isResearching, isSelected),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getNodeGlowColor(node, isCompleted, isAvailable, isResearching, shouldPulse)
                        .withValues(alpha: 0.3 + pulseValue * 0.4),
                    blurRadius: 10 + pulseValue * 6,
                    spreadRadius: pulseValue * 3,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress ring for researching
                  if (isResearching)
                    SizedBox(
                      width: nodeSize - 6,
                      height: nodeSize - 6,
                      child: CircularProgressIndicator(
                        value: widget.gameProvider.researchProgress,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(node.categoryColor),
                      ),
                    ),
                  // Node icon
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.green, size: 20)
                      : Text(
                          node.icon,
                          style: TextStyle(
                            fontSize: 18,
                            color: isAvailable ? null : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                  // Tier badge
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.green.withValues(alpha: 0.5)
                              : node.categoryColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'T${node.tier}',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.green : node.categoryColor,
                        ),
                      ),
                    ),
                  ),
                  // Lock icon for unavailable
                  if (!isAvailable && !isCompleted)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 8,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Gradient _getNodeGradient(ResearchNode node, bool isCompleted, bool isAvailable, bool isResearching) {
    if (isCompleted) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.withValues(alpha: 0.4),
          Colors.green.withValues(alpha: 0.2),
        ],
      );
    }
    if (isResearching) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          node.categoryColor.withValues(alpha: 0.5),
          node.categoryColor.withValues(alpha: 0.3),
        ],
      );
    }
    if (isAvailable) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          node.categoryColor.withValues(alpha: 0.25),
          node.categoryColor.withValues(alpha: 0.1),
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.withValues(alpha: 0.2),
        Colors.grey.withValues(alpha: 0.1),
      ],
    );
  }

  Color _getNodeBorderColor(ResearchNode node, bool isCompleted, bool isAvailable, bool isResearching, bool isSelected) {
    if (isSelected) return isCompleted ? Colors.green : node.categoryColor;
    if (isCompleted) return Colors.green.withValues(alpha: 0.8);
    if (isResearching) return node.categoryColor;
    if (isAvailable) return node.categoryColor.withValues(alpha: 0.6);
    return Colors.grey.withValues(alpha: 0.3);
  }

  Color _getNodeGlowColor(ResearchNode node, bool isCompleted, bool isAvailable, bool isResearching, bool shouldPulse) {
    if (isCompleted) return Colors.green;
    if (isResearching) return node.categoryColor;
    if (shouldPulse) return node.categoryColor;
    return Colors.transparent;
  }

  Widget _buildCurrentResearchCard(EraConfig eraConfig) {
    final currentId = widget.gameProvider.currentResearchId;
    if (currentId == null) return const SizedBox();

    final research = getResearchNodeById(currentId);
    if (research == null) return const SizedBox();

    final progress = widget.gameProvider.researchProgress;
    final remaining = widget.gameProvider.researchTimeRemaining;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.9),
        border: Border.all(
          color: research.categoryColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: research.categoryColor.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Text(research.icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESEARCHING',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 7,
                        color: research.categoryColor.withValues(alpha: 0.8),
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      research.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: research.categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                GameProvider.formatTime(remaining),
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => widget.gameProvider.cancelResearch(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.red.shade300),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(research.categoryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(ResearchNode node, EraConfig eraConfig) {
    final isCompleted = widget.gameProvider.isResearchCompleted(node.id);
    final isAvailable = widget.gameProvider.isResearchAvailable(node);
    final isResearching = widget.gameProvider.currentResearchId == node.id;
    final canAfford = widget.gameProvider.state.energy >= node.energyCost;
    final alreadyResearching = widget.gameProvider.currentResearchId != null;

    final missingPrereqs = node.prerequisites
        .where((prereq) => !widget.gameProvider.isResearchCompleted(prereq))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: node.categoryColor.withValues(alpha: 0.5), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: node.categoryColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: node.categoryColor.withValues(alpha: 0.2),
                  border: Border.all(color: node.categoryColor, width: 2),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.green, size: 24)
                      : Text(node.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: node.categoryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getCategoryName(node.category),
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 7,
                              color: node.categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'T${node.tier}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 8,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: node.categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: Colors.white.withValues(alpha: 0.5),
                onPressed: () => setState(() {
                  _showDetails = false;
                  _selectedNode = null;
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Effect
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: node.categoryColor.withValues(alpha: 0.1),
              border: Border.all(color: node.categoryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: node.categoryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.effect.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: node.categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Cost and time row
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  icon: Icons.bolt,
                  value: GameProvider.formatNumber(node.energyCost),
                  color: canAfford ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoBox(
                  icon: Icons.timer,
                  value: GameProvider.formatTime(node.timeSeconds),
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          // Prerequisites warning
          if (!isCompleted && missingPrereqs.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.orange.withValues(alpha: 0.1),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.orange.shade300),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Requires: ${missingPrereqs.map((p) => getResearchNodeById(p)?.name ?? p).join(", ")}',
                      style: TextStyle(fontSize: 10, color: Colors.orange.shade300),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(isCompleted, isAvailable, canAfford, isResearching, alreadyResearching, node),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isCompleted || isResearching || !isAvailable || !canAfford || alreadyResearching
                  ? null
                  : () {
                      widget.gameProvider.startResearchV2(node);
                      setState(() {
                        _showDetails = false;
                        _selectedNode = null;
                      });
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getButtonIcon(isCompleted, isResearching, isAvailable, alreadyResearching), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _getButtonText(isCompleted, isResearching, isAvailable, canAfford, alreadyResearching),
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({required IconData icon, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(bool isCompleted, bool isAvailable, bool canAfford, bool isResearching, bool alreadyResearching, ResearchNode node) {
    if (isCompleted) return Colors.green;
    if (isResearching) return node.categoryColor.withValues(alpha: 0.5);
    if (!isAvailable || !canAfford || alreadyResearching) return Colors.grey.withValues(alpha: 0.3);
    return node.categoryColor;
  }

  IconData _getButtonIcon(bool isCompleted, bool isResearching, bool isAvailable, bool alreadyResearching) {
    if (isCompleted) return Icons.check_circle;
    if (isResearching) return Icons.hourglass_bottom;
    if (alreadyResearching) return Icons.pending;
    if (!isAvailable) return Icons.lock;
    return Icons.science;
  }

  String _getButtonText(bool isCompleted, bool isResearching, bool isAvailable, bool canAfford, bool alreadyResearching) {
    if (isCompleted) return 'COMPLETED';
    if (isResearching) return 'RESEARCHING...';
    if (alreadyResearching) return 'RESEARCH IN PROGRESS';
    if (!isAvailable) return 'LOCKED';
    if (!canAfford) return 'NOT ENOUGH ENERGY';
    return 'START RESEARCH';
  }

  String _getCategoryName(ResearchCategory category) {
    switch (category) {
      case ResearchCategory.efficiency: return 'EFFICIENCY';
      case ResearchCategory.automation: return 'AUTOMATION';
      case ResearchCategory.expansion: return 'EXPANSION';
      case ResearchCategory.exotic: return 'EXOTIC';
    }
  }

  Widget _buildLegend(EraConfig eraConfig) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withValues(alpha: 0.8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem('Efficiency', const Color(0xFF4FC3F7)),
          _buildLegendItem('Automation', const Color(0xFF81C784)),
          _buildLegendItem('Expansion', const Color(0xFFFFB74D)),
          _buildLegendItem('Exotic', const Color(0xFFBA68C8)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.3),
              border: Border.all(color: color, width: 1.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tree node with position
class _TreeNode {
  final ResearchNode research;
  final Offset position;

  _TreeNode({required this.research, required this.position});
}

/// Custom painter for drawing connection lines
class _ConnectionPainter extends CustomPainter {
  final List<_TreeNode> nodes;
  final GameProvider gameProvider;
  final EraConfig eraConfig;
  final Animation<double> animation;

  _ConnectionPainter({
    required this.nodes,
    required this.gameProvider,
    required this.eraConfig,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final treeNode in nodes) {
      final node = treeNode.research;

      for (final prereqId in node.prerequisites) {
        final prereqTreeNode = nodes.where((n) => n.research.id == prereqId).firstOrNull;
        if (prereqTreeNode == null) continue;

        final isPrereqComplete = gameProvider.isResearchCompleted(prereqId);
        final isNodeComplete = gameProvider.isResearchCompleted(node.id);
        final isNodeAvailable = gameProvider.isResearchAvailable(node);

        // Determine line color and style
        Color lineColor;
        double lineWidth;
        
        if (isNodeComplete) {
          lineColor = Colors.green.withValues(alpha: 0.8);
          lineWidth = 2.5;
        } else if (isPrereqComplete && isNodeAvailable) {
          final glowIntensity = 0.4 + math.sin(animation.value * 2 * math.pi) * 0.3;
          lineColor = node.categoryColor.withValues(alpha: glowIntensity);
          lineWidth = 2;
        } else if (isPrereqComplete) {
          lineColor = Colors.white.withValues(alpha: 0.25);
          lineWidth = 1.5;
        } else {
          lineColor = Colors.white.withValues(alpha: 0.1);
          lineWidth = 1;
        }

        final paint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final start = prereqTreeNode.position;
        final end = treeNode.position;

        // Draw smooth curved connection
        final path = Path();
        path.moveTo(start.dx, start.dy + 26);

        final midY = (start.dy + end.dy) / 2;
        path.cubicTo(
          start.dx, midY,
          end.dx, midY,
          end.dx, end.dy - 26,
        );

        canvas.drawPath(path, paint);

        // Draw glow for completed/available connections
        if (isNodeComplete || (isPrereqComplete && isNodeAvailable)) {
          final glowPaint = Paint()
            ..color = lineColor.withValues(alpha: 0.15)
            ..strokeWidth = lineWidth + 4
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          canvas.drawPath(path, glowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}
