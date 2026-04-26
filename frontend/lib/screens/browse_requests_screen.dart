import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late List<dynamic> requests;

  @override
  void initState() {
    super.initState();
    requests = List.from(widget.serviceRequests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Matching Requests"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (requests.isEmpty)
            _emptyCard("No matching requests right now.")
          else
            ...requests.map((request) => _requestCard(request)),
        ],
      ),
    );
  }

  Widget _requestCard(Map request) {
    final parsedDate = request['date'] != null
        ? DateTime.tryParse(request['date'].toString())
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request['service_type'] ?? "",
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            request['description'] ?? "",
            style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request['location'] ?? "—",
                  style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                parsedDate != null
                    ? "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}"
                    : "—",
                style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showBidDialog(request['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text("Place Bid"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(color: Colors.grey.shade600),
      ),
    );
  }

  void _showBidDialog(int requestId) {
    final amountController = TextEditingController();
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Place Bid"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Amount (Rs.)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid amount")),
                );
                return;
              }

              try {
                await ApiService.placeBid(
                  requestId: requestId,
                  workerId: widget.workerId,
                  amount: amount,
                  todaydate: "${now.year}-${twoDigits(now.month)}-${twoDigits(now.day)}",
                  todaytime: "${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}",
                );

                if (!mounted) return;
                setState(() => requests.removeWhere((r) => r['id'] == requestId));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Bid placed successfully")),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ApiService.errorMessage(e))),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
