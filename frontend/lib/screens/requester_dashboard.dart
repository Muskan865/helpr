import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequesterDashboard extends StatelessWidget {
  const RequesterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.grey.shade200,
        // Three-line menu — opens the Drawer automatically
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          "Helpr",
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.blue,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          // chat icon
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        
      

          // Notification bell 
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline,
                    color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),


      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        "SR",
                        style: GoogleFonts.nunito(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sara Rahman",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Requester",
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),
              const SizedBox(height: 10),

              // _drawerItem(Icons.notifications_outlined, "Notifications",
              //     badge: true),
              // _drawerItem(Icons.chat_bubble_outline, "Messages", badge: true),
              _drawerItem(Icons.person_2_outlined, "Profile"),
              _drawerItem(Icons.history, "History"),
              _drawerItem(Icons.edit_note_outlined, "Post a Request"),

              const Spacer(),
              const Divider(height: 1),
              _drawerItem(Icons.help_outline_outlined, "Help"),
              _drawerItem(Icons.logout, "Logout"),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              "Good Morning,",
              style: GoogleFonts.nunito(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              "Sara Rahman",
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
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
                    children: [
                      Text(
                        "Received bids",
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to review",
                        style: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      "5",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Browse Active Requests Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Browse Active Requests",
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section label
            Text(
              "ACTIVE JOBS",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 10),

            // Job cards
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

            // All Active Jobs Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "All Active Jobs",
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "History",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  static Widget _drawerItem(IconData icon, String label,
      {bool badge = false}) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.grey.shade700),
          if (badge)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      onTap: () {},
    );
  }
}

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
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
                style: GoogleFonts.nunito(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
