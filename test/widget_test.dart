import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Kardashev Ascension app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const KardashevApp());
    
    // App should start with splash screen
    expect(find.text('KARDASHEV'), findsOneWidget);
  });
}
