import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Service: thin wrapper around the TFLite interpreter. No business logic —
// just loads the model, preprocesses images, and runs inference. The
// repository layer decides what to do with the result.
class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult({required this.label, required this.confidence});
}

class MlClassifierService {
  static const String _modelPath = 'assets/models/food_model.tflite';
  static const String _labelsPath = 'assets/labels/labels.txt';
  static const int _inputSize = 192; // this model expects 192x192 images

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(_modelPath);
    final labelsData = await rootBundle.loadString(_labelsPath);
    _labels = labelsData.split('\n').where((l) => l.trim().isNotEmpty).toList();
  }

  bool get isReady => _interpreter != null && _labels != null;

  Future<ClassificationResult> classify(File imageFile) async {
    if (!isReady) {
      throw StateError('MlClassifierService.loadModel() must be called first');
    }

    // Decode and resize the image to what the model expects
    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) {
      throw const FormatException('Could not decode image file');
    }
    final resized = img.copyResize(rawImage, width: _inputSize, height: _inputSize);

    // Convert to a flat Uint8List of RGB values (this model takes quantized
    // uint8 input, not normalized floats)
    final input = List.generate(
      1,
          (_) => List.generate(
        _inputSize,
            (y) => List.generate(
          _inputSize,
              (x) {
            final pixel = resized.getPixel(x, y);
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          },
        ),
      ),
    );

    // Output shape matches the number of labels (quantized uint8 scores)
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final output = List.filled(outputShape.reduce((a, b) => a * b), 0)
        .reshape(outputShape);

    _interpreter!.run(input, output);

    // Find the highest-scoring class
    final scores = (output[0] as List).cast<int>();
    int bestIndex = 0;
    int bestScore = 0;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIndex = i;
      }
    }

    final label = (bestIndex < _labels!.length) ? _labels![bestIndex] : 'unknown';
    final confidence = bestScore / 255.0; // quantized output, 0-255 range

    return ClassificationResult(label: label, confidence: confidence);
  }

  void dispose() {
    _interpreter?.close();
  }
}