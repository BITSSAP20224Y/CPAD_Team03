import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class SummaryChart extends StatefulWidget {
  final String month;

  const SummaryChart({super.key, required this.month});

  @override
  State<SummaryChart> createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart> {
  Map<String, double> categoryData = {};

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() async {
  try {
    print("➡️ Fetching summary...");
    final data = await ApiService.fetchMonthlySummary(widget.month);
    print("✅ Summary data: $data");
    Map<String, dynamic> raw = data['byCategory'];
    setState(() {
      categoryData = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
      double total = categoryData.values.fold(0, (sum, val) => sum + val);
    });
  } catch (e) {
    print("❌ Error fetching summary: $e");
  }
  }

  @override
Widget build(BuildContext context) {
  double total = categoryData.values.fold(0, (sum, val) => sum + val);

  return Scaffold(
    appBar: AppBar(title: Text("Summary: ${widget.month}")),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: categoryData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No data yet. Add some expenses!", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(PieChartData(
                    sections: categoryData.entries.map((entry) {
                      return PieChartSectionData(
                        value: entry.value,
                        title: "${entry.key}\n₹${entry.value.toStringAsFixed(0)}\n${((entry.value / total) * 100).toStringAsFixed(1)}%",
                        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                        radius: 80,
                      );
                    }).toList(),
                  )),
                ),
                const SizedBox(height: 16),
                const Text("Top Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: (categoryData.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                    .map((entry) => ListTile(
                    title: Text(entry.key),
                    trailing: Text("₹${entry.value.toStringAsFixed(0)}"),
                    ))
                    .toList(),
                  ),
                ),
              ],
            ),
    ),
  );
}
}
