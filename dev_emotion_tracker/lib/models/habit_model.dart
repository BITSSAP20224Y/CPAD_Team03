import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class Habit {
  final String id;
  final String name;
  final DateTime createdAt;
  bool isCompletedToday;
  DateTime? lastCompletedDate; // Track the last date it was completed

  Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    this.isCompletedToday = false,
    this.lastCompletedDate,
  });

  // Helper to check if the habit was completed on the current day
  void updateCompletionStatus() {
    if (lastCompletedDate == null) {
      isCompletedToday = false;
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompletionDay = DateTime(lastCompletedDate!.year, lastCompletedDate!.month, lastCompletedDate!.day);
    isCompletedToday = lastCompletionDay.isAtSameMomentAs(today);
  }

  // Convert a Habit object into a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Firestore Timestamp
      'isCompletedToday': isCompletedToday,
      'lastCompletedDate': lastCompletedDate != null ? Timestamp.fromDate(lastCompletedDate!) : null,
    };
  }

  // Create a Habit object from a Firestore DocumentSnapshot
  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data();
    return Habit(
      id: snapshot.id,
      name: data?['name'] as String,
      createdAt: (data?['createdAt'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      isCompletedToday: data?['isCompletedToday'] as bool? ?? false,
      lastCompletedDate: (data?['lastCompletedDate'] as Timestamp?)?.toDate(),
    );
  }
}