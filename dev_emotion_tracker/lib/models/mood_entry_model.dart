import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class MoodEntry {
  final String id;
  final String mood;
  final String note;
  final DateTime timestamp;
  final String? imagePath; // Path to the image file (can be a Firebase Storage URL later)

  MoodEntry({
    required this.id,
    required this.mood,
    this.note = '',
    required this.timestamp,
    this.imagePath,
  });

  // Convert a MoodEntry object into a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'mood': mood,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Firestore Timestamp
      'imagePath': imagePath,
    };
  }

  // Create a MoodEntry object from a Firestore DocumentSnapshot
  factory MoodEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, [SnapshotOptions? options]) {
    final data = snapshot.data();
    return MoodEntry(
      id: snapshot.id,
      mood: data?['mood'] as String,
      note: data?['note'] as String? ?? '',
      timestamp: (data?['timestamp'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      imagePath: data?['imagePath'] as String?,
    );
  }
}