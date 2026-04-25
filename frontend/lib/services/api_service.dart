import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.11:3000";
  static const String apiBase = "$baseUrl/api";

  // ---------------- AUTH ----------------
  static Future<Map<String, dynamic>> login(
    String contact,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$apiBase/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contact_number": contact,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String contactNumber,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse("$apiBase/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": name,
        "contact_number": contactNumber,
        "password": password,
        "role": role,
      }),
    );

    return jsonDecode(response.body);
  }

  // ---------------- WORKER DASHBOARD ----------------

  static Future<List<dynamic>> getWorkerJobs(int workerId) async {
    final res = await http.get(
      Uri.parse("$apiBase/worker/$workerId/jobs"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load jobs");
    }
  }

  static Future<List<dynamic>> getWorkerBids(int workerId) async {
    final res = await http.get(
      Uri.parse("$apiBase/worker/$workerId/bids"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load bids");
    }
  }

  static Future<Map<String, dynamic>> getWorkerProfile(int workerId) async {
    final res = await http.get(
      Uri.parse("$apiBase/worker/$workerId/profile"),
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  static Future<List<dynamic>> getAllRequests() async {
    final response = await http.get(Uri.parse("$apiBase/worker/requests"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load requests");
    }
  }

  static Future<List<dynamic>> getMatchingRequests(int workerId) async {
    final res = await http.get(
      Uri.parse("$apiBase/worker/$workerId/matching-requests"),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
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

  // ---------------- WORKER PROFILE CREATION ----------------

  static Future<Map<String, dynamic>> createWorkerProfile(
    int userId,
    String profession,
    String skills,
    int experience,
  ) async {
    final res = await http.post(
      Uri.parse("$apiBase/worker/profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "profession": profession,
        "skills": skills,
        "experience_years": experience,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed: ${res.body}");
    }
  }

  // ---------------- PROFILE COMPLETION ----------------

  static Future<Map<String, dynamic>> completeWorkerProfile(
    int userId,
    String profession,
    String skills,
    int experienceYears,
    XFile? profilePicture,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$apiBase/profile-completion/worker"),
    );

    request.fields["userId"] = userId.toString();
    request.fields["profession"] = profession;
    request.fields["skills"] = skills;
    request.fields["experience_years"] = experienceYears.toString();

    if (profilePicture != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "profile_picture",
          await profilePicture.readAsBytes(),
          filename: profilePicture.name,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> completeRequesterProfile(
    int userId,
    XFile? profilePicture,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$apiBase/profile-completion/requester"),
    );

    request.fields["userId"] = userId.toString();

    if (profilePicture != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "profile_picture",
          await profilePicture.readAsBytes(),
          filename: profilePicture.name,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }

  // ---------------- USER PROFILE ----------------

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final res = await http.get(
      Uri.parse("$apiBase/profile/user/$userId"),
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  static Future<void> submitReview({
  required int reviewerId,
  required int revieweeId,
  required int rating,
  required String comment,
}) async {
  final response = await http.post(
    Uri.parse("$apiBase/worker/review"),
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
}