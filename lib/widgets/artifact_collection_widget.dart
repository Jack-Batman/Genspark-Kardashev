import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../models/artifact.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

/// Artifact Collection Display Widget
class ArtifactCollectionWidget extends StatefulWidget {
  final GameProvider gameProvider;
  
  const ArtifactCollectionWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<ArtifactCollectionWidget> createState() => _ArtifactCollectionWidgetState();
}

class _ArtifactCollectionWidgetState extends State<ArtifactCollectionWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ArtifactRarity? _selectedRarity;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final currentEra = widget.gameProvider.state.currentEra;
    
    // Get all artifacts available up to current era
    final availableArtifacts = getArtifactsForEra(currentEra);
    
    // Get actual owned artifacts from GameState
    final ownedArtifactIds = widget.gameProvider.state.ownedArtifactIds.toSet();
    
    return Column(
      children: [
        // Header with stats
        _buildHeader(eraConfig, availableArtifacts.length, ownedArtifactIds.length),
        
        // Era tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: eraConfig.primaryColor.withValues(alpha: 0.3),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: eraConfig.accentColor,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
            labelStyle: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'ERA I'),
              Tab(text: 'ERA II'),
              Tab(text: 'ERA III'),
              Tab(text: 'ERA IV'),
            ],
          ),
        ),
        
        // Rarity filter
        _buildRarityFilter(eraConfig),
        
        // Artifact grid
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildArtifactGrid(eraIArtifacts, ownedArtifactIds, eraConfig, 0, currentEra),
              _buildArtifactGrid(eraIIArtifacts, ownedArtifactIds, eraConfig, 1, currentEra),
              _buildArtifactGrid(eraIIIArtifacts, ownedArtifactIds, eraConfig, 2, currentEra),
              _buildArtifactGrid(eraIVArtifacts, ownedArtifactIds, eraConfig, 3, currentEra),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader(EraConfig eraConfig, int total, int owned) {
    final completion = total > 0 ? (owned / total * 100) : 0;
    
    return Column(
      children: [
        // Main stats header
        Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            eraConfig.primaryColor.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Collection icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  eraConfig.primaryColor.withValues(alpha: 0.5),
                  eraConfig.accentColor.withValues(alpha: 0.5),
                ],
              ),
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARTIFACT COLLECTION',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: eraConfig.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$owned / $total artifacts discovered',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(eraConfig.primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          
          // Completion percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: eraConfig.primaryColor.withValues(alpha: 0.2),
            ),
            child: Text(
              '${completion.toStringAsFixed(0)}%',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: eraConfig.accentColor,
              ),
            ),
          ),
        ],
      ),
    ),
        
        // How to Get Artifacts info panel
        _buildHowToGetArtifactsPanel(eraConfig),
      ],
    );
  }
  
  Widget _buildHowToGetArtifactsPanel(EraConfig eraConfig) {
    return GestureDetector(
      onTap: () => _showArtifactGuideDialog(context, eraConfig),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.purple.withValues(alpha: 0.15),
              Colors.blue.withValues(alpha: 0.15),
            ],
          ),
          border: Border.all(
            color: Colors.purple.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.purpleAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOW TO GET ARTIFACTS',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to learn about artifact sources and drop rates',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.4),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showArtifactGuideDialog(BuildContext context, EraConfig eraConfig) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ArtifactGuideSheet(eraConfig: eraConfig),
    );
  }
  
  Widget _buildRarityFilter(EraConfig eraConfig) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildRarityChip(null, 'All', eraConfig),
            ...ArtifactRarity.values.map((rarity) => 
              _buildRarityChip(rarity, rarity.displayName, eraConfig)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRarityChip(ArtifactRarity? rarity, String label, EraConfig eraConfig) {
    final isSelected = _selectedRarity == rarity;
    final color = rarity?.color ?? eraConfig.primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRarity = rarity);
          AudioService.playClick();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildArtifactGrid(
    List<Artifact> artifacts,
    Set<String> ownedIds,
    EraConfig eraConfig,
    int eraIndex,
    int currentEra,
  ) {
    // Filter by rarity if selected
    var filteredArtifacts = artifacts;
    if (_selectedRarity != null) {
      filteredArtifacts = artifacts.where((a) => a.rarity == _selectedRarity).toList();
    }
    
    final isLocked = eraIndex > currentEra;
    
    if (isLocked) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Reach Era ${['I', 'II', 'III', 'IV'][eraIndex]} to unlock',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    if (filteredArtifacts.isEmpty) {
      return Center(
        child: Text(
          'No artifacts of this rarity in this era',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredArtifacts.length,
      itemBuilder: (context, index) {
        final artifact = filteredArtifacts[index];
        final isOwned = ownedIds.contains(artifact.id);
        return _ArtifactCard(
          artifact: artifact,
          isOwned: isOwned,
          eraConfig: eraConfig,
          onTap: () => _showArtifactDetail(context, artifact, isOwned, eraConfig),
        );
      },
    );
  }
  
  void _showArtifactDetail(
    BuildContext context,
    Artifact artifact,
    bool isOwned,
    EraConfig eraConfig,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ArtifactDetailSheet(
        artifact: artifact,
        isOwned: isOwned,
        eraConfig: eraConfig,
      ),
    );
  }
}

