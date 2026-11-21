import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/diagnosis.dart';
import '../domain/diagnosis_classifier.dart';
import 'disease_catalog.dart';

/// Exception thrown when on-device classifier encounters a model, image, or inference error.
/// Handled cleanly by presentation screens to display error states rather than crashing.
class ClassifierException implements Exception {
  final String message;
  final Object? originalError;

  const ClassifierException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

/// Parameters passed to background isolate for off-thread image preprocessing.
class _PreprocessParams {
  final Uint8List imageBytes;
  final int targetWidth;
  final int targetHeight;

  const _PreprocessParams(this.imageBytes, this.targetWidth, this.targetHeight);
}

/// Top-level worker executed in a background isolate via [compute].
/// Replicates the preprocessing contract defined in ml/README.md:
/// 1. Reads image bytes and checks validity.
/// 2. Bakes EXIF orientation so rotated photos are correctly aligned.
/// 3. Resizes to model input dimensions (224x224).
/// 4. Converts to RGB float32 normalized from [0, 255] to [-1.0, 1.0] using (pixel - 127.5) / 127.5.
List<List<List<List<double>>>> _preprocessWorker(_PreprocessParams params) {
  final decoded = img.decodeImage(params.imageBytes);
  if (decoded == null) {
    throw const ClassifierException('Could not decode image file. File may be corrupted or unsupported.');
  }

  // Bake orientation to correct EXIF rotation
  final oriented = img.bakeOrientation(decoded);

  // Resize using linear interpolation
  final resized = img.copyResize(
    oriented,
    width: params.targetWidth,
    height: params.targetHeight,
    interpolation: img.Interpolation.linear,
  );

  final height = params.targetHeight;
  final width = params.targetWidth;

  // Build [1, height, width, 3] buffer normalized to [-1.0, 1.0]
  final buffer = List.generate(
    1,
    (_) => List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          final pixel = resized.getPixel(x, y);
          return <double>[
            (pixel.r - 127.5) / 127.5,
            (pixel.g - 127.5) / 127.5,
            (pixel.b - 127.5) / 127.5,
          ];
        },
      ),
    ),
  );

  return buffer;
}

/// Production implementation of [DiagnosisClassifier] backed by TensorFlow Lite.
///
/// Features:
/// - Singleton / single load: loads the model and labels once.
/// - Dynamic input introspection: reads input dimensions and tensor type directly from the model.
/// - Preprocessing contract: RGB order, [-1, 1] normalization, EXIF orientation correction.
/// - Off-UI-thread execution: image preprocessing runs inside [compute].
/// - Catalog mapping: maps 0-indexed outputs to canonical labels and rich disease catalog text.
/// - Graceful error handling: handles missing models, corrupt images, and inference faults safely.
class TfliteClassifier implements DiagnosisClassifier {
  final String modelAssetPath;
  final String labelsAssetPath;
  final String catalogAssetPath;

  Interpreter? _interpreter;
  List<String>? _labels;
  DiseaseCatalog? _catalog;

  int _inputHeight = 224;
  int _inputWidth = 224;
  int _inputChannels = 3;
  TensorType _inputType = TensorType.float32;
  bool _isInitialized = false;

  TfliteClassifier({
    this.modelAssetPath = 'assets/model/model.tflite',
    this.labelsAssetPath = 'assets/model/labels.txt',
    this.catalogAssetPath = 'assets/data/disease_catalog.json',
    Interpreter? interpreter,
    List<String>? labels,
    DiseaseCatalog? catalog,
  })  : _interpreter = interpreter,
        _labels = labels,
        _catalog = catalog {
    if (interpreter != null && labels != null && catalog != null) {
      _applyModelMetadata(interpreter);
      _isInitialized = true;
    }
  }

  void _applyModelMetadata(Interpreter interpreter) {
    final inputTensor = interpreter.getInputTensor(0);
    final shape = inputTensor.shape;
    if (shape.length >= 4) {
      _inputHeight = shape[1];
      _inputWidth = shape[2];
      _inputChannels = shape[3];
    }
    _inputType = inputTensor.type;
  }

  /// Initialises the model, labels, and disease catalog once.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    // 1. Load labels.txt
    if (_labels == null) {
      _labels = await _loadLabels();
    }

    // 2. Load DiseaseCatalog
    if (_catalog == null) {
      _catalog = await DiseaseCatalog.loadFromAsset(assetPath: catalogAssetPath);
    }

