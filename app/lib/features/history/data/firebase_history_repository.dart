import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../diagnosis/domain/diagnosis.dart';
import '../../diagnosis/domain/diagnosis_repository.dart';
import '../domain/decision_log_entry.dart';
import '../domain/history_repository.dart';
import '../domain/history_stats.dart';

/// Firebase Firestore implementation of [HistoryRepository].
///
/// Implements statistics calculation purely from [DiagnosisRepository.watchHistory]
/// or [DiagnosisRepository.getHistory] (ensuring compatibility with both fake and real repositories),
/// and manages farmer decision logs under Firestore `decisionLogs` collection.
class FirebaseHistoryRepository implements HistoryRepository {
  final DiagnosisRepository _diagnosisRepository;
  final FirebaseFirestore _firestore;
  final String? Function()? _currentUserIdProvider;

  FirebaseHistoryRepository({
    required DiagnosisRepository diagnosisRepository,
    FirebaseFirestore? firestore,
    String? Function()? currentUserIdProvider,
  })  : _diagnosisRepository = diagnosisRepository,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUserIdProvider = currentUserIdProvider;

  CollectionReference<Map<String, dynamic>> get _decisionLogsRef =>
      _firestore.collection('decisionLogs');

  /// Computes [HistoryStats] from diagnoses retrieved via [DiagnosisRepository].
  ///
  /// Calculates:
  /// - totalScans
  /// - healthyPercent
  /// - topIssue (most frequent non-healthy disease)
  /// - 8-week chronological bucket count (handling month boundaries)
  /// - diseaseBreakdown (counts per disease class)
  @override
  Future<HistoryStats> getStats({String? userId}) async {
    final diagnoses = await _diagnosisRepository.getHistory(userId: userId);
    return computeStatsFromDiagnoses(diagnoses);
  }

  /// Pure computation function that derives [HistoryStats] from a list of diagnoses.
  static HistoryStats computeStatsFromDiagnoses(
    List<Diagnosis> diagnoses, {
    DateTime? referenceDate,
  }) {
    if (diagnoses.isEmpty) {
      final emptyWeekly = _buildEmptyWeeklyBuckets(referenceDate ?? DateTime.now());
      return HistoryStats(
        totalScans: 0,
        healthyPercent: 100,
        topIssue: 'None',
        weeklyScans: emptyWeekly,
        diseaseBreakdown: const {},
      );
    }

    final totalScans = diagnoses.length;
    final healthyCount = diagnoses.where((d) => d.predictedClass.isHealthy).length;
    final healthyPercent = ((healthyCount / totalScans) * 100).round();

    // Disease breakdown and top issue calculation
    final diseaseBreakdown = <String, int>{};
    final issueCounts = <String, int>{};

    for (final diagnosis in diagnoses) {
      final name = diagnosis.predictedClass.displayName;
      diseaseBreakdown[name] = (diseaseBreakdown[name] ?? 0) + 1;

      if (!diagnosis.predictedClass.isHealthy) {
        issueCounts[name] = (issueCounts[name] ?? 0) + 1;
      }
    }

    String topIssue = 'None';
    if (issueCounts.isNotEmpty) {
      final sortedIssues = issueCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topIssue = sortedIssues.first.key;
    }

    // 8-week scan count calculation across month boundaries
    final weeklyScans = _calculateWeeklyBuckets(diagnoses, referenceDate ?? DateTime.now());

    return HistoryStats(
      totalScans: totalScans,
      healthyPercent: healthyPercent,
      topIssue: topIssue,
      weeklyScans: weeklyScans,
      diseaseBreakdown: diseaseBreakdown,
    );
  }

