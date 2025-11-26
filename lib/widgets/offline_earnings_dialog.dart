import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import 'glass_container.dart';

/// Offline Earnings Collection Dialog
class OfflineEarningsDialog extends StatefulWidget {
  final double earnings;
  final VoidCallback onCollect;
  final VoidCallback onDismiss;
  
  const OfflineEarningsDialog({
    super.key,
    required this.earnings,
    required this.onCollect,
    required this.onDismiss,
  });
  
  @override
  State<OfflineEarningsDialog> createState() => _OfflineEarningsDialogState();
}

class _OfflineEarningsDialogState extends State<OfflineEarningsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              borderColor: AppColors.goldAccent.withValues(alpha: 0.6),
              showGlow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldLight.withValues(alpha: _glowAnimation.value),
                          AppColors.goldAccent.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      size: 48,
                      color: AppColors.goldLight,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 3,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Your civilization continued while you were away',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Earnings display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.goldAccent.withValues(alpha: 0.4),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.goldAccent.withValues(alpha: 0.2),
                          AppColors.goldAccent.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'OFFLINE ENTROPY',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: AppColors.goldLight,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${GameProvider.formatNumber(widget.earnings)}',
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Collect button
                  GlassButton(
                    text: 'COLLECT',
                    icon: Icons.download,
                    accentColor: AppColors.goldAccent,
                    width: double.infinity,
                    onPressed: widget.onCollect,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Watch ad for bonus (placeholder)
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement ad watching for 2x bonus
                      widget.onCollect();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Watch ad for 2x bonus',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Show the offline earnings dialog
void showOfflineEarningsDialog(
  BuildContext context, {
  required double earnings,
  required VoidCallback onCollect,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (context) => OfflineEarningsDialog(
      earnings: earnings,
      onCollect: () {
        Navigator.of(context).pop();
        onCollect();
      },
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
