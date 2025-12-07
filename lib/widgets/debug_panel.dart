// ═══════════════════════════════════════════════════════════════════════════
// DEBUG PANEL - REMOVE THIS FILE FOR PRODUCTION RELEASE
// ═══════════════════════════════════════════════════════════════════════════
// This file provides developer tools for testing the game.
// Before releasing to the Play Store:
// 1. Delete this file
// 2. Remove the import from settings_widget.dart
// 3. Set GameProvider._debugModeEnabled = false
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';

/// Debug Panel for developer testing
/// Access: Settings > Tap version number 7 times
class DebugPanel extends StatelessWidget {
  final GameProvider gameProvider;
  final VoidCallback onClose;

  const DebugPanel({
    super.key,
    required this.gameProvider,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final eraConfig = gameProvider.state.eraConfig;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade900.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade800.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEBUG PANEL',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Developer Tools - Remove for Release',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current State Display
                  _buildStateDisplay(eraConfig),
                  const SizedBox(height: 16),
                  
                  // Era Skip Section
                  _buildSectionTitle('ERA SKIP', Icons.rocket_launch),
                  const SizedBox(height: 8),
                  _buildEraButtons(context),
                  const SizedBox(height: 16),
                  
                  // Resource Section
                  _buildSectionTitle('RESOURCES', Icons.monetization_on),
                  const SizedBox(height: 8),
                  _buildResourceButtons(context),
                  const SizedBox(height: 16),
                  
                  // Progress Section
                  _buildSectionTitle('PROGRESS BOOST', Icons.speed),
                  const SizedBox(height: 8),
                  _buildProgressButtons(context),
                  const SizedBox(height: 16),
                  
                  // Unlock Section
                  _buildSectionTitle('UNLOCK ALL', Icons.lock_open),
                  const SizedBox(height: 8),
                  _buildUnlockButtons(context),
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  _buildSectionTitle('QUICK ACTIONS', Icons.flash_on),
                  const SizedBox(height: 8),
                  _buildQuickActions(context),
                  
                  const SizedBox(height: 24),
                  
                  // Warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Debug mode must be disabled before Play Store release!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStateDisplay(EraConfig eraConfig) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Era', eraConfig.subtitle, Colors.cyan),
              _buildStatItem('K Level', 'K${gameProvider.state.kardashevLevel.toStringAsFixed(3)}', Colors.amber),
              _buildStatItem('Prestige', '${gameProvider.state.prestigeCount}', Colors.purple),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Energy', GameProvider.formatNumber(gameProvider.state.energy), Colors.yellow),
              _buildStatItem('DM', GameProvider.formatNumber(gameProvider.state.darkMatter), Colors.deepPurple),
              _buildStatItem('DE', GameProvider.formatNumber(gameProvider.state.darkEnergy), Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.red.shade300),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade300,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEraButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Era.values.map((era) {
        final eraConfig = eraConfigs[era]!;
        final isUnlocked = gameProvider.state.unlockedEras.contains(era.index);
        final isCurrent = gameProvider.state.currentEra == era.index;
        
        return _buildDebugButton(
          label: 'Era ${era.index + 1}',
          subtitle: eraConfig.subtitle.split(' ').first,
          icon: isCurrent ? Icons.check_circle : (isUnlocked ? Icons.lock_open : Icons.lock),
          color: isCurrent ? Colors.green : (isUnlocked ? Colors.blue : Colors.grey),
          onTap: () {
            gameProvider.debugSkipToEra(era);
            _showSnackBar(context, 'Skipped to ${eraConfig.subtitle}');
          },
        );
      }).toList(),
    );
  }

