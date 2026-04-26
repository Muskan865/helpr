import 'package:flutter/material.dart';
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
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
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
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatListScreen(
                        userId: userId!,
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
            } else {
              // Requester menu
              return const [
                PopupMenuItem(value: 'chat', child: Text("Chat")),
                PopupMenuItem(value: 'logout', child: Text("Logout")),
              ];
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}