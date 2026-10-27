import 'diagnosis.dart';

/// Contract for the on-device leaf disease image classifier.
abstract class DiagnosisClassifier {
  /// Classifies an image file on disk and returns the predicted [Diagnosis].
  Future<Diagnosis> classify(
    String imagePath, {
    String? cropType,
    String? cropId,
    String? userId,
    double? latitude,
    double? longitude,
  });
}
