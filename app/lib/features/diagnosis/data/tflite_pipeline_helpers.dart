import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../domain/diagnosis.dart';
import 'disease_catalog.dart';

/// Exception thrown when the on-device classifier encounters a model, label,
/// image, or inference error.
/// Handled cleanly by presentation screens to display error states rather than crashing.
class ClassifierException implements Exception {
  final String message;
  final Object? originalError;

  const ClassifierException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

/// Parameters passed to the image preprocessing worker.
class PreprocessParams {
  final Uint8List imageBytes;
  final int targetWidth;
  final int targetHeight;

  const PreprocessParams(this.imageBytes, this.targetWidth, this.targetHeight);
}

/// Decodes [params.imageBytes], bakes EXIF orientation, resizes linearly to
/// [params.targetWidth] x [params.targetHeight], and produces a `[1, H, W, 3]`
/// RGB float buffer normalized to `[-1.0, 1.0]` using `(pixel - 127.5) / 127.5`.
///
/// Matches the preprocessing contract documented in `ml/README.md`.
List<List<List<List<double>>>> preprocessImageBytes(PreprocessParams params) {
  final decoded = img.decodeImage(params.imageBytes);
  if (decoded == null) {
    throw const ClassifierException(
      'Could not decode image file. File may be corrupted or unsupported.',
    );
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

  // Build [1, height, width, 3] buffer normalized to [-1.0, 1.0] in RGB order
  return List.generate(
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
}

/// Validates that the model's output class dimension matches the loaded labels count.
void validateModelLabelCount({
  required int outputClassCount,
  required int labelsCount,
}) {
  if (outputClassCount <= 0) {
    throw ClassifierException(
      'Invalid model output class dimension: $outputClassCount.',
    );
  }
  if (outputClassCount != labelsCount) {
    throw ClassifierException(
      'Model output dimension ($outputClassCount) does not match '
      'labels.txt count ($labelsCount).',
    );
  }
}

/// Ensures raw model outputs represent a valid probability distribution, applying
/// numerically stable softmax if the model emitted raw logits.
List<double> normalizeModelProbabilities(List<double> rawOutputs) {
  if (rawOutputs.isEmpty) {
    throw const ClassifierException('Model produced an empty output vector.');
  }

  final sum = rawOutputs.fold<double>(0.0, (acc, val) => acc + val);
  final looksLikeProbabilities =
      rawOutputs.every((v) => v >= 0.0 && v <= 1.0) &&
          sum > 0.90 &&
          sum < 1.10;

  if (looksLikeProbabilities) {
    return List<double>.from(rawOutputs);
  }

  final maxVal = rawOutputs.reduce((a, b) => a > b ? a : b);
  final exps = rawOutputs.map((v) => math.exp(v - maxVal)).toList();
  final expSum = exps.reduce((a, b) => a + b);
  if (expSum == 0.0 || expSum.isNaN || expSum.isInfinite) {
    throw const ClassifierException('Model produced non-finite output values.');
  }
  return exps.map((v) => v / expSum).toList();
}

/// Ranks canonical labels by descending probability and returns the top [topK] pairs.
List<({String label, double score})> rankPredictions(
  List<String> labels,
  List<double> probabilities, {
  int topK = 3,
}) {
  if (labels.isEmpty) {
    throw const ClassifierException('Labels list is empty.');
  }
  if (labels.length != probabilities.length) {
    throw ClassifierException(
      'Probability vector length (${probabilities.length}) does not match '
      'labels length (${labels.length}).',
    );
  }

  final ranked = List.generate(
    labels.length,
    (i) => (
      label: labels[i],
      score: probabilities[i].clamp(0.0, 1.0).toDouble(),
    ),
  )..sort((a, b) => b.score.compareTo(a.score));

  return ranked.take(topK).toList();
}

/// Maps ranked label/probability predictions and catalog metadata into a [Diagnosis].
Diagnosis buildDiagnosisFromScores({
  required List<String> labels,
  required List<double> rawOutputs,
  required DiseaseCatalog catalog,
  required String imagePath,
  String? cropType,
  String? cropId,
  String? userId,
  double? latitude,
  double? longitude,
  DateTime? diagnosedAt,
}) {
  final probabilities = normalizeModelProbabilities(rawOutputs);
  final topMatchesRanked = rankPredictions(labels, probabilities, topK: 3);

  final top3 = topMatchesRanked.map((match) {
    final entry = catalog.lookup(match.label);
    return TopMatch(
      diseaseClass: entry.diseaseClass,
      confidence: match.score,
    );
  }).toList();

  final topMatch = topMatchesRanked.first;
  final topEntry = catalog.lookup(topMatch.label);
  final timestamp = diagnosedAt ?? DateTime.now();

  return Diagnosis(
    id: 'diag_${timestamp.millisecondsSinceEpoch}',
    userId: userId ?? 'farmer_local_01',
    cropId: cropId,
    cropType: cropType ?? topEntry.crop,
    imagePath: imagePath,
    predictedClass: topEntry.diseaseClass,
    confidence: topMatch.score,
    topMatches: top3,
    latitude: latitude,
    longitude: longitude,
    diagnosedAt: timestamp,
    syncStatus: SyncStatus.pending,
  );
}
