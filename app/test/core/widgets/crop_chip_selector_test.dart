import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/widgets/crop_chip_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('CropChipSelector', () {
    testWidgets('renders all four nightshade crops with their icons', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const CropChipSelector(),
        ),
      );

      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Chilli'), findsOneWidget);
      expect(find.text('Eggplant'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);

      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
      expect(find.byIcon(Icons.grain_rounded), findsOneWidget);
    });

    testWidgets('single-select mode selects chip and shows checkmark icon', (tester) async {
      String? selected;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              CropChipSelector(
                selectedCrop: selected,
                onCropSelected: (crop) {
                  setState(() => selected = crop);
                },
              ),
            );
          },
        ),
      );

      // Initially no check icon
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      // Tap Tomato
      await tester.tap(find.text('Tomato'));
      await tester.pumpAndSettle();

      expect(selected, 'Tomato');
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Tap Chilli -> switches selection
      await tester.tap(find.text('Chilli'));
      await tester.pumpAndSettle();

      expect(selected, 'Chilli');
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('multi-select mode allows multiple selections with checkmarks', (tester) async {
      Set<String> selected = {'Tomato'};

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              CropChipSelector(
                isMultiSelect: true,
                selectedCrops: selected,
                onCropsChanged: (crops) {
                  setState(() => selected = crops);
                },
              ),
            );
          },
        ),
      );

      // Tomato is already selected
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Tap Potato
      await tester.tap(find.text('Potato'));
      await tester.pumpAndSettle();

      expect(selected.contains('Tomato'), isTrue);
      expect(selected.contains('Potato'), isTrue);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));

      // Tap Tomato again to deselect
      await tester.tap(find.text('Tomato'));
      await tester.pumpAndSettle();

      expect(selected.contains('Tomato'), isFalse);
      expect(selected.contains('Potato'), isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('disabled state does not fire tap callbacks', (tester) async {
      String? selected;

      await tester.pumpWidget(
        _wrapWithTheme(
          CropChipSelector(
            enabled: false,
            selectedCrop: selected,
            onCropSelected: (crop) => selected = crop,
          ),
        ),
      );

      await tester.tap(find.text('Tomato'));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });
  });

  group('OptionChips', () {
    testWidgets('renders soil type options and allows single selection', (tester) async {
      String? selectedSoil;
      const soils = ['Clay', 'Loam', 'Sandy', 'Silt'];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              OptionChips<String>(
                options: soils,
                selectedOption: selectedSoil,
                onOptionSelected: (soil) {
                  setState(() => selectedSoil = soil);
                },
              ),
            );
          },
        ),
      );

      for (final soil in soils) {
        expect(find.text(soil), findsOneWidget);
      }

      // Tap Loam
      await tester.tap(find.text('Loam'));
      await tester.pumpAndSettle();

      expect(selectedSoil, 'Loam');
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('supports season options and multi-selection mode', (tester) async {
      Set<String> selectedSeasons = {};
      const seasons = ['Maha (Oct - Feb)', 'Yala (May - Aug)'];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrapWithTheme(
              OptionChips<String>(
                options: seasons,
                isMultiSelect: true,
                selectedOptions: selectedSeasons,
                onOptionsChanged: (newSeasons) {
                  setState(() => selectedSeasons = newSeasons);
                },
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Maha (Oct - Feb)'));
      await tester.pumpAndSettle();

      expect(selectedSeasons.contains('Maha (Oct - Feb)'), isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
