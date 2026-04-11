import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'browse_requests_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  Map<String, dynamic>? profile;
  List<dynamic> jobs = [];
  List<dynamic> bids = [];
  List<dynamic> serviceRequests = [];
  bool isLoading = true;
  String? error;

  int workerId = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      profile = await ApiService.getWorkerProfile(workerId);
      print("Profile: $profile");
    } catch (e) {
      print("Profile error: $e");
      setState(() {
        error = "Failed at profile";
        isLoading = false;
      });
    }

    try {
      jobs = await ApiService.getWorkerJobs(workerId);
    } catch (e) {
      print("Jobs error: $e");
      setState(() {
        error = "Failed at jobs";
        isLoading = false;
      });
    }

    try {
      bids = await ApiService.getWorkerBids(workerId);
    } catch (e) {
      print("Bids error: $e");
      setState(() {
        error = "Failed at bids";
        isLoading = false;
      });
    }
    try {
      serviceRequests = await ApiService.getAllRequests();
      print("Requests: $serviceRequests");
    } catch (e) {
      print("Requests error: $e");
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
      appBar: AppBar(
        title: const Text("Helpr"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  print("Go to profile");
                  break;
                case 'notifications':
                  print("View notifications");
                  break;
                case 'chat':
                  print("Open chat");
                  break;
                case 'logout':
                  print("Logout");
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text("Profile")),
              PopupMenuItem(
                value: 'notifications',
                child: Text("Notifications"),
              ),
              PopupMenuItem(value: 'chat', child: Text("Chat")),
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
              // Welcome Text
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

              // Nearby Requests
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
                      "Nearby requests",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (serviceRequests.isEmpty)
                      const Text("No nearby requests")
                    else
                      ...serviceRequests
                          .take(3)
                          .map(
                            (request) => requestItem(
                              request['service_type'] ?? "",
                              "${request['location'] ?? "-"}",
                              "",
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Browse Requests Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowseRequestsScreen(),
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

              const Text(
                "ONGOING JOBS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (jobs.isEmpty)
                const Text("No ongoing jobs")
              else
                ...jobs.map(
                  (job) => jobCard(
                    job['service_type'] ?? "",

                    "${job['client_name'] ?? "-"} · Due ${DateTime.parse(job['date'] ?? "").day}/${DateTime.parse(job['date'] ?? "").month}/${DateTime.parse(job['date'] ?? "").year}",
                    job['status'] ?? "Pending",
                  ),
                ),

              const SizedBox(height: 20),

              // All Jobs Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("All jobs"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Request Item Widget
  Widget requestItem(String title, String subtitle, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Job Card Widget
  Widget jobCard(String title, String subtitle, String status) {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: const TextStyle(fontSize: 12)),
              ),
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
    );
  }
}
