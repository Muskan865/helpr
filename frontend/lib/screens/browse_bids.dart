import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class BrowseBidsScreen extends StatefulWidget {
  final List<dynamic> bids;

  const BrowseBidsScreen({super.key, required this.bids});

  @override
  State<BrowseBidsScreen> createState() => _BrowseBidsScreenState();
}

class _BrowseBidsScreenState extends State<BrowseBidsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "My Bids"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.bids.isEmpty)
            _emptyCard("You haven't placed any bids yet.")
          else
            ...widget.bids.map((bid) => _bidCard(bid)),
        ],
      ),
    );
  }

  Widget _bidCard(Map bid) {
    final status = (bid['bid_status'] ?? '').toString();
    Color statusColor = Colors.grey;
    if (status == 'pending') statusColor = Colors.orange;
    if (status == 'accepted') statusColor = Colors.green;
    if (status == 'rejected') statusColor = Colors.redAccent;

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
            bid['service_type'] ?? "",
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            bid['description'] ?? "",
            style: GoogleFonts.nunito(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            "Bid Amount: Rs. ${bid['bid_amount'] ?? '—'}",
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Status: ${status.isEmpty ? 'unknown' : status}",
            style: GoogleFonts.nunito(color: statusColor, fontWeight: FontWeight.w600),
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelBid(bid['bid_id']),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text("Cancel Bid"),
              ),
            ),
          ],
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

  Future<void> _cancelBid(int bidId) async {
    try {
      await ApiService.cancelBid(bidId);
      if (!mounted) return;
      setState(() => widget.bids.removeWhere((b) => b['bid_id'] == bidId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid cancelled")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.errorMessage(e))),
      );
    }
  }
}
