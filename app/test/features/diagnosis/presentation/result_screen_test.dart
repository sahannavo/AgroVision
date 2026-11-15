import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/diagnosis_repository.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';
import 'package:app/features/diagnosis/presentation/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDiagnosisRepository implements DiagnosisRepository {
  Diagnosis? lastSaved;

  @override
  Future<Diagnosis> save(Diagnosis diagnosis) async {
    lastSaved = diagnosis;
    return diagnosis;
  }

  @override
  Future<List<Diagnosis>> getHistory({String? userId}) async => [];

  @override
  Stream<List<Diagnosis>> watchHistory({String? userId}) => Stream.value([]);
}

Widget _createResultScreenWithTheme({
  required Diagnosis diagnosis,
  required _MockDiagnosisRepository repository,
}) {
  return ProviderScope(
    overrides: [
      diagnosisRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: ResultScreen(diagnosis: diagnosis),
    ),
  );
}

void main() {
  group('ResultScreen Variants', () {
    testWidgets('renders Disease Found variant correctly (>= 70% confidence)', (tester) async {
      final mockRepo = _MockDiagnosisRepository();
      final diagnosis = Diagnosis(
        id: 'test-disease-01',
        userId: 'user-01',
        cropType: 'Tomato',
        imagePath: '',
        predictedClass: DiseaseClass.earlyBlight,
        confidence: 0.92,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.92),
        ],
        diagnosedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _createResultScreenWithTheme(
          diagnosis: diagnosis,
          repository: mockRepo,
        ),
      );

      // Verify header titles and elements
      expect(find.text('Diagnosis Result'), findsOneWidget);
      expect(find.text('Early Blight'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('What it is'), findsOneWidget);
      expect(find.text('Recommended action'), findsOneWidget);
      expect(find.text('Prevention'), findsOneWidget);
      expect(find.text('Save to history'), findsOneWidget);
      expect(find.text('Scan another leaf'), findsOneWidget);

      // Save to history button click
      await tester.tap(find.text('Save to history'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastSaved?.id, 'test-disease-01');
      expect(find.text('Saved to history'), findsWidgets);
    });

    testWidgets('renders Low Confidence variant correctly (< 70% confidence)', (tester) async {
      final mockRepo = _MockDiagnosisRepository();
      final diagnosis = Diagnosis(
        id: 'test-low-01',
        userId: 'user-01',
        cropType: 'Tomato',
        imagePath: '',
        predictedClass: DiseaseClass.earlyBlight,
        confidence: 0.48,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.48),
          TopMatch(diseaseClass: DiseaseClass.bacterialSpot, confidence: 0.31),
        ],
        diagnosedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _createResultScreenWithTheme(
          diagnosis: diagnosis,
          repository: mockRepo,
        ),
      );

      // Verify Low confidence warning banner and candidate matches
      expect(find.text('Low Confidence Detection'), findsOneWidget);
      expect(find.text('Uncertain Match'), findsOneWidget);
      expect(find.text('48%'), findsWidgets);
      expect(find.text('Candidate matches'), findsOneWidget);
      expect(find.text('Tips for better capture'), findsOneWidget);
      expect(find.text('Retake photo'), findsOneWidget);
      expect(find.text('Save anyway'), findsOneWidget);
    });

    testWidgets('renders Healthy Plant variant correctly', (tester) async {
      final mockRepo = _MockDiagnosisRepository();
      final diagnosis = Diagnosis(
        id: 'test-healthy-01',
        userId: 'user-01',
        cropType: 'Chilli',
        imagePath: '',
        predictedClass: DiseaseClass.healthy,
        confidence: 0.96,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.healthy, confidence: 0.96),
        ],
        diagnosedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        _createResultScreenWithTheme(
          diagnosis: diagnosis,
          repository: mockRepo,
        ),
      );

      // Verify Healthy card and tips
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('96%'), findsOneWidget);
      expect(find.text('Vibrant & Disease-Free'), findsOneWidget);
      expect(find.text('Zero Pathogens'), findsOneWidget);
      expect(find.text('Looking good'), findsOneWidget);
      expect(find.text('Keep it healthy'), findsOneWidget);
      expect(find.text('Save to history'), findsOneWidget);
    });
  });
}
