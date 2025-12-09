import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Era-specific music themes
enum MusicTheme {
  planetary,   // Era I - Ambient, hopeful
  stellar,     // Era II - Energetic, building momentum
  galactic,    // Era III - Epic, cosmic
  universal,   // Era IV - Transcendent, ethereal
  multiversal, // Era V - Void, prismatic
  menu,        // Main menu music
}

/// Sound effect categories
enum SoundCategory {
  ui,          // UI clicks, buttons
  action,      // Taps, purchases
  reward,      // Achievements, rewards
  milestone,   // Prestige, era transitions
  ambient,     // Background ambiance
}

/// Enhanced audio service for game sounds with era-based music
/// Implements actual audio playback using audioplayers package
class AudioService {
  // Audio players
  static AudioPlayer? _musicPlayer;
  static AudioPlayer? _ambientPlayer;
  static final Map<String, AudioPlayer> _sfxPlayers = {};
  
  // Volume controls (0.0 - 1.0)
  static double _masterVolume = 1.0;
  static double _musicVolume = 0.7;
  static double _sfxVolume = 1.0;
  static double _ambientVolume = 0.5;
  
  // State tracking
  static bool _musicEnabled = true;
  static bool _sfxEnabled = true;
  static MusicTheme? _currentMusic;
  static bool _isFading = false;
  static bool _isInitialized = false;
  
  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════
  
  /// Initialize audio service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Create music player with looping
      _musicPlayer = AudioPlayer();
      _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      
      // Create ambient player with looping
      _ambientPlayer = AudioPlayer();
      _ambientPlayer!.setReleaseMode(ReleaseMode.loop);
      
