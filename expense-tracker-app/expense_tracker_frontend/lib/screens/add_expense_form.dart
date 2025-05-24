import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({super.key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  final isDup = await _isDuplicate();
  if (isDup) {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Duplicate Warning"),
        content: const Text("A similar expense already exists. Do you still want to add this?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Proceed"),
          ),
        ],
      ),
    );

    if (proceed != true) return; // Abort if user says Cancel
  }

  // ✅ POST request to backend
  final response = await http.post(
    Uri.parse("http://localhost:3000/api/expenses"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "amount": double.parse(_amountController.text),
      "category": _categoryController.text,
      "description": _descriptionController.text,
      "createdAt": _selectedDate.toIso8601String(),
    }),
  );

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully!')),
    );
    _amountController.clear();
    _categoryController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add expense')),
    );
  }
}

 Future<bool> _isDuplicate() async {
    final month = _selectedDate.toIso8601String().substring(0, 7);
    final response = await http.get(Uri.parse("http://localhost:3000/api/expenses/month/$month"));

    if (response.statusCode == 200) {
        final List<dynamic> expenses = json.decode(response.body);
        return expenses.any((exp) =>
        exp['amount'] == double.parse(_amountController.text) &&
        exp['category'] == _categoryController.text &&
        exp['createdAt'].toString().substring(0, 10) == _selectedDate.toIso8601String().substring(0, 10)
        );
    }
  return false;
}

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value == null || value.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
