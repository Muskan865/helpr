import 'package:flutter/material.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Worker Dashboard"),
      ),
      body: Center(
        child: Text("Welcome Worker"),
      ),
    );
  }
}