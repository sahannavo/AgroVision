import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/diagnosis_classifier.dart';
import '../domain/diagnosis_repository.dart';
import 'fake_diagnosis_classifier.dart';
import 'fake_diagnosis_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

/// Provider exposing the [DiagnosisRepository] instance.
final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  return FakeDiagnosisRepository();
});

/// Provider exposing the on-device [DiagnosisClassifier] instance.
final diagnosisClassifierProvider = Provider<DiagnosisClassifier>((ref) {
  return FakeDiagnosisClassifier();
});

