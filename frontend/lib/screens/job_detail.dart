import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job['service_type'] ?? "",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Text("Client: ${job['client_name'] ?? "-"}"),
            const SizedBox(height: 5),

            Text("Status: ${job['status'] ?? "-"}"),
            const SizedBox(height: 5),

            Text(
              "Date: ${job['date'] != null ? "${DateTime.parse(job['date']).day}/${DateTime.parse(job['date']).month}/${DateTime.parse(job['date']).year}" : "-"}",
            ),

            const SizedBox(height: 20),

            const Text("More details coming here..."),
          ],
        ),
      ),
    );
  }
}