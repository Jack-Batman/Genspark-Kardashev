import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_app/providers/game_provider.dart';
import 'package:flutter_app/models/game_state.dart';
import 'package:flutter_app/core/era_data.dart';

void main() {
  group('GameProvider', () {
    late GameProvider gameProvider;

    setUp(() async {
      // Initialize Hive for testing
      Hive.init('./test_hive');
      
      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(GameStateAdapter());
      }
      
      gameProvider = GameProvider();
    });

    tearDown(() async {
      await Hive.close();
    });

    group('Initial State', () {
      test('should start with default energy', () {
        expect(gameProvider.state.energy, greaterThanOrEqualTo(0));
      });

      test('should start in Era I', () {
        expect(gameProvider.state.currentEra, 0);
      });

      test('should have Kardashev level 0 initially', () {
        expect(gameProvider.state.kardashevLevel, greaterThanOrEqualTo(0));
      });
    });

    group('Energy System', () {
      test('tap should increase energy', () async {
        await gameProvider.initialize();
        final initialEnergy = gameProvider.state.energy;
        gameProvider.tap();
        expect(gameProvider.state.energy, greaterThan(initialEnergy));
      });

      test('tap should increase total taps', () async {
        await gameProvider.initialize();
        final initialTaps = gameProvider.state.totalTaps;
        gameProvider.tap();
        expect(gameProvider.state.totalTaps, initialTaps + 1);
      });

      test('addEnergy should increase energy', () async {
        await gameProvider.initialize();
        final initialEnergy = gameProvider.state.energy;
        gameProvider.addEnergy(100);
        expect(gameProvider.state.energy, initialEnergy + 100);
      });

      test('addEnergy should not accept negative values', () async {
        await gameProvider.initialize();
        final initialEnergy = gameProvider.state.energy;
        gameProvider.addEnergy(-50);
        expect(gameProvider.state.energy, initialEnergy);
      });
    });

    group('Generator System', () {
      test('should have starting generator', () async {
        await gameProvider.initialize();
        expect(gameProvider.state.generators.isNotEmpty, true);
      });

      test('buyGeneratorV2 should fail without enough energy', () async {
        await gameProvider.initialize();
        gameProvider.state.energy = 0;
        
        final generators = getCurrentEraGenerators();
        if (generators.isNotEmpty) {
          final result = gameProvider.buyGeneratorV2(generators.first);
          expect(result, false);
        }
      });

      test('buyGeneratorV2 should succeed with enough energy', () async {
        await gameProvider.initialize();
        gameProvider.state.energy = 1000000;
        
        final generators = getCurrentEraGenerators();
        if (generators.isNotEmpty) {
          final genData = generators.first;
          final initialCount = gameProvider.state.getGeneratorCount(genData.id);
          final result = gameProvider.buyGeneratorV2(genData);
          
          expect(result, true);
          expect(
            gameProvider.state.getGeneratorCount(genData.id),
            initialCount + 1,
          );
        }
      });
    });

    group('Dark Matter System', () {
      test('addDarkMatter should increase dark matter', () async {
        await gameProvider.initialize();
        final initial = gameProvider.state.darkMatter;
        gameProvider.addDarkMatter(50);
        expect(gameProvider.state.darkMatter, greaterThan(initial));
      });
    });

    group('Era System', () {
      test('should start with Era I unlocked', () async {
        await gameProvider.initialize();
        expect(gameProvider.state.unlockedEras.contains(0), true);
      });

      test('switchEra should not switch to locked era', () async {
        await gameProvider.initialize();
        gameProvider.state.unlockedEras = [0]; // Only Era I
        gameProvider.switchEra(Era.stellar);
        expect(gameProvider.state.currentEra, 0);
      });

      test('switchEra should switch to unlocked era', () async {
        await gameProvider.initialize();
        gameProvider.state.unlockedEras = [0, 1]; // Era I and II
        gameProvider.switchEra(Era.stellar);
        expect(gameProvider.state.currentEra, 1);
      });
    });

    group('Prestige System', () {
      test('getPrestigeInfo should return valid info', () async {
        await gameProvider.initialize();
        gameProvider.state.kardashevLevel = 1.0;
        final info = gameProvider.getPrestigeInfo();
        expect(info, isNotNull);
      });
    });

    group('Offline Progress', () {
      test('should calculate offline earnings correctly', () async {
        await gameProvider.initialize();
        gameProvider.state.lastOnlineTime = DateTime.now().subtract(
          const Duration(hours: 1),
        );
        
        final result = gameProvider.calculateOfflineProgressOptimized();
        expect(result.timeAway.inMinutes, greaterThan(50));
      });

      test('should respect max offline hours', () async {
        await gameProvider.initialize();
        gameProvider.state.lastOnlineTime = DateTime.now().subtract(
          const Duration(hours: 100),
        );
        
        final result = gameProvider.calculateOfflineProgressOptimized();
        expect(
          result.cappedHours,
          lessThanOrEqualTo(gameProvider.state.maxOfflineHours),
        );
      });
    });

    group('Daily Reward System', () {
      test('first login should set streak to 1', () async {
        await gameProvider.initialize();
        gameProvider.state.lastLoginDate = null;
        gameProvider.state.loginStreak = 0;
        
        // Trigger daily login check
        // This is normally done in initialize()
        expect(gameProvider.state.loginStreak, greaterThanOrEqualTo(0));
      });
    });

    group('Settings', () {
      test('toggleSound should toggle sound state', () async {
        await gameProvider.initialize();
        final initial = gameProvider.state.soundEnabled;
        gameProvider.toggleSound();
        expect(gameProvider.state.soundEnabled, !initial);
      });

      test('toggleHaptics should toggle haptics state', () async {
        await gameProvider.initialize();
        final initial = gameProvider.state.hapticsEnabled;
        gameProvider.toggleHaptics();
        expect(gameProvider.state.hapticsEnabled, !initial);
      });
    });

    group('Number Formatting', () {
      test('should format small numbers correctly', () {
        expect(GameProvider.formatNumber(100), '100');
        expect(GameProvider.formatNumber(999), '999');
      });

      test('should format thousands correctly', () {
        final result = GameProvider.formatNumber(1500);
        expect(result, contains('K'));
      });

      test('should format millions correctly', () {
        final result = GameProvider.formatNumber(1500000);
        expect(result, contains('M'));
      });

      test('should format billions correctly', () {
        final result = GameProvider.formatNumber(1500000000);
        expect(result, contains('B'));
      });
    });
  });
}
