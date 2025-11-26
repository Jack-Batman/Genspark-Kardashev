import 'dart:math';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import '../providers/game_provider.dart';

/// Stunning Era Transition Dialog
/// Shows when player reaches a new Kardashev milestone
class EraTransitionDialog extends StatefulWidget {
  final EraTransition transition;
  final GameProvider gameProvider;
  final VoidCallback onDismiss;
  final VoidCallback onTransition;

  const EraTransitionDialog({
    super.key,
    required this.transition,
    required this.gameProvider,
    required this.onDismiss,
    required this.onTransition,
  });

  @override
  State<EraTransitionDialog> createState() => _EraTransitionDialogState();
}

class _EraTransitionDialogState extends State<EraTransitionDialog>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  final List<_TransitionParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..repeat();

    _particleController.addListener(_updateParticles);

    // Initialize particles
    _initParticles();

    _entryController.forward();
  }

  void _initParticles() {
    final toEraConfig = eraConfigs[widget.transition.toEra]!;
    for (int i = 0; i < 50; i++) {
      _particles.add(_TransitionParticle(
        position: Offset(
          _random.nextDouble() * 400 - 200,
          _random.nextDouble() * 600 - 300,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 100,
          -50 - _random.nextDouble() * 100,
        ),
        color: toEraConfig.primaryColor,
        size: 2 + _random.nextDouble() * 4,
        lifetime: 2 + _random.nextDouble() * 3,
      ));
    }
  }

  void _updateParticles() {
    final dt = 0.05;
    final toEraConfig = eraConfigs[widget.transition.toEra]!;
    
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (_particles[i].isDead) {
        _particles[i] = _TransitionParticle(
          position: Offset(
            _random.nextDouble() * 400 - 200,
            300,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 100,
            -50 - _random.nextDouble() * 100,
          ),
          color: toEraConfig.primaryColor,
          size: 2 + _random.nextDouble() * 4,
          lifetime: 2 + _random.nextDouble() * 3,
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toEraConfig = eraConfigs[widget.transition.toEra]!;
    final canAfford = widget.gameProvider.state.energy >= widget.transition.energyCost;
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.black.withValues(alpha: 0.9 * _fadeAnimation.value),
            child: Stack(
              children: [
                // Particle background
                CustomPaint(
                  size: screenSize,
                  painter: _ParticlePainter(
                    particles: _particles,
                    center: Offset(screenSize.width / 2, screenSize.height / 2),
                  ),
                ),

                // Main content
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: screenSize.width * 0.9,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Era icon with glow
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      toEraConfig.primaryColor.withValues(alpha: 0.8),
                                      toEraConfig.primaryColor.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                    stops: [0.3, 0.6 * _glowAnimation.value, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: toEraConfig.primaryColor.withValues(alpha: 0.5 * _glowAnimation.value),
                                      blurRadius: 30 * _glowAnimation.value,
                                      spreadRadius: 10 * _glowAnimation.value,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getEraIcon(widget.transition.toEra),
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Title
                          Text(
                            widget.transition.title,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: toEraConfig.primaryColor,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: toEraConfig.primaryColor.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            '${toEraConfig.name} - ${toEraConfig.subtitle}',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Description
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: toEraConfig.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              widget.transition.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Rewards
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  toEraConfig.primaryColor.withValues(alpha: 0.2),
                                  toEraConfig.secondaryColor.withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: toEraConfig.accentColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      color: toEraConfig.accentColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'REWARDS',
                                      style: TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: toEraConfig.accentColor,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...widget.transition.rewards.map((reward) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: toEraConfig.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          reward,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Cost
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: canAfford
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              border: Border.all(
                                color: canAfford
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : Colors.red.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Cost: ${GameProvider.formatNumber(widget.transition.energyCost)}',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: canAfford ? Colors.green : Colors.red,
                                  ),
                                ),
                                if (!canAfford) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(Need ${GameProvider.formatNumber(widget.transition.energyCost - widget.gameProvider.state.energy)} more)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Later button
                              TextButton(
                                onPressed: widget.onDismiss,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: Text(
                                  'LATER',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Ascend button
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    decoration: canAfford
                                        ? BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: toEraConfig.primaryColor.withValues(alpha: 0.3 * _glowAnimation.value),
                                                blurRadius: 15 * _glowAnimation.value,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          )
                                        : null,
                                    child: ElevatedButton(
                                      onPressed: canAfford ? widget.onTransition : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: canAfford
                                            ? toEraConfig.primaryColor
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.rocket_launch, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'ASCEND',
                                            style: TextStyle(
                                              fontFamily: 'Orbitron',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
}

/// Particle for transition effect
class _TransitionParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifetime;
  double age = 0;

  _TransitionParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
  });

  void update(double dt) {
    position += velocity * dt;
    age += dt;
    velocity = velocity * 0.98; // Slight slowdown
  }

  bool get isDead => age >= lifetime;
  double get alpha => (1 - (age / lifetime)).clamp(0, 1);
}

/// Particle painter
class _ParticlePainter extends CustomPainter {
  final List<_TransitionParticle> particles;
  final Offset center;

  _ParticlePainter({required this.particles, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        center + particle.position,
        particle.size * particle.alpha,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
