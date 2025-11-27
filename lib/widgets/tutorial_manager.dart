import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/era_data.dart';
import '../models/tutorial_state.dart';
import 'feature_tutorial_overlay.dart';

/// Tutorial manager service for handling feature-specific tutorials
class TutorialManager extends ChangeNotifier {
  static TutorialManager? _instance;
  static TutorialManager get instance {
    _instance ??= TutorialManager._();
    return _instance!;
  }
  
  TutorialManager._();
  
  TutorialStateData _state = TutorialStateData();
  Box<TutorialStateData>? _box;
  bool _isInitialized = false;
  
  // Current active tutorial
  TutorialTopic? _activeTutorial;
  TutorialTopic? get activeTutorial => _activeTutorial;
  
  // Pending hints queue
  final List<TutorialHint> _pendingHints = [];
  TutorialHint? _currentHint;
  TutorialHint? get currentHint => _currentHint;
  
  // Getters
  TutorialStateData get state => _state;
  bool get isInitialized => _isInitialized;
  bool get hintsEnabled => _state.hintsEnabled;
  
  /// Initialize the tutorial manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(TutorialStateDataAdapter());
    }
    
    // Open box
    _box = await Hive.openBox<TutorialStateData>('tutorial_state');
    
    // Load or create state
    if (_box!.isNotEmpty) {
      _state = _box!.getAt(0) ?? TutorialStateData();
    } else {
      _state = TutorialStateData();
      await _box!.add(_state);
    }
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Save state to Hive
  Future<void> _save() async {
    if (_box != null && _box!.isNotEmpty) {
      await _box!.putAt(0, _state);
    }
  }
  
  /// Check if a tutorial should be shown
  bool shouldShowTutorial(TutorialTopic topic) {
    if (!_isInitialized) return false;
    return !_state.hasSeenTutorial(topic);
  }
  
  /// Start showing a feature tutorial
  void startTutorial(TutorialTopic topic) {
    if (_activeTutorial != null) return; // Don't interrupt active tutorial
    _activeTutorial = topic;
    notifyListeners();
  }
  
  /// Complete the current tutorial
  void completeTutorial() {
    if (_activeTutorial != null) {
      _state.markTutorialSeen(_activeTutorial!);
      _activeTutorial = null;
      _save();
      notifyListeners();
    }
  }
  
  /// Skip the current tutorial
  void skipTutorial() {
    if (_activeTutorial != null) {
      _state.markTutorialSeen(_activeTutorial!);
      _activeTutorial = null;
      _save();
      notifyListeners();
    }
  }
  
  /// Queue a hint to show
  void queueHint(TutorialHint hint) {
    if (!_state.hintsEnabled) return;
    if (_state.hasSeenHint(hint.id)) return;
    if (!_pendingHints.any((h) => h.id == hint.id)) {
      _pendingHints.add(hint);
      _showNextHint();
    }
  }
  
  void _showNextHint() {
    if (_currentHint != null) return;
    if (_pendingHints.isEmpty) return;
    if (_activeTutorial != null) return; // Don't show hints during tutorials
    
    // Throttle hints (minimum 5 seconds between hints)
    if (_state.lastHintTime != null) {
      final elapsed = DateTime.now().difference(_state.lastHintTime!);
      if (elapsed.inSeconds < 5) {
        Future.delayed(Duration(seconds: 5 - elapsed.inSeconds), _showNextHint);
        return;
      }
    }
    
    _currentHint = _pendingHints.removeAt(0);
    notifyListeners();
  }
  
  /// Dismiss the current hint
  void dismissHint() {
    if (_currentHint != null) {
      _state.markHintSeen(_currentHint!.id);
      _currentHint = null;
      _save();
      notifyListeners();
      
      // Show next hint after delay
      Future.delayed(const Duration(seconds: 2), _showNextHint);
    }
  }
  
  /// Enable or disable hints
  void setHintsEnabled(bool enabled) {
    _state.hintsEnabled = enabled;
    _save();
    notifyListeners();
  }
  
  /// Reset all tutorials
  void resetAllTutorials() {
    _state.resetAll();
    _activeTutorial = null;
    _currentHint = null;
    _pendingHints.clear();
    _save();
    notifyListeners();
  }
  
  /// Reset only feature tutorials (keep intro)
  void resetFeatureTutorials() {
    _state.resetFeatureTutorials();
    _save();
    notifyListeners();
  }
  
  /// Mark intro tutorial completed (from main game)
  void markIntroCompleted() {
    _state.introCompleted = true;
    // Mark basic topics as seen
    _state.markTutorialSeen(TutorialTopic.welcome);
    _state.markTutorialSeen(TutorialTopic.energyProduction);
    _state.markTutorialSeen(TutorialTopic.tapping);
    _state.markTutorialSeen(TutorialTopic.research);
    _state.markTutorialSeen(TutorialTopic.kardashevScale);
    _state.markTutorialSeen(TutorialTopic.darkMatter);
    _state.markTutorialSeen(TutorialTopic.prestige);
    _state.markTutorialSeen(TutorialTopic.entropy);
    _save();
    notifyListeners();
  }
  
  /// Get topics that have tutorials available
  List<TutorialTopic> getAvailableTutorials() {
    return [
      TutorialTopic.generators,
      TutorialTopic.expeditions,
      TutorialTopic.architects,
      TutorialTopic.architectAbilities,
      TutorialTopic.dailyChallenges,
      TutorialTopic.prestige,
      TutorialTopic.eraProgression,
    ];
  }
  
  /// Check if any tutorial is active
  bool get hasTutorialActive => _activeTutorial != null;
}

