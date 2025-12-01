import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../core/era_data.dart';
import 'particle_systems.dart';
import 'era_visuals.dart';

/// Main Kardashev Game - Handles the visual rendering for all Eras
class KardashevGame extends FlameGame with TapCallbacks, ScaleDetector {
  // Zoom level for "Powers of Ten" effect
  double _zoomLevel = 1.0;
  double _targetZoom = 1.0;
  
  // Camera position
  Vector2 _cameraOffset = Vector2.zero();
  
  // Current Era state
  Era _currentEra = Era.planetary;
  double _techLevel = 0; // 0.0 - 1.0 within current era
  double _energyProduction = 0;
  
  // Era visuals renderer
  late EraVisuals _eraVisuals;
  
  // Animation timer
  double _animationTime = 0;
  
  // Enhanced Particle Systems
  final List<EnergyStreamParticle> _energyStreams = [];
  final List<NebulaParticle> _nebulaClouds = [];
  final List<SparkParticle> _sparks = [];
  final List<OrbitalParticle> _orbitalParticles = [];
  final List<CometParticle> _comets = [];
  final List<FloatingNumber> _floatingNumbers = [];
  final List<Star> _backgroundStars = [];
  
  // Lens Flare
  late LensFlare _sunFlare;
  double _flareIntensity = 0.8;
  double _flarePulse = 0;
  
  // Ambient animation timers
  double _ambientTimer = 0;
  double _cometTimer = 0;
  
  // Era-specific colors
  Color _primaryColor = const Color(0xFF00D9FF);
  Color _accentColor = const Color(0xFFFFD700);
  
  final Random _random = Random();
  
  // Callback for taps
  Function()? onTapCallback;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize era visuals
    _eraVisuals = EraVisuals(_currentEra);
    
    // Initialize background stars
    _initializeStars();
    
    // Initialize nebula clouds
    _initializeNebulaClouds();
    
    // Initialize orbital particle ring
    _initializeOrbitalRing();
    
