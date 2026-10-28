import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/app.dart';

void main() {
  testWidgets('AgroVisionApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AgroVisionApp()));

    expect(find.text('AgroVision'), findsWidgets);
    expect(find.text('Material 3 Light Theme Active'), findsOneWidget);
  });
}
