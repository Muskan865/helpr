import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'browse_requests_screen.dart';
import 'browse_bids.dart';
import 'job_history.dart';
import 'job_detail.dart';
import '/widgets/appbar.dart';
import 'worker_ratings_screen.dart';

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
    try {
      profile = await ApiService.getWorkerProfile(workerId);
    } catch (e) {
      setState(() {
        error = "Failed at profile";
        isLoading = false;
      });
    }

    try {
      ongoingJobs = (await ApiService.getWorkerJobs(
        workerId,
      )).where((job) => job['status'] != "completed").toList();

      pastJobs = (await ApiService.getWorkerJobs(
        workerId,
      )).where((job) => job['status'] == "completed").toList();
    } catch (e) {
      setState(() {
        error = "Failed at jobs";
        isLoading = false;
      });
    }

    try {
      bids = await ApiService.getWorkerBids(workerId);
    } catch (e) {
      setState(() {
        error = "Failed at bids";
        isLoading = false;
      });
    }

    try {
      serviceRequests = await ApiService.getMatchingRequests(workerId);
    } catch (e) {
      setState(() {
        error = "Failed at requests";
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }

    return Scaffold(
      appBar: CustomAppBar(workerId: workerId, profile: profile),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back,", style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 5),

              Text(
                profile?['full_name'] ?? "Worker",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowseRequestsScreen(
                          workerId: workerId,
                          serviceRequests: serviceRequests,
                        ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Browse More requests"),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nearby Requests",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (serviceRequests.isEmpty)
                      const Text("No nearby requests")
                    else
                      ...serviceRequests.map(
                        (request) => requestItem(
                          request['service_type'] ?? "",
                          request['description'] ?? "",
                          request['location'] ?? "-",
                          request['date'] ?? "-",
                          "Rs. 1500",
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowseBidsScreen(bids: bids),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Browse My Bids"),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "ONGOING JOBS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (ongoingJobs.isEmpty)
                const Text("No ongoing jobs")
              else
                ...ongoingJobs.map(
                  (job) => jobCard(
                    job['service_type'] ?? "",

                    "${job['client_name'] ?? "-"} · Due ${job['date'] != null ? "${DateTime.parse(job['date']).day}/${DateTime.parse(job['date']).month}/${DateTime.parse(job['date']).year}" : "-"}",
                    // job['status'] ?? "Pending",
                    job,
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BrowsePastJobs(pastJobs: pastJobs),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("View Job History"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget requestItem(
    String serviceType,
    String description,
    String location,
    String date,
    String price,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceType,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location, // or description if you prefer
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Divider like in first image
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  // Job Card Widget
  Widget jobCard(String title, String subtitle, Map job) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                JobDetailsScreen(job: job, workerId: workerId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 109, 109, 109)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: Colors.grey[300],
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   // child: Text(status, style: const TextStyle(fontSize: 12)),
                // ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[300],
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
