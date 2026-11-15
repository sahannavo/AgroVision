import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/crop_plots/data/firebase_crop_plot_repository.dart';
import 'package:app/features/crop_plots/domain/crop_plot.dart';

const _firestoreEmulatorHost = 'localhost';
const _firestoreEmulatorPort = 8080;
const _projectId = 'agrovision-dev';

bool _isEmulatorAvailable = false;
FirebaseCropPlotRepository _validationRepo = FirebaseCropPlotRepository();
FirebaseCropPlotRepository? _repo;
FirebaseFirestore? _firestore;

Future<void> _bootstrap() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: '1:000000000000:android:0000000000000000000000',
        messagingSenderId: '000000000000',
        projectId: _projectId,
        storageBucket: '$_projectId.appspot.com',
      ),
    );

    FirebaseFirestore.instance.useFirestoreEmulator(
      _firestoreEmulatorHost,
      _firestoreEmulatorPort,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );

    _firestore = FirebaseFirestore.instance;
    _repo = FirebaseCropPlotRepository(firestore: _firestore);
    _isEmulatorAvailable = true;
  } catch (_) {
    _isEmulatorAvailable = false;
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _bootstrap();
  });

  group('FirebaseCropPlotRepository validation', () {
    test('addPlot throws ArgumentError when areaSize is <= 0', () {
      final invalidPlot = CropPlot(
        userId: 'farmer_01',
        name: 'Tomato Zero Area',
        cropType: 'Tomato',
        plantedDate: DateTime.now().subtract(const Duration(days: 5)),
        soilType: 'Loam',
        areaSize: 0.0,
      );

      expect(
        () => _validationRepo.addPlot(invalidPlot),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('area must be greater than 0'),
        )),
      );
    });

    test('addPlot throws ArgumentError when plantedDate is in the future', () {
      final futurePlot = CropPlot(
        userId: 'farmer_01',
        name: 'Future Chilli',
        cropType: 'Chilli',
        plantedDate: DateTime.now().add(const Duration(days: 10)),
        soilType: 'Clay',
        areaSize: 1.5,
      );

      expect(
        () => _validationRepo.addPlot(futurePlot),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Planted date cannot be in the future'),
        )),
      );
    });

    test('updatePlot throws ArgumentError when areaSize is <= 0', () {
      final invalidPlot = CropPlot(
        id: 'plot_01',
        userId: 'farmer_01',
        name: 'Tomato Negative Area',
        cropType: 'Tomato',
        plantedDate: DateTime.now().subtract(const Duration(days: 5)),
        soilType: 'Loam',
        areaSize: -0.5,
      );

      expect(
        () => _validationRepo.updatePlot(invalidPlot),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('area must be greater than 0'),
        )),
      );
    });
  });

  group('FirebaseCropPlotRepository Firestore operations', () {
    const userA = 'farmer_user_A';
    const userB = 'farmer_user_B';

    test('addPlot successfully saves to cropProfiles collection', () async {
      if (!_isEmulatorAvailable) return;
      final plot = CropPlot(
        userId: userA,
        name: 'Tomato (Thilina)',
        cropType: 'Tomato',
        plantedDate: DateTime.now().subtract(const Duration(days: 20)),
        soilType: 'Loam',
        growthStage: GrowthStage.flowering,
        areaSize: 1.2,
        location: 'North Field Bed #2',
      );

      final added = await _repo!.addPlot(plot);
      expect(added.id, isNotEmpty);
      expect(added.userId, userA);

      final doc = await _firestore!.collection('cropProfiles').doc(added.id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Tomato (Thilina)');
      expect(doc.data()!['cropType'], 'Tomato');
      expect(doc.data()!['areaSize'], 1.2);
      expect(doc.data()!['area'], 1.2);
    }, skip: _isEmulatorAvailable ? null : 'Firebase emulator is not running');

    test('updatePlot updates existing crop plot data', () async {
      if (!_isEmulatorAvailable) return;
      final plot = CropPlot(
        userId: userA,
        name: 'Green Chilli (MICH 1)',
        cropType: 'Chilli',
        plantedDate: DateTime.now().subtract(const Duration(days: 15)),
        soilType: 'Loam',
        growthStage: GrowthStage.vegetative,
        areaSize: 0.8,
      );

      final added = await _repo!.addPlot(plot);

      final updated = CropPlot(
        id: added.id,
        userId: userA,
        name: 'Green Chilli (MICH 1 Updated)',
        cropType: 'Chilli',
        plantedDate: added.plantedDate,
        soilType: 'Loam',
        growthStage: GrowthStage.fruiting,
        areaSize: 0.9,
      );

      await _repo!.updatePlot(updated);

      final doc = await _firestore!.collection('cropProfiles').doc(added.id).get();
      expect(doc.data()!['name'], 'Green Chilli (MICH 1 Updated)');
      expect(doc.data()!['growthStage'], GrowthStage.fruiting.displayName);
      expect(doc.data()!['areaSize'], 0.9);
    }, skip: _isEmulatorAvailable ? null : 'Firebase emulator is not running');

    test('deletePlot removes crop plot from collection', () async {
      if (!_isEmulatorAvailable) return;
      final plot = CropPlot(
        userId: userA,
        name: 'Temporary Plot',
        cropType: 'Eggplant',
        plantedDate: DateTime.now().subtract(const Duration(days: 10)),
        soilType: 'Sandy',
        areaSize: 0.5,
      );

      final added = await _repo!.addPlot(plot);
      await _repo!.deletePlot(added.id);

      final doc = await _firestore!.collection('cropProfiles').doc(added.id).get();
      expect(doc.exists, isFalse);
    }, skip: _isEmulatorAvailable ? null : 'Firebase emulator is not running');

    test('user A cannot read user B crop plots in query isolation', () async {
      if (!_isEmulatorAvailable) return;
      // Add plot for user A
      await _repo!.addPlot(CropPlot(
        userId: userA,
        name: 'User A Plot',
        cropType: 'Tomato',
        plantedDate: DateTime.now().subtract(const Duration(days: 30)),
        soilType: 'Loam',
        areaSize: 1.0,
      ));

      // Add plot for user B
      await _repo!.addPlot(CropPlot(
        userId: userB,
        name: 'User B Plot',
        cropType: 'Potato',
        plantedDate: DateTime.now().subtract(const Duration(days: 12)),
        soilType: 'Clay',
        areaSize: 2.0,
      ));

      final plotsUserA = await _repo!.getPlots(userId: userA);
      expect(plotsUserA.any((p) => p.userId == userB), isFalse);
      expect(plotsUserA.every((p) => p.userId == userA), isTrue);

      final plotsUserB = await _repo!.getPlots(userId: userB);
      expect(plotsUserB.any((p) => p.userId == userA), isFalse);
      expect(plotsUserB.every((p) => p.userId == userB), isTrue);
    }, skip: _isEmulatorAvailable ? null : 'Firebase emulator is not running');

    test('user A cannot read user B crop plots under AHMS security rules', () async {
      // TODO: Test against live emulator security rules with Auth tokens once AHMS rule suite runs in CI
      // Verification: firestore.rules enforces `allow read: if isDocOwner();`
    }, skip: 'Requires live authenticated tokens in emulator environment');
  });
}
