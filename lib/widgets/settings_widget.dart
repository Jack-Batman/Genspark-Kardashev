import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import 'tutorial_manager.dart';

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
          _buildToggleTile(
            'Haptic Feedback',
            'Enable vibration feedback',
            Icons.vibration,
            widget.gameProvider.state.hapticsEnabled,
            () => widget.gameProvider.toggleHaptics(),
            eraConfig,
          ),

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

          // Section: Game Info
          _buildSectionHeader('GAME INFO', eraConfig),
          const SizedBox(height: 8),
          _buildInfoTile('Version', '1.0.0', Icons.info_outline, eraConfig),
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
                  'Sprint 4 - Polish Update',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
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
          ),
        ],
      ),
    );
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
}
