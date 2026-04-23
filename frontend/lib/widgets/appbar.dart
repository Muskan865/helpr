import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, this.title = "Helpr"});

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
              case 'profile':
                print("Go to profile");
                break;
              case 'ratings':
                print("View ratings");
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
            PopupMenuItem(value: 'ratings', child: Text("Ratings")),
            PopupMenuItem(value: 'chat', child: Text("Chat")),
            PopupMenuItem(value: 'logout', child: Text("Logout")),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}