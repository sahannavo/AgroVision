import 'dart:async';
import '../domain/diagnosis.dart';
import '../domain/diagnosis_repository.dart';
import '../domain/disease_class.dart';

/// Fake implementation of [DiagnosisRepository] returning sample diagnoses
/// from the design PNGs (Early Blight on Tomato 92%, Kurunegala).
class FakeDiagnosisRepository implements DiagnosisRepository {
  FakeDiagnosisRepository({
    this.delay = const Duration(milliseconds: 300),
  }) {
    _history = List.of(_initialSampleHistory);
    _controller = StreamController<List<Diagnosis>>.broadcast(
      onListen: () => _controller.add(List.unmodifiable(_history)),
    );
  }

  final Duration delay;
  late final List<Diagnosis> _history;
  late final StreamController<List<Diagnosis>> _controller;

  static List<Diagnosis> get _initialSampleHistory {
    final now = DateTime.now();
    return [
      Diagnosis(
        id: 'diag_sample_01',
        userId: 'farmer_nimal_01',
        cropId: 'plot_tomato_01',
        cropType: 'Tomato',
        imagePath: 'assets/sample/early_blight_tomato.jpg',
        predictedClass: DiseaseClass.earlyBlight,
        confidence: 0.92,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.earlyBlight, confidence: 0.92),
          TopMatch(diseaseClass: DiseaseClass.lateBlight, confidence: 0.05),
          TopMatch(diseaseClass: DiseaseClass.healthy, confidence: 0.03),
        ],
        latitude: 7.4863,
        longitude: 80.3623,
        diagnosedAt: now.subtract(const Duration(hours: 2)),
        syncStatus: SyncStatus.synced,
      ),
      Diagnosis(
        id: 'diag_sample_02',
        userId: 'farmer_nimal_01',
        cropId: 'plot_chilli_01',
        cropType: 'Chilli',
        imagePath: 'assets/sample/chilli_leaf.jpg',
        predictedClass: DiseaseClass.healthy,
        confidence: 0.96,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.healthy, confidence: 0.96),
          TopMatch(diseaseClass: DiseaseClass.bacterialSpot, confidence: 0.03),
        ],
        latitude: 7.4863,
        longitude: 80.3623,
        diagnosedAt: now.subtract(const Duration(days: 3)),
        syncStatus: SyncStatus.synced,
      ),
      Diagnosis(
        id: 'diag_sample_03',
        userId: 'farmer_nimal_01',
        cropId: 'plot_brinjal_01',
        cropType: 'Eggplant',
        imagePath: 'assets/sample/brinjal_leaf.jpg',
        predictedClass: DiseaseClass.healthy,
        confidence: 0.94,
        topMatches: const [
          TopMatch(diseaseClass: DiseaseClass.healthy, confidence: 0.94),
          TopMatch(diseaseClass: DiseaseClass.leafCurl, confidence: 0.04),
        ],
        latitude: 7.4863,
        longitude: 80.3623,
        diagnosedAt: now.subtract(const Duration(days: 7)),
        syncStatus: SyncStatus.synced,
      ),
    ];
  }

  @override
  Stream<List<Diagnosis>> watchHistory({String? userId}) => _controller.stream;

  @override
  Future<List<Diagnosis>> getHistory({String? userId}) async {
    await Future<void>.delayed(delay);
    return List.unmodifiable(_history);
  }

  @override
  Future<Diagnosis> save(Diagnosis diagnosis) async {
    await Future<void>.delayed(delay);
    _history.insert(0, diagnosis);
    _controller.add(List.unmodifiable(_history));
    return diagnosis;
  }

  void dispose() {
    _controller.close();
  }
}

