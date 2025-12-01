import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Glass Morphism Container Widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? borderColor;
  final double blur;
  final Color? backgroundColor;
  final bool showGlow;
  final VoidCallback? onTap;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16,
    this.borderColor,
    this.blur = 10,
    this.backgroundColor,
    this.showGlow = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.goldAccent.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.glassWhite,
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    
    return container;
  }
}

/// Glass Button with golden accent
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final IconData? icon;
  final Color? accentColor;
  final double? width;
  final bool isLoading;
  
  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.icon,
    this.accentColor,
    this.width,
    this.isLoading = false,
  });
  
  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }
  
  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }
  
  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? AppColors.goldAccent;
    final effectiveEnabled = widget.enabled && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: effectiveEnabled
                      ? accentColor.withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: effectiveEnabled
                      ? [
                          accentColor.withValues(alpha: 0.3),
                          accentColor.withValues(alpha: 0.1),
                        ]
                      : [
                          Colors.grey.withValues(alpha: 0.2),
                          Colors.grey.withValues(alpha: 0.1),
                        ],
                ),
                boxShadow: effectiveEnabled && _isPressed
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(accentColor),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: effectiveEnabled ? accentColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: effectiveEnabled ? accentColor : Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated energy counter display
class EnergyCounter extends StatelessWidget {
  final double value;
  final String label;
  final IconData icon;
  final Color color;
  
  const EnergyCounter({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.goldLight,
  });
  
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              Text(
                _formatValue(value),
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatValue(double value) {
    if (value < 1000) return value.toStringAsFixed(1);
    if (value < 999.995e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    if (value < 999.995e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value < 999.995e9) return '${(value / 1e9).toStringAsFixed(2)}B';
    if (value < 999.995e12) return '${(value / 1e12).toStringAsFixed(2)}T';
    if (value < 999.995e15) return '${(value / 1e15).toStringAsFixed(2)}Q';
    if (value < 999.995e18) return '${(value / 1e18).toStringAsFixed(2)}Qi';
    if (value < 999.995e21) return '${(value / 1e21).toStringAsFixed(2)}Sx';
    if (value < 999.995e24) return '${(value / 1e24).toStringAsFixed(2)}Sp';
    if (value < 999.995e27) return '${(value / 1e27).toStringAsFixed(2)}Oc';
    return '${(value / 1e30).toStringAsFixed(2)}No';
  }
}

/// Kardashev level progress indicator
class KardashevIndicator extends StatelessWidget {
  final double level;
  final int era;
  final dynamic eraConfig; // EraConfig from era_data.dart
  
  const KardashevIndicator({
    super.key,
    required this.level,
    required this.era,
    this.eraConfig,
  });
  
  @override
  Widget build(BuildContext context) {
    // Use era config colors if available, otherwise defaults
    final primaryColor = eraConfig?.primaryColor ?? AppColors.goldAccent;
    final accentColor = eraConfig?.accentColor ?? AppColors.goldLight;
    final subtitle = eraConfig?.subtitle ?? 'ERA ${era + 1}';
    
    // Calculate progress within current era (0.0 - 1.0)
    final eraProgress = (level - level.floor()).clamp(0.0, 1.0);
    
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderColor: primaryColor.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KARDASHEV',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            level.toStringAsFixed(3),
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: eraProgress,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