      _isInitialized = true;
      _logAudio('AudioService initialized successfully');
    } catch (e) {
      _logAudio('AudioService initialization failed: $e');
    }
  }
  
  /// Dispose audio resources
  static void dispose() {
    _musicPlayer?.dispose();
    _ambientPlayer?.dispose();
    for (final player in _sfxPlayers.values) {
      player.dispose();
    }
    _sfxPlayers.clear();
    _isInitialized = false;
    _logAudio('AudioService disposed');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // VOLUME CONTROLS
  // ═══════════════════════════════════════════════════════════════
  
  /// Get master volume (0.0 - 1.0)
  static double get masterVolume => _masterVolume;
  
  /// Set master volume
  static void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _updateMusicVolume();
    _updateAmbientVolume();
    _logAudio('Master volume: ${(_masterVolume * 100).toInt()}%');
  }
  
  /// Get music volume (0.0 - 1.0)
  static double get musicVolume => _musicVolume;
  
  /// Set music volume
  static void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _updateMusicVolume();
    _logAudio('Music volume: ${(_musicVolume * 100).toInt()}%');
  }
  
  static void _updateMusicVolume() {
    final effectiveVolume = _masterVolume * _musicVolume;
    _musicPlayer?.setVolume(effectiveVolume);
  }
  
  /// Get SFX volume (0.0 - 1.0)
  static double get sfxVolume => _sfxVolume;
  
  /// Set SFX volume
  static void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _logAudio('SFX volume: ${(_sfxVolume * 100).toInt()}%');
  }
  
  /// Get ambient volume (0.0 - 1.0)
  static double get ambientVolume => _ambientVolume;
  
  /// Set ambient volume
  static void setAmbientVolume(double volume) {
    _ambientVolume = volume.clamp(0.0, 1.0);
    _updateAmbientVolume();
    _logAudio('Ambient volume: ${(_ambientVolume * 100).toInt()}%');
  }
  
  static void _updateAmbientVolume() {
    final effectiveVolume = _masterVolume * _ambientVolume;
    _ambientPlayer?.setVolume(effectiveVolume);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ENABLE/DISABLE CONTROLS
  // ═══════════════════════════════════════════════════════════════
  
  /// Check if music is enabled
  static bool get isMusicEnabled => _musicEnabled;
  
  /// Set music enabled state
  static void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
    _logAudio('Music ${enabled ? "enabled" : "disabled"}');
  }
  
  /// Check if SFX is enabled
  static bool get isSfxEnabled => _sfxEnabled;
  
  /// Set SFX enabled state
  static void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
    _logAudio('SFX ${enabled ? "enabled" : "disabled"}');
  }
  
  /// Legacy method for backward compatibility
  static void setEnabled(bool enabled) {
    setSfxEnabled(enabled);
    setMusicEnabled(enabled);
  }
  
  /// Legacy getter for backward compatibility
  static bool get isEnabled => _sfxEnabled;
  
  // ═══════════════════════════════════════════════════════════════
  // BACKGROUND MUSIC (Per Era)
  // ═══════════════════════════════════════════════════════════════
  
  /// Get current music theme
  static MusicTheme? get currentMusic => _currentMusic;
  
  /// Play background music for era
  static void playEraMusic(int eraIndex) {
    if (!_musicEnabled) return;
    
    final theme = switch (eraIndex) {
      0 => MusicTheme.planetary,
      1 => MusicTheme.stellar,
      2 => MusicTheme.galactic,
      3 => MusicTheme.universal,
      4 => MusicTheme.multiversal,
      _ => MusicTheme.planetary,
    };
    
    if (_currentMusic == theme) return; // Already playing
    
    _crossfadeToMusic(theme);
  }
  
  /// Play specific music theme
  static void playMusic(MusicTheme theme) {
    if (!_musicEnabled) return;
    if (_currentMusic == theme) return;
    
    _crossfadeToMusic(theme);
  }
  
  /// Crossfade to new music track
  static Future<void> _crossfadeToMusic(MusicTheme theme) async {
    if (_isFading) return;
    _isFading = true;
    
    final oldTheme = _currentMusic;
    _currentMusic = theme;
    
    _logAudio('🎵 Crossfading music: ${oldTheme?.name ?? "none"} → ${theme.name}');
    
    try {
      // Stop current music
      await _musicPlayer?.stop();
      
      // Get the track path
      final trackPath = getMusicTrackPath(theme);
      
      // Set volume and play
      final effectiveVolume = _masterVolume * _musicVolume;
      await _musicPlayer?.setVolume(effectiveVolume);
      await _musicPlayer?.play(AssetSource(trackPath.replaceFirst('assets/', '')));
      
    } catch (e) {
      _logAudio('Music playback error: $e');
    }
    
    _isFading = false;
  }
  
  /// Stop all music
  static void stopMusic() {
    if (_currentMusic != null) {
      _musicPlayer?.stop();
      _logAudio('🎵 Music stopped');
      _currentMusic = null;
    }
  }
  
  /// Pause music (e.g., when app backgrounded)
  static void pauseMusic() {
    _musicPlayer?.pause();
    _logAudio('🎵 Music paused');
  }
  
  /// Resume music
  static void resumeMusic() {
    if (_musicEnabled && _currentMusic != null) {
      _musicPlayer?.resume();
      _logAudio('🎵 Music resumed');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // SOUND EFFECTS
  // ═══════════════════════════════════════════════════════════════
  
  /// Play a sound effect by asset path
  static Future<void> _playSfxAsset(String assetPath) async {
    if (!_sfxEnabled || _masterVolume == 0 || _sfxVolume == 0) return;
    
    try {
      final player = AudioPlayer();
      final effectiveVolume = _masterVolume * _sfxVolume;
      await player.setVolume(effectiveVolume);
      await player.play(AssetSource(assetPath));
      
      // Auto-dispose after playback
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
      
    } catch (e) {
      _logAudio('SFX playback error: $e');
    }
  }
  
  // UI Sounds
  
  /// Play button click sound
  static void playClick() {
    _playSfxAsset('audio/sfx/ui_click.mp3');
    _logAudio('🔊 SFX: click');
  }
  
  /// Play tab switch sound
  static void playTabSwitch() {
    _playSfxAsset('audio/sfx/ui_click.mp3');
    _logAudio('🔊 SFX: tab_switch');
  }
  
  /// Play modal open sound
  static void playModalOpen() {
    _playSfxAsset('audio/sfx/notification.mp3');
    _logAudio('🔊 SFX: modal_open');
  }
  
  /// Play modal close sound
  static void playModalClose() {
    _playSfxAsset('audio/sfx/ui_click.mp3');
    _logAudio('🔊 SFX: modal_close');
  }
  
  // Action Sounds
  
  /// Play tap/collect energy sound
  static void playTap() {
    _playSfxAsset('audio/sfx/tap_collect.mp3');
    _logAudio('🔊 SFX: tap');
  }
  
  /// Play purchase/build sound
  static void playPurchase() {
    _playSfxAsset('audio/sfx/purchase.mp3');
    _logAudio('🔊 SFX: purchase');
  }
  
  /// Play generator upgrade sound
  static void playUpgrade() {
    _playSfxAsset('audio/sfx/upgrade.mp3');
    _logAudio('🔊 SFX: upgrade');
  }
  
  /// Play research start sound
  static void playResearchStart() {
    _playSfxAsset('audio/sfx/ui_click.mp3');
    _logAudio('🔊 SFX: research_start');
  }
  
  /// Play expedition launch sound
  static void playExpeditionLaunch() {
    _playSfxAsset('audio/sfx/expedition_launch.mp3');
    _logAudio('🔊 SFX: expedition_launch');
  }
  
  /// Play ability activation sound
  static void playAbilityActivate() {
    _playSfxAsset('audio/sfx/ability_activate.mp3');
    _logAudio('🔊 SFX: ability_activate');
  }
  
  // Reward Sounds
  
  /// Play achievement unlock sound
  static void playAchievement() {
    _playSfxAsset('audio/sfx/achievement.mp3');
    _logAudio('🔊 SFX: achievement');
  }
  
  /// Play research complete sound
  static void playResearchComplete() {
    _playSfxAsset('audio/sfx/research_complete.mp3');
    _logAudio('🔊 SFX: research_complete');
  }
  
  /// Play expedition complete sound
  static void playExpeditionComplete() {
    _playSfxAsset('audio/sfx/expedition_complete.mp3');
    _logAudio('🔊 SFX: expedition_complete');
  }
  
  /// Play expedition failed sound
  static void playExpeditionFailed() {
    _playSfxAsset('audio/sfx/expedition_failed.mp3');
    _logAudio('🔊 SFX: expedition_failed');
  }
  
  /// Play challenge complete sound
  static void playChallengeComplete() {
    _playSfxAsset('audio/sfx/achievement.mp3');
    _logAudio('🔊 SFX: challenge_complete');
  }
  
  /// Play daily reward sound
  static void playDailyReward() {
    _playSfxAsset('audio/sfx/daily_reward.mp3');
    _logAudio('🔊 SFX: daily_reward');
  }
  
  /// Play architect synthesize sound
  static void playArchitectSynthesize() {
    _playSfxAsset('audio/sfx/ability_activate.mp3');
    _logAudio('🔊 SFX: architect_synthesize');
  }
  
  /// Play level up sound
  static void playLevelUp() {
    _playSfxAsset('audio/sfx/level_up.mp3');
    _logAudio('🔊 SFX: level_up');
  }
  
  // Milestone Sounds
  
  /// Play prestige sound
  static void playPrestige() {
    _playSfxAsset('audio/sfx/prestige.mp3');
    _logAudio('🔊 SFX: prestige');
  }
  
  /// Play era transition sound
  static void playEraTransition() {
    _playSfxAsset('audio/sfx/era_transition.mp3');
    _logAudio('🔊 SFX: era_transition');
  }
  
  /// Play milestone reached sound
  static void playMilestone() {
    _playSfxAsset('audio/sfx/level_up.mp3');
    _logAudio('🔊 SFX: milestone');
  }
  
  /// Play Kardashev level up sound
  static void playKardashevUp() {
    _playSfxAsset('audio/sfx/level_up.mp3');
    _logAudio('🔊 SFX: kardashev_up');
  }
  
  // Error/Info Sounds
  
  /// Play error/invalid action sound
  static void playError() {
    _playSfxAsset('audio/sfx/error.mp3');
    _logAudio('🔊 SFX: error');
  }
  
  /// Play notification sound
  static void playNotification() {
    _playSfxAsset('audio/sfx/notification.mp3');
    _logAudio('🔊 SFX: notification');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // AMBIENT SOUNDS
  // ═══════════════════════════════════════════════════════════════
  
  static int? _currentAmbientEra;
  
  /// Play ambient sound loop for current era
  static Future<void> playEraAmbient(int eraIndex) async {
    if (_masterVolume == 0 || _ambientVolume == 0) return;
    if (_currentAmbientEra == eraIndex) return; // Already playing
    
    _currentAmbientEra = eraIndex;
    
    try {
      await _ambientPlayer?.stop();
      
      final trackPath = getAmbientTrackPath(eraIndex);
      final effectiveVolume = _masterVolume * _ambientVolume;
      
      await _ambientPlayer?.setVolume(effectiveVolume);
      await _ambientPlayer?.play(AssetSource(trackPath.replaceFirst('assets/', '')));
      
      _logAudio('🌌 Ambient: era $eraIndex started');
    } catch (e) {
      _logAudio('Ambient playback error: $e');
    }
  }
  
  /// Stop ambient sounds
  static void stopAmbient() {
    _ambientPlayer?.stop();
    _currentAmbientEra = null;
    _logAudio('🌌 Ambient stopped');
  }
  
  /// Pause ambient sounds
  static void pauseAmbient() {
    _ambientPlayer?.pause();
    _logAudio('🌌 Ambient paused');
  }
  
  /// Resume ambient sounds
  static void resumeAmbient() {
    if (_currentAmbientEra != null) {
      _ambientPlayer?.resume();
      _logAudio('🌌 Ambient resumed');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // INTERNAL HELPERS
  // ═══════════════════════════════════════════════════════════════
  
  /// Log audio event for debugging
  static void _logAudio(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════
  
  /// Handle app lifecycle changes
  static void onAppLifecycleStateChange(bool isActive) {
    if (isActive) {
      resumeMusic();
      resumeAmbient();
    } else {
      pauseMusic();
      pauseAmbient();
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // MUSIC TRACK INFO
  // ═══════════════════════════════════════════════════════════════
  
  /// Get music track file path for theme
  static String getMusicTrackPath(MusicTheme theme) {
    return switch (theme) {
      MusicTheme.planetary => 'assets/audio/music/planetary_theme.mp3',
      MusicTheme.stellar => 'assets/audio/music/stellar_theme.mp3',
      MusicTheme.galactic => 'assets/audio/music/galactic_theme.mp3',
      MusicTheme.universal => 'assets/audio/music/universal_theme.mp3',
      MusicTheme.multiversal => 'assets/audio/music/multiversal_theme.mp3',
      MusicTheme.menu => 'assets/audio/music/planetary_theme.mp3', // Use planetary as menu
    };
  }
  
  /// Get music theme display name
  static String getMusicThemeName(MusicTheme theme) {
    return switch (theme) {
      MusicTheme.planetary => 'Planetary Origins',
      MusicTheme.stellar => 'Stellar Ascension',
      MusicTheme.galactic => 'Galactic Empire',
      MusicTheme.universal => 'Universal Transcendence',
      MusicTheme.multiversal => 'Void Eternal',
      MusicTheme.menu => 'Kardashev Main Theme',
    };
  }
  
  /// Get ambient track file path for era
  static String getAmbientTrackPath(int eraIndex) {
    return switch (eraIndex) {
      0 => 'assets/audio/ambient/planetary_ambient.mp3',
      1 => 'assets/audio/ambient/stellar_ambient.mp3',
      2 => 'assets/audio/ambient/galactic_ambient.mp3',
      3 => 'assets/audio/ambient/universal_ambient.mp3',
      4 => 'assets/audio/ambient/multiversal_ambient.mp3',
      _ => 'assets/audio/ambient/planetary_ambient.mp3',
    };
  }
}

/// Audio settings data class for persistence
class AudioSettings {
  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final double ambientVolume;
  final bool musicEnabled;
  final bool sfxEnabled;
  
  const AudioSettings({
    this.masterVolume = 1.0,
    this.musicVolume = 0.7,
    this.sfxVolume = 1.0,
    this.ambientVolume = 0.5,
    this.musicEnabled = true,
    this.sfxEnabled = true,
  });
  
  /// Apply settings to AudioService
  void apply() {
    AudioService.setMasterVolume(masterVolume);
    AudioService.setMusicVolume(musicVolume);
    AudioService.setSfxVolume(sfxVolume);
    AudioService.setAmbientVolume(ambientVolume);
    AudioService.setMusicEnabled(musicEnabled);
    AudioService.setSfxEnabled(sfxEnabled);
  }
  
  /// Get current settings from AudioService
  factory AudioSettings.fromCurrent() {
    return AudioSettings(
      masterVolume: AudioService.masterVolume,
      musicVolume: AudioService.musicVolume,
      sfxVolume: AudioService.sfxVolume,
      ambientVolume: AudioService.ambientVolume,
      musicEnabled: AudioService.isMusicEnabled,
      sfxEnabled: AudioService.isSfxEnabled,
    );
  }
  
  AudioSettings copyWith({
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    double? ambientVolume,
    bool? musicEnabled,
    bool? sfxEnabled,
  }) {
    return AudioSettings(
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      ambientVolume: ambientVolume ?? this.ambientVolume,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    );
  }
}
