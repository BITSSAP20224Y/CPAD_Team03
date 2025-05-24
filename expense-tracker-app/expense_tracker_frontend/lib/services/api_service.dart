import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";

  static Future<Map<String, dynamic>> fetchMonthlySummary(String month) async {
    final response = await http.get(Uri.parse("$baseUrl/expenses/summary/monthly?month=$month"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load summary");
    }
  }
}
