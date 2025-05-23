import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const HabitListItem({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date to be more readable
    String formattedDate = DateFormat('MMM d,yyyy - hh:mm a').format(habit.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Checkbox(
          value: habit.isCompletedToday,
          onChanged: onToggle,
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
            color: habit.isCompletedToday ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          'Added: $formattedDate\nLast completed: ${habit.lastCompletedDate != null ? DateFormat('MMM d,yyyy').format(habit.lastCompletedDate!) : 'Never'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          onPressed: onDelete,
          tooltip: 'Delete Habit',
        ),
      ),
    );
  }
}