    // Initialize lens flare
    _sunFlare = LensFlare(
      position: const Offset(-200, -200),
      color: _accentColor,
      intensity: 0.8,
    );
  }
  
  void _initializeStars() {
    _backgroundStars.clear();
    for (int i = 0; i < 300; i++) {
      _backgroundStars.add(Star(
        position: Vector2(
          _random.nextDouble() * 2000 - 500,
          _random.nextDouble() * 2000 - 500,
        ),
        size: _random.nextDouble() * 2.5 + 0.5,
        brightness: _random.nextDouble(),
        twinkleSpeed: _random.nextDouble() * 2 + 0.5,
      ));
    }
  }
  
  void _initializeNebulaClouds() {
    _nebulaClouds.clear();
    final config = eraConfigs[_currentEra]!;
    final colors = [
      config.primaryColor.withValues(alpha: 0.3),
      config.secondaryColor.withValues(alpha: 0.2),
      config.accentColor.withValues(alpha: 0.15),
    ];
    
    for (int i = 0; i < 12; i++) {
      _nebulaClouds.add(NebulaParticle(
        position: Offset(
          _random.nextDouble() * 1200 - 400,
          _random.nextDouble() * 1200 - 400,
        ),
        color: colors[_random.nextInt(colors.length)],
        baseSize: 100 + _random.nextDouble() * 150,
        pulseSpeed: 0.2 + _random.nextDouble() * 0.3,
      ));
    }
  }
  
  void _initializeOrbitalRing() {
    _orbitalParticles.clear();
    for (int i = 0; i < 40; i++) {
      _orbitalParticles.add(OrbitalParticle(
        orbitRadius: 140 + _random.nextDouble() * 30,
        orbitAngle: (i / 40) * 2 * pi,
        orbitSpeed: 0.2 + _random.nextDouble() * 0.3,
        color: _primaryColor.withValues(alpha: 0.6),
        size: 1.5 + _random.nextDouble() * 2,
        orbitTilt: 0.25,
      ));
    }
  }
  
  /// Update game state from provider
  void updateGameState({
    required double kardashevLevel,
    required double energyPerSecond,
    required int totalGenerators,
    required Map<String, int> generators,
    required Era currentEra,
  }) {
    // Check for era change
    if (_currentEra != currentEra) {
      _currentEra = currentEra;
      _eraVisuals = EraVisuals(_currentEra);
      _updateEraColors();
      _initializeNebulaClouds();
    }
    
    _energyProduction = energyPerSecond;
    
    // Calculate tech level within current era (0.0 - 1.0)
    final config = eraConfigs[_currentEra]!;
    _techLevel = ((kardashevLevel - config.minKardashev) / 
                  (config.maxKardashev - config.minKardashev)).clamp(0.0, 1.0);
  }
  
  void _updateEraColors() {
    final config = eraConfigs[_currentEra]!;
    _primaryColor = config.primaryColor;
    _accentColor = config.accentColor;
    
    // Update orbital particles with new colors
    for (final particle in _orbitalParticles) {
      particle.color = _primaryColor.withValues(alpha: 0.6);
    }
  }
  
  void _spawnEnergyStreams() {
    if (_energyProduction <= 0) return;
    
    // Spawn rate scales with era
    final eraMultiplier = 1.0 + _currentEra.index * 0.5;
    final spawnChance = min(_energyProduction / (50 * pow(10, _currentEra.index * 7)), 0.9);
    
    if (_random.nextDouble() < spawnChance * eraMultiplier) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 200 + _random.nextDouble() * 100;
      
      _energyStreams.add(EnergyStreamParticle(
        position: Offset(
          cos(angle) * distance,
          sin(angle) * distance,
        ),
        target: Offset.zero,
        color: _accentColor,
        size: 2 + _random.nextDouble() * 3,
        lifetime: 2.5,
      ));
    }
  }
  
  void _spawnComet() {
    if (_random.nextDouble() > 0.3) return;
    
    // Random edge spawn
    final edge = _random.nextInt(4);
    Offset position;
    Offset velocity;
    
    switch (edge) {
      case 0: // Top
        position = Offset(_random.nextDouble() * 600 - 300, -400);
        velocity = Offset(_random.nextDouble() * 40 - 20, 80 + _random.nextDouble() * 40);
        break;
      case 1: // Right
        position = Offset(400, _random.nextDouble() * 600 - 300);
        velocity = Offset(-80 - _random.nextDouble() * 40, _random.nextDouble() * 40 - 20);
        break;
      case 2: // Bottom
        position = Offset(_random.nextDouble() * 600 - 300, 400);
        velocity = Offset(_random.nextDouble() * 40 - 20, -80 - _random.nextDouble() * 40);
        break;
      default: // Left
        position = Offset(-400, _random.nextDouble() * 600 - 300);
        velocity = Offset(80 + _random.nextDouble() * 40, _random.nextDouble() * 40 - 20);
    }
    
    _comets.add(CometParticle(
      position: position,
      velocity: velocity,
      color: _primaryColor.withValues(alpha: 0.8),
      size: 2 + _random.nextDouble() * 2,
      lifetime: 8.0,
    ));
  }
  
  /// Add floating number animation
  void addFloatingNumber(String text, Offset position, {Color? color}) {
    _floatingNumbers.add(FloatingNumber(
      position: position,
      text: text,
      color: color ?? _accentColor,
    ));
  }
  
  /// Spawn tap burst effect
  void _spawnTapBurst(Offset position) {
    for (int i = 0; i < 15; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 100 + _random.nextDouble() * 150;
      
      _sparks.add(SparkParticle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: _accentColor,
        size: 3 + _random.nextDouble() * 4,
        lifetime: 0.8 + _random.nextDouble() * 0.4,
      ));
    }
    
    // Add energy stream burst
    for (int i = 0; i < 5; i++) {
      _energyStreams.add(EnergyStreamParticle(
        position: position,
        target: Offset.zero,
        color: _accentColor,
        size: 4,
        lifetime: 1.5,
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Smooth zoom interpolation
    _zoomLevel = lerpDouble(_zoomLevel, _targetZoom, dt * 5)!;
    
    // Update animation time
    _animationTime += dt;
    
    // Update era visuals
    _eraVisuals.update(dt);
    
    // Animate lens flare
    _flarePulse += dt * 2;
    _flareIntensity = 0.6 + 0.2 * sin(_flarePulse);
    
    // Update ambient timer
    _ambientTimer += dt;
    _cometTimer += dt;
    
    // Spawn ambient effects
    if (_ambientTimer > 0.05) {
      _ambientTimer = 0;
      _spawnEnergyStreams();
    }
    
    if (_cometTimer > 3.0) {
      _cometTimer = 0;
      _spawnComet();
    }
    
    // Update all particle systems
    for (final star in _backgroundStars) {
      star.update(dt);
    }
    
    for (final nebula in _nebulaClouds) {
      nebula.update(dt);
    }
    
    for (final orbital in _orbitalParticles) {
      orbital.update(dt);
    }
    
    // Update and clean energy streams
    for (int i = _energyStreams.length - 1; i >= 0; i--) {
      _energyStreams[i].update(dt);
      if (_energyStreams[i].isDead) {
        _energyStreams.removeAt(i);
      }
    }
    
    // Update and clean sparks
    for (int i = _sparks.length - 1; i >= 0; i--) {
      _sparks[i].update(dt);
      if (_sparks[i].isDead) {
        _sparks.removeAt(i);
      }
    }
    
    // Update and clean comets
    for (int i = _comets.length - 1; i >= 0; i--) {
      _comets[i].update(dt);
      if (_comets[i].isDead) {
        _comets.removeAt(i);
      }
    }
    
    // Update and clean floating numbers
    for (int i = _floatingNumbers.length - 1; i >= 0; i--) {
      _floatingNumbers[i].update(dt);
      if (_floatingNumbers[i].isDead) {
        _floatingNumbers.removeAt(i);
      }
    }
    
    // Limit particles
    while (_energyStreams.length > 100) {
      _energyStreams.removeAt(0);
    }
    while (_sparks.length > 120) {
      _sparks.removeAt(0);
    }
    while (_comets.length > 8) {
      _comets.removeAt(0);
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = size / 2;
    
    canvas.save();
    canvas.translate(center.x + _cameraOffset.x, center.y + _cameraOffset.y);
    canvas.scale(_zoomLevel);
    
    // Draw era-specific background
    _drawSpaceBackground(canvas);
    
    // Draw nebula clouds (far background)
    ParticleSystemPainter.drawNebulaClouds(canvas, _nebulaClouds);
    
    // Draw stars
    _drawStars(canvas);
    
    // Draw comets
    ParticleSystemPainter.drawComets(canvas, _comets);
    
    // Draw energy grid (tech level dependent)
    if (_techLevel > 0.1) {
      _drawEnergyGrid(canvas);
    }
    
    // Draw orbital particles
    if (_techLevel > 0.2) {
      ParticleSystemPainter.drawOrbitalParticles(canvas, _orbitalParticles);
    }
    
    // Draw energy streams flowing to center
    ParticleSystemPainter.drawEnergyStreams(canvas, _energyStreams);
    
    // Draw central object for current era (Earth, Sun, Galaxy, or Universe)
    _eraVisuals.drawCentralObject(canvas, _techLevel);
    
    // Draw sparks (tap effects)
    ParticleSystemPainter.drawSparks(canvas, _sparks);
    
    // Draw atmospheric effects
    _drawAtmosphericEffects(canvas);
    
    // Draw lens flare (position depends on era)
    final flarePos = _getFlarePosition();
    _sunFlare = LensFlare(
      position: flarePos,
      color: _accentColor,
      intensity: _flareIntensity,
    );
    ParticleSystemPainter.drawLensFlare(canvas, _sunFlare, Offset.zero);
    
    // Draw floating numbers
    _drawFloatingNumbers(canvas);
    
    // Draw era indicator
    _drawEraIndicator(canvas);
    
    canvas.restore();
  }
  
  Offset _getFlarePosition() {
    switch (_currentEra) {
      case Era.planetary:
        return const Offset(-200, -200); // Sun position
      case Era.stellar:
        return Offset.zero; // Sun is center
      case Era.galactic:
        return Offset.zero; // Galactic core
      case Era.universal:
        return Offset.zero; // Singularity
      case Era.multiversal:
        return Offset.zero; // Void
    }
  }
  
  void _drawSpaceBackground(Canvas canvas) {
    final config = eraConfigs[_currentEra]!;
    
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: 2000,
      height: 2000,
    );
    
    if (_currentEra == Era.multiversal) {
      // Era V: True void - absolute black with subtle void energy at edges
      _drawVoidBackground(canvas, rect);
      return;
    }
    
    // Era-specific background gradient
    final gradient = RadialGradient(
      colors: [
        Color.lerp(config.backgroundColor, config.primaryColor, 0.1)!,
        config.backgroundColor,
        const Color(0xFF000005),
      ],
      stops: const [0.0, 0.4, 1.0],
    );
    
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }
  
  /// Era V specific: The Void - absolute nothingness with prismatic edges
  void _drawVoidBackground(Canvas canvas, Rect rect) {
    // Base: True black - the absence of everything
    canvas.drawRect(
      rect,
      Paint()..color = Colors.black,
    );
    
    // Subtle void energy gradient at the very edges - suggests infinite depth
    final voidGradient = RadialGradient(
      colors: [
        Colors.black,
        Colors.black,
        const Color(0xFF050005), // Barely perceptible purple-black
        const Color(0xFF080010), // Slightly more visible at far edges
      ],
      stops: const [0.0, 0.6, 0.85, 1.0],
    );
    
    canvas.drawRect(
      rect,
      Paint()..shader = voidGradient.createShader(rect),
    );
    
    // Prismatic void edge shimmer - reality breaking down at the boundaries
    final edgeRadius = 900.0;
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + _animationTime * 0.05;
      final hue = (i * 30 + _animationTime * 10) % 360;
      final shimmerColor = HSVColor.fromAHSV(0.08, hue, 1.0, 1.0).toColor();
      
      final shimmerPath = Path();
      final arcLength = pi / 8;
      for (double t = -arcLength; t <= arcLength; t += 0.1) {
        final r = edgeRadius + sin(t * 5 + _animationTime) * 30;
        final a = angle + t;
        if (t == -arcLength) {
          shimmerPath.moveTo(cos(a) * r, sin(a) * r);
        } else {
          shimmerPath.lineTo(cos(a) * r, sin(a) * r);
        }
      }
      
      canvas.drawPath(
        shimmerPath,
        Paint()
          ..color = shimmerColor
          ..strokeWidth = 20
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
      );
    }
  }
  
  void _drawStars(Canvas canvas) {
    for (final star in _backgroundStars) {
      // Era affects star color tint
      Color starColor = Colors.white;
      double starAlpha = star.currentBrightness * 0.8;
      double starSize = star.size;
      
      if (_currentEra == Era.stellar) {
        starColor = Color.lerp(Colors.white, _primaryColor, 0.2)!;
      } else if (_currentEra == Era.galactic) {
        starColor = Color.lerp(Colors.white, _primaryColor, 0.3)!;
      } else if (_currentEra == Era.universal) {
        // Rainbow-shifting stars in Era IV
        final hue = (star.position.x + star.position.y + _animationTime * 30) % 360;
        starColor = HSVColor.fromAHSV(1, hue.abs(), 0.3, 1.0).toColor();
      } else if (_currentEra == Era.multiversal) {
        // Era V: Stars are dying/fading into the void - much dimmer
        // Only brightest stars visible, with prismatic flicker
        starAlpha = star.currentBrightness * 0.25; // Much dimmer
        starSize = star.size * 0.7; // Smaller
        
        // Occasional prismatic flicker
        if ((star.position.x.abs() + star.position.y.abs() + _animationTime * 50).toInt() % 30 < 3) {
          final hue = (_animationTime * 100 + star.position.x) % 360;
          starColor = HSVColor.fromAHSV(1, hue.abs(), 1.0, 1.0).toColor();
          starAlpha = 0.8; // Brief bright flash
        } else {
          // Fading white-purple
          starColor = Color.lerp(Colors.white, const Color(0xFF6600CC), 0.5)!;
        }
      }
      
      final paint = Paint()
        ..color = starColor.withValues(alpha: starAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      
      canvas.drawCircle(
        Offset(star.position.x, star.position.y),
        starSize,
        paint,
      );
    }
  }
  
  void _drawEnergyGrid(Canvas canvas) {
    final paint = Paint()
      ..color = _primaryColor.withValues(alpha: 0.1 + _techLevel * 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Number of rings scales with era
    final ringCount = 5 + _currentEra.index * 2;
    final baseRadius = 120.0 + _currentEra.index * 20;
    
    // Draw orbital rings with glow
    for (int i = 1; i <= ringCount; i++) {
      final radius = baseRadius + i * 25;
      if (_techLevel >= i / ringCount) {
        // Glow
        canvas.drawCircle(
          Offset.zero,
          radius,
          Paint()
            ..color = _primaryColor.withValues(alpha: 0.05)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawCircle(Offset.zero, radius, paint);
      }
    }
    
    // Draw animated connection lines
    final linePaint = Paint()
      ..color = _primaryColor.withValues(alpha: 0.05 + _techLevel * 0.1)
      ..strokeWidth = 0.5;
    
    final lineCount = 12 + _currentEra.index * 4;
    for (int i = 0; i < lineCount; i++) {
      if (_techLevel >= i / lineCount) {
        final angle = (i / lineCount) * 2 * pi + _animationTime * 0.1;
        final pulseOffset = sin(_animationTime * 3 + i) * 0.3;
        final start = Offset(cos(angle) * 100, sin(angle) * 100);
        final end = Offset(
          cos(angle) * (baseRadius + ringCount * 25 + pulseOffset * 20),
          sin(angle) * (baseRadius + ringCount * 25 + pulseOffset * 20),
        );
        canvas.drawLine(start, end, linePaint);
      }
    }
  }
  
  void _drawAtmosphericEffects(Canvas canvas) {
    // Era-specific atmospheric glow
    final config = eraConfigs[_currentEra]!;
    
    // Central glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        colors: [
          config.primaryColor.withValues(alpha: 0.1 * _flareIntensity),
          config.primaryColor.withValues(alpha: 0.03 * _flareIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(const Rect.fromLTWH(-200, -200, 400, 400));
    
    canvas.drawCircle(Offset.zero, 150, glowPaint);
    
    // Era IV & V get extra cosmic effects
    if (_currentEra == Era.universal || _currentEra == Era.multiversal) {
      _drawCosmicEffects(canvas);
    }
  }
  
  void _drawCosmicEffects(Canvas canvas) {
    if (_currentEra == Era.multiversal) {
      // Era V: Void pulse waves - expanding ripples of non-existence
      _drawVoidPulseWaves(canvas);
      return;
    }
    
    // Era IV: Reality distortion waves
    for (int i = 0; i < 3; i++) {
      final waveRadius = 100 + i * 50 + sin(_animationTime + i) * 20;
      final waveAlpha = 0.1 * (1 - i / 3);
      
      canvas.drawCircle(
        Offset.zero,
        waveRadius,
        Paint()
          ..color = _primaryColor.withValues(alpha: waveAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }
  
  /// Era V specific: Void pulse waves emanating from the Omniversal Throne
  void _drawVoidPulseWaves(Canvas canvas) {
    // Multiple expanding void waves at different phases
    for (int wave = 0; wave < 4; wave++) {
      // Each wave has its own phase
      final wavePhase = (_animationTime * 0.5 + wave * 0.7) % 3.0;
      final waveProgress = wavePhase / 3.0; // 0 to 1
      
      if (waveProgress < 0.9) {
        final waveRadius = 50 + waveProgress * 200;
        final waveAlpha = (1 - waveProgress) * 0.15; // Fade out as it expands
        
        // Prismatic wave color shifting through void spectrum
        final hue = (wave * 90 + _animationTime * 30) % 360;
        final waveColor = HSVColor.fromAHSV(waveAlpha, hue, 0.6, 1.0).toColor();
        
        // Draw wave ring
        canvas.drawCircle(
          Offset.zero,
          waveRadius,
          Paint()
            ..color = waveColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 - waveProgress * 2 // Thinner as it expands
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        
        // Inner bright edge
        canvas.drawCircle(
          Offset.zero,
          waveRadius - 2,
          Paint()
            ..color = Colors.white.withValues(alpha: waveAlpha * 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
    
    // Void static - random pixels of reality glitching
    final staticRandom = Random((_animationTime * 10).toInt());
    for (int i = 0; i < 30; i++) {
      final sx = (staticRandom.nextDouble() - 0.5) * 350;
      final sy = (staticRandom.nextDouble() - 0.5) * 350;
      final staticSize = 1 + staticRandom.nextDouble() * 3;
      
      canvas.drawRect(
        Rect.fromCenter(center: Offset(sx, sy), width: staticSize, height: staticSize),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1 + staticRandom.nextDouble() * 0.2),
      );
    }
  }
  
  void _drawFloatingNumbers(Canvas canvas) {
    for (final number in _floatingNumbers) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: number.text,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 20 * number.scale,
            fontWeight: FontWeight.bold,
            color: number.color.withValues(alpha: number.alpha),
            shadows: [
              Shadow(
                color: number.color.withValues(alpha: number.alpha * 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          number.position.dx - textPainter.width / 2,
          number.position.dy - textPainter.height / 2,
        ),
      );
    }
  }
  
  void _drawEraIndicator(Canvas canvas) {
    // Small era indicator in corner
    final config = eraConfigs[_currentEra]!;
    final text = '${config.name}\n${config.subtitle}';
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 10,
          color: config.primaryColor.withValues(alpha: 0.6),
          letterSpacing: 2,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    textPainter.layout();
    
    // Position in top-right corner
    canvas.save();
    canvas.translate(size.x / 2 - 20, -size.y / 2 + 30);
    textPainter.paint(canvas, Offset(-textPainter.width, 0));
    canvas.restore();
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTapCallback?.call();
    
    // Calculate tap position relative to game center
    final tapPos = event.localPosition - size / 2;
    final scaledPos = Offset(tapPos.x / _zoomLevel, tapPos.y / _zoomLevel);
    
    // Spawn burst effect
    _spawnTapBurst(scaledPos);
    
    // Add floating number (will be set by game provider)
    addFloatingNumber('+1', scaledPos);
  }
  
  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    if (info.scale.global.x != 1.0) {
      _targetZoom = (_targetZoom * info.scale.global.x).clamp(0.5, 3.0);
    }
    
    _cameraOffset += info.delta.global;
  }
  
  /// Set zoom level programmatically
  void setZoom(double zoom) {
    _targetZoom = zoom.clamp(0.5, 3.0);
  }
  
  /// Reset camera position
  void resetCamera() {
    _cameraOffset = Vector2.zero();
    _targetZoom = 1.0;
  }
}

/// Background star
class Star {
  final Vector2 position;
  final double size;
  final double brightness;
  final double twinkleSpeed;
  double _phase = 0;
  
  Star({
    required this.position,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
  }) {
    _phase = Random().nextDouble() * 2 * pi;
  }
  
  double get currentBrightness => 
    brightness * (0.5 + 0.5 * sin(_phase));
  
  void update(double dt) {
    _phase += twinkleSpeed * dt;
  }
}
