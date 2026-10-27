import 'package:flutter/foundation.dart';
import '../../diagnosis/domain/diagnosis.dart';

/// Single farm decision log entry recorded in the History timeline.
@immutable
class DecisionLogEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String title;
  final String detail;
  final String resultLabel;
  final SyncStatus syncStatus;
  final String? cropId;

  const DecisionLogEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.detail,
    required this.resultLabel,
    this.syncStatus = SyncStatus.synced,
    this.cropId,
  });

  DecisionLogEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? title,
    String? detail,
    String? resultLabel,
    SyncStatus? syncStatus,
    String? cropId,
  }) {
    return DecisionLogEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      resultLabel: resultLabel ?? this.resultLabel,
      syncStatus: syncStatus ?? this.syncStatus,
      cropId: cropId ?? this.cropId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionLogEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          title == other.title &&
          detail == other.detail &&
          resultLabel == other.resultLabel &&
          syncStatus == other.syncStatus &&
          cropId == other.cropId;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        date.year,
        date.month,
        date.day,
        title,
        detail,
        resultLabel,
        syncStatus,
        cropId,
      );

  @override
  String toString() =>
      'DecisionLogEntry(id: $id, title: $title, result: $resultLabel, sync: $syncStatus)';
}
