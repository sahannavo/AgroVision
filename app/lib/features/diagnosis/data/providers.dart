import '../domain/diagnosis_classifier.dart';
import '../domain/diagnosis_repository.dart';
import 'fake_diagnosis_classifier.dart';
import 'fake_diagnosis_repository.dart';

const bool kUseFakes = bool.fromEnvironment('USE_FAKES', defaultValue: true);

final _fakeDiagnosisRepositoryInstance = FakeDiagnosisRepository();
final _fakeDiagnosisClassifierInstance = FakeDiagnosisClassifier();

/// Provider for [DiagnosisRepository].
DiagnosisRepository get diagnosisRepositoryProvider => _fakeDiagnosisRepositoryInstance;

/// Provider for [DiagnosisClassifier].
DiagnosisClassifier get diagnosisClassifierProvider => _fakeDiagnosisClassifierInstance;
