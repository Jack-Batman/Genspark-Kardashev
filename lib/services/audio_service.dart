import 'package:flutter/foundation.dart';

/// Era-specific music themes
enum MusicTheme {
  planetary,   // Era I - Ambient, hopeful
  stellar,     // Era II - Energetic, building momentum
  galactic,    // Era III - Epic, cosmic
  universal,   // Era IV - Transcendent, ethereal
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
/// Note: This is an expanded stub for web preview compatibility
/// For full audio, integrate audioplayers or flutter_soloud package
class AudioService {
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
  
  // ═══════════════════════════════════════════════════════════════
  // VOLUME CONTROLS
  // ═══════════════════════════════════════════════════════════════
  
  /// Get master volume (0.0 - 1.0)
  static double get masterVolume => _masterVolume;
  
  /// Set master volume
  static void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _logAudio('Master volume: ${(_masterVolume * 100).toInt()}%');
  }
  
  /// Get music volume (0.0 - 1.0)
  static double get musicVolume => _musicVolume;
  
  /// Set music volume
  static void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _logAudio('Music volume: ${(_musicVolume * 100).toInt()}%');
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
    _logAudio('Ambient volume: ${(_ambientVolume * 100).toInt()}%');
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
  static void _crossfadeToMusic(MusicTheme theme) {
    if (_isFading) return;
    _isFading = true;
    
    final oldTheme = _currentMusic;
    _currentMusic = theme;
    
    // Simulated crossfade (placeholder for actual implementation)
    _logAudio('🎵 Crossfading music: ${oldTheme?.name ?? "none"} → ${theme.name}');
    
    // In a real implementation:
    // 1. Fade out current track over 1-2 seconds
    // 2. Start new track at low volume
    // 3. Fade in new track
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _isFading = false;
    });
  }
  
  /// Stop all music
  static void stopMusic() {
    if (_currentMusic != null) {
      _logAudio('🎵 Music stopped');
      _currentMusic = null;
    }
  }
  
  /// Pause music (e.g., when app backgrounded)
  static void pauseMusic() {
    _logAudio('🎵 Music paused');
  }
  
  /// Resume music
  static void resumeMusic() {
    if (_musicEnabled && _currentMusic != null) {
      _logAudio('🎵 Music resumed');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // SOUND EFFECTS
  // ═══════════════════════════════════════════════════════════════
  
  // UI Sounds
  
  /// Play button click sound
  static void playClick() {
    _playSfx('click', SoundCategory.ui);
  }
  
  /// Play tab switch sound
  static void playTabSwitch() {
    _playSfx('tab_switch', SoundCategory.ui);
  }
  
  /// Play modal open sound
  static void playModalOpen() {
    _playSfx('modal_open', SoundCategory.ui);
  }
  
  /// Play modal close sound
  static void playModalClose() {
    _playSfx('modal_close', SoundCategory.ui);
  }
  
  // Action Sounds
  
  /// Play tap/collect energy sound
  static void playTap() {
    _playSfx('tap', SoundCategory.action);
  }
  
  /// Play purchase/build sound
  static void playPurchase() {
    _playSfx('purchase', SoundCategory.action);
  }
  
  /// Play generator upgrade sound
  static void playUpgrade() {
    _playSfx('upgrade', SoundCategory.action);
  }
  
  /// Play research start sound
  static void playResearchStart() {
    _playSfx('research_start', SoundCategory.action);
  }
  
  /// Play expedition launch sound
  static void playExpeditionLaunch() {
    _playSfx('expedition_launch', SoundCategory.action);
  }
  
  /// Play ability activation sound
  static void playAbilityActivate() {
    _playSfx('ability_activate', SoundCategory.action);
  }
  
  // Reward Sounds
  
  /// Play achievement unlock sound
  static void playAchievement() {
    _playSfx('achievement', SoundCategory.reward);
  }
  
  /// Play research complete sound
  static void playResearchComplete() {
    _playSfx('research_complete', SoundCategory.reward);
  }
  
  /// Play expedition complete sound
  static void playExpeditionComplete() {
    _playSfx('expedition_complete', SoundCategory.reward);
  }
  
  /// Play expedition failed sound
  static void playExpeditionFailed() {
    _playSfx('expedition_failed', SoundCategory.reward);
  }
  
  /// Play challenge complete sound
  static void playChallengeComplete() {
    _playSfx('challenge_complete', SoundCategory.reward);
  }
  
  /// Play daily reward sound
  static void playDailyReward() {
    _playSfx('daily_reward', SoundCategory.reward);
  }
  
  /// Play architect synthesize sound
  static void playArchitectSynthesize() {
    _playSfx('architect_synthesize', SoundCategory.reward);
  }
  
  /// Play level up sound
  static void playLevelUp() {
    _playSfx('level_up', SoundCategory.reward);
  }
  
  // Milestone Sounds
  
  /// Play prestige sound
  static void playPrestige() {
    _playSfx('prestige', SoundCategory.milestone);
  }
  
  /// Play era transition sound
  static void playEraTransition() {
    _playSfx('era_transition', SoundCategory.milestone);
  }
  
  /// Play milestone reached sound
  static void playMilestone() {
    _playSfx('milestone', SoundCategory.milestone);
  }
  
  /// Play Kardashev level up sound
  static void playKardashevUp() {
    _playSfx('kardashev_up', SoundCategory.milestone);
  }
  
  // Error/Info Sounds
  
  /// Play error/invalid action sound
  static void playError() {
    _playSfx('error', SoundCategory.ui);
  }
  
  /// Play notification sound
  static void playNotification() {
    _playSfx('notification', SoundCategory.ui);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // AMBIENT SOUNDS
  // ═══════════════════════════════════════════════════════════════
  
  /// Play ambient sound loop for current era
  static void playEraAmbient(int eraIndex) {
    if (_masterVolume == 0 || _ambientVolume == 0) return;
    
    final ambientName = switch (eraIndex) {
      0 => 'ambient_planetary', // Wind, nature sounds
      1 => 'ambient_stellar',   // Energy hum, solar winds
      2 => 'ambient_galactic',  // Space sounds, cosmic
      3 => 'ambient_universal', // Ethereal, transcendent
      _ => 'ambient_planetary',
    };
    
    _logAudio('🌌 Ambient: $ambientName (volume: ${(_ambientVolume * _masterVolume * 100).toInt()}%)');
  }
  
  /// Stop ambient sounds
  static void stopAmbient() {
    _logAudio('🌌 Ambient stopped');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // INTERNAL HELPERS
  // ═══════════════════════════════════════════════════════════════
  
  /// Play a sound effect
  static void _playSfx(String soundName, SoundCategory category) {
    if (!_sfxEnabled || _masterVolume == 0 || _sfxVolume == 0) return;
    
    final effectiveVolume = _masterVolume * _sfxVolume;
    _logAudio('🔊 SFX: $soundName [${category.name}] (vol: ${(effectiveVolume * 100).toInt()}%)');
  }
  
  /// Log audio event for debugging
  static void _logAudio(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════
  
  /// Initialize audio service
  static Future<void> initialize() async {
    _logAudio('AudioService initialized');
    // In a real implementation:
    // 1. Load audio assets
    // 2. Initialize audio pools for frequently used sounds
    // 3. Pre-cache music tracks
  }
  
  /// Dispose audio resources
  static void dispose() {
    stopMusic();
    stopAmbient();
    _logAudio('AudioService disposed');
  }
  
  /// Handle app lifecycle changes
  static void onAppLifecycleStateChange(bool isActive) {
    if (isActive) {
      resumeMusic();
    } else {
      pauseMusic();
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // MUSIC TRACK INFO (for future implementation)
  // ═══════════════════════════════════════════════════════════════
  
  /// Get music track file path for theme
  static String getMusicTrackPath(MusicTheme theme) {
    return switch (theme) {
      MusicTheme.planetary => 'assets/audio/music/planetary_theme.mp3',
      MusicTheme.stellar => 'assets/audio/music/stellar_theme.mp3',
      MusicTheme.galactic => 'assets/audio/music/galactic_theme.mp3',
      MusicTheme.universal => 'assets/audio/music/universal_theme.mp3',
      MusicTheme.menu => 'assets/audio/music/menu_theme.mp3',
    };
  }
  
  /// Get music theme display name
  static String getMusicThemeName(MusicTheme theme) {
    return switch (theme) {
      MusicTheme.planetary => 'Planetary Origins',
      MusicTheme.stellar => 'Stellar Ascension',
      MusicTheme.galactic => 'Galactic Empire',
      MusicTheme.universal => 'Universal Transcendence',
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
