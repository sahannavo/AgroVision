import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/diagnosis_classifier.dart';
import '../domain/diagnosis_repository.dart';
import 'fake_diagnosis_classifier.dart';
import 'fake_diagnosis_repository.dart';
import 'firebase_diagnosis_repository.dart';
import 'pending_upload_queue.dart';

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

/// Provider for the [PendingUploadQueue] used to sync offline diagnoses.
///
/// Only meaningful when `USE_FAKES=false`. Callers can trigger
/// [PendingUploadQueue.processQueue] after connectivity is restored.
final pendingUploadQueueProvider = Provider<PendingUploadQueue>((ref) {
  return PendingUploadQueue();
});

/// Stream provider that watches the `outbreakAlerts` Firestore collection.
///
/// Each document represents a geo-cluster of disease diagnoses that crossed
/// the outbreak threshold (configured in Cloud Function env vars).
///
/// Returns a list of maps ordered by most-recent `detectedAt`. The stream
/// emits an empty list when `USE_FAKES=true` so UI can be developed without
/// Firebase, and emits live updates once alerts are created by
/// [onDiagnosisCreated] Cloud Function.
final outbreakAlertsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  if (kUseFakes) {
    // Fake mode: emit an empty list — no outbreak alerts during UI dev.
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('outbreakAlerts')
      .orderBy('detectedAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => <String, dynamic>{
                'id': doc.id,
                ...doc.data(),
              })
          .toList());
});
