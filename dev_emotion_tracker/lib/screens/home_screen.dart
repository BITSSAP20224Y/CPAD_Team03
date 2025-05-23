import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../view_models/habit_view_model.dart';
import '../view_models/emotion_view_model.dart';
import '../models/habit_model.dart';
import '../models/mood_entry_model.dart'; // New model for mood entries
import '../widgets/habit_list_item.dart';
import '../widgets/emotion_display.dart';
import '../widgets/custom_modal.dart';
import 'package:mood_habit_tracker/screens/emotion_detection_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _habitNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch habits and emotion data from Firestore when the screen initializes
    Provider.of<HabitViewModel>(context, listen: false).fetchHabits();
    Provider.of<EmotionViewModel>(context, listen: false).fetchMoodEntries();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
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

  void _showAddHabitDialog() {
    _habitNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Add New Habit', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _habitNameController,
            decoration: InputDecoration(
              hintText: "Enter habit name (e.g., Read a book)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
              ),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: const Text('Add Habit'),
              onPressed: () {
                if (_habitNameController.text.isNotEmpty) {
                  Provider.of<HabitViewModel>(context, listen: false)
                      .addHabit(_habitNameController.text);
                  Navigator.of(context).pop();
                } else {
                   CustomModal.show(
                    // ignore: use_build_context_synchronously
                    context,
                    title: 'Empty Habit',
                    message: 'Habit name cannot be empty.',
                    isError: true,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMoodEntryDialog(BuildContext context, EmotionViewModel emotionViewModel) {
    TextEditingController moodNoteController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Log Your Mood', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmotionDisplay(
                imageFile: emotionViewModel.currentImage,
                detectedEmotion: emotionViewModel.detectedEmotion,
                isLoading: emotionViewModel.isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: moodNoteController,
                decoration: InputDecoration(
                  hintText: "Add a note (optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                emotionViewModel.clearEmotionData(); // Clear data if cancelled
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: const Text('Log Mood'),
              onPressed: () {
                if (emotionViewModel.detectedEmotion.isNotEmpty && emotionViewModel.detectedEmotion != 'Processing...') {
                  emotionViewModel.addMoodEntry(moodNoteController.text);
                  Navigator.of(context).pop();
                } else {
                  CustomModal.show(
                    // ignore: use_build_context_synchronously
                    context,
                    title: 'No Mood Detected',
                    message: 'Please pick an image and wait for mood detection before logging.',
                    isError: true,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion & Habit Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Emotion Tracking Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Consumer<EmotionViewModel>(
                      builder: (context, emotionViewModel, child) {
                        return Column(
                          children: [
                            EmotionDisplay(
                              imageFile: emotionViewModel.currentImage,
                              detectedEmotion: emotionViewModel.detectedEmotion,
                              isLoading: emotionViewModel.isLoading,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Camera'),
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
                                ),
                              ],
                            ),
                            if (emotionViewModel.detectedEmotion.isNotEmpty && emotionViewModel.detectedEmotion != 'Processing...')
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddMoodEntryDialog(context, emotionViewModel),
                                  icon: const Icon(Icons.add_reaction),
                                  label: const Text('Log This Mood'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Mood History Section
            Text(
              'Your Mood History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Consumer<EmotionViewModel>(
              builder: (context, emotionViewModel, child) {
                if (emotionViewModel.moodEntries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'No mood entries yet. Log your first mood!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: emotionViewModel.moodEntries.length,
                  itemBuilder: (context, index) {
                    final entry = emotionViewModel.moodEntries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 1,
                      child: ListTile(
                        leading: entry.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(entry.imagePath!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.sentiment_satisfied_alt, size: 40, color: Theme.of(context).primaryColor),
                        title: Text(entry.mood, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${entry.note.isNotEmpty ? '${entry.note}\n' : ''}${DateFormat('MMM d,yyyy - hh:mm a').format(entry.timestamp)}',
                        ),
                        isThreeLine: entry.note.isNotEmpty,
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          onPressed: () => emotionViewModel.removeMoodEntry(entry.id),
                          tooltip: 'Delete Mood Entry',
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Habit Tracking Section
            Text(
              'Track Your Habits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Consumer<HabitViewModel>(
              builder: (context, habitViewModel, child) {
                if (habitViewModel.habits.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'No habits added yet. Tap "+" to add one!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habitViewModel.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitViewModel.habits[index];
                    return HabitListItem(
                      habit: habit,
                      onToggle: (value) {
                        habitViewModel.toggleHabitCompletion(habit.id, value ?? false);
                      },
                      onDelete: () {
                        habitViewModel.removeHabit(habit.id);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHabitDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}