import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/era_data.dart';
import '../models/architect.dart';
import '../models/architect_ability.dart';
import '../models/tutorial_state.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import 'animated_widgets.dart';
import 'expeditions_widget.dart';
import 'tutorial_manager.dart';

/// Enhanced Architects tab widget with detailed architect cards and expeditions
class ArchitectsWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const ArchitectsWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<ArchitectsWidget> createState() => _ArchitectsWidgetState();
}

class _ArchitectsWidgetState extends State<ArchitectsWidget> 
    with SingleTickerProviderStateMixin {
  bool _showOwnedOnly = false;
  late TabController _subTabController;
  Timer? _cooldownRefreshTimer;
  
  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    // Refresh cooldown display every second
    _cooldownRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    
    // Check if we should show the architects tutorial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (TutorialManager.instance.shouldShowTutorial(TutorialTopic.architects)) {
        TutorialManager.instance.startTutorial(TutorialTopic.architects);
      }
    });
  }
  
  @override
  void dispose() {
    _subTabController.dispose();
    _cooldownRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final activeExpeditions = widget.gameProvider.activeExpeditions;
    
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
            controller: _subTabController,
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
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, size: 12),
                    SizedBox(width: 4),
                    Text('ROSTER'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore, size: 12),
                    const SizedBox(width: 4),
                    const Text('MISSIONS'),
                    if (activeExpeditions.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${activeExpeditions.length}',
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
            controller: _subTabController,
            children: [
              _buildRosterTab(),
              ExpeditionsWidget(gameProvider: widget.gameProvider),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRosterTab() {
    final eraConfig = widget.gameProvider.state.eraConfig;
    final ownedArchitects = widget.gameProvider.state.ownedArchitects;
    final currentEra = widget.gameProvider.state.eraName; // Get current era as string (I, II, III, IV)
    
    // Get architects for current era
    final eraArchitects = getArchitectsForEra(currentEra);
    
    // Get architects to display
    final architectsToShow = _showOwnedOnly
        ? eraArchitects.where((a) => ownedArchitects.contains(a.id)).toList()
        : eraArchitects;

    return Column(
      children: [
        // Header with Dark Matter and Synthesize button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              // Dark Matter display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.purple.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌑', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      widget.gameProvider.state.darkMatter.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade200,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Toggle owned/all
              GestureDetector(
                onTap: () => setState(() => _showOwnedOnly = !_showOwnedOnly),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _showOwnedOnly 
                        ? eraConfig.primaryColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    _showOwnedOnly ? 'OWNED' : 'ALL',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9,
                      color: _showOwnedOnly 
                          ? eraConfig.primaryColor 
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Synthesize button
              Builder(
                builder: (context) {
                  final cost = widget.gameProvider.getSynthesisCost();
                  final canAfford = widget.gameProvider.state.darkMatter >= cost;
                  final allEraArchitectsOwned = eraArchitects.every((a) => ownedArchitects.contains(a.id));
                  
                  return GestureDetector(
                    onTap: canAfford && !allEraArchitectsOwned
                        ? () => _showSynthesizeDialog(context, eraArchitects)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: canAfford && !allEraArchitectsOwned
                            ? LinearGradient(
                                colors: [
                                  Colors.purple.shade700,
                                  Colors.blue.shade700,
                                ],
                              )
                            : null,
                        color: canAfford && !allEraArchitectsOwned
                            ? null
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            allEraArchitectsOwned ? Icons.check_circle : Icons.auto_awesome,
                            size: 14,
                            color: canAfford && !allEraArchitectsOwned
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            allEraArchitectsOwned ? 'ALL OWNED' : 'SYNTH (${cost.toInt()})',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: canAfford && !allEraArchitectsOwned
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Collection progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text(
                'Era $currentEra: ${eraArchitects.where((a) => ownedArchitects.contains(a.id)).length}/${eraArchitects.length}',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: eraArchitects.isEmpty ? 0 : eraArchitects.where((a) => ownedArchitects.contains(a.id)).length / eraArchitects.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(eraConfig.primaryColor),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Architect list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: architectsToShow.length,
            itemBuilder: (context, index) {
              final architect = architectsToShow[index];
              final isOwned = ownedArchitects.contains(architect.id);
              return _buildArchitectCard(architect, isOwned, eraConfig);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArchitectCard(Architect architect, bool isOwned, EraConfig eraConfig) {
    final rarityColor = Color(architect.rarityColor);
    
    return GestureDetector(
      onTap: isOwned ? () => _showArchitectDetail(context, architect) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isOwned 
              ? rarityColor.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.3),
          border: Border.all(
            color: isOwned 
                ? rarityColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isOwned ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Architect portrait
              _buildArchitectPortrait(architect, isOwned, rarityColor),
              
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and rarity
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isOwned ? architect.name : '???',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isOwned 
                                  ? rarityColor 
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        _buildRarityBadge(architect.rarity, rarityColor, isOwned),
                      ],
                    ),
                    
                    if (isOwned) ...[
                      const SizedBox(height: 2),
                      Text(
                        architect.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 6),
                    
                    // Passive bonus - MAIN INFO
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: isOwned 
                            ? rarityColor.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: isOwned 
                                ? Colors.green 
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOwned 
                                ? '+${(architect.passiveBonus * 100).toStringAsFixed(0)}% ${_getShortBonusType(architect)}'
                                : '??? bonus',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOwned 
                                  ? Colors.green.shade300 
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ability button or lock indicator
              if (isOwned)
                _buildAbilityButton(architect, rarityColor)
              else
                Icon(
                  Icons.lock,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchitectPortrait(Architect architect, bool isOwned, Color rarityColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOwned 
            ? rarityColor.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: isOwned 
              ? rarityColor 
              : Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: isOwned ? [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          isOwned ? _getArchitectEmoji(architect.id) : '?',
          style: TextStyle(
            fontSize: isOwned ? 28 : 24,
          ),
        ),
      ),
    );
  }

  Widget _buildRarityBadge(ArchitectRarity rarity, Color color, bool isOwned) {
    final String rarityText;
    switch (rarity) {
      case ArchitectRarity.common:
        rarityText = 'C';
      case ArchitectRarity.rare:
        rarityText = 'R';
      case ArchitectRarity.epic:
        rarityText = 'E';
      case ArchitectRarity.legendary:
        rarityText = 'L';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isOwned 
            ? color.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: isOwned 
              ? color.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        rarityText,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isOwned 
              ? color 
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  String _getArchitectEmoji(String id) {
    switch (id) {
      // Era I - Planetary
      case 'tesla':
        return '⚡';
      case 'einstein':
        return '🧠';
      case 'curie':
        return '☢️';
      case 'dyson':
        return '🔮';
      case 'oppenheimer':
        return '💥';
      case 'lovelace':
        return '💻';
      case 'engineer_alpha':
        return '🔧';
      case 'scientist_alpha':
        return '🔬';
      // Era II - Stellar
      case 'dyson_ii':
        return '☀️';
      case 'kardashev':
        return '📊';
      case 'sagan':
        return '🌍';
      case 'von_neumann':
        return '🤖';
      case 'oberth':
        return '🚀';
      case 'tsiolkovsky':
        return '🌙';
      case 'stellar_engineer':
        return '⭐';
      case 'swarm_coordinator':
        return '🛰️';
      // Era III - Galactic
      case 'hawking':
        return '🕳️';
      case 'penrose':
        return '🔄';
      case 'thorne':
        return '🌀';
      case 'chandrasekhar':
        return '💫';
      case 'vera_rubin':
        return '🌑';
      case 'jocelyn_bell':
        return '📡';
      case 'galactic_commander':
        return '🎖️';
      case 'singularity_priest':
        return '🙏';
      // Era IV - Universal
      case 'omega':
        return '♾️';
      case 'eternus':
        return '⏳';
      case 'architect_prime':
        return '🏛️';
      case 'entropy_keeper':
        return '⚖️';
      case 'void_walker':
        return '👁️';
      case 'quantum_sage':
        return '🎲';
      case 'cosmic_initiate':
        return '✨';
      case 'multiverse_scout':
        return '🔭';
      default:
        return '👤';
    }
  }

  String _getShortBonusType(Architect architect) {
    if (architect.passiveAbility.contains('All')) return 'All Production';
    if (architect.passiveAbility.contains('Fusion')) return 'Fusion';
    if (architect.passiveAbility.contains('Fission')) return 'Fission';
    if (architect.passiveAbility.contains('Orbital')) return 'Orbital';
    if (architect.passiveAbility.contains('reactor')) return 'Reactors';
    if (architect.passiveAbility.contains('Automation')) return 'Automation';
    if (architect.passiveAbility.contains('Research')) return 'Research';
    return 'Production';
  }
  
  Widget _buildAbilityButton(Architect architect, Color rarityColor) {
    final ability = getAbilityForArchitect(architect.id);
    if (ability == null) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withValues(alpha: 0.2),
        ),
        child: const Icon(
          Icons.check,
          size: 16,
          color: Colors.green,
        ),
      );
    }
    
    final isAvailable = widget.gameProvider.isAbilityAvailable(architect.id);
    final cooldownProgress = widget.gameProvider.getAbilityCooldownProgress(architect.id);
    final cooldownText = widget.gameProvider.getAbilityCooldownText(architect.id);
    
    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          _showAbilityConfirmDialog(context, architect, ability);
        } else {
          // Show cooldown info
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${ability.name} on cooldown: $cooldownText remaining'),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAvailable 
              ? ability.color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          border: Border.all(
            color: isAvailable 
                ? ability.color 
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cooldown progress indicator
            if (!isAvailable)
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: cooldownProgress,
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    ability.color.withValues(alpha: 0.5),
                  ),
                ),
              ),
            // Icon
            Icon(
              ability.icon,
              size: 18,
              color: isAvailable 
                  ? ability.color 
                  : Colors.grey.withValues(alpha: 0.5),
            ),
            // Cooldown text overlay
            if (!isAvailable)
              Positioned(
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    cooldownText,
                    style: const TextStyle(
                      fontSize: 6,
                      fontFamily: 'Orbitron',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showAbilityConfirmDialog(BuildContext context, Architect architect, ArchitectAbility ability) {
    final rarityColor = Color(architect.rarityColor);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ability.color.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(ability.icon, color: ability.color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ability.name,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  color: ability.color,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Architect info
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rarityColor.withValues(alpha: 0.3),
                    border: Border.all(color: rarityColor),
                  ),
                  child: Center(
                    child: Text(
                      _getArchitectEmoji(architect.id),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      architect.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: rarityColor,
                      ),
                    ),
                    Text(
                      architect.title,
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ability description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ability.color.withValues(alpha: 0.1),
                border: Border.all(color: ability.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ability.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 12, color: Colors.orange.shade300),
                      const SizedBox(width: 4),
                      Text(
                        'Cooldown: ${ability.cooldownMinutes ~/ 60}h ${ability.cooldownMinutes % 60}m',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 10,
                          color: Colors.orange.shade300,
                        ),
                      ),
                    ],
                  ),
                  if (ability.durationMinutes > 0) ...[  
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.hourglass_bottom, size: 12, color: Colors.cyan.shade300),
                        const SizedBox(width: 4),
                        Text(
                          'Duration: ${ability.durationMinutes >= 60 ? "${ability.durationMinutes ~/ 60}h" : ""} ${ability.durationMinutes % 60 > 0 ? "${ability.durationMinutes % 60}m" : ""}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            color: Colors.cyan.shade300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Activate this ability?',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ability.color,
            ),
            onPressed: () {
              Navigator.pop(context);
              _activateAbility(architect.id, ability);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ability.icon, size: 16),
                const SizedBox(width: 6),
                const Text('ACTIVATE'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _activateAbility(String architectId, ArchitectAbility ability) {
    final result = widget.gameProvider.activateAbility(architectId);
    
    if (result != null) {
      final isSuccess = !result.contains('cooldown') && !result.contains('not activated');
      
      // Show particle burst effect for successful activation
      if (isSuccess) {
        _showAbilityParticleEffect(ability.color);
      }
      
      // Show result message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(ability.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: isSuccess
              ? ability.color.withValues(alpha: 0.9)
              : Colors.orange.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  /// Show particle burst effect when ability is activated
  void _showAbilityParticleEffect(Color color) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: ParticleBurst(
              color: color,
              particleCount: 32,
              maxRadius: 120,
              onComplete: () {
                entry.remove();
              },
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(entry);
  }

  void _showSynthesizeDialog(BuildContext context, List<Architect> eraArchitects) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.purple.withValues(alpha: 0.5),
          ),
        ),
        title: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'SYNTHESIZE ARCHITECT',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: Colors.purple.shade200,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cost display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.purple.withValues(alpha: 0.2),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌑', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.gameProvider.getSynthesisCost().toInt()} Dark Matter',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Synthesize a random Architect?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Next synthesis: ${(widget.gameProvider.getSynthesisCost() + 50).toInt()} DM',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Rarity chances
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Column(
                children: [
                  Text(
                    'DROP RATES',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropRateRow('Common', '50%', const Color(0xFF808080)),
                  _buildDropRateRow('Rare', '30%', const Color(0xFF4FC3F7)),
                  _buildDropRateRow('Epic', '15%', const Color(0xFFAB47BC)),
                  _buildDropRateRow('Legendary', '5%', const Color(0xFFFFD700)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
            ),
            onPressed: () {
              Navigator.pop(context);
              _performSynthesize(eraArchitects);
            },
            child: const Text('SYNTHESIZE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropRateRow(String rarity, String chance, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            rarity,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
          Text(
            chance,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _performSynthesize(List<Architect> eraArchitects) {
    final result = widget.gameProvider.synthesizeArchitect(eraArchitects);
    if (result) {
      AudioService.playAchievement();
      // Show the newly acquired architect
      final ownedArchitects = widget.gameProvider.state.ownedArchitects;
      if (ownedArchitects.isNotEmpty) {
        final newArchitectId = ownedArchitects.last;
        final newArchitect = getArchitectById(newArchitectId);
        if (newArchitect != null) {
          // Show particle burst for successful synthesis
          _showAbilityParticleEffect(Color(newArchitect.rarityColor));
          _showNewArchitectDialog(context, newArchitect);
        }
      }
    }
  }

  void _showNewArchitectDialog(BuildContext context, Architect architect) {
    final rarityColor = Color(architect.rarityColor);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: rarityColor, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '✨ NEW ARCHITECT! ✨',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                color: rarityColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            // Portrait
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rarityColor.withValues(alpha: 0.3),
                border: Border.all(color: rarityColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getArchitectEmoji(architect.id),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              architect.name,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: rarityColor,
              ),
            ),
            Text(
              architect.title,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: rarityColor.withValues(alpha: 0.2),
              ),
              child: Text(
                architect.rarityName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: rarityColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bonus info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_up, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        '+${(architect.passiveBonus * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    architect.passiveAbility,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: rarityColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'AWESOME!',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showArchitectDetail(BuildContext context, Architect architect) {
    final rarityColor = Color(architect.rarityColor);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Portrait
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rarityColor.withValues(alpha: 0.3),
                        border: Border.all(color: rarityColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: rarityColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getArchitectEmoji(architect.id),
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Name and title
                    Text(
                      architect.name,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: rarityColor,
                      ),
                    ),
                    Text(
                      architect.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: rarityColor.withValues(alpha: 0.2),
                        border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        architect.rarityName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rarityColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      architect.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Passive Ability
                    _buildAbilityCard(
                      'PASSIVE BONUS',
                      Icons.trending_up,
                      '+${(architect.passiveBonus * 100).toStringAsFixed(0)}%',
                      architect.passiveAbility,
                      Colors.green,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Active Ability with activation button
                    _buildActiveAbilitySection(architect),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityCard(
    String title,
    IconData icon,
    String badge,
    String description,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: color.withValues(alpha: 0.2),
                ),
                child: Text(
                  badge,
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
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveAbilitySection(Architect architect) {
    final ability = getAbilityForArchitect(architect.id);
    if (ability == null) {
      return _buildAbilityCard(
        'ACTIVE ABILITY',
        Icons.bolt,
        '${architect.activeCooldownMinutes ~/ 60}h CD',
        architect.activeAbility,
        Colors.amber,
      );
    }
    
    final isAvailable = widget.gameProvider.isAbilityAvailable(architect.id);
    final cooldownProgress = widget.gameProvider.getAbilityCooldownProgress(architect.id);
    final cooldownText = widget.gameProvider.getAbilityCooldownText(architect.id);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ability.color.withValues(alpha: 0.1),
        border: Border.all(color: ability.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ability.icon, size: 18, color: ability.color),
              const SizedBox(width: 8),
              Text(
                'ACTIVE ABILITY',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: ability.color,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isAvailable 
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAvailable) ...[
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          value: cooldownProgress,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(ability.color),
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isAvailable ? 'READY' : cooldownText,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Ability name
          Text(
            ability.name,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ability.color,
            ),
          ),
          const SizedBox(height: 4),
          
          // Description
          Text(
            ability.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Cooldown info
          Row(
            children: [
              Icon(Icons.timer, size: 14, color: Colors.orange.shade300),
              const SizedBox(width: 4),
              Text(
                'Cooldown: ${ability.cooldownMinutes ~/ 60}h ${ability.cooldownMinutes % 60}m',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: Colors.orange.shade300,
                ),
              ),
              if (ability.durationMinutes > 0) ...[
                const SizedBox(width: 16),
                Icon(Icons.hourglass_bottom, size: 14, color: Colors.cyan.shade300),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${ability.durationMinutes >= 60 ? "${ability.durationMinutes ~/ 60}h" : ""} ${ability.durationMinutes % 60 > 0 ? "${ability.durationMinutes % 60}m" : ""}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: Colors.cyan.shade300,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Activate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable 
                    ? ability.color 
                    : Colors.grey.withValues(alpha: 0.3),
                foregroundColor: isAvailable 
                    ? Colors.white 
                    : Colors.white.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isAvailable 
                  ? () {
                      Navigator.pop(context);
                      _activateAbility(architect.id, ability);
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAvailable ? ability.icon : Icons.hourglass_empty,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable ? 'ACTIVATE ABILITY' : 'ON COOLDOWN',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
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
}
