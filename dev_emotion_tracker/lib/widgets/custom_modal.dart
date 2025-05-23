import 'package:flutter/material.dart';

class CustomModal {
  static void show(BuildContext context, {required String title, required String message, bool isError = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.info_outline,
                color: isError ? Colors.red : Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}