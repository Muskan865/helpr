import 'package:flutter/material.dart';
import '../screens/chat_list_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int userId;           //added
  final bool isRequester;     //added

  const CustomAppBar({
  super.key,
  this.title = "Helpr",
  this.userId = 0,           // default value
  this.isRequester = false,  // default value
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
              case 'profile':
                print("Go to profile");
                break;
              case 'ratings':
                print("View ratings");
                break;
              case 'chat':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatListScreen(
                      userId: userId,           // 
                      isRequester: isRequester, // 
                    ),
                  ),
                );
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