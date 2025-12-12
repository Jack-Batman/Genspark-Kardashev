import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants.dart';
import '../providers/game_provider.dart';

/// AI Nexus indicator widget - shows when the player owns the AI Nexus
/// Displays a stylish animated indicator showing 2x production bonus
class AINexusIndicator extends StatefulWidget {
  final bool isOwned;
  final VoidCallback? onTap;
  
  const AINexusIndicator({
    super.key,
    required this.isOwned,
    this.onTap,
  });
  
  @override
  State<AINexusIndicator> createState() => _AINexusIndicatorState();
}

class _AINexusIndicatorState extends State<AINexusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isOwned) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.3 * _pulseAnimation.value),
                  const Color(0xFF7C4DFF).withValues(alpha: 0.3 * _pulseAnimation.value),
                ],
              ),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFF00E5FF),
                  const Color(0xFF7C4DFF),
                  (math.sin(_controller.value * math.pi * 2) + 1) / 2,
                )!.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3 * _pulseAnimation.value),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated AI Icon
                Transform.rotate(
                  angle: _rotationAnimation.value * 0.1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.memory,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // 2X Text with glow
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                  ).createShader(bounds),
                  child: const Text(
                    '2X',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Compact AI Nexus badge for header display
class AINexusBadge extends StatefulWidget {
  final bool isOwned;
  
  const AINexusBadge({
    super.key,
    required this.isOwned,
  });
  
  @override
  State<AINexusBadge> createState() => _AINexusBadgeState();
}

class _AINexusBadgeState extends State<AINexusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isOwned) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_controller.value * 0.4);
        return Tooltip(
          message: 'AI Nexus Active\n2x Energy Production',
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: glowIntensity),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.memory,
              size: 16,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// AI Nexus purchase card for the store
class AINexusPurchaseCard extends StatefulWidget {
  final GameProvider gameProvider;
  final VoidCallback onPurchase;
  final bool isPurchasing;
  
  const AINexusPurchaseCard({
    super.key,
    required this.gameProvider,
    required this.onPurchase,
    required this.isPurchasing,
  });
  
  @override
  State<AINexusPurchaseCard> createState() => _AINexusPurchaseCardState();
}

class _AINexusPurchaseCardState extends State<AINexusPurchaseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isOwned = widget.gameProvider.state.hasAINexus;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isOwned
                  ? [
                      const Color(0xFF1B5E20).withValues(alpha: 0.3),
                      const Color(0xFF2E7D32).withValues(alpha: 0.2),
                    ]
                  : [
                      const Color(0xFF0D47A1).withValues(alpha: 0.3),
                      const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    ],
            ),
            border: Border.all(
              color: isOwned
                  ? AppColors.success.withValues(alpha: 0.5)
                  : Color.lerp(
                      const Color(0xFF00E5FF),
                      const Color(0xFF7C4DFF),
                      (math.sin(_controller.value * math.pi * 2) + 1) / 2,
                    )!.withValues(alpha: 0.7),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isOwned
                    ? AppColors.success.withValues(alpha: 0.2)
                    : const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with AI Icon and Badge
                Row(
                  children: [
                    // Animated AI Icon Container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isOwned
                              ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
                              : [const Color(0xFF00E5FF), const Color(0xFF7C4DFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isOwned ? AppColors.success : const Color(0xFF00E5FF))
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circuit pattern background
                          CustomPaint(
                            size: const Size(56, 56),
                            painter: _CircuitPatternPainter(
                              color: Colors.white.withValues(alpha: 0.2),
                              progress: _controller.value,
                            ),
                          ),
                          Icon(
                            isOwned ? Icons.check_circle : Icons.memory,
                            size: 32,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: isOwned
                                      ? [AppColors.success, AppColors.success]
                                      : [const Color(0xFF00E5FF), const Color(0xFF7C4DFF)],
                                ).createShader(bounds),
                                child: Text(
                                  'AI NEXUS',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!isOwned)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Text(
                                    'BEST',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFD700),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              if (isOwned)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.success.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Text(
                                    'OWNED',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOwned
                                ? 'AI-powered production boost active!'
                                : 'Quantum AI System',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Benefits list
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBenefitRow(
                        Icons.bolt,
                        '2X Energy Production',
                        'Doubles ALL energy output permanently',
                        const Color(0xFF00E5FF),
                      ),
                      const SizedBox(height: 8),
                      _buildBenefitRow(
                        Icons.all_inclusive,
                        'Works in Every Era',
                        'Active from Era I through Era IV',
                        const Color(0xFF7C4DFF),
                      ),
                      const SizedBox(height: 8),
                      _buildBenefitRow(
                        Icons.auto_awesome,
                        'Permanent Upgrade',
                        'One-time purchase, forever boost',
                        const Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Purchase button or status
                if (!isOwned)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.isPurchasing ? null : widget.onPurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.isPurchasing)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else ...[
                                const Icon(Icons.shopping_cart, size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text(
                                  'UNLOCK FOR \$17.99',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // Owned status with production info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI NEXUS ACTIVE',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBenefitRow(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for circuit pattern animation
class _CircuitPatternPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  _CircuitPatternPainter({required this.color, required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;
    
    // Draw rotating circuit lines
    for (int i = 0; i < 4; i++) {
      final angle = (progress * math.pi * 2) + (i * math.pi / 2);
      final startX = center.dx + math.cos(angle) * radius * 0.5;
      final startY = center.dy + math.sin(angle) * radius * 0.5;
      final endX = center.dx + math.cos(angle) * radius;
      final endY = center.dy + math.sin(angle) * radius;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
      
      // Draw dots at endpoints
      canvas.drawCircle(Offset(endX, endY), 2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }
  
  @override
  bool shouldRepaint(covariant _CircuitPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
