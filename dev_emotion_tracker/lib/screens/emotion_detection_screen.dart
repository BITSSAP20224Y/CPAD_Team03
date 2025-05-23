// lib/screens/emotion_detection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../view_models/emotion_view_model.dart';
import '../widgets/emotion_display.dart';
import '../widgets/custom_modal.dart';

class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({super.key});

  @override
  State<EmotionDetectionScreen> createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        // Use the EmotionViewModel to handle image and update emotion
        // ignore: use_build_context_synchronously
        await Provider.of<EmotionViewModel>(context, listen: false)
            .setImageAndUpdateEmotion(File(pickedFile.path));
      }
    } catch (e) {
      // Handle exceptions, e.g., permission denied
      // ignore: use_build_context_synchronously
      CustomModal.show(
        context,
        title: 'Error Picking Image',
        message: 'Could not pick image: $e. Please ensure permissions are granted.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect Emotion', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<EmotionViewModel>(
        builder: (context, emotionViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload an image to see the detected emotion.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                EmotionDisplay(
                  imageFile: emotionViewModel.currentImage,
                  detectedEmotion: emotionViewModel.detectedEmotion,
                  isLoading: emotionViewModel.isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        onPressed: () => _pickImage(ImageSource.gallery, context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        onPressed: () => _pickImage(ImageSource.camera, context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (emotionViewModel.detectedEmotion.isNotEmpty && emotionViewModel.detectedEmotion != 'Processing...')
                  ElevatedButton.icon(
                    onPressed: () {
                      // This button can be used to confirm or log the detection.
                      // For this example, it just shows a success message.
                      CustomModal.show(
                        context,
                        title: 'Emotion Detected!',
                        message: 'Emotion "${emotionViewModel.detectedEmotion}" detected successfully.',
                        isError: false,
                      );
                      // You might also want to navigate back or clear the image after this.
                      // emotionViewModel.clearEmotionData();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}