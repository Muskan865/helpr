import 'package:flutter/material.dart';
import '../screens/worker_ratings_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int? workerId;
  final Map<String, dynamic>? profile;

  const CustomAppBar({
    super.key,
    this.title = "Helpr",
    this.workerId,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        if (workerId != null) 
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

                case 'ratings':
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
              PopupMenuItem(value: 'ratings', child: Text("View Ratings")),
              PopupMenuItem(value: 'logout', child: Text("Logout")),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}