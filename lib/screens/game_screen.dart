import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/era_data.dart';
import '../game/kardashev_game.dart';
import '../models/architect.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/generator_card_v2.dart';
import '../widgets/entropy_assistant.dart';
import '../widgets/offline_earnings_dialog.dart';
import '../widgets/research_tree_v2.dart';
import '../widgets/era_transition_dialog.dart';

/// Main Game Screen - Multi-Era Support
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late KardashevGame _game;
  int _selectedTab = 0;
  bool _showEntropy = false;
  bool _hasShownOfflineDialog = false;

  late AnimationController _tabAnimationController;

  @override
  void initState() {
    super.initState();
    _game = KardashevGame();

    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final eraConfig = gameProvider.state.eraConfig;
        
        // Show offline earnings dialog if needed
        if (gameProvider.showOfflineEarnings &&
            gameProvider.offlineEarnings > 0 &&
            !_hasShownOfflineDialog) {
          _hasShownOfflineDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showOfflineEarningsDialog(
              context,
              earnings: gameProvider.offlineEarnings,
              onCollect: () {
                gameProvider.collectOfflineEarnings();
              },
            );
          });
        }

        // Update game visuals
        _game.updateGameState(
          kardashevLevel: gameProvider.state.kardashevLevel,
          energyPerSecond: gameProvider.state.energyPerSecond,
          totalGenerators:
              gameProvider.state.generators.values.fold(0, (a, b) => a + b),
          generators: gameProvider.state.generators,
          currentEra: gameProvider.state.era,
        );

        _game.onTapCallback = () => gameProvider.tap();

        return Scaffold(
          backgroundColor: eraConfig.backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Game Canvas (Background)
                Positioned.fill(child: GameWidget(game: _game)),

                // Top HUD
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildTopHUD(gameProvider),
                ),

                // Era selector (if multiple eras unlocked)
                if (gameProvider.state.unlockedEras.length > 1)
                  Positioned(
                    top: 80,
                    left: 16,
                    right: 16,
                    child: _buildEraSelector(gameProvider),
                  ),

                // Bottom Panel
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomPanel(gameProvider),
                ),

                // Tap Energy Feedback
                if (gameProvider.tapEnergy > 0)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: 1 - value,
                            child: Transform.translate(
                              offset: Offset(0, -50 * value),
                              child: Text(
                                '+${gameProvider.tapEnergy.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: eraConfig.accentColor,
                                  shadows: [
                                    Shadow(
                                      color: eraConfig.primaryColor,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // ENTROPY Assistant
                Positioned(
                  right: 16,
                  bottom: _selectedTab == 0 ? 380 : 280,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _showEntropy
                            ? SizedBox(
                              width: MediaQuery.of(context).size.width - 32,
                              child: EntropyAssistant(
                                isExpanded: true,
                                message: _getEntropyMessage(gameProvider),
                                onTap: () => setState(() => _showEntropy = false),
                              ),
                            )
                            : EntropyAssistant(
                              isExpanded: false,
                              onTap: () => setState(() => _showEntropy = true),
                            ),
                  ),
                ),

                // Era Transition Dialog
                if (gameProvider.showEraTransition && gameProvider.pendingTransition != null)
                  EraTransitionDialog(
                    transition: gameProvider.pendingTransition!,
                    gameProvider: gameProvider,
                    onDismiss: () => gameProvider.dismissEraTransition(),
                    onTransition: () {
                      if (gameProvider.executeEraTransition()) {
                        // Transition successful
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHUD(GameProvider gameProvider) {
    final eraConfig = gameProvider.state.eraConfig;
    
    return Row(
      children: [
        // Energy Counter
        Expanded(
          child: EnergyCounter(
            value: gameProvider.state.energy,
            label: 'ENERGY',
            icon: Icons.bolt,
            color: eraConfig.accentColor,
          ),
        ),
        const SizedBox(width: 12),

        // Kardashev Indicator
        KardashevIndicator(
          level: gameProvider.state.kardashevLevel,
          era: gameProvider.state.currentEra,
          eraConfig: eraConfig,
        ),
      ],
    );
  }

  Widget _buildEraSelector(GameProvider gameProvider) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gameProvider.state.unlockedEras.length,
        itemBuilder: (context, index) {
          final eraIndex = gameProvider.state.unlockedEras[index];
          final era = Era.values[eraIndex];
          final config = eraConfigs[era]!;
          final isSelected = gameProvider.state.currentEra == eraIndex;
          
          return GestureDetector(
            onTap: () => gameProvider.switchEra(era),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected 
                    ? config.primaryColor.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
                border: Border.all(
                  color: isSelected 
                      ? config.primaryColor
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getEraIcon(era),
                    size: 16,
                    color: isSelected ? config.primaryColor : Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    config.subtitle,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? config.primaryColor : Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getEraIcon(Era era) {
    switch (era) {
      case Era.planetary:
        return Icons.public;
      case Era.stellar:
        return Icons.wb_sunny;
      case Era.galactic:
        return Icons.blur_circular;
      case Era.universal:
        return Icons.all_inclusive;
    }
  }

  Widget _buildBottomPanel(GameProvider gameProvider) {
    final eraConfig = gameProvider.state.eraConfig;
    
    return GlassContainer(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(0),
      borderColor: eraConfig.primaryColor.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _buildTab(0, 'BUILD', Icons.construction, eraConfig, gameProvider: gameProvider),
                const SizedBox(width: 8),
                _buildTab(1, 'RESEARCH', Icons.science, eraConfig, gameProvider: gameProvider),
                const SizedBox(width: 8),
                _buildTab(2, 'ARCHITECTS', Icons.people, eraConfig, gameProvider: gameProvider),
                const SizedBox(width: 8),
                _buildTab(3, 'STATS', Icons.analytics, eraConfig, gameProvider: gameProvider, showPrestigeBadge: gameProvider.getNextPrestigeInfo() != null && gameProvider.state.kardashevLevel >= (gameProvider.getNextPrestigeInfo()?.requiredKardashev ?? 999)),
              ],
            ),
          ),

          // Tab Content
          SizedBox(
            height: 260,
            child: _buildTabContent(gameProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon, EraConfig eraConfig, {GameProvider? gameProvider, bool showPrestigeBadge = false}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          _tabAnimationController.forward(from: 0);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    isSelected
                        ? eraConfig.primaryColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected
                          ? eraConfig.primaryColor.withValues(alpha: 0.5)
                          : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? eraConfig.accentColor : Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? eraConfig.accentColor : Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Prestige notification badge
            if (showPrestigeBadge)
              Positioned(
                top: -2,
                right: 8,
                child: _PrestigeBadge(eraConfig: eraConfig),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(GameProvider gameProvider) {
    switch (_selectedTab) {
      case 0:
        return _buildBuildTab(gameProvider);
      case 1:
        return _buildResearchTab(gameProvider);
      case 2:
        return _buildArchitectsTab(gameProvider);
      case 3:
        return _buildStatsTab(gameProvider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBuildTab(GameProvider gameProvider) {
    final eraConfig = gameProvider.state.eraConfig;
    final generators = gameProvider.getCurrentEraGenerators();
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Production summary
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: eraConfig.primaryColor.withValues(alpha: 0.1),
            border: Border.all(
              color: eraConfig.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, color: eraConfig.accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '${GameProvider.formatNumber(gameProvider.state.energyPerSecond)}/s',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: eraConfig.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Total Production',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        // Generator cards for current era
        ...generators.map(
          (genData) => GeneratorCardV2(
            genData: genData,
            gameProvider: gameProvider,
            eraConfig: eraConfig,
            onBuy: () => gameProvider.buyGeneratorV2(genData),
            onUpgrade: () => gameProvider.upgradeGeneratorV2(genData),
          ),
        ),
      ],
    );
  }

  Widget _buildResearchTab(GameProvider gameProvider) {
    return ResearchTreeWidgetV2(gameProvider: gameProvider);
  }

  Widget _buildArchitectsTab(GameProvider gameProvider) {
    final eraConfig = gameProvider.state.eraConfig;
    final ownedArchitects = gameProvider.state.ownedArchitects;

    return Column(
      children: [
        // Dark Matter counter
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: eraConfig.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${gameProvider.state.darkMatter.toStringAsFixed(0)} Dark Matter',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        color: eraConfig.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GlassButton(
                text: 'SYNTHESIZE',
                icon: Icons.add_circle_outline,
                accentColor: eraConfig.primaryColor,
                enabled: gameProvider.state.darkMatter >= 100,
                onPressed: () => gameProvider.synthesizeArchitect(),
              ),
            ],
          ),
        ),

        // Owned architects or empty state
        Expanded(
          child:
              ownedArchitects.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Architects Yet',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Synthesize with 100 Dark Matter',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: ownedArchitects.length,
                    itemBuilder: (context, index) {
                      final architectId = ownedArchitects[index];
                      final architect = getArchitectById(architectId);
                      if (architect == null) return const SizedBox();

                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(8),
                          borderColor: Color(architect.rarityColor).withValues(
                            alpha: 0.5,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(
                                    architect.rarityColor,
                                  ).withValues(alpha: 0.3),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                architect.name,
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                architect.rarityName,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(architect.rarityColor),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '+${(architect.passiveBonus * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(architect.rarityColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(GameProvider gameProvider) {
    final state = gameProvider.state;
    final eraConfig = state.eraConfig;
    final nextPrestige = gameProvider.getNextPrestigeInfo();
    final canPrestige = nextPrestige != null && state.kardashevLevel >= nextPrestige.requiredKardashev;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Prominent Prestige Card when available
          if (canPrestige)
            _PrestigeAvailableCard(
              nextPrestige: nextPrestige,
              eraConfig: eraConfig,
              onPrestige: () => _showPrestigeDialog(gameProvider),
            ),
          
          if (canPrestige) const SizedBox(height: 12),
          
          // Stats rows
          _buildStatRow('Total Energy Earned', GameProvider.formatNumber(state.totalEnergyEarned), eraConfig),
          _buildStatRow('Total Taps', state.totalTaps.toString(), eraConfig),
          _buildStatRow(
            'Play Time',
            '${(state.playTimeSeconds / 3600).floor()}h ${((state.playTimeSeconds % 3600) / 60).floor()}m',
            eraConfig,
          ),
          _buildStatRow('Prestige Count', state.prestigeCount.toString(), eraConfig),
          _buildStatRow(
            'Prestige Bonus',
            '+${(state.prestigeBonus * 100).toStringAsFixed(1)}%',
            eraConfig,
          ),
          
          // Progress to next prestige
          if (nextPrestige != null && !canPrestige)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress further for more rewards',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        'K${state.kardashevLevel.toStringAsFixed(2)} / ${nextPrestige.requiredKardashev.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (state.kardashevLevel / nextPrestige.requiredKardashev).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(eraConfig.primaryColor.withValues(alpha: 0.6)),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
          
          const Spacer(),
          
          // Standard prestige button (shown when available but less prominent than card)
          if (!canPrestige && nextPrestige != null)
            Text(
              'Reach K${nextPrestige.requiredKardashev.toStringAsFixed(1)} to unlock prestige rewards',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, EraConfig eraConfig) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: eraConfig.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrestigeDialog(GameProvider gameProvider) {
    final eraConfig = gameProvider.state.eraConfig;
    final nextPrestige = gameProvider.getNextPrestigeInfo();
    
    if (nextPrestige == null) return;
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: eraConfig.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: eraConfig.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            title: Text(
              'PRESTIGE: ${nextPrestige.tierName}',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: eraConfig.primaryColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reset your progress for permanent bonuses?',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  '+${(nextPrestige.productionBonusGain * 100).toStringAsFixed(1)}% Production',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    color: eraConfig.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(Total: ${(nextPrestige.totalProductionBonus * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '+${GameProvider.formatNumber(nextPrestige.darkMatterReward)} Dark Matter',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    color: eraConfig.primaryColor,
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
                  backgroundColor: eraConfig.primaryColor,
                ),
                onPressed: () {
                  gameProvider.prestige();
                  Navigator.pop(context);
                },
                child: const Text('PRESTIGE'),
              ),
            ],
          ),
    );
  }

  String _getEntropyMessage(GameProvider gameProvider) {
    final state = gameProvider.state;
    final eraConfig = state.eraConfig;

    // Era-specific contextual hints
    if (state.generators.isEmpty) {
      return 'Commander, begin by building generators to harness energy. Tap the ${_getCentralObjectName(state.era)} to manually gather energy.';
    }

    if (state.energyPerSecond < _getMinProductionForEra(state.era)) {
      return 'Energy reserves are low. Focus on building more ${eraConfig.subtitle} generators to increase passive income.';
    }

    // Check for era transition
    final transition = state.nextTransition;
    if (transition != null && state.kardashevLevel >= transition.requiredKardashev * 0.9) {
      return 'You approach ${transition.title}! Prepare ${GameProvider.formatNumber(transition.energyCost)} energy to ascend to the ${eraConfigs[transition.toEra]!.subtitle} era.';
    }

    if (state.darkMatter >= 100 && state.ownedArchitects.isEmpty) {
      return 'You have enough Dark Matter to synthesize an Architect. These brilliant minds will boost your production permanently.';
    }
    
    // Check for prestige availability - HIGH PRIORITY MESSAGE
    final nextPrestige = gameProvider.getNextPrestigeInfo();
    if (nextPrestige != null && state.kardashevLevel >= nextPrestige.requiredKardashev) {
      return 'PRESTIGE AVAILABLE! Go to STATS tab to ascend to "${nextPrestige.tierName}". You\'ll gain +${(nextPrestige.productionBonusGain * 100).toStringAsFixed(1)}% permanent production bonus and ${GameProvider.formatNumber(nextPrestige.darkMatterReward)} Dark Matter!';
    }

    // Era-specific messages
    switch (state.era) {
      case Era.planetary:
        if (state.kardashevLevel >= 0.5) {
          return 'Your civilization approaches Type I status. The stars are within reach.';
        }
        break;
      case Era.stellar:
        if (state.kardashevLevel >= 1.5) {
          return 'The Dyson infrastructure expands. Soon you will command stellar-scale power.';
        }
        break;
      case Era.galactic:
        if (state.kardashevLevel >= 2.5) {
          return 'Your galactic network spans millions of stars. The universe itself calls to you.';
        }
        break;
      case Era.universal:
        return 'You manipulate the fabric of reality. Transcendence awaits.';
    }

    return 'Your ${eraConfig.subtitle} energy infrastructure is developing well. Continue expanding to reach higher Kardashev levels.';
  }

  String _getCentralObjectName(Era era) {
    switch (era) {
      case Era.planetary:
        return 'planet';
      case Era.stellar:
        return 'star';
      case Era.galactic:
        return 'galaxy';
      case Era.universal:
        return 'creation point';
    }
  }

  double _getMinProductionForEra(Era era) {
    switch (era) {
      case Era.planetary:
        return 10;
      case Era.stellar:
        return 100000;
      case Era.galactic:
        return 1e14;
      case Era.universal:
        return 1e22;
    }
  }
}

/// Pulsing prestige notification badge
class _PrestigeBadge extends StatefulWidget {
  final EraConfig eraConfig;
  
  const _PrestigeBadge({required this.eraConfig});

  @override
  State<_PrestigeBadge> createState() => _PrestigeBadgeState();
}

class _PrestigeBadgeState extends State<_PrestigeBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.eraConfig.accentColor,
              boxShadow: [
                BoxShadow(
                  color: widget.eraConfig.accentColor.withValues(alpha: 0.6),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.rocket_launch,
                size: 10,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Prestige available card with call-to-action
class _PrestigeAvailableCard extends StatefulWidget {
  final PrestigeInfo nextPrestige;
  final EraConfig eraConfig;
  final VoidCallback onPrestige;
  
  const _PrestigeAvailableCard({
    required this.nextPrestige,
    required this.eraConfig,
    required this.onPrestige,
  });

  @override
  State<_PrestigeAvailableCard> createState() => _PrestigeAvailableCardState();
}

class _PrestigeAvailableCardState extends State<_PrestigeAvailableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _borderAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPrestige,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.eraConfig.accentColor.withValues(alpha: 0.15),
                  widget.eraConfig.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: widget.eraConfig.accentColor.withValues(alpha: _borderAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.eraConfig.accentColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.eraConfig.accentColor.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        color: widget.eraConfig.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRESTIGE AVAILABLE!',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.eraConfig.accentColor,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Ascend to ${widget.nextPrestige.tierName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: widget.eraConfig.accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRewardChip(
                      '+${(widget.nextPrestige.productionBonusGain * 100).toStringAsFixed(1)}%',
                      'Production',
                      widget.eraConfig,
                    ),
                    _buildRewardChip(
                      '+${GameProvider.formatNumber(widget.nextPrestige.darkMatterReward)}',
                      'Dark Matter',
                      widget.eraConfig,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardChip(String value, String label, EraConfig eraConfig) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: eraConfig.accentColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
