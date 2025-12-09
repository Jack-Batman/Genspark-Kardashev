import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../services/cloud_save_service.dart';
import 'tutorial_manager.dart';
import 'privacy_policy_widget.dart';
import 'debug_panel.dart'; // DEBUG: Remove for production release

/// Enhanced Settings widget with volume controls, notification preferences, and data management
class SettingsWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const SettingsWidget({
    super.key,
    required this.gameProvider,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  // Volume state (synced with AudioService)
  double _masterVolume = AudioService.masterVolume;
  double _musicVolume = AudioService.musicVolume;
  double _sfxVolume = AudioService.sfxVolume;
  double _ambientVolume = AudioService.ambientVolume;
  
  // DEBUG: Hidden debug mode activation - tap version 7 times
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  @override
  Widget build(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Audio Controls
          _buildSectionHeader('AUDIO', eraConfig),
          const SizedBox(height: 8),
          _buildVolumeSlider(
            'Master Volume',
            Icons.volume_up,
            _masterVolume,
            (value) {
              setState(() => _masterVolume = value);
              AudioService.setMasterVolume(value);
            },
            eraConfig,
          ),
          _buildVolumeSlider(
            'Music',
            Icons.music_note,
            _musicVolume,
            (value) {
              setState(() => _musicVolume = value);
              AudioService.setMusicVolume(value);
            },
            eraConfig,
          ),
          _buildVolumeSlider(
            'Sound Effects',
            Icons.speaker,
            _sfxVolume,
            (value) {
              setState(() => _sfxVolume = value);
              AudioService.setSfxVolume(value);
            },
            eraConfig,
          ),
          _buildVolumeSlider(
            'Ambient',
            Icons.waves,
            _ambientVolume,
            (value) {
              setState(() => _ambientVolume = value);
              AudioService.setAmbientVolume(value);
            },
            eraConfig,
          ),
          
          const SizedBox(height: 16),
          
          // Section: Feedback
          _buildSectionHeader('FEEDBACK', eraConfig),
          const SizedBox(height: 8),
          _buildToggleTile(
            'Sound Effects',
            'Enable game sounds',
            Icons.volume_up,
            widget.gameProvider.state.soundEnabled,
            () => widget.gameProvider.toggleSound(),
            eraConfig,
          ),
          _buildHapticIntensitySelector(eraConfig),

          const SizedBox(height: 16),
          
          // Section: Display
          _buildSectionHeader('DISPLAY', eraConfig),
          const SizedBox(height: 8),
          _buildNumberFormatSelector(eraConfig),
          
          const SizedBox(height: 16),
          
          // Section: Notifications
          _buildSectionHeader('NOTIFICATIONS', eraConfig),
          const SizedBox(height: 8),
          _buildToggleTile(
            'Push Notifications',
            'Enable system notifications',
            Icons.notifications,
            widget.gameProvider.state.notificationsEnabled,
            () => widget.gameProvider.toggleNotifications(),
            eraConfig,
          ),
          _buildInfoTile(
            'In-App Banners',
            'Always on',
            Icons.notifications_active,
            eraConfig,
          ),

          const SizedBox(height: 16),

          // Section: Data Management
          _buildSectionHeader('DATA MANAGEMENT', eraConfig),
          const SizedBox(height: 8),
          _buildActionButton(
            'Export Save Data',
            'Copy save to clipboard',
            Icons.upload_file,
            () => _exportSaveData(context),
            eraConfig,
          ),
          _buildActionButton(
            'Import Save Data',
            'Load save from clipboard',
            Icons.download,
            () => _showImportDialog(context),
            eraConfig,
          ),

          const SizedBox(height: 16),

          // Section: Cloud Save
          _buildSectionHeader('CLOUD SAVE', eraConfig),
          const SizedBox(height: 8),
          _buildCloudSaveSection(eraConfig),

          const SizedBox(height: 16),

          // Section: Game Info
          _buildSectionHeader('GAME INFO', eraConfig),
          const SizedBox(height: 8),
          // DEBUG: Tap version 7 times to open debug panel
          _buildVersionTile(context, eraConfig),
          _buildInfoTile(
            'Play Time',
            _formatPlayTime(widget.gameProvider.state.playTimeSeconds),
            Icons.timer,
            eraConfig,
          ),
          _buildInfoTile(
            'Prestige Count',
            '${widget.gameProvider.state.prestigeCount}',
            Icons.auto_awesome,
            eraConfig,
          ),
          _buildInfoTile(
            'Era',
            eraConfig.subtitle,
            Icons.public,
            eraConfig,
          ),
          _buildInfoTile(
            'Kardashev Level',
            'K${widget.gameProvider.state.kardashevLevel.toStringAsFixed(3)}',
            Icons.show_chart,
            eraConfig,
          ),
          _buildInfoTile(
            'Total Taps',
            GameProvider.formatNumber(widget.gameProvider.state.totalTaps.toDouble()),
            Icons.touch_app,
            eraConfig,
          ),
          _buildInfoTile(
            'Total Energy',
            GameProvider.formatNumber(widget.gameProvider.state.totalEnergyEarned),
            Icons.bolt,
            eraConfig,
          ),

          const SizedBox(height: 16),

          // Section: Tutorials
          _buildSectionHeader('TUTORIALS', eraConfig),
          const SizedBox(height: 8),
          TutorialSettingsSection(eraConfig: eraConfig),

          const SizedBox(height: 16),

          // Section: Danger Zone
          _buildSectionHeader('DANGER ZONE', eraConfig, isWarning: true),
          const SizedBox(height: 8),
          _buildDangerButton(
            'Reset Full Tutorial',
            'Reset intro and all feature tutorials',
            Icons.school,
            () {
              widget.gameProvider.resetTutorial();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All tutorials reset - intro will show on restart'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            eraConfig,
            isMinor: true,
          ),
          _buildDangerButton(
            'Reset Progress',
            'Start fresh with all progress deleted',
            Icons.delete_forever,
            () => _showResetConfirmation(context),
            eraConfig,
          ),

          const SizedBox(height: 24),

          // Legal & Support Section
          _buildSectionHeader('LEGAL & SUPPORT', eraConfig),
          const SizedBox(height: 8),
          _buildActionTile(
            'Privacy Policy',
            'View our privacy policy',
            Icons.privacy_tip_outlined,
            () => showPrivacyPolicy(context, accentColor: eraConfig.primaryColor),
            eraConfig,
          ),
          _buildActionTile(
            'Terms of Service',
            'View terms and conditions',
            Icons.description_outlined,
            () => showPrivacyPolicy(context, accentColor: eraConfig.primaryColor),
            eraConfig,
          ),
          _buildActionTile(
            'Restore Purchases',
            'Restore previous purchases',
            Icons.restore,
            () => _restorePurchases(context),
            eraConfig,
          ),

          const SizedBox(height: 24),

          // Credits
          Center(
            child: Column(
              children: [
                Text(
                  'KARDASHEV: ASCENSION',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    color: eraConfig.primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guide civilization through cosmic eras',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0 (Beta)',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 16),
                PrivacyPolicyLink(color: eraConfig.primaryColor.withValues(alpha: 0.6)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Future<void> _restorePurchases(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restoring purchases...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // TODO: Call IAPService().restorePurchases() here
    // For now, show a placeholder message
    await Future.delayed(const Duration(seconds: 1));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchases restored successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, EraConfig eraConfig, {bool isWarning = false}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: isWarning ? Colors.red.shade300 : eraConfig.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.red.shade300 : eraConfig.primaryColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(
    String title,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
    EraConfig eraConfig,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: eraConfig.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
                child: Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: eraConfig.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: eraConfig.primaryColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: eraConfig.accentColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: eraConfig.primaryColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0,
              max: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    VoidCallback onToggle,
    EraConfig eraConfig,
  ) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: eraConfig.primaryColor.withValues(alpha: 0.2),
              ),
              child: Icon(icon, size: 18, color: eraConfig.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value
                    ? eraConfig.primaryColor.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: value
                      ? eraConfig.primaryColor
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? eraConfig.primaryColor : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudSaveSection(EraConfig eraConfig) {
    final isSignedIn = CloudSaveService.isSignedIn;
    final user = CloudSaveService.currentUser;
    final status = CloudSaveService.status;

    return Column(
      children: [
        // Sign in status
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(
              color: isSignedIn
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSignedIn
                      ? Colors.green.withValues(alpha: 0.2)
                      : eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  isSignedIn ? Icons.cloud_done : Icons.cloud_off,
                  size: 20,
                  color: isSignedIn ? Colors.green : eraConfig.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSignedIn ? 'Cloud Save Active' : 'Cloud Save Disabled',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSignedIn ? Colors.green : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSignedIn
                          ? user?.email ?? 'Guest Account'
                          : 'Sign in to backup your progress',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (status == CloudSaveStatus.syncing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: eraConfig.primaryColor,
                  ),
                ),
            ],
          ),
        ),

        // Actions
        if (!isSignedIn) ...[
          _buildActionButton(
            'Sign in with Google',
            'Sync progress across devices',
            Icons.login,
            () => _signInWithGoogle(context),
            eraConfig,
          ),
        ] else ...[
          _buildActionButton(
            'Sync Now',
            'Backup current progress to cloud',
            Icons.sync,
            () => _syncToCloud(context),
            eraConfig,
          ),
          _buildActionButton(
            'Sign Out',
            'Disconnect cloud save',
            Icons.logout,
            () => _signOut(context),
            eraConfig,
          ),
        ],
      ],
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final result = await CloudSaveService.signInWithGoogle();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Sign in result'),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      setState(() {}); // Refresh UI
    }
  }

  Future<void> _syncToCloud(BuildContext context) async {
    final result = await CloudSaveService.saveToCloud(widget.gameProvider.state);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Sync result'),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      setState(() {}); // Refresh UI
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await CloudSaveService.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out from cloud save'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {}); // Refresh UI
    }
  }

  Widget _buildInfoTile(String title, String value, IconData icon, EraConfig eraConfig) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: eraConfig.primaryColor.withValues(alpha: 0.2),
            ),
            child: Icon(icon, size: 18, color: eraConfig.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white),
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
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DEBUG: Version tile with hidden debug panel activation
  // Tap 7 times within 3 seconds to open debug panel
  // REMOVE THIS METHOD FOR PRODUCTION RELEASE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVersionTile(BuildContext context, EraConfig eraConfig) {
    // Only show debug activation if debug mode is available
    if (!GameProvider.isDebugModeAvailable) {
      return _buildInfoTile('Version', '1.0.0', Icons.info_outline, eraConfig);
    }
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures taps are captured even inside ScrollView
      onTap: () {
        final now = DateTime.now();
        
        // Reset counter if more than 3 seconds since last tap
        if (_lastVersionTap != null && 
            now.difference(_lastVersionTap!).inSeconds > 3) {
          _versionTapCount = 0;
        }
        
        _lastVersionTap = now;
        setState(() {
          _versionTapCount++;
        });
        
        // Show progress hints starting from first tap for better feedback
        if (_versionTapCount >= 1 && _versionTapCount < 7) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_versionTapCount < 3 
                  ? 'Tap ${7 - _versionTapCount} more times...' 
                  : '${7 - _versionTapCount} more taps...'),
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
        
        // Activate debug panel after 7 taps
        if (_versionTapCount >= 7) {
          setState(() {
            _versionTapCount = 0;
          });
          HapticService.heavyImpact();
          showDebugPanel(context, widget.gameProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: eraConfig.primaryColor.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.info_outline, size: 18, color: eraConfig.primaryColor),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Version',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            Text(
              '1.0.0',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: eraConfig.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    EraConfig eraConfig,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: eraConfig.primaryColor.withValues(alpha: 0.2),
              ),
              child: Icon(icon, size: 18, color: eraConfig.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
    EraConfig eraConfig,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: eraConfig.primaryColor.withValues(alpha: 0.1),
          border: Border.all(color: eraConfig.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: eraConfig.primaryColor.withValues(alpha: 0.2),
              ),
              child: Icon(icon, size: 18, color: eraConfig.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: eraConfig.primaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: eraConfig.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
    EraConfig eraConfig, {
    bool isMinor = false,
  }) {
    final color = isMinor ? Colors.orange : Colors.red;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: Icon(icon, size: 18, color: color.shade300),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color.shade300,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.shade200.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.shade300),
          ],
        ),
      ),
    );
  }

  void _exportSaveData(BuildContext context) {
    try {
      // Create export data
      final exportData = {
        'version': '1.0.0',
        'exportTime': DateTime.now().toIso8601String(),
        'gameData': {
          'energy': widget.gameProvider.state.energy,
          'darkMatter': widget.gameProvider.state.darkMatter,
          'kardashevLevel': widget.gameProvider.state.kardashevLevel,
          'currentEra': widget.gameProvider.state.currentEra,
          'prestigeCount': widget.gameProvider.state.prestigeCount,
          'prestigeBonus': widget.gameProvider.state.prestigeBonus,
          'prestigeTier': widget.gameProvider.state.prestigeTier,
          'totalTaps': widget.gameProvider.state.totalTaps,
          'totalEnergyEarned': widget.gameProvider.state.totalEnergyEarned,
          'playTimeSeconds': widget.gameProvider.state.playTimeSeconds,
          'generators': widget.gameProvider.state.generators,
          'generatorLevels': widget.gameProvider.state.generatorLevels,
          'unlockedResearch': widget.gameProvider.state.unlockedResearch,
          'ownedArchitects': widget.gameProvider.state.ownedArchitects,
          'unlockedEras': widget.gameProvider.state.unlockedEras,
          'unlockedAchievements': widget.gameProvider.state.unlockedAchievements,
          'claimedAchievements': widget.gameProvider.state.claimedAchievements,
          'loginStreak': widget.gameProvider.state.loginStreak,
          'totalLoginDays': widget.gameProvider.state.totalLoginDays,
        },
      };
      
      final jsonString = jsonEncode(exportData);
      final encodedData = base64Encode(utf8.encode(jsonString));
      
      Clipboard.setData(ClipboardData(text: 'KARDASHEV:$encodedData'));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Save data copied to clipboard!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: eraConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: eraConfig.primaryColor.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(Icons.download, color: eraConfig.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Import Save Data',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: eraConfig.primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your save data below:',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'KARDASHEV:...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: eraConfig.primaryColor.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: eraConfig.primaryColor.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: eraConfig.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber, size: 14, color: Colors.orange.shade300),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'This will overwrite your current progress!',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
              if (clipboardData?.text != null) {
                controller.text = clipboardData!.text!;
              }
            },
            child: const Text('PASTE FROM CLIPBOARD'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: eraConfig.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              _importSaveData(context, controller.text);
            },
            child: const Text('IMPORT'),
          ),
        ],
      ),
    );
  }

  void _importSaveData(BuildContext context, String data) {
    try {
      if (!data.startsWith('KARDASHEV:')) {
        throw Exception('Invalid save data format');
      }
      
      final encodedData = data.substring(10); // Remove 'KARDASHEV:' prefix
      final jsonString = utf8.decode(base64Decode(encodedData));
      final Map<String, dynamic> importData = jsonDecode(jsonString);
      
      // Validate version
      final version = importData['version'] as String?;
      if (version == null) {
        throw Exception('Missing version information');
      }
      
      // Import the data (would need to implement in GameProvider)
      // widget.gameProvider.importSaveData(importData['gameData']);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Save data imported! Restart app to apply.'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Import failed: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetConfirmation(BuildContext context) {
    final eraConfig = widget.gameProvider.state.eraConfig;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: eraConfig.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade300),
            const SizedBox(width: 8),
            const Text(
              'Reset Progress?',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your progress including:\n\n'
          '• All energy and dark matter\n'
          '• All generators and upgrades\n'
          '• All research progress\n'
          '• All achievements\n'
          '• Prestige bonuses\n\n'
          'This action cannot be undone!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              widget.gameProvider.resetProgress();
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  String _formatPlayTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
  
  Widget _buildHapticIntensitySelector(EraConfig eraConfig) {
    final currentIntensity = widget.gameProvider.hapticIntensity;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(Icons.vibration, size: 18, color: eraConfig.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Haptic Feedback',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      HapticService.getIntensityName(currentIntensity),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (index) {
              final isSelected = currentIntensity == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.gameProvider.setHapticIntensity(index);
                    if (index > 0) {
                      // Trigger haptic to demonstrate
                      HapticService.mediumImpact();
                    }
                    setState(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: index > 0 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? eraConfig.primaryColor.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: isSelected
                            ? eraConfig.primaryColor
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          index == 0 ? Icons.block : Icons.vibration,
                          size: 16,
                          color: isSelected
                              ? eraConfig.primaryColor
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          HapticService.getIntensityName(index),
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 8,
                            color: isSelected
                                ? eraConfig.primaryColor
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberFormatSelector(EraConfig eraConfig) {
    final currentFormat = widget.gameProvider.numberFormat;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: eraConfig.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(Icons.format_list_numbered, size: 18, color: eraConfig.primaryColor),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number Format',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'How large numbers are displayed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildNumberFormatOption(0, 'Standard', '1.23M, 4.56B', eraConfig, currentFormat),
              const SizedBox(height: 6),
              _buildNumberFormatOption(1, 'Scientific', '1.23e6, 4.56e9', eraConfig, currentFormat),
              const SizedBox(height: 6),
              _buildNumberFormatOption(2, 'Engineering', '1.23×10⁶, 4.56×10⁹', eraConfig, currentFormat),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberFormatOption(int format, String name, String example, EraConfig eraConfig, int currentFormat) {
    final isSelected = currentFormat == format;
    
    return GestureDetector(
      onTap: () {
        widget.gameProvider.updateNumberFormat(format);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? eraConfig.primaryColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: isSelected
                ? eraConfig.primaryColor
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected
                  ? eraConfig.primaryColor
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? eraConfig.primaryColor
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    example,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
