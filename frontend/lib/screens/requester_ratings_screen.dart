import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class RequesterRatingsScreen extends StatefulWidget {
  final int requesterId;
  const RequesterRatingsScreen({super.key, required this.requesterId});

  @override
  State<RequesterRatingsScreen> createState() => _RequesterRatingsScreenState();
}

class _RequesterRatingsScreenState extends State<RequesterRatingsScreen> {
  List<dynamic> ratings = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    try {
      final data = await ApiService.getRequesterRatings(widget.requesterId);
      setState(() {
        ratings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = ApiService.errorMessage(e, fallback: "Couldn't load ratings.");
        isLoading = false;
      });
    }
  }

  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    final sum = ratings.fold<double>(
      0.0,
      (prev, r) => prev + (double.tryParse(r['rating'].toString()) ?? 0.0),
    );
    return sum / ratings.length;
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
          "My Ratings",
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
                  child: Text(error!,
                      style: GoogleFonts.nunito(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchRatings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Average rating summary card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: GoogleFonts.nunito(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  final full = i < averageRating.floor();
                                  final half = !full &&
                                      i < averageRating &&
                                      (averageRating - i) >= 0.5;
                                  return Icon(
                                    full
                                        ? Icons.star
                                        : half
                                            ? Icons.star_half
                                            : Icons.star_border,
                                    color: Colors.amber,
                                    size: 28,
                                  );
                                }),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${ratings.length} review${ratings.length != 1 ? 's' : ''}",
                                style: GoogleFonts.nunito(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (ratings.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.star_border,
                                      size: 60, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No ratings yet",
                                    style: GoogleFonts.nunito(
                                        color: Colors.grey, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...ratings.map((r) => _ratingCard(r)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _ratingCard(Map r) {
    final ratingVal =
        double.tryParse(r['rating'].toString()) ?? 0.0;
    final comment = r['comment'] ?? '';
    final reviewerName = r['reviewer_name'] ?? 'Worker';
    final jobType = r['service_type'] ?? '';
    final date = r['created_at'] != null
        ? DateTime.tryParse(r['created_at'].toString())
        : null;
    final dateStr = date != null
        ? "${date.day}/${date.month}/${date.year}"
        : '';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reviewerName,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < ratingVal.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          if (jobType.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              jobType,
              style: GoogleFonts.nunito(
                  color: Colors.blue, fontSize: 13),
            ),
          ],
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: GoogleFonts.nunito(
                  color: Colors.black87, fontSize: 14),
            ),
          ],
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: GoogleFonts.nunito(
                  color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
