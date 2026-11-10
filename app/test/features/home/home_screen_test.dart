import 'package:app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home dashboard shows the main content', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Good morning, Nimal'), findsOneWidget);
    expect(find.text('My crops'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Quick actions'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quick actions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent diagnosis'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent diagnosis'), findsOneWidget);
    expect(find.textContaining('Early Blight'), findsOneWidget);
  });
}
