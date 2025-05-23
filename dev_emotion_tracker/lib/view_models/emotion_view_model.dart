import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../services/emotion_recognition_service.dart';
import '../models/mood_entry_model.dart'; // Import the new MoodEntry model

class EmotionViewModel extends ChangeNotifier {
  File? _currentImage;
  String _detectedEmotion = '';
  bool _isLoading = false;
  final List<MoodEntry> _moodEntries = [];

  final EmotionRecognitionService _emotionService = EmotionRecognitionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? get currentImage => _currentImage;
  String get detectedEmotion => _detectedEmotion;
  bool get isLoading => _isLoading;
  List<MoodEntry> get moodEntries => _moodEntries;

  // Fetch mood entries from Firestore
  void fetchMoodEntries() {
    _firestore.collection('moodEntries').orderBy('timestamp', descending: true).snapshots().listen((snapshot) {
      _moodEntries.clear();
      for (var doc in snapshot.docs) {
        _moodEntries.add(MoodEntry.fromFirestore(doc));
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error fetching mood entries: $error");
    });
  }

  Future<void> setImageAndUpdateEmotion(File imageFile) async {
    _currentImage = imageFile;
    _isLoading = true;
    _detectedEmotion = 'Processing...'; // Indicate processing
    notifyListeners();

    _detectedEmotion = await _emotionService.detectEmotionFromImage(imageFile);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMoodEntry(String note) async {
    if (_currentImage == null || _detectedEmotion.isEmpty || _detectedEmotion == 'Processing...') {
      debugPrint("Cannot add mood entry: image or emotion not ready.");
      return;
    }

    final newMoodEntry = MoodEntry(
      id: '', // Firestore will generate an ID
      mood: _detectedEmotion,
      note: note,
      timestamp: DateTime.now(),
      imagePath: _currentImage?.path, // For now, storing local path. In a real app, upload to Firebase Storage.
    );

    try {
      await _firestore.collection('moodEntries').add(newMoodEntry.toFirestore());
      clearEmotionData(); // Clear UI after successful addition
      debugPrint("Mood entry added to Firestore!");
    } catch (e) {
      debugPrint("Error adding mood entry to Firestore: $e");
      // You might want to show an error modal here
    }
  }

  Future<void> removeMoodEntry(String id) async {
    try {
      await _firestore.collection('moodEntries').doc(id).delete();
    } catch (e) {
      debugPrint("Error removing mood entry from Firestore: $e");
      // You might want to show an error modal here
    }
  }

  void clearEmotionData() {
    _currentImage = null;
    _detectedEmotion = '';
    _isLoading = false;
    notifyListeners();
  }
}