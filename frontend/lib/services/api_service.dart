import 'dart:convert';
import 'package:http/http.dart' as http;

//"http://10.0.2.2:3000/api"; for phone
class ApiService {
  static const String baseUrl = "http://192.168.1.11:3000/api";

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
    // print("PROFILE STATUS: ${response.statusCode}");
    // print("PROFILE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  // Get all service requests
  static Future<List<dynamic>> getAllRequests() async {
    final response = await http.get(Uri.parse("$baseUrl/worker/requests"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load requests");
    }
  }

  static Future<List<dynamic>> getMatchingRequests(int workerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/worker/$workerId/matching-requests"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load matching requests");
    }
  }

  static Future<void> placeBid({
    required int requestId,
    required int workerId,
    required int amount,
    required String todaydate,
    required String todaytime,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/worker/$workerId/place-bid"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "request_id": requestId,
        "bid_amount": amount,
        "bid_date": todaydate,
        "bid_time": todaytime,
        "status": "pending",
      }),
    );

    if (response.statusCode != 200) {
      print("Bid error body: ${response.body}"); // Add this
      throw Exception("Failed to place bid");
    }
  }

  static Future<void> cancelBid(int bidId) async {
    final response = await http.delete(Uri.parse("$baseUrl/worker/bid/$bidId"));

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel bid");
    }
  }

  static Future<void> updateJobStatus(int jobId, String status) async {
    final response = await http.put(
      Uri.parse("$baseUrl/worker/job/$jobId/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update status");
    }
  }

  static Future<void> submitReview({
  required int reviewerId,
  required int revieweeId,
  required int rating,
  required String comment,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/worker/review"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "reviewer_id": reviewerId,
      "reviewee_id": revieweeId,
      "rating": rating,
      "comment": comment,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to submit review");
  }
}
}
