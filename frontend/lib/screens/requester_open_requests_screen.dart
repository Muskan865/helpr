import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'received_bids_screen.dart';

class RequesterOpenRequestsScreen extends StatefulWidget {
  final int requesterId;
  const RequesterOpenRequestsScreen({super.key, required this.requesterId});

  @override
  State<RequesterOpenRequestsScreen> createState() =>
      _RequesterOpenRequestsScreenState();
}

class _RequesterOpenRequestsScreenState
    extends State<RequesterOpenRequestsScreen> {
  List<dynamic> openRequests = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final result =
          await ApiService.getRequesterOpenRequests(widget.requesterId);
      if (mounted) {
        setState(() {
          openRequests = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Failed to load requests";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.grey.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Active Requests",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(error!,
                          style: GoogleFonts.nunito(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            error = null;
                          });
                          _loadRequests();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: openRequests.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No active requests",
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Post a request to start receiving bids",
                                    style: GoogleFonts.nunito(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: openRequests.length,
                          itemBuilder: (context, index) =>
                              _requestCard(openRequests[index]),
                        ),
                ),
    );
  }

  Widget _requestCard(Map request) {
    final bidCount = request['bid_count'] ?? 0;
    final date = request['date'] != null
        ? DateTime.tryParse(request['date'].toString())
        : null;
    final dateStr = date != null
        ? "${date.day}/${date.month}/${date.year}"
        : "—";

    return GestureDetector(
      onTap: () {
        // Tap card to view received bids for this request
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ReceivedBidsScreen(requesterId: widget.requesterId),
          ),
        ).then((_) => _loadRequests());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request['service_type'] ?? "",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Open badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Open",
                    style: GoogleFonts.nunito(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            if (request['description'] != null &&
                request['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  request['description'],
                  style: GoogleFonts.nunito(
                      color: Colors.grey.shade600, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  request['location'] ?? "—",
                  style:
                      GoogleFonts.nunito(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "$dateStr  •  ${request['time'] ?? '—'}",
                  style:
                      GoogleFonts.nunito(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row: bid count + view bids button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bidCount > 0
                            ? Colors.blue.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.gavel,
                            size: 14,
                            color: bidCount > 0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$bidCount bid${bidCount != 1 ? 's' : ''}",
                            style: GoogleFonts.nunito(
                              color: bidCount > 0
                                  ? Colors.blue
                                  : Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "View Bids ",
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
