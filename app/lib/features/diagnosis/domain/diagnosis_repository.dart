import 'diagnosis.dart';

/// Contract for managing diagnosis history records.
abstract class DiagnosisRepository {
  /// Stream of diagnoses, ordered by diagnosedAt descending.
  Stream<List<Diagnosis>> watchHistory({String? userId});

  /// Fetches historical diagnoses for the user.
  Future<List<Diagnosis>> getHistory({String? userId});

  /// Saves a newly diagnosed record to storage/cache.
  Future<Diagnosis> save(Diagnosis diagnosis);
}
