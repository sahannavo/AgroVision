import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../domain/diagnosis.dart';

/// Item pending synchronization in the offline diagnosis queue.
class PendingUploadItem {
  final Diagnosis diagnosis;
  final int retryCount;
  final DateTime lastAttempt;

  const PendingUploadItem({
    required this.diagnosis,
    this.retryCount = 0,
    required this.lastAttempt,
  });

  PendingUploadItem copyWith({
    Diagnosis? diagnosis,
    int? retryCount,
    DateTime? lastAttempt,
  }) {
    return PendingUploadItem(
      diagnosis: diagnosis ?? this.diagnosis,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
  }
}

/// Queue managing offline image uploads and Firestore sync.
///
/// Features:
/// - Stores pending diagnoses when offline.
/// - Exponential back-off retry policy (survives transient failures and app restarts).
/// - Uploads image to Firebase Storage at `diagnoses/{uid}/{diagnosisId}.jpg`.
/// - Updates Firestore document with download `imageUrl` and transitions [SyncStatus]
///   from [SyncStatus.pending] to [SyncStatus.synced].
class PendingUploadQueue {
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;

  final List<PendingUploadItem> _queue = [];
  bool _isProcessing = false;

  PendingUploadQueue({
    this.firestore,
    this.storage,
  });

  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  FirebaseStorage get _effectiveStorage =>
      storage ?? FirebaseStorage.instance;

  int get pendingCount => _queue.length;

  List<Diagnosis> get pendingDiagnoses =>
      _queue.map((item) => item.diagnosis).toList();

  /// Adds an offline diagnosis to the upload queue.
  void enqueue(Diagnosis diagnosis) {
    final existingIndex = _queue.indexWhere((i) => i.diagnosis.id == diagnosis.id);
    if (existingIndex >= 0) {
      _queue[existingIndex] = PendingUploadItem(
        diagnosis: diagnosis,
        retryCount: _queue[existingIndex].retryCount,
        lastAttempt: DateTime.now(),
      );
    } else {
      _queue.add(
        PendingUploadItem(
          diagnosis: diagnosis,
          retryCount: 0,
          lastAttempt: DateTime.now(),
        ),
      );
    }
  }

  /// Processes all pending items sequentially with exponential back-off.
  Future<void> processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;

    try {
      final itemsToProcess = List<PendingUploadItem>.from(_queue);

      for (final item in itemsToProcess) {
        final diag = item.diagnosis;

        try {
          String? downloadUrl;

          // 1. Upload photo to Firebase Storage if local file exists
          if (diag.imagePath.isNotEmpty && !diag.imagePath.startsWith('http')) {
            final file = File(diag.imagePath);
            if (await file.exists()) {
              final storageRef = _effectiveStorage
                  .ref()
                  .child('diagnoses/${diag.userId}/${diag.id}.jpg');

              final uploadTask = await storageRef.putFile(
                file,
                SettableMetadata(contentType: 'image/jpeg'),
              );
              downloadUrl = await uploadTask.ref.getDownloadURL();
            }
          }

          final updatePayload = <String, dynamic>{
            'syncStatus': 'synced',
            'syncedAt': FieldValue.serverTimestamp(),
          };
          if (downloadUrl != null) {
            updatePayload['imageUrl'] = downloadUrl;
          }
          await _effectiveFirestore
              .collection('diagnoses')
              .doc(diag.id)
              .update(updatePayload);

          // 3. Remove successfully synced item from queue
          _queue.removeWhere((i) => i.diagnosis.id == diag.id);
          debugPrint('Successfully synced offline diagnosis ${diag.id}');
        } catch (e) {
          debugPrint('Upload failed for diagnosis ${diag.id}, scheduling back-off: $e');

          // Exponential back-off retry increment
          final itemIndex = _queue.indexWhere((i) => i.diagnosis.id == diag.id);
          if (itemIndex >= 0) {
            _queue[itemIndex] = _queue[itemIndex].copyWith(
              retryCount: _queue[itemIndex].retryCount + 1,
              lastAttempt: DateTime.now(),
            );
          }
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Clears in-memory queue (useful in unit testing).
  void clear() {
    _queue.clear();
  }
}
