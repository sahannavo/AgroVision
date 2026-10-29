import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/diagnosis.dart';
import '../domain/diagnosis_repository.dart';
import '../domain/disease_class.dart';
import 'pending_upload_queue.dart';

/// Encodes geographical latitude and longitude to a standard 32-character Geohash.
String encodeGeohash(double latitude, double longitude, {int precision = 9}) {
  const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
  final latInterval = [-90.0, 90.0];
  final lonInterval = [-180.0, 180.0];
  var isEven = true;
  var bit = 0;
  var ch = 0;
  final buffer = StringBuffer();

  while (buffer.length < precision) {
    double mid;
    if (isEven) {
      mid = (lonInterval[0] + lonInterval[1]) / 2;
      if (longitude > mid) {
        ch |= (1 << (4 - bit));
        lonInterval[0] = mid;
      } else {
        lonInterval[1] = mid;
      }
    } else {
      mid = (latInterval[0] + latInterval[1]) / 2;
      if (latitude > mid) {
        ch |= (1 << (4 - bit));
        latInterval[0] = mid;
      } else {
        latInterval[1] = mid;
      }
    }
    isEven = !isEven;
    if (bit < 4) {
      bit++;
    } else {
      buffer.write(base32[ch]);
      bit = 0;
      ch = 0;
    }
  }
  return buffer.toString();
}

/// Firebase Firestore & Storage production implementation of [DiagnosisRepository].
///
/// Features:
/// - Persists records into top-level `diagnoses` Firestore collection with
///   `GeoPoint` and geohash.
/// - Uploads leaf photos to Firebase Storage at `diagnoses/{uid}/{diagnosisId}.jpg`.
/// - Automatic offline fallback with [PendingUploadQueue] when internet connection
///   is unavailable.
class FirebaseDiagnosisRepository implements DiagnosisRepository {
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;
  final PendingUploadQueue? uploadQueue;

  FirebaseDiagnosisRepository({
    this.firestore,
    this.storage,
    this.uploadQueue,
  });

  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  PendingUploadQueue get _effectiveQueue =>
      uploadQueue ?? PendingUploadQueue(firestore: firestore, storage: storage);

  @override
  Stream<List<Diagnosis>> watchHistory({String? userId}) {
    Query query = _effectiveFirestore
        .collection('diagnoses')
        .orderBy('diagnosedAt', descending: true);

    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _mapToDiagnosis(doc.id, data);
      }).toList();
    });
  }

  @override
  Future<List<Diagnosis>> getHistory({String? userId}) async {
    Query query = _effectiveFirestore
        .collection('diagnoses')
        .orderBy('diagnosedAt', descending: true);

    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _mapToDiagnosis(doc.id, data);
    }).toList();
  }

  @override
  Future<Diagnosis> save(Diagnosis diagnosis) async {
    final lat = diagnosis.latitude ?? 7.4863;
    final lon = diagnosis.longitude ?? 80.3623;
    final geohash = encodeGeohash(lat, lon);

    final docRef = _effectiveFirestore.collection('diagnoses').doc(diagnosis.id);

    final payload = {
      'diagnosisId': diagnosis.id,
      'userId': diagnosis.userId,
      'cropId': diagnosis.cropId,
      'cropType': diagnosis.cropType,
      'imageUrl': diagnosis.imagePath,
      'predictedClass': diagnosis.predictedClass.name,
      'confidenceScore': diagnosis.confidence,
      'topMatches': diagnosis.topMatches
          .map((m) => {
                'diseaseClass': m.diseaseClass.name,
                'confidence': m.confidence,
              })
          .toList(),
      'location': GeoPoint(lat, lon),
      'geohash': geohash,
      'diagnosedAt': Timestamp.fromDate(diagnosis.diagnosedAt),
      'syncStatus': diagnosis.syncStatus.name,
    };

    try {
      await docRef.set(payload);

      // Attempt immediate sync via upload queue
      _effectiveQueue.enqueue(diagnosis);
      unawaited(_effectiveQueue.processQueue());

      return diagnosis;
    } catch (e) {
      // Offline fallback: save to local cache with pending syncStatus
      final pendingDiagnosis = diagnosis.copyWith(syncStatus: SyncStatus.pending);
      _effectiveQueue.enqueue(pendingDiagnosis);

      try {
        await docRef.set(
          {...payload, 'syncStatus': SyncStatus.pending.name},
          SetOptions(merge: true),
        );
      } catch (_) {
        // Local offline write recorded
      }

      return pendingDiagnosis;
    }
  }

  Diagnosis _mapToDiagnosis(String docId, Map<String, dynamic> data) {
    final rawClass = data['predictedClass'] as String? ?? 'healthy';
    final disease = DiseaseClass.values.firstWhere(
      (e) => e.name == rawClass,
      orElse: () => DiseaseClass.healthy,
    );

    final rawMatches = (data['topMatches'] as List<dynamic>?) ?? [];
    final topMatches = rawMatches.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      final rawMatchClass = map['diseaseClass'] as String? ?? 'healthy';
      final matchDisease = DiseaseClass.values.firstWhere(
        (e) => e.name == rawMatchClass,
        orElse: () => DiseaseClass.healthy,
      );
      return TopMatch(
        diseaseClass: matchDisease,
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final location = data['location'] as GeoPoint?;
    final timestamp = data['diagnosedAt'] as Timestamp?;
    final rawSync = data['syncStatus'] as String? ?? 'synced';
    final syncStatus = SyncStatus.values.firstWhere(
      (e) => e.name == rawSync,
      orElse: () => SyncStatus.synced,
    );

    return Diagnosis(
      id: docId,
      userId: data['userId'] as String? ?? '',
      cropId: data['cropId'] as String? ?? '',
      cropType: data['cropType'] as String? ?? 'Tomato',
      imagePath: (data['imageUrl'] as String?) ?? '',
      predictedClass: disease,
      confidence: (data['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      topMatches: topMatches,
      latitude: location?.latitude,
      longitude: location?.longitude,
      diagnosedAt: timestamp?.toDate() ?? DateTime.now(),
      syncStatus: syncStatus,
    );
  }
}
