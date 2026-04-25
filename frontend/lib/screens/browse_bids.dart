import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class BrowseBidsScreen extends StatefulWidget {
  final List<dynamic> bids;
  const BrowseBidsScreen({super.key, required this.bids});

  @override
  State<BrowseBidsScreen> createState() => _BrowseBidsScreenState();
}

class _BrowseBidsScreenState extends State<BrowseBidsScreen> {
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
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
              "My Bids",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (widget.bids.isEmpty)
              const Text("No bids found")
            else
              ...widget.bids.map((bid) => bidCard(bid)),
          ],
        ),
      ),
    );
  }

  Widget bidCard(Map bid) {
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
            bid['service_type'] ?? "",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          Text(
            bid['description'] ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 6),
              Text(bid['location'] ?? "-"),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text(
                bid['date'] != null
                    ? "${DateTime.parse(bid['date']).day}/${DateTime.parse(bid['date']).month}/${DateTime.parse(bid['date']).year}"
                    : "-",
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Your Bid: Rs. ${bid['bid_amount']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            "Status: ${bid['bid_status']}",
            style: TextStyle(
              color: bid['bid_status'] == 'pending'
                  ? Colors.orange
                  : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

      
          if (bid['bid_status'] == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cancelBid(bid['bid_id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Cancel Bid"),
              ),
            ),
        ],
      ),
    );
  }

  void cancelBid(int bidId) async {
    try {
      await ApiService.cancelBid(bidId);

      setState(() {
        widget.bids.removeWhere((b) => b['bid_id'] == bidId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bid cancelled")));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to cancel bid")));
    }
  }
}
