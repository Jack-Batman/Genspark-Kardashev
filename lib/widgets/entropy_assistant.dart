import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'glass_container.dart';

/// ENTROPY AI Assistant Visual Widget
class EntropyAssistant extends StatefulWidget {
  final String? message;
  final VoidCallback? onTap;
  final bool isExpanded;
  
  const EntropyAssistant({
    super.key,
    this.message,
    this.onTap,
    this.isExpanded = false,
  });
  
  @override
  State<EntropyAssistant> createState() => _EntropyAssistantState();
}

class _EntropyAssistantState extends State<EntropyAssistant>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: widget.isExpanded
            ? _buildExpandedView()
            : _buildCollapsedView(),
      ),
    );
  }
  
  Widget _buildCollapsedView() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceDark,
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldAccent.withValues(alpha: 0.3 * _pulseAnimation.value),
                blurRadius: 20 * _pulseAnimation.value,
                spreadRadius: 5 * _pulseAnimation.value,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated rings
              CustomPaint(
                size: const Size(56, 56),
                painter: _EntropyRingPainter(
                  animation: _waveController,
                ),
              ),
              // Core
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldLight,
                      AppColors.goldAccent,
                      AppColors.goldDark,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Ξ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildExpandedView() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.goldAccent.withValues(alpha: 0.5),
      showGlow: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Animated icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldLight.withValues(alpha: _pulseAnimation.value),
                          AppColors.goldAccent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Ξ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ENTROPY',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldLight,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Cosmic Intelligence',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Close button
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: widget.onTap,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Message with typing animation
          _TypewriterText(
            text: widget.message ?? _getDefaultMessage(),
          ),
          
          const SizedBox(height: 12),
          
          // Hint text
          Text(
            '[ Tap to minimize ]',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDefaultMessage() {
    final messages = [
      'Commander, your civilization progresses well. Focus on fusion technology for exponential growth.',
      'The stars await. Increase orbital collectors to prepare for stellar expansion.',
      'Energy efficiency can be improved. Consider upgrading your existing generators.',
      'Dark matter reserves are low. Expeditions may yield valuable resources.',
      'Your Kardashev progression is stable. Continue building infrastructure.',
    ];
    return messages[DateTime.now().second % messages.length];
  }
}

/// Animated typing text effect
class _TypewriterText extends StatefulWidget {
  final String text;
  
  const _TypewriterText({required this.text});
  
  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayText = '';
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _startTyping();
  }
  
  @override
  void didUpdateWidget(_TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayText = '';
      _currentIndex = 0;
      _startTyping();
    }
  }
  
  void _startTyping() async {
    for (int i = 0; i < widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() {
        _currentIndex = i + 1;
        _displayText = widget.text.substring(0, _currentIndex);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    );
  }
}

/// Custom painter for animated rings around ENTROPY
class _EntropyRingPainter extends CustomPainter {
  final Animation<double> animation;
  
  _EntropyRingPainter({required this.animation}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    
    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + i / 3) % 1.0;
      final radius = maxRadius * 0.4 + (maxRadius * 0.6 * progress);
      final opacity = (1 - progress) * 0.5;
      
      final paint = Paint()
        ..color = AppColors.goldAccent.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawCircle(center, radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _EntropyRingPainter oldDelegate) => true;
}

/// Floating tips that appear contextually
class EntropyTip extends StatelessWidget {
  final String tip;
  final VoidCallback? onDismiss;
  
  const EntropyTip({
    super.key,
    required this.tip,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: AppColors.goldAccent.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldAccent.withValues(alpha: 0.3),
            ),
            child: const Center(
              child: Text(
                'Ξ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.textSecondary,
              ),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