/// Individual artifact card
class _ArtifactCard extends StatelessWidget {
  final Artifact artifact;
  final bool isOwned;
  final EraConfig eraConfig;
  final VoidCallback onTap;
  
  const _ArtifactCard({
    required this.artifact,
    required this.isOwned,
    required this.eraConfig,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = artifact.rarity.color;
    
    return GestureDetector(
      onTap: () {
        AudioService.playClick();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isOwned
              ? color.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.3),
          border: Border.all(
            color: isOwned
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isOwned ? 2 : 1,
          ),
          boxShadow: isOwned
              ? [
                  BoxShadow(
                    color: artifact.rarity.glowColor,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji/Icon
                Text(
                  isOwned ? artifact.emoji : '❓',
                  style: TextStyle(
                    fontSize: 32,
                    color: isOwned ? null : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    isOwned ? artifact.name : '???',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOwned
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Rarity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: color.withValues(alpha: isOwned ? 0.3 : 0.1),
                  ),
                  child: Text(
                    artifact.rarity.displayName,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isOwned ? color : color.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            
            // Owned indicator
            if (isOwned)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Artifact detail sheet
class _ArtifactDetailSheet extends StatelessWidget {
  final Artifact artifact;
  final bool isOwned;
  final EraConfig eraConfig;
  
  const _ArtifactDetailSheet({
    required this.artifact,
    required this.isOwned,
    required this.eraConfig,
  });

  @override
  Widget build(BuildContext context) {
    final color = artifact.rarity.color;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: color.withValues(alpha: 0.5),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Artifact icon with glow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: artifact.rarity.glowColor,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    artifact.emoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Rarity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color.withValues(alpha: 0.2),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    artifact.rarity.displayName.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Name
                Text(
                  artifact.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  artifact.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Bonus
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        artifact.bonusType.icon,
                        color: color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artifact.bonusType.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            artifact.bonusDisplay,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Lore
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📜', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          artifact.lore,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Status and acquisition info
                if (isOwned)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IN YOUR COLLECTION',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Bonus active: ${artifact.bonusDisplay}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  _buildAcquisitionInfoBox(artifact, color),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildAcquisitionInfoBox(Artifact artifact, Color color) {
    // Determine acquisition method based on artifact properties
    final hasSourceExpedition = artifact.sourceExpedition != null;
    final isLegendary = artifact.rarity == ArtifactRarity.legendary;
    final isMythic = artifact.rarity == ArtifactRarity.mythic;
    final isEpic = artifact.rarity == ArtifactRarity.epic;
    
    String sourceTitle;
    String sourceDescription;
    IconData sourceIcon;
    Color sourceColor;
    String dropInfo;
    
    if (hasSourceExpedition) {
      // Specific legendary expedition drop
      sourceTitle = 'LEGENDARY EXPEDITION DROP';
      sourceDescription = _getExpeditionName(artifact.sourceExpedition!);
      sourceIcon = Icons.military_tech;
      sourceColor = Colors.orange;
      dropInfo = 'Guaranteed drop on first completion';
    } else if (isMythic) {
      sourceTitle = 'MYTHIC EXPEDITION DROP';
      sourceDescription = 'Complete rare boss encounters';
      sourceIcon = Icons.star;
      sourceColor = Colors.red;
      dropInfo = '1% chance from legendary expeditions';
    } else if (isLegendary) {
      sourceTitle = 'EXPEDITION DROP';
      sourceDescription = 'Complete expeditions in Era ${['I', 'II', 'III', 'IV'][artifact.requiredEra]}';
      sourceIcon = Icons.rocket_launch;
      sourceColor = Colors.orange;
      dropInfo = '4% drop rate from expeditions';
    } else if (isEpic) {
      sourceTitle = 'EXPEDITION DROP';
      sourceDescription = 'Complete expeditions in Era ${['I', 'II', 'III', 'IV'][artifact.requiredEra]}';
      sourceIcon = Icons.rocket_launch;
      sourceColor = Colors.purple;
      dropInfo = '10% drop rate from expeditions';
    } else {
      // Common, uncommon, rare
      sourceTitle = 'EXPEDITION DROP';
      sourceDescription = 'Complete any expedition in Era ${['I', 'II', 'III', 'IV'][artifact.requiredEra]}+';
      sourceIcon = Icons.rocket_launch;
      sourceColor = artifact.rarity.color;
      dropInfo = '${(artifact.rarity.dropChance * 100).toInt()}% drop rate from expeditions';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            sourceColor.withValues(alpha: 0.15),
            sourceColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: sourceColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sourceColor.withValues(alpha: 0.2),
                ),
                child: Icon(sourceIcon, color: sourceColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sourceTitle,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: sourceColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sourceDescription,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  dropInfo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getExpeditionName(String expeditionId) {
    // Map expedition IDs to display names
    switch (expeditionId) {
      case 'leg_primordial_engine':
        return 'The Primordial Engine (Era I)';
      case 'leg_stellar_leviathan':
        return 'Hunt for the Stellar Leviathan (Era II)';
      case 'leg_black_hole_heart':
        return 'Heart of the Black Hole (Era III)';
      case 'leg_omega_confrontation':
        return 'The Omega Confrontation (Era IV)';
      case 'exp_sagittarius_approach':
        return 'Sagittarius Expedition (Era III)';
      default:
        return 'Legendary Expedition';
    }
  }
}

/// Artifact acquisition guide sheet
class _ArtifactGuideSheet extends StatelessWidget {
  final EraConfig eraConfig;
  
  const _ArtifactGuideSheet({required this.eraConfig});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.purple.withValues(alpha: 0.5),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.5),
                        Colors.blue.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                  child: const Text('📖', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARTIFACT GUIDE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'How to discover rare artifacts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Main acquisition method
                _buildGuideSection(
                  icon: Icons.rocket_launch,
                  iconColor: Colors.blue,
                  title: 'COMPLETE EXPEDITIONS',
                  description: 'Artifacts drop randomly from successful expeditions. '
                      'The rarer the artifact, the lower the drop chance.',
                  children: [
                    _buildDropRateRow('Common', '40%', Colors.grey),
                    _buildDropRateRow('Uncommon', '30%', Colors.green),
                    _buildDropRateRow('Rare', '15%', Colors.blue),
                    _buildDropRateRow('Epic', '10%', Colors.purple),
                    _buildDropRateRow('Legendary', '4%', Colors.orange),
                    _buildDropRateRow('Mythic', '1%', Colors.red),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Legendary expeditions
                _buildGuideSection(
                  icon: Icons.military_tech,
                  iconColor: Colors.orange,
                  title: 'LEGENDARY EXPEDITIONS',
                  description: 'Some artifacts are GUARANTEED drops from specific legendary expeditions. '
                      'Complete the multi-stage legendary expeditions to unlock these powerful artifacts.',
                  children: [
                    _buildExpeditionArtifactRow('The Primordial Engine', 'Primordial Spark', 'ERA I'),
                    _buildExpeditionArtifactRow('Hunt for Stellar Leviathan', 'Leviathan Scale', 'ERA II'),
                    _buildExpeditionArtifactRow('Heart of the Black Hole', 'Singularity Heart', 'ERA III'),
                    _buildExpeditionArtifactRow('The Omega Confrontation', 'Omega Fragment', 'ERA IV'),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Tips
                _buildGuideSection(
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.amber,
                  title: 'TIPS FOR COLLECTORS',
                  description: '',
                  children: [
                    _buildTipRow('🎯', 'Use preferred architects on expeditions for +20% success bonus'),
                    _buildTipRow('⭐', 'Higher era expeditions can drop artifacts from that era AND previous eras'),
                    _buildTipRow('🔄', 'Artifacts persist through prestige - never lost!'),
                    _buildTipRow('📈', 'Owned artifact bonuses stack and boost your production'),
                    _buildTipRow('🏆', 'Complete legendary expeditions for guaranteed rare artifacts'),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Artifact bonuses explanation
                _buildGuideSection(
                  icon: Icons.auto_awesome,
                  iconColor: Colors.cyan,
                  title: 'ARTIFACT BONUSES',
                  description: 'Each artifact provides a permanent bonus once discovered. '
                      'Bonuses are automatically applied and stack with other modifiers.',
                  children: [],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.purple.withValues(alpha: 0.5)),
                  ),
                ),
                child: Text(
                  'GOT IT!',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuideSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: iconColor.withValues(alpha: 0.08),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...children,
          ],
        ],
      ),
    );
  }
  
  Widget _buildDropRateRow(String rarity, String rate, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rarity,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.2),
            ),
            child: Text(
              rate,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpeditionArtifactRow(String expedition, String artifact, String era) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.orange.withValues(alpha: 0.2),
            ),
            child: Text(
              era,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expedition,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '→ $artifact',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star,
            size: 14,
            color: Colors.orange.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipRow(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
