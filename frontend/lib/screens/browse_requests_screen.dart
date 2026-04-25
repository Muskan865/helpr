import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class BrowseRequestsScreen extends StatefulWidget {
  final int workerId;
  final List<dynamic> serviceRequests;
  const BrowseRequestsScreen({
    super.key,
    required this.serviceRequests,
    required this.workerId,
  });

  @override
  State<BrowseRequestsScreen> createState() => _BrowseRequestsScreenState();
}

class _BrowseRequestsScreenState extends State<BrowseRequestsScreen> {
  bool isLoading = true;
  String? error;
  late List<dynamic> requests;

  @override
  void initState() {
    super.initState();
    requests = List.from(widget.serviceRequests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Nearby Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (requests.isEmpty)
              const Text("No nearby requests")
            else
              ...requests.map((request) => requestCard(request)),
          ],
        ),
      ),
    );
  }

  Widget requestCard(Map request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request['service_type'] ?? "",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          Text(
            request['description'] ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 6),
              Text(request['location'] ?? "-"),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text(
                request['date'] != null
                    ? "${DateTime.parse(request['date']).day}/${DateTime.parse(request['date']).month}/${DateTime.parse(request['date']).year}"
                    : "-",
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print("Button clicked for request ${request['id']}");
                showBidDialog(request['id']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Place Bid"),
            ),
          ),
        ],
      ),
    );
  }

  void showBidDialog(int requestId) {
    print("Dialog opened for request $requestId");
    final amountController = TextEditingController();
    DateTime now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Place Bid"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount (Rs.)"),
              ),
              // TextField(
              //   controller: messageController,
              //   decoration: const InputDecoration(labelText: "Message"),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                  amountController.text.trim(),
                )?.toInt();

                if (amount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid number")),
                  );
                  return;
                }

                try {
                  await ApiService.placeBid(
                    requestId: requestId,
                    workerId: widget.workerId,
                    amount: amount,
                    todaydate:
                        "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}",
                    todaytime:
                        "${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}",
                  );

                
                  setState(() {
                    requests.removeWhere((r) => r['id'] == requestId);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bid placed successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error placing bid")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
