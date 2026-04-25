import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/worker_dashboard.dart';
import 'screens/requester_dashboard.dart';
import 'screens/worker_profile_screen.dart';
import 'screens/worker_profile_completion_screen.dart';
import 'screens/requester_profile_completion_screen.dart';
import 'screens/requester_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),

        // DASHBOARDS
        '/workerDashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userId = args?['userId'];
          return WorkerDashboard(userId: userId);
        },

        '/requesterDashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userId = args?['userId'];
          return RequesterDashboard(userId: userId);
        },

        // WORKER FLOW
        '/workerProfile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userId = args?['userId'] ?? 0;
          return WorkerProfileScreen(userId: userId);
        },

        '/workerProfileCompletion': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userId = args?['userId'] ?? 0;
          return WorkerProfileCompletionScreen(userId: userId);
        },

        // REQUESTER FLOW
        '/requesterProfileCompletion': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userId = args?['userId'] ?? 0;
          return RequesterProfileCompletionScreen(userId: userId);
        },

        '/requesterProfile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userId = args?['userId'] ?? 0;
          return RequesterProfileScreen(userId: userId);
        },
      },
    );
  }
}