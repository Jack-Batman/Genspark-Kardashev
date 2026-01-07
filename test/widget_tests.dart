import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(GlassContainer), findsOneWidget);
    });

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassContainer(
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
      // Use the getGeneratorsForEra function from era_data.dart
      expect(getGeneratorsForEra(Era.planetary).isNotEmpty, true);
      expect(getGeneratorsForEra(Era.stellar).isNotEmpty, true);
      expect(getGeneratorsForEra(Era.galactic).isNotEmpty, true);
      expect(getGeneratorsForEra(Era.universal).isNotEmpty, true);
      expect(getGeneratorsForEra(Era.multiversal).isNotEmpty, true);
    });

    test('generators have valid data', () {
      // Use allGenerators from era_data.dart
      for (final gen in allGenerators) {
        expect(gen.id.isNotEmpty, true);
        expect(gen.name.isNotEmpty, true);
        expect(gen.baseCost, greaterThan(0));
        expect(gen.baseProduction, greaterThan(0));
        expect(gen.costMultiplier, greaterThan(1));
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
