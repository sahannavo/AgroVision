import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/diagnosis_classifier.dart';
import '../domain/diagnosis_repository.dart';
import 'fake_diagnosis_classifier.dart';
import 'fake_diagnosis_repository.dart';
import 'firebase_diagnosis_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [DiagnosisRepository] instance.
///
/// Returns [FakeDiagnosisRepository] when developing locally or executing tests.
/// Switches to [FirebaseDiagnosisRepository] when built with `--dart-define=USE_FAKES=false`.
final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  if (kUseFakes) {
    return FakeDiagnosisRepository();
  }
  return FirebaseDiagnosisRepository();
});

/// Provider exposing the on-device [DiagnosisClassifier] instance.
final diagnosisClassifierProvider = Provider<DiagnosisClassifier>((ref) {
  return FakeDiagnosisClassifier();
});
