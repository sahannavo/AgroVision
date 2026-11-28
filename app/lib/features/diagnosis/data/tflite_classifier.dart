import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/diagnosis.dart';
import '../domain/diagnosis_classifier.dart';
import 'disease_catalog.dart';
import 'tflite_pipeline_helpers.dart';

export 'tflite_pipeline_helpers.dart' show ClassifierException;

/// Top-level worker executed in a background isolate via [compute].
/// Replicates the preprocessing contract defined in ml/README.md:
/// 1. Reads image bytes and checks validity.
/// 2. Bakes EXIF orientation so rotated photos are correctly aligned.
/// 3. Resizes to model input dimensions (224x224).
/// 4. Converts to RGB float32 normalized from [0, 255] to [-1.0, 1.0] using (pixel - 127.5) / 127.5.
List<List<List<List<double>>>> _preprocessWorker(PreprocessParams params) {
  return preprocessImageBytes(params);
}

/// Production implementation of [DiagnosisClassifier] backed by TensorFlow Lite.
///
/// Features:
/// - Singleton / single load: loads the model and labels once.
/// - Dynamic input/output introspection: reads input dimensions, tensor type, and
///   output class count directly from the model and validates them against labels.txt.
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
  int? _outputNumClasses;
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
      if (_outputNumClasses != null) {
        validateModelLabelCount(
          outputClassCount: _outputNumClasses!,
          labelsCount: labels.length,
        );
      }
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

    if (_inputChannels != 3) {
      throw ClassifierException(
        'Unsupported model input channels: $_inputChannels. Expected 3 (RGB).',
      );
    }
    if (_inputType != TensorType.float32) {
      throw ClassifierException(
        'Unsupported model input tensor type: $_inputType. Expected float32.',
      );
    }

    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    if (outputShape.isNotEmpty) {
      _outputNumClasses = outputShape.last;
    }
  }

  /// Initialises the model, labels, and disease catalog once.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    // 1. Load labels.txt
    _labels ??= await _loadLabels();

    // 2. Load DiseaseCatalog
    _catalog ??= await DiseaseCatalog.loadFromAsset(assetPath: catalogAssetPath);

    // 3. Load TFLite model
    if (_interpreter == null) {
      _interpreter = await _loadInterpreter();
      _applyModelMetadata(_interpreter!);
    }

    if (_outputNumClasses != null) {
      validateModelLabelCount(
        outputClassCount: _outputNumClasses!,
        labelsCount: _labels!.length,
      );
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
        PreprocessParams(imageBytes, _inputWidth, _inputHeight),
      );
    } catch (e) {
      if (e is ClassifierException) rethrow;
      throw ClassifierException('Failed to preprocess image: $e', e);
    }

    // Allocate output buffer [1, num_classes]
    final numClasses = _labels!.length;
    if (_outputNumClasses != null) {
      validateModelLabelCount(
        outputClassCount: _outputNumClasses!,
        labelsCount: numClasses,
      );
    }
    final outputBuffer = List.generate(1, (_) => List<double>.filled(numClasses, 0.0));

    try {
      _interpreter!.run(inputBuffer, outputBuffer);
    } catch (e) {
      throw ClassifierException('Inference execution error: $e', e);
    }

    return buildDiagnosisFromScores(
      labels: _labels!,
      rawOutputs: outputBuffer[0],
      catalog: _catalog!,
      imagePath: imagePath,
      cropType: cropType,
      cropId: cropId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Releases native interpreter resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