/// Tutorial manager widget that wraps screens
class TutorialManagerWidget extends StatefulWidget {
  final Widget child;
  final EraConfig eraConfig;

  const TutorialManagerWidget({
    super.key,
    required this.child,
    required this.eraConfig,
  });

  @override
  State<TutorialManagerWidget> createState() => _TutorialManagerWidgetState();
}

class _TutorialManagerWidgetState extends State<TutorialManagerWidget> {
  @override
  void initState() {
    super.initState();
    TutorialManager.instance.addListener(_onTutorialChange);
  }

  @override
  void dispose() {
    TutorialManager.instance.removeListener(_onTutorialChange);
    super.dispose();
  }

  void _onTutorialChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = TutorialManager.instance;
    
    return Stack(
      children: [
        // Main content
        widget.child,
        
        // Feature tutorial overlay
        if (manager.activeTutorial != null)
          Positioned.fill(
            child: FeatureTutorialOverlay(
              topic: manager.activeTutorial!,
              steps: getTutorialSteps(manager.activeTutorial!),
              eraConfig: widget.eraConfig,
              onComplete: () => manager.completeTutorial(),
              onSkip: () => manager.skipTutorial(),
            ),
          ),
        
        // Hint tooltip
        if (manager.currentHint != null)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: TutorialHintTooltip(
              hint: manager.currentHint!,
              eraConfig: widget.eraConfig,
              onDismiss: () => manager.dismissHint(),
            ),
          ),
      ],
    );
  }
}

/// Tutorial section in settings for replay
class TutorialSettingsSection extends StatelessWidget {
  final EraConfig eraConfig;
  
  const TutorialSettingsSection({
    super.key,
    required this.eraConfig,
  });
  
  @override
  Widget build(BuildContext context) {
    final manager = TutorialManager.instance;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.school, color: eraConfig.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'TUTORIALS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: eraConfig.accentColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Hints toggle
        _buildToggleRow(
          context,
          'Tutorial Hints',
          'Show contextual tips for new features',
          manager.hintsEnabled,
          (value) {
            manager.setHintsEnabled(value);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Available tutorials list
        Text(
          'Replay Tutorials',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Tutorial buttons grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: manager.getAvailableTutorials().map((topic) {
            final hasSeenIt = manager.state.hasSeenTutorial(topic);
            return _buildTutorialChip(context, topic, hasSeenIt);
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Reset buttons
        Row(
          children: [
            Expanded(
              child: _buildResetButton(
                context,
                'Reset Feature Tutorials',
                Icons.refresh,
                () {
                  manager.resetFeatureTutorials();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Feature tutorials reset'),
                      backgroundColor: eraConfig.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildToggleRow(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: eraConfig.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: eraConfig.accentColor.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return eraConfig.accentColor;
              }
              return Colors.grey;
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTutorialChip(BuildContext context, TutorialTopic topic, bool hasSeen) {
    return GestureDetector(
      onTap: () {
        TutorialManager.instance.startTutorial(topic);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: hasSeen
              ? Colors.white.withValues(alpha: 0.1)
              : eraConfig.primaryColor.withValues(alpha: 0.3),
          border: Border.all(
            color: hasSeen
                ? Colors.white.withValues(alpha: 0.2)
                : eraConfig.primaryColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasSeen) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: eraConfig.accentColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              getTutorialTopicName(topic),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: hasSeen
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.play_circle_outline,
              size: 14,
              color: hasSeen
                  ? Colors.white.withValues(alpha: 0.5)
                  : eraConfig.accentColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResetButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
