import 'package:flutter/material.dart';
import '../core/era_data.dart';

/// Tutorial step data
class TutorialStep {
  final String title;
  final String description;
  final String icon;
  final String? highlightArea; // 'top', 'bottom', 'center', 'build', 'research', etc.

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.highlightArea,
  });
}

/// Tutorial steps for new players
const List<TutorialStep> tutorialSteps = [
  TutorialStep(
    title: 'Welcome, Commander!',
    description: 'You are tasked with guiding civilization from a planetary species to a Type IV Universal civilization on the Kardashev Scale.',
    icon: '🚀',
  ),
  TutorialStep(
    title: 'Energy Production',
    description: 'Build generators to produce energy automatically. Start with Wind Turbines and unlock more powerful generators as you progress.',
    icon: '⚡',
    highlightArea: 'build',
  ),
  TutorialStep(
    title: 'Tap for Energy',
    description: 'Tap the planet to manually generate energy. This is useful in the early game!',
    icon: '👆',
    highlightArea: 'center',
  ),
  TutorialStep(
    title: 'Research Technology',
    description: 'Invest energy into research to unlock powerful bonuses and new capabilities.',
    icon: '🔬',
    highlightArea: 'research',
  ),
  TutorialStep(
    title: 'Kardashev Scale',
    description: 'Your Kardashev level shows your civilization\'s progress. Reach Type I (K1.0) to unlock the Stellar Era!',
    icon: '📊',
    highlightArea: 'top',
  ),
  TutorialStep(
    title: 'Dark Matter & Architects',
    description: 'Earn Dark Matter through prestige. Use it to synthesize Architects who provide permanent production bonuses.',
    icon: '🌑',
    highlightArea: 'architects',
  ),
  TutorialStep(
    title: 'Prestige System',
    description: 'When you reach K0.3+, you can prestige to reset progress but gain permanent bonuses and Dark Matter!',
    icon: '✨',
    highlightArea: 'stats',
  ),
  TutorialStep(
    title: 'Ready to Begin!',
    description: 'Build your first generator and start your journey to becoming a Type IV civilization!',
    icon: '🎮',
  ),
];

/// Tutorial overlay widget
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final EraConfig eraConfig;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    required this.eraConfig,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> 
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < tutorialSteps.length - 1) {
      _animationController.reset();
      setState(() {
        _currentStep++;
      });
      _animationController.forward();
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animationController.reset();
      setState(() {
        _currentStep--;
      });
      _animationController.forward();
    }
  }

  void _skipTutorial() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = tutorialSteps[_currentStep];
    final progress = (_currentStep + 1) / tutorialSteps.length;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _skipTutorial,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Text(
                      step.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.eraConfig.accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Progress dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    tutorialSteps.length,
                    (index) => Container(
                      width: index == _currentStep ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: index == _currentStep
                            ? widget.eraConfig.accentColor
                            : index < _currentStep
                                ? widget.eraConfig.primaryColor
                                : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),

              // Progress bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(widget.eraConfig.primaryColor),
                    minHeight: 4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Row(
                  children: [
                    // Back button
                    if (_currentStep > 0)
                      Expanded(
                        child: GestureDetector(
                          onTap: _previousStep,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.eraConfig.primaryColor
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'BACK',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: widget.eraConfig.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    if (_currentStep > 0) const SizedBox(width: 16),

                    // Next/Start button
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _nextStep,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                widget.eraConfig.primaryColor,
                                widget.eraConfig.accentColor,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.eraConfig.primaryColor
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _currentStep == tutorialSteps.length - 1
                                  ? 'START PLAYING'
                                  : 'NEXT',
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
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
    );
  }
}