  Widget _buildResourceButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDebugButton(
          label: '+1 Hour',
          subtitle: 'Energy',
          icon: Icons.bolt,
          color: Colors.yellow,
          onTap: () {
            gameProvider.debugAddEnergy(1);
            _showSnackBar(context, 'Added 1 hour of energy production');
          },
        ),
        _buildDebugButton(
          label: '+12 Hours',
          subtitle: 'Energy',
          icon: Icons.bolt,
          color: Colors.amber,
          onTap: () {
            gameProvider.debugAddEnergy(12);
            _showSnackBar(context, 'Added 12 hours of energy production');
          },
        ),
        _buildDebugButton(
          label: '+1000',
          subtitle: 'Dark Matter',
          icon: Icons.auto_awesome,
          color: Colors.purple,
          onTap: () {
            gameProvider.debugAddDarkMatter(1000);
            _showSnackBar(context, 'Added 1000 Dark Matter');
          },
        ),
        _buildDebugButton(
          label: '+100',
          subtitle: 'Dark Energy',
          icon: Icons.flash_on,
          color: Colors.pink,
          onTap: () {
            gameProvider.debugAddDarkEnergy(100);
            _showSnackBar(context, 'Added 100 Dark Energy');
          },
        ),
      ],
    );
  }

  Widget _buildProgressButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDebugButton(
          label: 'K +0.1',
          subtitle: 'Kardashev',
          icon: Icons.trending_up,
          color: Colors.cyan,
          onTap: () {
            final newK = gameProvider.state.kardashevLevel + 0.1;
            gameProvider.debugSetKardashevLevel(newK);
            _showSnackBar(context, 'Set Kardashev to ${newK.toStringAsFixed(3)}');
          },
        ),
        _buildDebugButton(
          label: 'K +0.5',
          subtitle: 'Kardashev',
          icon: Icons.trending_up,
          color: Colors.teal,
          onTap: () {
            final newK = gameProvider.state.kardashevLevel + 0.5;
            gameProvider.debugSetKardashevLevel(newK);
            _showSnackBar(context, 'Set Kardashev to ${newK.toStringAsFixed(3)}');
          },
        ),
        _buildDebugButton(
          label: 'Max Gens',
          subtitle: 'Generators',
          icon: Icons.settings,
          color: Colors.orange,
          onTap: () {
            gameProvider.debugMaxGenerators();
            _showSnackBar(context, 'Maxed all current era generators');
          },
        ),
        _buildDebugButton(
          label: 'Prestige',
          subtitle: 'Instant',
          icon: Icons.stars,
          color: Colors.deepPurple,
          onTap: () {
            gameProvider.debugInstantPrestige();
            _showSnackBar(context, 'Applied instant prestige bonuses');
          },
        ),
      ],
    );
  }

  Widget _buildUnlockButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDebugButton(
          label: 'All Eras',
          subtitle: 'Unlock',
          icon: Icons.public,
          color: Colors.blue,
          onTap: () {
            gameProvider.debugUnlockAllEras();
            _showSnackBar(context, 'Unlocked all eras');
          },
        ),
        _buildDebugButton(
          label: 'All Research',
          subtitle: 'Complete',
          icon: Icons.science,
          color: Colors.green,
          onTap: () {
            gameProvider.debugCompleteAllResearch();
            _showSnackBar(context, 'Completed all research for current era');
          },
        ),
        _buildDebugButton(
          label: 'All Architects',
          subtitle: 'Unlock',
          icon: Icons.people,
          color: Colors.indigo,
          onTap: () {
            gameProvider.debugUnlockAllArchitects();
            _showSnackBar(context, 'Unlocked all architects');
          },
        ),
        _buildDebugButton(
          label: 'All Artifacts',
          subtitle: 'Give',
          icon: Icons.diamond,
          color: Colors.amber,
          onTap: () {
            gameProvider.debugGiveAllArtifacts();
            _showSnackBar(context, 'Gave all artifacts');
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDebugButton(
          label: 'Reset',
          subtitle: 'Cooldowns',
          icon: Icons.timer_off,
          color: Colors.red,
          onTap: () {
            gameProvider.debugResetCooldowns();
            _showSnackBar(context, 'Reset all ability cooldowns');
          },
        ),
        _buildDebugButton(
          label: 'Complete',
          subtitle: 'Research',
          icon: Icons.check_circle,
          color: Colors.green,
          onTap: () {
            gameProvider.debugCompleteCurrentResearch();
            _showSnackBar(context, 'Completed current research');
          },
        ),
        _buildDebugButton(
          label: 'Complete',
          subtitle: 'Expeditions',
          icon: Icons.explore,
          color: Colors.orange,
          onTap: () {
            gameProvider.debugCompleteExpeditions();
            _showSnackBar(context, 'Completed all expeditions');
          },
        ),
      ],
    );
  }

  Widget _buildDebugButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bug_report, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Show the debug panel as a dialog
void showDebugPanel(BuildContext context, GameProvider gameProvider) {
  if (!GameProvider.isDebugModeAvailable) return;
  
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: DebugPanel(
          gameProvider: gameProvider,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}
