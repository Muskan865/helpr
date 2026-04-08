import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api"; 

  //Get Worker Jobs
  static Future<List<dynamic>> getWorkerJobs(int workerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/worker/$workerId/jobs"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load jobs");
    }
  }

  //Get Worker Bids
  static Future<List<dynamic>> getWorkerBids(int workerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/worker/$workerId/bids"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load bids");
    }
  }

  //Get Worker Profile
  static Future<Map<String, dynamic>> getWorkerProfile(int workerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/worker/$workerId/profile"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }
}