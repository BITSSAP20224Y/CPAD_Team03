import 'dart:io';
import 'package:flutter/material.dart';

class EmotionDisplay extends StatelessWidget {
  final File? imageFile;
  final String detectedEmotion;
  final bool isLoading;

  const EmotionDisplay({
    super.key,
    this.imageFile,
    required this.detectedEmotion,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11), // slightly less than container to prevent overflow
                  child: Image.file(imageFile!, fit: BoxFit.cover),
                )
              : Center(
                  child: Icon(Icons.image_search, size: 60, color: Colors.grey[500]),
                ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const CircularProgressIndicator()
        else if (detectedEmotion.isNotEmpty && detectedEmotion != 'Processing...')
          Chip(
            avatar: Icon(_getEmotionIcon(detectedEmotion), color: _getEmotionColor(detectedEmotion)),
            label: Text(
              'Detected Emotion: $detectedEmotion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getEmotionColor(detectedEmotion)),
            ),
            backgroundColor: _getEmotionColor(detectedEmotion).withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          )
        else if (imageFile != null && detectedEmotion == 'Processing...')
          Text(
            'Processing image for emotion...',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
          )
        else
          Text(
            'Pick an image to detect emotion',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
      ],
    );
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied_outlined; // Placeholder, find better
      case 'surprised':
        return Icons.sentiment_neutral; // Placeholder
      case 'neutral':
        return Icons.sentiment_neutral;
      default:
        return Icons.tag_faces;
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'surprised':
        return Colors.orange;
      case 'neutral':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }
}