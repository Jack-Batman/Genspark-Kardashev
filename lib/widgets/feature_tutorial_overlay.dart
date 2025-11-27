import 'package:flutter/material.dart';
import '../models/tutorial_state.dart';
import '../core/era_data.dart';

/// Feature-specific tutorial overlay for new features
class FeatureTutorialOverlay extends StatefulWidget {
  final TutorialTopic topic;
  final List<InteractiveTutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final EraConfig eraConfig;
  final String? actionCompleted; // Set when user completes the required action

  const FeatureTutorialOverlay({
    super.key,
    required this.topic,
    required this.steps,
    required this.onComplete,
    this.onSkip,
    required this.eraConfig,
    this.actionCompleted,
  });

  @override
  State<FeatureTutorialOverlay> createState() => _FeatureTutorialOverlayState();
}

class _FeatureTutorialOverlayState extends State<FeatureTutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FeatureTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if action was completed
    if (widget.actionCompleted != null && 
        widget.steps[_currentStep].actionRequired == widget.actionCompleted) {
      _nextStep();
    }
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
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
    widget.onSkip?.call();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final progress = (_currentStep + 1) / widget.steps.length;
    final hasAction = step.actionRequired != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.9),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                // Header with topic and skip
                _buildHeader(),

                const Spacer(flex: 1),

                // Main tutorial content
                _buildContent(step, hasAction),

                const Spacer(flex: 1),

                // Progress indicators
                _buildProgressIndicators(progress),

                // Navigation buttons
                _buildNavigationButtons(step, hasAction),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Topic badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  widget.eraConfig.primaryColor.withValues(alpha: 0.3),
                  widget.eraConfig.accentColor.withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: widget.eraConfig.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school,
                  size: 16,
                  color: widget.eraConfig.accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  getTutorialTopicName(widget.topic).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.eraConfig.accentColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Skip button
          GestureDetector(
            onTap: _skipTutorial,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Text(
                'SKIP',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(InteractiveTutorialStep step, bool hasAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon with glow
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.eraConfig.primaryColor.withValues(alpha: 0.3 * value),
                        widget.eraConfig.primaryColor.withValues(alpha: 0.1 * value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    step.icon,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Title with animated underline
          Column(
            children: [
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.eraConfig.accentColor,
                ),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Container(
                    width: 80 * value,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          widget.eraConfig.primaryColor,
                          widget.eraConfig.accentColor,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),

          // Action hint
          if (hasAction) ...[
            const SizedBox(height: 24),
            _buildActionHint(step),
          ],

          // Highlight hint
          if (step.highlightWidget != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.eraConfig.primaryColor.withValues(alpha: 0.2),
                border: Border.all(
                  color: widget.eraConfig.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: widget.eraConfig.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Look for this in the interface',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionHint(InteractiveTutorialStep step) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        final pulse = (1 + 0.1 * (value < 0.5 ? value * 2 : (1 - value) * 2));
        return Transform.scale(
          scale: pulse,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              widget.eraConfig.primaryColor.withValues(alpha: 0.3),
              widget.eraConfig.accentColor.withValues(alpha: 0.3),
            ],
          ),
          border: Border.all(
            color: widget.eraConfig.accentColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.eraConfig.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: widget.eraConfig.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Try it now!',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: widget.eraConfig.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: Column(
        children: [
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.steps.length,
              (index) => TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: index == _currentStep ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    width: index == _currentStep ? 24 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: index == _currentStep
                          ? widget.eraConfig.accentColor
                          : index < _currentStep
                              ? widget.eraConfig.primaryColor
                              : Colors.white.withValues(alpha: 0.2),
                      boxShadow: index == _currentStep
                          ? [
                              BoxShadow(
                                color: widget.eraConfig.accentColor
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(widget.eraConfig.primaryColor),
              minHeight: 4,
            ),
          ),

          const SizedBox(height: 8),

          // Step counter
          Text(
            'Step ${_currentStep + 1} of ${widget.steps.length}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(InteractiveTutorialStep step, bool hasAction) {
    final isLastStep = _currentStep == widget.steps.length - 1;
    final canProceed = !hasAction || step.canSkip;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.eraConfig.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: widget.eraConfig.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'BACK',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.eraConfig.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Next/Done button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: canProceed ? _nextStep : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: canProceed
                      ? LinearGradient(
                          colors: [
                            widget.eraConfig.primaryColor,
                            widget.eraConfig.accentColor,
                          ],
                        )
                      : null,
                  color: canProceed ? null : Colors.grey.withValues(alpha: 0.3),
                  boxShadow: canProceed
                      ? [
                          BoxShadow(
                            color: widget.eraConfig.primaryColor
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLastStep ? 'GOT IT!' : (hasAction && !step.canSkip ? 'WAITING...' : 'NEXT'),
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: canProceed
                              ? Colors.black
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      if (!isLastStep && canProceed) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                      if (isLastStep) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.black,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact tutorial hint tooltip for contextual help
class TutorialHintTooltip extends StatefulWidget {
  final TutorialHint hint;
  final VoidCallback onDismiss;
  final EraConfig eraConfig;

  const TutorialHintTooltip({
    super.key,
    required this.hint,
    required this.onDismiss,
    required this.eraConfig,
  });

  @override
  State<TutorialHintTooltip> createState() => _TutorialHintTooltipState();
}

class _TutorialHintTooltipState extends State<TutorialHintTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withValues(alpha: 0.95),
          border: Border.all(
            color: widget.eraConfig.primaryColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.eraConfig.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  widget.hint.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.hint.title,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.eraConfig.accentColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              widget.hint.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Dismiss button
            GestureDetector(
              onTap: _dismiss,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      widget.eraConfig.primaryColor,
                      widget.eraConfig.accentColor,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'GOT IT',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tutorial badge that shows "NEW" or "?" for features with tutorials
class TutorialBadge extends StatelessWidget {
  final bool showNew;
  final bool showHelp;
  final VoidCallback? onTap;
  final EraConfig eraConfig;

  const TutorialBadge({
    super.key,
    this.showNew = false,
    this.showHelp = false,
    this.onTap,
    required this.eraConfig,
  });

  @override
  Widget build(BuildContext context) {
    if (!showNew && !showHelp) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: showNew
              ? LinearGradient(
                  colors: [
                    eraConfig.primaryColor,
                    eraConfig.accentColor,
                  ],
                )
              : null,
          color: showNew ? null : Colors.white.withValues(alpha: 0.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showNew)
              Text(
                'NEW',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            else
              Icon(
                Icons.help_outline,
                size: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