    // 3. Load TFLite model
    if (_interpreter == null) {
      _interpreter = await _loadInterpreter();
      _applyModelMetadata(_interpreter!);
    }

    _isInitialized = true;
  }

  Future<List<String>> _loadLabels() async {
    String text;
    try {
      text = await rootBundle.loadString(labelsAssetPath);
    } catch (_) {
      final file = File(labelsAssetPath);
      if (file.existsSync()) {
        text = await file.readAsString();
      } else {
        final nestedFile = File('app/$labelsAssetPath');
        if (nestedFile.existsSync()) {
          text = await nestedFile.readAsString();
        } else {
          throw ClassifierException('Labels file not found at $labelsAssetPath');
        }
      }
    }

    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw const ClassifierException('Labels file is empty.');
    }
    return lines;
  }

  Future<Interpreter> _loadInterpreter() async {
    try {
      return await Interpreter.fromAsset(modelAssetPath);
    } catch (_) {
      // Headless / test environment fallback to File system
      final file = File(modelAssetPath);
      if (file.existsSync()) {
        return Interpreter.fromFile(file);
      }
      final nestedFile = File('app/$modelAssetPath');
      if (nestedFile.existsSync()) {
        return Interpreter.fromFile(nestedFile);
      }
      throw ClassifierException('TFLite model file not found at $modelAssetPath');
    }
  }

  @override
  Future<Diagnosis> classify(
    String imagePath, {
    String? cropType,
    String? cropId,
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _ensureInitialized();
    } catch (e) {
      if (e is ClassifierException) rethrow;
      throw ClassifierException('Failed to initialise TFLite model: $e', e);
    }

    final file = File(imagePath);
    if (!file.existsSync()) {
      throw ClassifierException('Image file not found: $imagePath');
    }

    Uint8List imageBytes;
    try {
      imageBytes = await file.readAsBytes();
      if (imageBytes.isEmpty) {
        throw const ClassifierException('Image file is empty or corrupted.');
      }
    } catch (e) {
      if (e is ClassifierException) rethrow;
      throw ClassifierException('Could not read image file: $e', e);
    }

    // Run off UI thread in background isolate via compute
    List<List<List<List<double>>>> inputBuffer;
    try {
      inputBuffer = await compute(
        _preprocessWorker,
        _PreprocessParams(imageBytes, _inputWidth, _inputHeight),
      );
    } catch (e) {
      if (e is ClassifierException) rethrow;
      throw ClassifierException('Failed to preprocess image: $e', e);
    }

    // Allocate output buffer [1, num_classes]
    final numClasses = _labels!.length;
    final outputBuffer = List.generate(1, (_) => List<double>.filled(numClasses, 0.0));

    try {
      _interpreter!.run(inputBuffer, outputBuffer);
    } catch (e) {
      throw ClassifierException('Inference execution error: $e', e);
    }

    final rawOutputs = outputBuffer[0];

    // Verify if outputs are probabilities or raw logits
    final sum = rawOutputs.fold<double>(0.0, (acc, val) => acc + val);
    List<double> probabilities;
    if (sum > 0.90 && sum < 1.10) {
      probabilities = rawOutputs;
    } else {
      // Apply softmax if raw logits were produced
      final maxVal = rawOutputs.reduce((a, b) => a > b ? a : b);
      final exps = rawOutputs.map((v) => math.exp(v - maxVal)).toList();
      final expSum = exps.reduce((a, b) => a + b);
      probabilities = exps.map((v) => v / expSum).toList();
    }

    // Rank classes by descending probability
    final ranked = List.generate(
      numClasses,
      (i) => (label: _labels![i], score: probabilities[i]),
    )..sort((a, b) => b.score.compareTo(a.score));

    // Top-3 matches mapped through catalog
    final top3 = ranked.take(3).map((match) {
      final entry = _catalog!.lookup(match.label);
      return TopMatch(
        diseaseClass: entry.diseaseClass,
        confidence: match.score.clamp(0.0, 1.0),
      );
    }).toList();

    final topMatch = ranked.first;
    final topEntry = _catalog!.lookup(topMatch.label);
    final topConfidence = topMatch.score.clamp(0.0, 1.0);

    return Diagnosis(
      id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'farmer_local_01',
      cropId: cropId,
      cropType: cropType ?? topEntry.crop,
      imagePath: imagePath,
      predictedClass: topEntry.diseaseClass,
      confidence: topConfidence,
      topMatches: top3,
      latitude: latitude,
      longitude: longitude,
      diagnosedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
  }

  /// Releases native interpreter resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
