import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/game_provider.dart';
import 'package:flutter_app/widgets/glass_container.dart';
import 'package:flutter_app/core/era_data.dart';

void main() {
  group('GlassContainer Widget', () {
    testWidgets('renders child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: const Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              borderRadius: BorderRadius.circular(16),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(GlassContainer), findsOneWidget);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              color: Colors.blue.withValues(alpha: 0.2),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassContainer), findsOneWidget);
    });
  });

  group('Era Configuration', () {
    test('all eras have valid configs', () {
      for (final era in Era.values) {
        final config = eraConfigs[era];
        expect(config, isNotNull, reason: 'Config for $era should exist');
        expect(config!.name.isNotEmpty, true);
        expect(config.subtitle.isNotEmpty, true);
        expect(config.description.isNotEmpty, true);
        expect(config.minKardashev, greaterThanOrEqualTo(0));
        expect(config.maxKardashev, greaterThan(config.minKardashev));
      }
    });

    test('era transitions are valid', () {
      for (final transition in eraTransitions) {
        expect(transition.requiredKardashev, greaterThan(0));
        expect(transition.energyCost, greaterThanOrEqualTo(0));
        expect(transition.title.isNotEmpty, true);
        expect(transition.rewards.isNotEmpty, true);
      }
    });

    test('all eras have generators', () {
      expect(eraIGenerators.isNotEmpty, true);
      expect(eraIIGenerators.isNotEmpty, true);
      expect(eraIIIGenerators.isNotEmpty, true);
      expect(eraIVGenerators.isNotEmpty, true);
      expect(eraVGenerators.isNotEmpty, true);
    });

    test('generators have valid data', () {
      final allGenerators = [
        ...eraIGenerators,
        ...eraIIGenerators,
        ...eraIIIGenerators,
        ...eraIVGenerators,
        ...eraVGenerators,
      ];

      for (final gen in allGenerators) {
        expect(gen.id.isNotEmpty, true);
        expect(gen.name.isNotEmpty, true);
        expect(gen.baseCost, greaterThan(0));
        expect(gen.baseProduction, greaterThan(0));
        expect(gen.costMultiplier, greaterThan(1));
      }
    });
  });

  group('Architect Data', () {
    test('all eras have architects', () {
      expect(eraIArchitects.isNotEmpty, true);
      expect(eraIIArchitects.isNotEmpty, true);
      expect(eraIIIArchitects.isNotEmpty, true);
      expect(eraIVArchitects.isNotEmpty, true);
    });

    test('architects have valid data', () {
      final allArchitects = [
        ...eraIArchitects,
        ...eraIIArchitects,
        ...eraIIIArchitects,
        ...eraIVArchitects,
      ];

      for (final architect in allArchitects) {
        expect(architect.id.isNotEmpty, true);
        expect(architect.name.isNotEmpty, true);
        expect(architect.passiveBonus, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Research Data', () {
    test('research nodes exist', () {
      final nodes = getAllResearchNodes();
      expect(nodes.isNotEmpty, true);
    });

    test('research nodes have valid costs', () {
      final nodes = getAllResearchNodes();
      for (final node in nodes) {
        expect(node.energyCost, greaterThanOrEqualTo(0));
        expect(node.researchTime, greaterThan(0));
      }
    });
  });

  group('Prestige Tiers', () {
    test('prestige tiers are ordered', () {
      for (int i = 0; i < prestigeTiers.length - 1; i++) {
        expect(
          prestigeTiers[i + 1].requiredKardashev,
          greaterThan(prestigeTiers[i].requiredKardashev),
        );
      }
    });

    test('prestige tiers have increasing rewards', () {
      for (int i = 0; i < prestigeTiers.length - 1; i++) {
        expect(
          prestigeTiers[i + 1].darkMatterReward,
          greaterThanOrEqualTo(prestigeTiers[i].darkMatterReward),
        );
      }
    });
  });
}
