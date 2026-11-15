import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../domain/crop_plot.dart';
import '../domain/crop_plot_repository.dart';

/// Firebase Firestore implementation of [CropPlotRepository].
///
/// Manages documents in the top-level `cropProfiles` collection.
/// Reads and writes work offline via Firestore local persistence cache.
class FirebaseCropPlotRepository implements CropPlotRepository {
  FirebaseCropPlotRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  final FirebaseFirestore? _customFirestore;
  final fb.FirebaseAuth? _customAuth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  fb.FirebaseAuth get _auth => _customAuth ?? fb.FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('cropProfiles');

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Validates write constraints per specification:
  /// - Area must be strictly greater than 0.
  /// - Planted date cannot be in the future.
  void _validate(CropPlot plot) {
    if (plot.areaSize <= 0) {
      throw ArgumentError('Crop plot area must be greater than 0.');
    }
    // Allow small clock skew allowance (1 minute)
    if (plot.plantedDate.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      throw ArgumentError('Planted date cannot be in the future.');
    }
  }

  @override
  Stream<List<CropPlot>> watchPlots({String? userId}) {
    final targetUid = userId ?? _currentUserId;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const <CropPlot>[]);
    }

    return _collection
        .where('userId', isEqualTo: targetUid)
        .orderBy('plantedDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<List<CropPlot>> getPlots({String? userId}) async {
    final targetUid = userId ?? _currentUserId;
    if (targetUid == null || targetUid.isEmpty) {
      return const <CropPlot>[];
    }

    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: targetUid)
          .orderBy('plantedDate')
          .get();
      return snapshot.docs.map(_fromDoc).toList();
    } catch (_) {
      // Fallback to local cache if network is unavailable
      final cacheSnap = await _collection
          .where('userId', isEqualTo: targetUid)
          .orderBy('plantedDate')
          .get(const GetOptions(source: Source.cache));
      return cacheSnap.docs.map(_fromDoc).toList();
    }
  }

  @override
  Future<CropPlot> addPlot(CropPlot plot) async {
    _validate(plot);

    final targetUid = plot.userId.isNotEmpty ? plot.userId : (_currentUserId ?? '');
    final docRef = plot.id.isNotEmpty ? _collection.doc(plot.id) : _collection.doc();
    final newId = docRef.id;

    final createdPlot = CropPlot(
      id: newId,
      userId: targetUid,
      name: plot.name,
      cropType: plot.cropType,
      plantedDate: plot.plantedDate,
      soilType: plot.soilType,
      growthStage: plot.growthStage,
      areaSize: plot.areaSize,
      location: plot.location,
      variety: plot.variety,
      bed: plot.bed,
      status: plot.status,
      areaUnit: plot.areaUnit,
    );

    await docRef.set(_toMap(createdPlot, targetUid));
    return createdPlot;
  }

  @override
  Future<void> updatePlot(CropPlot plot) async {
    _validate(plot);

    final targetUid = plot.userId.isNotEmpty ? plot.userId : (_currentUserId ?? '');
    await _collection.doc(plot.id).set(
      _toMap(plot, targetUid),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deletePlot(String plotId) async {
    await _collection.doc(plotId).delete();
  }

  Map<String, dynamic> _toMap(CropPlot plot, String targetUserId) {
    return <String, dynamic>{
      'cropId': plot.id,
      'userId': targetUserId,
      'name': plot.name,
      'cropType': plot.cropType,
      'plantedDate': Timestamp.fromDate(plot.plantedDate),
      'soilType': plot.soilType,
      'growthStage': plot.growthStage,
      'areaSize': plot.areaSize,
      'area': plot.areaSize,
      'location': plot.location,
      if (plot.variety != null) 'variety': plot.variety,
      if (plot.bed != null) 'bed': plot.bed,
      if (plot.status != null) 'status': plot.status,
      'areaUnit': plot.areaUnit,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CropPlot _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    DateTime planted;
    final rawDate = data['plantedDate'];
    if (rawDate is Timestamp) {
      planted = rawDate.toDate();
    } else if (rawDate is String) {
      planted = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      planted = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      planted = DateTime.now();
    }

    final dynamic areaVal = data['areaSize'] ?? data['area'];
    final double area = (areaVal is num) ? areaVal.toDouble() : 0.0;

    return CropPlot(
      id: data['cropId'] as String? ?? doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      cropType: data['cropType'] as String? ?? '',
      plantedDate: planted,
      soilType: data['soilType'] as String? ?? '',
      growthStage: data['growthStage'] as String? ?? 'Seedling',
      areaSize: area,
      location: data['location'] as String? ?? '',
      variety: data['variety'] as String?,
      bed: data['bed'] as String?,
      status: data['status'] as String?,
      areaUnit: data['areaUnit'] as String? ?? 'acre',
    );
  }
}
