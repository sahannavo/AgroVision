import 'package:app/features/diagnosis/data/firebase_diagnosis_repository.dart';
import 'package:app/features/diagnosis/data/pending_upload_queue.dart';
import 'package:app/features/diagnosis/domain/diagnosis.dart';
import 'package:app/features/diagnosis/domain/disease_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PendingUploadQueue & Geohash Tests', () {
    test('encodeGeohash computes valid 9-character geohash string', () {
      // Kurunegala coordinates: 7.4863, 80.3623
      final hash = encodeGeohash(7.4863, 80.3623);
      expect(hash, isNotEmpty);
      expect(hash.length, equals(9));
      expect(hash.startsWith('tc'), isTrue); // Sri Lankan geohash prefix
    });

    test('PendingUploadQueue enqueues offline diagnosis item', () {
      final queue = PendingUploadQueue();
      expect(queue.pendingCount, equals(0));

      final diagnosis = Diagnosis(
        id: 'diag_offline_01',
        userId: 'farmer_01',
        cropType: 'Tomato',
        imagePath: '/tmp/leaf.jpg',
        predictedClass: DiseaseClass.earlyBlight,
        confidence: 0.91,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.91),
        ],
        diagnosedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      queue.enqueue(diagnosis);
      expect(queue.pendingCount, equals(1));
      expect(queue.pendingDiagnoses.first.id, equals('diag_offline_01'));

      queue.clear();
      expect(queue.pendingCount, equals(0));
    });
  });
}
