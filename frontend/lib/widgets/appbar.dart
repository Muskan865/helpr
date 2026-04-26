import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/chat_list_screen.dart';
import '../screens/worker_ratings_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  // requester side
  final int? userId;
  final bool isRequester;

  // worker side
  final int? workerId;
  final Map<String, dynamic>? profile;

  const CustomAppBar({
    super.key,
    this.title = "Helpr",
    this.userId,
    this.isRequester = false,
    this.workerId,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AppBar(
      backgroundColor: const Color(0xFF1E3A8A), // Blue theme
      elevation: 0.5,
      shadowColor: Colors.blue.shade200,
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          fontSize: isMobile ? 18 : 22,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              // ================= WORKER FLOW =================
              case 'worker_profile':
                if (workerId != null) {
                  Navigator.pushNamed(
                    context,
                    '/workerProfile',
                    arguments: {'userId': workerId},
                  );
                }
                break;

              case 'worker_ratings':
                if (workerId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerRatingsScreen(
                        workerId: workerId!,
                        avgRating: (profile?['avg_rating'] ?? 0).toDouble(),
                        workerName: profile?['full_name'] ?? '',
                      ),
                    ),
                  );
                }
                break;

              // ================= REQUESTER FLOW =================
              case 'chat':
                final chatUserId = userId ?? workerId;
                if (chatUserId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatListScreen(
                        userId: chatUserId,
                        isRequester: isRequester,
                      ),
                    ),
                  );
                }
                break;

              // ================= COMMON =================
              case 'logout':
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
                break;
            }
          },
          itemBuilder: (context) {
            if (workerId != null) {
              // Worker menu
              return const [
                PopupMenuItem(
                  value: 'chat',
                  child: Text("Chat"),
                ),
                PopupMenuItem(
                  value: 'worker_profile',
                  child: Text("Profile"),
                ),
                PopupMenuItem(
                  value: 'worker_ratings',
                  child: Text("View Ratings"),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text("Logout"),
                ),
              ];
            } else if (userId != null) {
              // Requester menu
              return const [
                PopupMenuItem(value: 'chat', child: Text("Chat")),
                PopupMenuItem(value: 'logout', child: Text("Logout")),
              ];
            }

            return const [
              PopupMenuItem(value: 'logout', child: Text("Logout")),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
