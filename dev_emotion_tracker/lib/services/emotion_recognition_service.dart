// lib/services/emotion_recognition_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class EmotionRecognitionService {
  List<String>? _labels;
  bool _isModelLoaded = false;
  Interpreter? _interpreter;
  int _numClasses = 0;

  // Input and output shapes should match your model
  // Assuming a common setup for a 48x48 grayscale image classification model
  final List<int> _inputShape = [1, 48, 48, 1]; // [batchSize, height, width, channels]
  late List<int> _outputShape; // Will be determined after model is loaded

  EmotionRecognitionService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // 1. Load Labels
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      if (_labels == null || _labels!.isEmpty) {
        throw Exception("Failed to load or parse labels.");
      }
      _numClasses = _labels!.length;

      // 2. Load Model from Assets
      _interpreter = await Interpreter.fromAsset(
        'models/model.tflite', // Path relative to assets folder
        options: InterpreterOptions()..threads = 1, // Set number of threads
      );

      // Optional: Print input and output tensor details to verify
      var inputTensor = _interpreter!.getInputTensor(0);
      var outputTensor = _interpreter!.getOutputTensor(0);
      print('Input Tensor Shape: ${inputTensor.shape}, Type: ${inputTensor.type}');
      print('Output Tensor Shape: ${outputTensor.shape}, Type: ${outputTensor.type}');

      // Validate input shape (optional but recommended)
      if (inputTensor.shape.toString() != _inputShape.toString()) {
          print('Warning: Model input shape ${inputTensor.shape} does not match expected shape $_inputShape');
          // You might want to update _inputShape here if dynamic or throw error
      }

      _outputShape = outputTensor.shape; // e.g., [1, numClasses]
      if (_outputShape.length != 2 || _outputShape[0] != 1 || _outputShape[1] != _numClasses) {
          print('Warning: Model output shape ${outputTensor.shape} does not align with [1, $_numClasses]. Please verify your model structure and labels.');
      }


      _interpreter!.allocateTensors(); // Not always necessary, but good practice

      _isModelLoaded = true;
      print('Emotion recognition model loaded successfully with tflite_flutter');
    } catch (e) {
      print('Error loading emotion recognition model with tflite_flutter: $e');
      _isModelLoaded = false;
    }
  }

  Future<String> detectEmotionFromImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null || _labels == null || _numClasses == 0) {
      print("Error: Emotion model not loaded, interpreter missing, or labels missing.");
      await _loadModel(); // Attempt to reload the model
      if (!_isModelLoaded || _interpreter == null || _labels == null || _numClasses == 0) {
        return "Error: Emotion model could not be loaded.";
      }
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        return "Error: Could not decode image.";
      }

      // 1. Resize image to model input size (e.g., 48x48)
      img.Image resizedImage = img.copyResize(originalImage, width: _inputShape[1], height: _inputShape[2]);
      // 2. Convert to grayscale
      img.Image grayscaleImage = img.grayscale(resizedImage);

      // 3. Prepare input tensor (normalize pixel values to [0,1] for Float32 model)
      // Assuming model expects Float32 input
      var inputTensor = Float32List(_inputShape[0] * _inputShape[1] * _inputShape[2] * _inputShape[3]);
      int tensorIndex = 0;
      for (int y = 0; y < _inputShape[2]; y++) { // height
        for (int x = 0; x < _inputShape[1]; x++) { // width
          final pixel = grayscaleImage.getPixel(x, y);
          // Assuming grayscale, so R, G, B are the same. Using Red channel.
          // Normalize to [0, 1]
          inputTensor[tensorIndex++] = pixel.r / 255.0;
        }
      }
      // Reshape to [1, 48, 48, 1]
      final input = inputTensor.reshape(_inputShape);


      // 4. Prepare output tensor
      // Output shape is typically [1, numClasses] for classification
      var output = List.filled(_outputShape[0] * _outputShape[1], 0.0).reshape(_outputShape);
      // For example: List<List<double>> output = List.generate(1, (_) => List<double>.filled(_numClasses, 0));


      // 5. Run inference
      _interpreter!.run(input, output);

      // 6. Process the output
      // `output` is typically List<List<double>> for classification, e.g., [[0.1, 0.7, 0.05, ...]]
      if (output.isEmpty || output[0] is! List || (output[0] as List).isEmpty) {
        return "No emotion detected (empty output).";
      }

      List<double> probabilities = List<double>.from(output[0] as List);

      String detectedEmotion = "Unknown Emotion";
      double maxConfidence = 0.0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          if (i < _labels!.length) {
            detectedEmotion = _labels![i];
          }
        }
      }
      // You might want to add a confidence threshold here if needed
      // if (maxConfidence < 0.5) return "Uncertain";

      return detectedEmotion;

    } catch (e) {
      print("Error during emotion detection with tflite_flutter: $e");
      return "Detection Failed: $e";
    }
  }

  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null; // Ensure it's nulled after closing
      print("Interpreter closed.");
    }
    _isModelLoaded = false;
  }
}