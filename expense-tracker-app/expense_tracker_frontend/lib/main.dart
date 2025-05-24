import 'package:flutter/material.dart';
import 'screens/summary_chart.dart';
import 'screens/add_expense_form.dart';
import 'screens/manage_expenses.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F2FF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMonth = "2025-05";
  final List<String> months = [
    "2025-01", "2025-02", "2025-03", "2025-04",
    "2025-05", "2025-06", "2025-07", "2025-08",
    "2025-09", "2025-10", "2025-11", "2025-12",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pie_chart_outline, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                "Expense Tracker",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Month Dropdown
              DropdownButton<String>(
                value: selectedMonth,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: Colors.white,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                    });
                  }
                },
                items: months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text("Month: $month"),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text("View Summary"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SummaryChart(month: selectedMonth),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Expense"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpenseForm()),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text("Manage Expenses"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageExpenses(month: selectedMonth),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
