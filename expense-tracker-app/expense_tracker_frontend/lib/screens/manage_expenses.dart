import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageExpenses extends StatefulWidget {
  final String month;

  const ManageExpenses({super.key, required this.month});

  @override
  State<ManageExpenses> createState() => _ManageExpensesState();
}

class _ManageExpensesState extends State<ManageExpenses> {
  List expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final url = "http://localhost:3000/api/expenses/month/${widget.month}";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        expenses = json.decode(response.body);
      });
    }
  }

  Future<void> _deleteExpense(String id) async {
    final response = await http.delete(Uri.parse("http://localhost:3000/api/expenses/$id"));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted successfully")),
      );
      _fetchExpenses(); // refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Expenses: ${widget.month}")),
      body: expenses.isEmpty
          ? const Center(child: Text("No expenses to show"))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final exp = expenses[index];
                return ListTile(
                  title: Text("${exp['category']} - ₹${exp['amount']}"),
                  subtitle: Text(exp['description']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExpense(exp['id']),
                  ),
                );
              },
            ),
    );
  }
}
