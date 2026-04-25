import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late String currentStatus;

  final List<String> steps = [
    "arriving",
    "arrived",
    "in_progress",
    "completed",
  ];

  final Map<String, String> labels = {
    "arriving": "Arriving",
    "arrived": "Arrived",
    "in_progress": "In Progress",
    "completed": "Completed",
  };

  @override
  void initState() {
    super.initState();
    currentStatus = widget.job['status'] ?? "arriving";
    print("Initial status: '$currentStatus'"); // check exact value
    print("Index in steps: ${steps.indexOf(currentStatus)}");
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.job['date'] != null
        ? DateTime.parse(widget.job['date'])
        : null;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Job Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job['service_type'] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(widget.job['description'] ?? ""),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 6),
                      Text(widget.job['location'] ?? "-"),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        date != null
                            ? "${date.day}/${date.month}/${date.year}"
                            : "-",
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 6),
                      Text("${widget.job['bid_amount'] ?? "-"}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            buildTimeline(),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: currentStatus == "completed" ? null : updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Update Status"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Timeline UI
  Widget buildTimeline() {
    int currentIndex = steps.indexOf(currentStatus);

    return Column(
      children: List.generate(steps.length, (index) {
        bool isCompleted = index <= currentIndex;
        bool isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Circle
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isCompleted
                      ? Colors.black
                      : Colors.grey.shade300,
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          "${index + 1}",
                          style: const TextStyle(fontSize: 10),
                        ),
                ),

                // Line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: index < currentIndex
                        ? Colors.black
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 10),

            // Label
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                labels[steps[index]]!,
                style: TextStyle(
                  color: isCompleted ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void updateStatus() async {
    int currentIndex = steps.indexOf(currentStatus);

    if (currentIndex == steps.length - 1) return;

    String nextStatus = steps[currentIndex + 1];

    try {
      await ApiService.updateJobStatus(widget.job['id'], nextStatus);

      setState(() {
        currentStatus = nextStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to ${labels[nextStatus]}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update status")));
    }
  }
}
