import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/era_data.dart';
import '../game/kardashev_game.dart';

import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../widgets/achievements_widget.dart';
import '../widgets/objectives_widget.dart';
import '../widgets/architects_widget.dart';
import '../widgets/daily_reward_dialog.dart';
import '../widgets/glass_container.dart';
import '../widgets/generator_card_v2.dart';
// Entropy assistant removed
import '../widgets/offline_earnings_dialog.dart';
import '../widgets/research_tree_v2.dart';
import '../widgets/visual_research_tree.dart';
import '../widgets/settings_widget.dart';
import '../widgets/era_transition_dialog.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/tutorial_manager.dart';
import '../widgets/statistics_widget.dart';
import '../widgets/notification_banner.dart';
import '../widgets/store_screen.dart';
import '../widgets/timed_ad_reward_button.dart';
import '../widgets/flying_bonus_widget.dart';
import '../widgets/legendary_stage_dialog.dart';
import '../widgets/sunday_challenge_widget.dart';
import '../widgets/boost_panel.dart';

/// Main Game Screen - Multi-Era Support
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late KardashevGame _game;
  int _selectedTab = 0;
  bool _isMenuOpen = false; // Track if the expandable menu is open
  // Entropy assistant removed
  bool _hasShownOfflineDialog = false;
  int? _lastEraForAudio; // Track era changes for audio

  late AnimationController _tabAnimationController;
  late AnimationController _menuAnimationController; // Animation for menu opening/closing

  @override
  void initState() {
    super.initState();
    _game = KardashevGame();
    
    // Register lifecycle observer for audio management
    WidgetsBinding.instance.addObserver(this);

    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Start audio after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAudioForCurrentEra();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    AudioService.onAppLifecycleStateChange(state == AppLifecycleState.resumed);
  }
  
  void _startAudioForCurrentEra() {
    final provider = context.read<GameProvider>();
    final currentEra = provider.state.currentEra;
    // Only play audio if sound is enabled in settings
    if (provider.state.soundEnabled) {
      AudioService.playEraMusic(currentEra);
      AudioService.playEraAmbient(currentEra);
    }
    _lastEraForAudio = currentEra;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabAnimationController.dispose();
    _menuAnimationController.dispose();
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
              timeAway: gameProvider.timeAway,
              offlineEfficiency: gameProvider.offlineEfficiency,
              maxOfflineHours: gameProvider.state.maxOfflineHours,
              isMember: gameProvider.state.isMembershipActive,
              onCollectWithBonus: (doubledEarnings) {
                // Collect with 2x bonus from ad
                gameProvider.state.energy += doubledEarnings;
                gameProvider.state.totalEnergyEarned += doubledEarnings;
                gameProvider.dismissOfflineEarnings();
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
        
        // Update audio when era changes (only if sound is enabled)
        final currentEra = gameProvider.state.currentEra;
        if (_lastEraForAudio != currentEra) {
          _lastEraForAudio = currentEra;
          // Only play audio if sound is enabled in settings
          if (gameProvider.state.soundEnabled) {
            AudioService.playEraMusic(currentEra);
            AudioService.playEraAmbient(currentEra);
          }
        }

        _game.onTapCallback = () {
          if (_isMenuOpen) {
            _closeMenu();
          } else {
            gameProvider.tap();
          }
        };

        return TutorialManagerWidget(
          eraConfig: eraConfig,
          child: Scaffold(
            backgroundColor: eraConfig.backgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  // Game Canvas (Background)
                  Positioned.fill(child: GameWidget(game: _game)),

                  // Flying Bonus Object (Alien Spaceship)
                  Positioned.fill(child: FlyingBonusWidget(gameProvider: gameProvider)),

                  // Top HUD
                  Positioned(
                    top: 16,
                  left: 16,
                  right: 16,
                  child: _buildTopHUD(gameProvider),
                ),

                // Era selector (if multiple eras unlocked) - moved down to avoid overlap
                if (gameProvider.state.unlockedEras.length > 1)
                  Positioned(
                    top: 130,
                    left: 16,
                    right: 16,
                    child: _buildEraSelector(gameProvider),
                  ),

                // Era Ascension Available Banner
                // Adjust position based on whether we have 2 rows of era tabs (4+ eras unlocked)
                if (_isEraTransitionAvailable(gameProvider))
                  Positioned(
                    top: gameProvider.state.unlockedEras.length > 1 
                        ? (gameProvider.state.unlockedEras.any((e) => e > 2) ? 220 : 175) // 2 rows vs 1 row
                        : 130,
                    left: 16,
                    right: 16,
                    child: _buildEraAscensionBanner(gameProvider),
                  ),

                // Sunday Challenge Banner (shows when available or active)
                if (gameProvider.isSundayChallengeAvailable || gameProvider.isSundayChallengeActive)
                  Positioned(
                    top: _getSundayChallengeBannerTop(gameProvider),
                    left: 0,
                    right: 0,
                    child: SundayChallengeBanner(
                      gameProvider: gameProvider,
                      onTap: () => _showSundayChallengeDialog(gameProvider),
                    ),
                  ),

                // Menu Overlay (Background Scrim & Content)
                if (_isMenuOpen)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        // Scrim - tap to close
                        GestureDetector(
                          onTap: _closeMenu,
                          behavior: HitTestBehavior.opaque, // Catch all touches
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5), // Dim background
                          ),
                        ),
                        // Menu Content - Sliding up
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 85), // Leave space for nav bar
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75, // 75% height
                              child: _buildExpandedMenu(gameProvider),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom Navigation Bar (Always visible)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomNavigationBar(gameProvider),
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
                                '+${GameProvider.formatNumber(gameProvider.tapEnergy)}',
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

                // Era Transition Dialog
                if (gameProvider.showEraTransition && gameProvider.pendingTransition != null)
                  EraTransitionDialog(
                    transition: gameProvider.pendingTransition!,
                    gameProvider: gameProvider,
                    onDismiss: () => gameProvider.dismissEraTransition(),
                    onTransition: () {
                      if (gameProvider.executeEraTransition()) {
                        AudioService.playEraTransition();
                      }
                    },
                  ),

                // Timed Ad Reward Button (appears every 5-10 minutes)
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height * 0.35,
                  child: TimedAdRewardButton(
                    gameProvider: gameProvider,
                  ),
                ),

                // In-app Notification Banner Stack
                Positioned(
                  top: 130,
                  left: 0,
                  right: 0,
                  child: NotificationBannerStack(
                    controller: gameProvider.notificationController,
                    eraConfig: eraConfig,
                  ),
                ),

                // Achievement Notification Overlay
                if (gameProvider.currentAchievementNotification != null)
                  Positioned(
                    top: 180,
                    left: 0,
                    right: 0,
                    child: AchievementNotification(
                      achievement: gameProvider.currentAchievementNotification!,
                      onDismiss: () {
                        gameProvider.dismissAchievementNotification();
                      },
                    ),
                  ),

                // Daily Login Reward Dialog - Now shows scaled rewards!
                if (gameProvider.showDailyReward && gameProvider.pendingDailyReward != null)
                  Positioned.fill(
                    child: DailyRewardDialog(
                      reward: gameProvider.pendingDailyReward!,
                      currentStreak: gameProvider.state.loginStreak,
                      totalLoginDays: gameProvider.state.totalLoginDays,
                      onClaim: () => gameProvider.claimDailyReward(),
                      onDismiss: () => gameProvider.dismissDailyReward(),
                      // Pass player progress for scaled reward display
                      energyPerSecond: gameProvider.state.energyPerSecond,
                      kardashevLevel: gameProvider.state.kardashevLevel,
                      currentEra: gameProvider.state.currentEra,
                      prestigeCount: gameProvider.state.prestigeCount,
                    ),
                  ),

                // Legendary Stage Ready Dialog
                if (gameProvider.showLegendaryStageDialog && 
                    gameProvider.activeLegendaryExpedition != null &&
                    gameProvider.activeLegendaryExpedition!.canResolveCurrentStage)
                  Positioned.fill(
                    child: LegendaryStageReadyDialog(
                      gameProvider: gameProvider,
                      onDismiss: () => gameProvider.dismissLegendaryStageDialog(),
                      onResolve: () {
                        gameProvider.dismissLegendaryStageDialog();
                        final result = gameProvider.resolveLegendaryStage();
                        if (result != null) {
                          _showLegendaryStageResultDialog(context, gameProvider, result);
                        }
                      },
                    ),
                  ),

                // Sunday Challenge Complete - Claim Rewards Dialog
                if (gameProvider.canClaimSundayChallengeReward)
                  Positioned.fill(
                    child: SundayChallengeWidget(
                      gameProvider: gameProvider,
                      onDismiss: () => setState(() {}),
                    ),
                  ),

                // Tutorial Overlay for New Players
                if (!gameProvider.state.tutorialCompleted)
                  TutorialOverlay(
                    eraConfig: eraConfig,
                    onComplete: () => gameProvider.completeTutorial(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHUD(GameProvider gameProvider) {
    final eraConfig = gameProvider.state.eraConfig;
    final primaryColor = gameProvider.getThemePrimaryColor();
    final accentColor = gameProvider.getThemeAccentColor();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Currency indicators (fills available space)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDarkMatterDisplay(gameProvider),
              const SizedBox(height: 8),
              _buildEnergyDisplay(gameProvider, accentColor),
            ],
          ),
        ),
        
        const SizedBox(width: 12),

        // Center: Kardashev Indicator (larger, more readable)
        _buildKardashevDisplay(gameProvider, eraConfig, primaryColor),
        
        const SizedBox(width: 12),
        
        // Right side: Action buttons (hugging right edge)
        _buildActionButtonsColumn(gameProvider, primaryColor, accentColor),
      ],
    );
  }
  
  /// Dark Matter display with label
  Widget _buildDarkMatterDisplay(GameProvider gameProvider) {
    const dmColor = Color(0xFF9C27B0);
    const dmTextColor = Color(0xFFCE93D8);
    
    return GestureDetector(
      onTap: () => _openStore(context, gameProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(
            color: dmColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: dmColor.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dmColor.withValues(alpha: 0.3),
              ),
              child: const Icon(
                Icons.blur_circular,
                color: dmTextColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            // Label and Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DARK MATTER',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    GameProvider.formatNumber(gameProvider.state.darkMatter),
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: dmTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Add button
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dmColor.withValues(alpha: 0.4),
              ),
              child: const Icon(
                Icons.add,
                color: dmTextColor,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Energy display with label
  Widget _buildEnergyDisplay(GameProvider gameProvider, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.3),
            ),
            child: Icon(
              Icons.bolt,
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENERGY',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  GameProvider.formatNumber(gameProvider.state.energy),
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Kardashev display (larger, more prominent)
  Widget _buildKardashevDisplay(GameProvider gameProvider, dynamic eraConfig, Color primaryColor) {
    final level = gameProvider.state.kardashevLevel;
    final subtitle = eraConfig?.subtitle ?? 'ERA ${gameProvider.state.currentEra + 1}';
    final eraProgress = (level - level.floor()).clamp(0.0, 1.0);
    
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withValues(alpha: 0.6),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with label and era badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'KARDASHEV',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Large level display
          Text(
            level.toStringAsFixed(3),
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00E5FF),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          SizedBox(
            width: 110,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: eraProgress,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Action buttons column (Settings + Store + AI Nexus) - pushed to right edge
  Widget _buildActionButtonsColumn(GameProvider gameProvider, Color primaryColor, Color accentColor) {
    const buttonSize = 40.0;
    const iconSize = 20.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI Nexus indicator (if owned) - at top
        if (gameProvider.state.hasAINexus) ...[
          _buildAINexusBadge(),
          const SizedBox(height: 6),
        ],
        // Settings button
        GestureDetector(
          onTap: () => _showSettingsModal(context, gameProvider),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white70,
              size: iconSize,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Store button
        GestureDetector(
          onTap: () => _openStore(context, gameProvider),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.4),
                  accentColor.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              Icons.storefront,
              color: accentColor,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }
  
  /// AI Nexus badge (2X indicator)
  Widget _buildAINexusBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '2X',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  void _openStore(BuildContext context, GameProvider gameProvider) {
    AudioService.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoreScreen(gameProvider: gameProvider),
      ),
    );
  }
  
  /// Check if era transition is available
  bool _isEraTransitionAvailable(GameProvider gameProvider) {
    final transition = gameProvider.state.nextTransition;
    if (transition == null) return false;
    
    // Check if reached required Kardashev level but haven't transitioned yet
    // Use small epsilon for floating point comparison (0.999 should count as 1.0)
    final hasReachedLevel = gameProvider.state.kardashevLevel >= (transition.requiredKardashev - 0.001);
    final hasNotTransitioned = !gameProvider.state.unlockedEras.contains(transition.toEra.index);
    
    return hasReachedLevel && hasNotTransitioned;
  }
  
  /// Calculate the top position for Sunday Challenge banner
  double _getSundayChallengeBannerTop(GameProvider gameProvider) {
    double baseTop = 130.0;
    
    // Adjust for era selector
    if (gameProvider.state.unlockedEras.length > 1) {
      baseTop = gameProvider.state.unlockedEras.any((e) => e > 2) ? 220.0 : 175.0;
    }
    
    // Adjust for era ascension banner
    if (_isEraTransitionAvailable(gameProvider)) {
      baseTop += 70;
    }
    
    return baseTop;
  }
  
  /// Show the Sunday Challenge dialog
  void _showSundayChallengeDialog(GameProvider gameProvider) {
    AudioService.playClick();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SundayChallengeWidget(
        gameProvider: gameProvider,
        onDismiss: () {
          Navigator.of(context).pop();
          setState(() {});
        },
      ),
    );
  }
  
  /// Build the Era Ascension banner
  Widget _buildEraAscensionBanner(GameProvider gameProvider) {
    final transition = gameProvider.state.nextTransition!;
    final canAfford = gameProvider.state.energy >= transition.energyCost;
    
    return GestureDetector(
      onTap: () {
        AudioService.playClick();
        _showEraTransitionDialog(context, gameProvider, transition);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: 0.3),
              Colors.orange.withValues(alpha: 0.2),
            ],
          ),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulsing icon
            _AscensionIcon(),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🚀 ${transition.title} AVAILABLE!',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    canAfford 
                        ? 'Tap to ascend to the next era!'
                        : 'Need ${GameProvider.formatNumber(transition.energyCost)} energy',
                    style: TextStyle(
                      fontSize: 10,
                      color: canAfford 
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.red.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.amber.withValues(alpha: 0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEraTransitionDialog(BuildContext context, GameProvider gameProvider, EraTransition transition) {
    // CRITICAL: Set the pending transition so executeEraTransition() can access it
    gameProvider.setPendingTransition(transition);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EraTransitionDialog(
        transition: transition,
        gameProvider: gameProvider,
        onDismiss: () {
          gameProvider.dismissEraTransition();
          Navigator.of(context).pop();
        },
        onTransition: () {
          if (gameProvider.executeEraTransition()) {
            AudioService.playEraTransition();
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
  
  void _showLegendaryStageResultDialog(BuildContext context, GameProvider gameProvider, dynamic result) {
    final eraConfig = gameProvider.state.eraConfig;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: eraConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: result.success 
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.red.withValues(alpha: 0.5),
          ),
        ),
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.cancel,
              color: result.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.success ? 'STAGE COMPLETE!' : 'STAGE FAILED',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  color: result.success ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (result.rewards.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'REWARDS:',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                ...result.rewards.map((reward) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(reward.icon, size: 14, color: reward.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reward.description,
                          style: TextStyle(fontSize: 11, color: reward.color),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
              if (result.expeditionCompleted) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Text('', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Legendary Expedition Complete!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!result.success && result.expeditionFailed) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Expedition failed. Partial rewards collected.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: result.success ? Colors.green : Colors.grey,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              result.expeditionCompleted || result.expeditionFailed 
                  ? 'COLLECT' 
                  : 'CONTINUE',
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSettingsModal(BuildContext context, GameProvider gameProvider) {
    AudioService.playClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: gameProvider.state.eraConfig.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: gameProvider.state.eraConfig.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: gameProvider.state.eraConfig.primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              child: SettingsWidget(gameProvider: gameProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEraSelector(GameProvider gameProvider) {
    final unlockedEras = gameProvider.state.unlockedEras;
    
    // Split eras into two rows: first 3 (Planetary, Stellar, Galactic) and last 2 (Universal, Multiversal)
    final firstRowEras = unlockedEras.where((e) => e <= 2).toList(); // Era indices 0, 1, 2
    final secondRowEras = unlockedEras.where((e) => e > 2).toList();  // Era indices 3, 4
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First row: Planetary, Stellar, Galactic
          if (firstRowEras.isNotEmpty)
            SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: firstRowEras.map((eraIndex) => 
                  _buildEraTab(gameProvider, eraIndex)
                ).toList(),
              ),
            ),
          
          // Second row: Universal, Multiversal (if unlocked)
          if (secondRowEras.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: secondRowEras.map((eraIndex) => 
                  _buildEraTab(gameProvider, eraIndex)
                ).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEraTab(GameProvider gameProvider, int eraIndex) {
    final era = Era.values[eraIndex];
    final config = eraConfigs[era]!;
    final isSelected = gameProvider.state.currentEra == eraIndex;
    
    return GestureDetector(
      onTap: () => gameProvider.switchEra(era),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
              size: 14,
              color: isSelected ? config.primaryColor : Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              config.subtitle,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? config.primaryColor : Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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
      case Era.multiversal:
        return Icons.bubble_chart;
    }
  }

  Widget _buildBottomNavigationBar(GameProvider gameProvider) {
    // Use theme colors if active, otherwise fall back to era colors
    final primaryColor = gameProvider.getThemePrimaryColor();
    final accentColor = gameProvider.getThemeAccentColor();
    
    return GlassContainer(
      borderRadius: 0, // Full width bar
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20), // Extra bottom padding for safe area
      margin: EdgeInsets.zero,
      borderColor: gameProvider.hasActiveTheme 
          ? primaryColor.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(0, 'BUILD', Icons.construction, primaryColor, accentColor, gameProvider: gameProvider),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTab(1, 'RESEARCH', Icons.science, primaryColor, accentColor, gameProvider: gameProvider),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTab(2, 'ARCHITECTS', Icons.people, primaryColor, accentColor, gameProvider: gameProvider),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTab(
              3, 
              'GOALS', 
              Icons.emoji_events, 
              primaryColor,
              accentColor, 
              gameProvider: gameProvider,
              showBadge: (gameProvider.unclaimedAchievementCount + gameProvider.unclaimedChallengeCount) > 0,
              badgeCount: gameProvider.unclaimedAchievementCount + gameProvider.unclaimedChallengeCount,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTab(
              4, 
              'BOOSTS', 
              Icons.flash_on, 
              primaryColor, 
              accentColor, 
              gameProvider: gameProvider,
              showBadge: gameProvider.hasActiveBoost,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTab(5, 'STATS', Icons.analytics, primaryColor, accentColor, gameProvider: gameProvider, showPrestigeBadge: gameProvider.getNextPrestigeInfo() != null && gameProvider.state.kardashevLevel >= (gameProvider.getNextPrestigeInfo()?.requiredKardashev ?? 999)),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon, Color primaryColor, Color accentColor, {GameProvider? gameProvider, bool showPrestigeBadge = false, bool showBadge = false, int badgeCount = 0}) {
    final isSelected = _selectedTab == index && _isMenuOpen; // Only highlight if menu is open
    
    return GestureDetector(
      onTap: () {
        AudioService.playClick();
        if (_selectedTab == index && _isMenuOpen) {
          _closeMenu();
        } else {
          setState(() => _selectedTab = index);
          _openMenu();
          _tabAnimationController.forward(from: 0);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected
                      ? primaryColor.withValues(alpha: 0.2)
                      : Colors.transparent,
              border: Border.all(
                color:
                    isSelected
                        ? primaryColor.withValues(alpha: 0.5)
                        : Colors.transparent,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.5),
                    size: 24, // Larger icon
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 8,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? accentColor : Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Prestige notification badge
          if (showPrestigeBadge && gameProvider != null)
            Positioned(
              top: -2,
              right: 4,
              child: _PrestigeBadge(primaryColor: primaryColor, accentColor: accentColor),
            ),
          // Achievement badge with count
          if (showBadge && badgeCount > 0)
            Positioned(
              top: -2,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _closeMenu() {
    if (!_isMenuOpen) return;
    setState(() {
      _isMenuOpen = false;
    });
    _menuAnimationController.reverse();
    AudioService.playClick(); // Close sound
  }

  void _openMenu() {
    if (_isMenuOpen) return;
    setState(() {
      _isMenuOpen = true;
    });
    _menuAnimationController.forward();
  }

  Widget _buildExpandedMenu(GameProvider gameProvider) {
    final primaryColor = gameProvider.getThemePrimaryColor();
    final accentColor = gameProvider.getThemeAccentColor();
    
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderColor: primaryColor.withValues(alpha: 0.3),
      child: Column(
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTabTitle(_selectedTab),
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: _closeMenu,
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: _buildTabContent(gameProvider),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return 'CONSTRUCTION';
      case 1: return 'RESEARCH LAB';
      case 2: return 'ARCHITECTS';
      case 3: return 'OBJECTIVES';
      case 4: return 'BOOSTS';
      case 5: return 'STATISTICS';
      default: return '';
    }
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
        return _buildAchievementsTab(gameProvider);
      case 4:
        return _buildBoostsTab(gameProvider);
      case 5:
        return _buildStatsTab(gameProvider);
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildBoostsTab(GameProvider gameProvider) {
    return BoostPanel(
      gameProvider: gameProvider,
      onOpenStore: () => _openStore(context, gameProvider),
    );
  }
  
  Widget _buildAchievementsTab(GameProvider gameProvider) {
    return ObjectivesWidget(gameProvider: gameProvider);
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
    return _ResearchTabWithToggle(gameProvider: gameProvider);
  }

  Widget _buildArchitectsTab(GameProvider gameProvider) {
    return ArchitectsWidget(gameProvider: gameProvider);
  }

  Widget _buildStatsTab(GameProvider gameProvider) {
    return StatisticsWidget(gameProvider: gameProvider);
  }

  // Entropy assistant and helper methods removed
}

/// Pulsing prestige notification badge
class _PrestigeBadge extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;
  
  const _PrestigeBadge({required this.primaryColor, required this.accentColor});

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
              color: widget.accentColor,
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: 0.6),
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
                      '+${GameProvider.formatNumber(widget.nextPrestige.darkEnergyReward)}',
                      'Dark Energy',
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

/// Pulsing ascension icon for era transition banner
class _AscensionIcon extends StatefulWidget {
  @override
  State<_AscensionIcon> createState() => _AscensionIconState();
}

class _AscensionIconState extends State<_AscensionIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.6),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Research Tab with List/Tree View Toggle
class _ResearchTabWithToggle extends StatefulWidget {
  final GameProvider gameProvider;
  
  const _ResearchTabWithToggle({required this.gameProvider});
  
  @override
  State<_ResearchTabWithToggle> createState() => _ResearchTabWithToggleState();
}

class _ResearchTabWithToggleState extends State<_ResearchTabWithToggle> {
  bool _showTreeView = true; // Default to visual tree view
  
  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    return Column(
      children: [
        // View toggle header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'RESEARCH LAB',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: eraConfig.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              // View toggle buttons
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: eraConfig.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton(
                      icon: Icons.account_tree,
                      tooltip: 'Tree View',
                      isSelected: _showTreeView,
                      onTap: () => setState(() => _showTreeView = true),
                      eraConfig: eraConfig,
                    ),
                    _buildToggleButton(
                      icon: Icons.list,
                      tooltip: 'List View',
                      isSelected: !_showTreeView,
                      onTap: () => setState(() => _showTreeView = false),
                      eraConfig: eraConfig,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showTreeView
                ? VisualResearchTree(
                    key: const ValueKey('tree'),
                    gameProvider: widget.gameProvider,
                  )
                : ResearchTreeWidgetV2(
                    key: const ValueKey('list'),
                    gameProvider: widget.gameProvider,
                  ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildToggleButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
    required EraConfig eraConfig,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? eraConfig.primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected
                ? eraConfig.primaryColor
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
