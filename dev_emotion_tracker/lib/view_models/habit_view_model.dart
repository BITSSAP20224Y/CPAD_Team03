import 'package:flutter/foundation.dart';
import 'dart:collection'; // For UnmodifiableListView
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../models/habit_model.dart';

class HabitViewModel extends ChangeNotifier {
  final List<Habit> _habits = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UnmodifiableListView<Habit> get habits {
    // Sort habits by creation date, newest first
    _habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // Update completion status before returning (this logic is now handled by Firestore updates)
    // for (var habit in _habits) {
    //   habit.updateCompletionStatus();
    // }
    return UnmodifiableListView(_habits);
  }

  // Fetch habits from Firestore
  void fetchHabits() {
    _firestore.collection('habits').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _habits.clear();
      for (var doc in snapshot.docs) {
        _habits.add(Habit.fromFirestore(doc));
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error fetching habits: $error");
    });
  }

  Future<void> addHabit(String name) async {
    final newHabit = Habit(
      id: '', // Firestore will generate an ID
      name: name,
      createdAt: DateTime.now(),
    );
    try {
      await _firestore.collection('habits').add(newHabit.toFirestore());
      debugPrint("Habit added to Firestore!");
    } catch (e) {
      debugPrint("Error adding habit to Firestore: $e");
      // You might want to show an error modal here
    }
  }

  Future<void> removeHabit(String id) async {
    try {
      await _firestore.collection('habits').doc(id).delete();
    } catch (e) {
      debugPrint("Error removing habit from Firestore: $e");
      // You might want to show an error modal here
    }
  }

  Future<void> toggleHabitCompletion(String id, bool completed) async {
    try {
      final habitRef = _firestore.collection('habits').doc(id);
      final now = DateTime.now();
      await habitRef.update({
        'isCompletedToday': completed,
        'lastCompletedDate': completed ? Timestamp.fromDate(now) : null, // Set to null if unchecked
      });
      debugPrint("Habit completion toggled in Firestore!");
    } catch (e) {
      debugPrint("Error toggling habit completion in Firestore: $e");
      // You might want to show an error modal here
    }
  }
}