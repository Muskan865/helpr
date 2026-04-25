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
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getWorkerBids(int workerId) async {
    final res = await http.get(
      Uri.parse("$apiBase/worker/$workerId/bids"),
    );
    return jsonDecode(res.body);
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
    final res = await http.get(
      Uri.parse("$apiBase/worker/requests"),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMatchingRequests(int workerId) async {
    final res = await http.get(
      Uri.parse("$apiBase/worker/$workerId/matching-requests"),
    );
    return jsonDecode(res.body);
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
}