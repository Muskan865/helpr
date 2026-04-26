import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class WorkerPublicProfileScreen extends StatefulWidget {
  final int workerId;

  const WorkerPublicProfileScreen({super.key, required this.workerId});

  @override
  State<WorkerPublicProfileScreen> createState() =>
      _WorkerPublicProfileScreenState();
}

class _WorkerPublicProfileScreenState
    extends State<WorkerPublicProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result =
          await ApiService.getWorkerPublicProfile(widget.workerId);
      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load worker profile";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (error != null || profile == null) {
      return Scaffold(
        appBar: const CustomAppBar(),
        body: Center(child: Text(error ?? "Profile not found")),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + title
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Worker Profile",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Avatar + name + rating
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      (profile!['full_name'] ?? "?")[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile!['full_name'] ?? "Worker",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${profile!['avg_rating'] ?? '—'}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.work_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${profile!['past_jobs'] ?? 0} jobs",
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Info rows
            _infoRow(Icons.build_outlined, "Profession",
                profile!['profession'] ?? "—"),
            const SizedBox(height: 14),
            _infoRow(Icons.star_border_outlined, "Skills",
                profile!['skills'] ?? "—"),
            const SizedBox(height: 14),
            _infoRow(Icons.history_outlined, "Experience",
                "${profile!['experience_years'] ?? 0} years"),
            const SizedBox(height: 14),
            _infoRow(Icons.phone_outlined, "Contact",
                profile!['contact_number'] ?? "—"),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
