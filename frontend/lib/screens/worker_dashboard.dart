import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'browse_requests_screen.dart';
import 'browse_bids.dart';
import 'job_history.dart';
import 'job_detail.dart';
import '/widgets/appbar.dart';

class WorkerDashboard extends StatefulWidget {
  final int? userId;

  const WorkerDashboard({super.key, this.userId});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  Map<String, dynamic>? profile;
  List<dynamic> ongoingJobs = [];
  List<dynamic> pastJobs = [];
  List<dynamic> bids = [];
  List<dynamic> serviceRequests = [];

  bool isLoading = true;
  String? error;
  late int workerId;

  @override
  void initState() {
    super.initState();
    workerId = widget.userId ?? 1;
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      profile = await ApiService.getWorkerProfile(workerId);
      final jobs = await ApiService.getWorkerJobs(workerId);
      ongoingJobs = jobs.where((job) => (job['status'] ?? '').toString().toLowerCase() != "completed").toList();
      pastJobs = jobs.where((job) => (job['status'] ?? '').toString().toLowerCase() == "completed").toList();
      bids = await ApiService.getWorkerBids(workerId);
      serviceRequests = await ApiService.getMatchingRequests(workerId);
    } catch (e) {
      error = ApiService.errorMessage(e);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        appBar: CustomAppBar(
          workerId: workerId,
          userId: workerId,
          isRequester: false,
          profile: profile,
        ),
        body: Center(child: Text(error!)),
      );
    }

    final workerName = profile?['full_name']?.toString() ?? "Worker";

    return Scaffold(
      appBar: CustomAppBar(
        workerId: workerId,
        userId: workerId,
        isRequester: false,
        profile: profile,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good to see you,",
                style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                workerName,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 24),
              ),
              const SizedBox(height: 16),
              _summaryRow(),
              const SizedBox(height: 16),
              _actionButton(
                context,
                label: "Browse Matching Requests",
                icon: Icons.search_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrowseRequestsScreen(
                        workerId: workerId,
                        serviceRequests: serviceRequests,
                      ),
                    ),
                  ).then((_) => fetchData());
                },
              ),
              const SizedBox(height: 12),
              _actionButton(
                context,
                label: "My Bids",
                icon: Icons.gavel_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrowseBidsScreen(bids: bids),
                    ),
                  ).then((_) => fetchData());
                },
              ),
              const SizedBox(height: 24),
              Text(
                "ACTIVE JOBS",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              if (ongoingJobs.isEmpty)
                _emptyState("No active jobs right now")
              else
                ...ongoingJobs.take(3).map((job) => _jobCard(job)),
              const SizedBox(height: 12),
              _actionButton(
                context,
                label: "Job History",
                icon: Icons.history_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrowsePastJobs(pastJobs: pastJobs),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            label: "Matching",
            value: "${serviceRequests.length}",
            icon: Icons.location_searching_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: "Pending Bids",
            value: "${bids.where((b) => (b['bid_status'] ?? '') == 'pending').length}",
            icon: Icons.pending_actions_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            label: "Active Jobs",
            value: "${ongoingJobs.length}",
            icon: Icons.work_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 18),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 20)),
          Text(label, style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          side: BorderSide(color: Colors.grey.shade300),
          minimumSize: const Size.fromHeight(50),
        ),
      ),
    );
  }

  Widget _jobCard(Map job) {
    final rawDate = job['date']?.toString();
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final dueDate = parsedDate != null
        ? "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}"
        : "—";

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job, workerId: workerId),
          ),
        ).then((_) => fetchData());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.handyman_outlined, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['service_type'] ?? "",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${job['client_name'] ?? 'Client'} • $dueDate",
                    style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        style: GoogleFonts.nunito(color: Colors.grey.shade600, fontSize: 14),
      ),
    );
  }
}
