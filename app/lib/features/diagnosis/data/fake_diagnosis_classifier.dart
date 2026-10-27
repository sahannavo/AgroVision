import '../domain/diagnosis.dart';
import '../domain/diagnosis_classifier.dart';
import '../domain/disease_class.dart';

/// Fake implementation of [DiagnosisClassifier].
/// Returns Early Blight at 92% confidence with candidate matches,
/// matching the design PNGs.
class FakeDiagnosisClassifier implements DiagnosisClassifier {
  FakeDiagnosisClassifier({
    this.delay = const Duration(milliseconds: 500),
  });

  final Duration delay;

  @override
  Future<Diagnosis> classify(
    String imagePath, {
    String? cropType,
    String? cropId,
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(delay);

    return Diagnosis(
      id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'farmer_nimal_01',
      cropId: cropId ?? 'plot_tomato_01',
      cropType: cropType ?? 'Tomato',
      imagePath: imagePath,
      predictedClass: DiseaseClass.earlyBlight,
      confidence: 0.92,
      topMatches: const [
        TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.92),
        TopMatch(diseaseClass: DiseaseClass.lateBlight, confidence: 0.05),
        TopMatch(diseaseClass: DiseaseClass.healthy, confidence: 0.03),
      ],
      latitude: latitude ?? 7.4863,
      longitude: longitude ?? 80.3623,
      diagnosedAt: DateTime.now(),
      syncStatus: SyncStatus.synced,
    );
  }
}
