import 'package:flutter/material.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Helpr"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'profile') {
                print("Go to profile");
              } else if (value == 'notifications') {
                print("View notifications");
              }
              else if (value == 'chat') {
                print("Open chat");
              }
              else if (value == 'logout') {
                print("Logout");
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text("Profile")),
              PopupMenuItem(value: 'notifications', child: Text("Notifications")),
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
              // Welcome text
              const Text("Welcome back,", style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 5),

              const Text(
                "Khalid Ansari",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Browse Requests Button
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
                  child: const Text("Browse requests"),
                ),
              ),

              const SizedBox(height: 20),

              // Nearby Requests Card
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

                    requestItem(
                      "Plumbing repair",
                      "0.8 km · DHA Phase 5",
                      "Rs. 1,500",
                    ),
                    requestItem(
                      "Furniture assembly",
                      "1.4 km · Clifton",
                      "Rs. 800",
                    ),
                    requestItem(
                      "Deep cleaning",
                      "2.1 km · Gulshan",
                      "Rs. 1,200",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "ONGOING JOBS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              jobCard(
                "Logo design for app",
                "Sara R. · Due in 2 days",
                "In progress",
              ),
              jobCard(
                "AC unit inspection",
                "Omar F. · Due tomorrow",
                "Arriving",
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

  // 🔹 Request Item Widget
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

  // 🔹 Job Card Widget
  Widget jobCard(String title, String subtitle, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
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

          // Progress bar
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
