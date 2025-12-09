import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import 'glass_container.dart';

/// Piggy Bank Widget - Shows accumulated Dark Matter that can only be collected via purchase
class PiggyBankWidget extends StatefulWidget {
  final GameProvider gameProvider;
  final VoidCallback? onBreak;

  const PiggyBankWidget({
    super.key,
    required this.gameProvider,
    this.onBreak,
  });

  @override
  State<PiggyBankWidget> createState() => _PiggyBankWidgetState();
}

class _PiggyBankWidgetState extends State<PiggyBankWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  bool _isBreaking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _showBreakDialog() {
    final balance = widget.gameProvider.piggyBankBalance;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.pink.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Text('🐷', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              'BREAK PIGGY BANK?',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                color: Colors.pink.shade200,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.3),
                    Colors.pink.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text('🌑', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    '${balance.toStringAsFixed(0)} Dark Matter',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.amber.withValues(alpha: 0.1),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber.shade300),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a one-time collection. A new piggy bank will start after.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
            ),
            onPressed: () {
              Navigator.pop(context);
              _breakPiggyBank();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, size: 16),
                SizedBox(width: 6),
                Text('BREAK IT! (\$0.99)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _breakPiggyBank() async {
    setState(() => _isBreaking = true);
    
    // Shake animation
    for (int i = 0; i < 5; i++) {
      await _shakeController.forward();
      await _shakeController.reverse();
    }
    
    // Break the piggy bank
    final success = widget.gameProvider.breakPiggyBank();
    
    if (success) {
      widget.onBreak?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Piggy Bank broken! Dark Matter collected!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.pink.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    
    setState(() => _isBreaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.gameProvider.piggyBankBalance;
    final isBroken = widget.gameProvider.isPiggyBankBroken;
    final canBreak = widget.gameProvider.canBreakPiggyBank;
    final fillLevel = widget.gameProvider.piggyBankFillLevel;
    final capacity = widget.gameProvider.piggyBankCapacity;
    final isFull = widget.gameProvider.isPiggyBankFull;
    
    if (isBroken) {
      return _buildBrokenState();
    }
    
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = _isBreaking 
            ? ((_shakeController.value - 0.5) * 10) 
            : 0.0;
        
        return Transform.translate(
          offset: Offset(shake, 0),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isFull 
                ? Colors.amber.withValues(alpha: 0.7)
                : Colors.pink.withValues(alpha: 0.5),
            showGlow: isFull,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      isFull ? '🐷✨' : '🐷',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'PIGGY BANK',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isFull 
                                      ? Colors.amber 
                                      : Colors.pink.shade200,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (isFull)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, 
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FULL!',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Accumulates DM from expeditions & achievements',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Balance and progress
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.2),
                        Colors.pink.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌑', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            balance.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                            ),
                          ),
                          Text(
                            ' / ${capacity.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar with piggy fill effect
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: fillLevel,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation(
                                isFull ? Colors.amber : Colors.pink,
                              ),
                              minHeight: 12,
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                '${(fillLevel * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Break button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBreak 
                          ? Colors.pink 
                          : Colors.grey.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: canBreak ? _showBreakDialog : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canBreak 
                              ? Icons.celebration 
                              : Icons.lock,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          canBreak 
                              ? 'BREAK & COLLECT (\$0.99)' 
                              : balance < 10 
                                  ? 'NEED 10+ DM TO BREAK'
                                  : 'PIGGY BANK EMPTY',
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Info text
                const SizedBox(height: 8),
                Text(
                  'Prestige count: ${widget.gameProvider.state.prestigeCount} • Capacity grows with prestige',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBrokenState() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: Colors.grey.withValues(alpha: 0.3),
      child: Column(
        children: [
          const Text('💔🐷', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'PIGGY BANK BROKEN',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve collected your savings!\nPrestige to get a new piggy bank.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.gameProvider.resetPiggyBank();
              setState(() {});
            },
            child: const Text(
              'GET NEW PIGGY (\$0.49)',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
