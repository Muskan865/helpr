import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';
import 'requester_job_tracking_screen.dart';

class RequesterActiveJobsScreen extends StatefulWidget {
  final int requesterId;

  const RequesterActiveJobsScreen({super.key, required this.requesterId});

  @override
  State<RequesterActiveJobsScreen> createState() =>
      _RequesterActiveJobsScreenState();
}

class _RequesterActiveJobsScreenState
    extends State<RequesterActiveJobsScreen> {
  List<dynamic> activeJobs = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final result =
          await ApiService.getRequesterActiveJobs(widget.requesterId);
      setState(() {
        activeJobs = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load active jobs";
        isLoading = false;
      });
    }
  }

  String _statusLabel(String status) {
    const labels = {
      "arriving": "Arriving",
      "arrived": "Arrived",
      "in_progress": "In Progress",
      "completed": "Completed",
    };
    return labels[status] ?? status;
  }

  Color _statusColor(String status) {
    switch (status) {
      case "arriving":
        return Colors.orange;
      case "arrived":
        return Colors.blue;
      case "in_progress":
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : activeJobs.isEmpty
                  ? const Center(
                      child: Text(
                        "No active jobs at the moment.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          "Active Jobs",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...activeJobs.map((job) => _jobCard(job)),
                      ],
                    ),
    );
  }

  Widget _jobCard(Map job) {
    final status = job['status'] ?? "arriving";
    final date = job['date'] != null
        ? DateTime.tryParse(job['date'])
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequesterJobTrackingScreen(
              job: job,
              requesterId: widget.requesterId,
            ),
          ),
        ).then((_) => _loadJobs());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job['service_type'] ?? "",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job['worker_name'] ?? "—",
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 3),
                Text(
                  "${job['worker_rating'] ?? '—'}",
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['location'] ?? "—",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  date != null
                      ? "${date.day}/${date.month}/${date.year} • ${job['time'] ?? ''}"
                      : "—",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            if (job['bid_amount'] != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.attach_money,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Rs. ${job['bid_amount']}",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "View Details ",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
