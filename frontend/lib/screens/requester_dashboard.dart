import 'package:flutter/material.dart';

class RequesterDashboard extends StatelessWidget {
  const RequesterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Row(
        children: [
          // 🔹 SIDE PANEL
          Container(
            width: 90,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Profile Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue.shade100,
                  child: const Text(
                    "SR",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),

                _sideIcon(Icons.notifications_outlined, badge: true),
                _sideIcon(Icons.chat_bubble_outline, badge: true),
                _sideIcon(Icons.edit_note_outlined),
                _sideIcon(Icons.settings_outlined),

                const Spacer(),

                _sideIcon(Icons.logout),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 🔹 MAIN DASHBOARD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  const Text(
                    "Good Morning,",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    "Sara Rahman",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Received Bids Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Received bids",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("Tap to review",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: const Text("5",
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Active Requests
                  const Text(
                    "ACTIVE REQUESTS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: const [
                        RequestCard(
                          title: "Logo design for app",
                          subtitle: "Posted 2 days ago • 4 bids",
                          status: "In Review",
                        ),
                        RequestCard(
                          title: "Furniture delivery",
                          subtitle: "Posted 5 days ago • 2 bids",
                          status: "Bidding",
                        ),
                        RequestCard(
                          title: "Plumbing quote",
                          subtitle: "Posted today • 1 bid",
                          status: "Open",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Past Requests
                  const Text(
                    "PAST REQUESTS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  const RequestCard(
                    title: "Website copywriting",
                    subtitle: "Completed • Jan 12",
                    status: "Done",
                    isPast: true,
                  ),

                  const RequestCard(
                    title: "AC repair estimate",
                    subtitle: "Completed • Dec 28",
                    status: "Done",
                    isPast: true,
                  ),

                  const SizedBox(height: 15),

                  // All Jobs Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("All Jobs"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Side Icon Widget
  Widget _sideIcon(IconData icon, {bool badge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Stack(
        children: [
          Icon(icon, color: Colors.grey),
          if (badge)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            )
        ],
      ),
    );
  }
}

// 🔹 Request Card Widget
class RequestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isPast;

  const RequestCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.blue, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}