  /// Builds 8 weekly bucket labels (e.g. W1 to W8) and counts matching diagnoses.
  static Map<String, int> _calculateWeeklyBuckets(
    List<Diagnosis> diagnoses,
    DateTime now,
  ) {
    // 8 weeks: [W1, W2, W3, W4, W5, W6, W7, W8] where W8 is current week
    final buckets = <String, int>{};
    for (int i = 7; i >= 0; i--) {
      final weekIndex = 8 - i;
      buckets['W$weekIndex'] = 0;
    }

    // Start of the 8th week cycle (7 * 7 days ago)
    for (final diagnosis in diagnoses) {
      final diffDays = now.difference(diagnosis.diagnosedAt).inDays;
      if (diffDays >= 0 && diffDays < 56) {
        // 0..7 days ago -> W8 (index 7 from end)
        // 49..55 days ago -> W1
        final weekFromEnd = diffDays ~/ 7;
        final weekIndex = 8 - weekFromEnd;
        final key = 'W$weekIndex';
        if (buckets.containsKey(key)) {
          buckets[key] = (buckets[key] ?? 0) + 1;
        }
      }
    }

    return buckets;
  }

  static Map<String, int> _buildEmptyWeeklyBuckets(DateTime now) {
    final buckets = <String, int>{};
    for (int i = 1; i <= 8; i++) {
      buckets['W$i'] = 0;
    }
    return buckets;
  }

  /// Fetches chronological decision logs for the given or current user.
  @override
  Future<List<DecisionLogEntry>> getDecisions({String? userId}) async {
    final uid = userId ?? _currentUserIdProvider?.call();
    try {
      Query<Map<String, dynamic>> query = _decisionLogsRef;
      if (uid != null && uid.isNotEmpty) {
        query = query.where('userId', isEqualTo: uid);
      }
      query = query.orderBy('date', descending: true);

      final snapshot = await query.get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map(_fromFirestore).toList();
    } catch (e) {
      debugPrint('[FirebaseHistoryRepository] Error getting decisions: $e');
      return [];
    }
  }

  /// Adds a new farmer action or decision log entry to Firestore.
  @override
  Future<DecisionLogEntry> addDecision(DecisionLogEntry entry) async {
    final uid = entry.userId.isNotEmpty
        ? entry.userId
        : (_currentUserIdProvider?.call() ?? 'anonymous');

    final updatedEntry = entry.copyWith(userId: uid);
    final docRef = updatedEntry.id.isNotEmpty
        ? _decisionLogsRef.doc(updatedEntry.id)
        : _decisionLogsRef.doc();

    final toSave = updatedEntry.copyWith(id: docRef.id);
    await docRef.set(_toFirestore(toSave));
    return toSave;
  }

  /// Helper for other features to record a farmer action into the decision timeline.
  Future<DecisionLogEntry> recordAction({
    required String title,
    required String detail,
    required String resultLabel,
    String? cropId,
    SyncStatus syncStatus = SyncStatus.synced,
    DateTime? date,
  }) async {
    final entry = DecisionLogEntry(
      id: '',
      userId: _currentUserIdProvider?.call() ?? '',
      date: date ?? DateTime.now(),
      title: title,
      detail: detail,
      resultLabel: resultLabel,
      cropId: cropId,
      syncStatus: syncStatus,
    );
    return addDecision(entry);
  }

  // --- Firestore Serialization ---

  static DecisionLogEntry _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final timestamp = data['date'];
    final date = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse(timestamp?.toString() ?? '') ?? DateTime.now();

    final syncStr = data['syncStatus'] as String? ?? 'synced';
    final syncStatus = syncStr == 'pending' ? SyncStatus.pending : SyncStatus.synced;

    return DecisionLogEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      date: date,
      title: data['title'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      resultLabel: data['resultLabel'] as String? ?? '',
      cropId: data['cropId'] as String?,
      syncStatus: syncStatus,
    );
  }

  static Map<String, dynamic> _toFirestore(DecisionLogEntry entry) {
    return {
      'userId': entry.userId,
      'date': Timestamp.fromDate(entry.date),
      'title': entry.title,
      'detail': entry.detail,
      'resultLabel': entry.resultLabel,
      if (entry.cropId != null) 'cropId': entry.cropId,
      'syncStatus': entry.syncStatus.name,
    };
  }
}
