import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    ),
  );
}

void main() {
  group('AppTextField', () {
    testWidgets('renders labelText, hintText, and leading icon', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const AppTextField(
            labelText: 'Land Location',
            hintText: 'Enter district or city',
            leadingIcon: Icons.location_on_outlined,
          ),
        ),
      );

      expect(find.text('Land Location'), findsOneWidget);
      expect(find.text('Enter district or city'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('handles user text entry and onChanged callback', (tester) async {
      String typedText = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        _wrapWithTheme(
          AppTextField(
            labelText: 'Crop Variety',
            controller: controller,
            onChanged: (val) => typedText = val,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Thilina');
      await tester.pump();

      expect(controller.text, 'Thilina');
      expect(typedText, 'Thilina');
    });

    testWidgets('password constructor toggles visibility on icon tap', (tester) async {
      final controller = TextEditingController(text: 'secret123');

      await tester.pumpWidget(
        _wrapWithTheme(
          AppTextField.password(
            labelText: 'Password',
            controller: controller,
          ),
        ),
      );

      // Initially obscured
      TextField textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap toggle button to show password
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap again to re-hide
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('displays unitText when specified', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const AppTextField(
            labelText: 'Land Area',
            unitText: 'Acres',
          ),
        ),
      );

      expect(find.text('Acres'), findsOneWidget);
    });

    testWidgets('renders errorText in error state', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const AppTextField(
            labelText: 'Field Name',
            errorText: 'Name cannot be empty',
          ),
        ),
      );

      expect(find.text('Name cannot be empty'), findsOneWidget);
    });

    testWidgets('disabled state does not allow user input', (tester) async {
      final controller = TextEditingController(text: 'Initial');

      await tester.pumpWidget(
        _wrapWithTheme(
          AppTextField(
            labelText: 'Read Only Location',
            controller: controller,
            enabled: false,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}
