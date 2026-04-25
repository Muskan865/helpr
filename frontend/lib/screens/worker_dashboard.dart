import 'package:flutter/material.dart';
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
    try {
      profile = await ApiService.getWorkerProfile(workerId);
    } catch (e) {
      setState(() {
        error = "Failed at profile";
        isLoading = false;
      });
    }

    try {
      ongoingJobs = (await ApiService.getWorkerJobs(workerId))
          .where((job) => job['status'] == "arriving")
          .toList();

      pastJobs = (await ApiService.getWorkerJobs(workerId))
          .where((job) => job['status'] == "completed")
          .toList();
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Helpr"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(
                    context,
                    '/workerProfile',
                    arguments: {'userId': workerId},
                  );
                  break;

                case 'logout':
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text("Profile")),
              PopupMenuItem(value: 'logout', child: Text("Logout")),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(color: Colors.grey),
              ),

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
                  child: const Text("Browse Requests"),
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
                    "${job['client_name'] ?? "-"}",
                    job['status'] ?? "Pending",
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
    return ListTile(
      title: Text(serviceType),
      subtitle: Text(location),
      trailing: Text(price),
    );
  }

  Widget jobCard(String title, String subtitle, String status, Map job) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(job: job),
            ),
          );
        },
      ),
    );
  }
}