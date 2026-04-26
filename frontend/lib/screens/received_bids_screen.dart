import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';
import 'worker_public_profile_screen.dart';

class ReceivedBidsScreen extends StatefulWidget {
  final int requesterId;

  const ReceivedBidsScreen({super.key, required this.requesterId});

  @override
  State<ReceivedBidsScreen> createState() => _ReceivedBidsScreenState();
}

class _ReceivedBidsScreenState extends State<ReceivedBidsScreen> {
  List<dynamic> bids = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    try {
      final result = await ApiService.getRequesterBids(widget.requesterId);
      setState(() {
        bids = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load bids";
        isLoading = false;
      });
    }
  }

  Future<void> _acceptBid(int bidId, int requestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accept Bid"),
        content: const Text(
            "Are you sure you want to accept this bid? The worker will be hired immediately."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("Accept", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.acceptBid(bidId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bid accepted! Job tracking started.")),
        );
        // Refresh bids
        setState(() => isLoading = true);
        _loadBids();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to accept bid. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : bids.isEmpty
                  ? const Center(
                      child: Text(
                        "No bids received yet.\nPost a request to get started!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          "Received Bids",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${bids.length} bid(s) on your requests",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ...bids.map((bid) => _bidCard(bid)),
                      ],
                    ),
    );
  }

  Widget _bidCard(Map bid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service request label
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              bid['service_type'] ?? "",
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            bid['description'] ?? "",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                bid['location'] ?? "-",
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          const Divider(height: 20),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  (bid['worker_name'] ?? "?")[0].toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid['worker_name'] ?? "Worker",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      "${bid['profession'] ?? ''} • ${bid['past_jobs'] ?? 0} jobs done",
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    "${bid['worker_rating'] ?? '—'}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs. ${bid['bid_amount'] ?? '—'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${bid['bid_date'] ?? ''} ${bid['bid_time'] ?? ''}",
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerPublicProfileScreen(
                          workerId: bid['worker_user_id'],
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "View Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _acceptBid(bid['bid_id'], bid['request_id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Accept Bid"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
