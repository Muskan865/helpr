import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '/widgets/appbar.dart';

class WorkerRatingsScreen extends StatefulWidget {
  final int workerId;
  final double avgRating;
  final String workerName;

  const WorkerRatingsScreen({
    super.key,
    required this.workerId,
    required this.avgRating,
    required this.workerName,
  });

  @override
  State<WorkerRatingsScreen> createState() => _WorkerRatingsScreenState();
}

class _WorkerRatingsScreenState extends State<WorkerRatingsScreen> {
  List<dynamic> ratings = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      final data = await ApiService.getWorkerRatings(widget.workerId);
      setState(() {
        ratings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get filteredRatings {
    if (selectedFilter == 'All') return ratings;
    if (selectedFilter == '5★') {
      return ratings.where((r) => (r['rating'] as num) == 5).toList();
    }
    if (selectedFilter == '3★ and below') {
      return ratings.where((r) => (r['rating'] as num) <= 3).toList();
    }
    return ratings;
  }

  int countForFilter(String filter) {
    if (filter == 'All') return ratings.length;
    if (filter == '5★') {
      return ratings.where((r) => (r['rating'] as num) == 5).length;
    }
    if (filter == '3★ and below') {
      return ratings.where((r) => (r['rating'] as num) <= 3).length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', '5★', '3★ and below'];

    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      // Worker identity row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              widget.workerName.isNotEmpty
                                  ? widget.workerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.workerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Rating summary box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _starRow(widget.avgRating),
                                const SizedBox(height: 4),
                                Text(
                                  "Based on ${ratings.length} reviews",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Filter tabs
                      Row(
                        children: filters.map((f) {
                          final isSelected = selectedFilter == f;
                          return GestureDetector(
                            onTap: () => setState(() => selectedFilter = f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                ),
                              ),
                              child: Text(
                                "$f (${countForFilter(f)})",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // const SizedBox(height, 8),
                      const Divider(),
                    ],
                  ),
                ),

                // Reviews list
                Expanded(
                  child: filteredRatings.isEmpty
                      ? const Center(child: Text("No reviews"))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRatings.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final r = filteredRatings[index];
                            final name = r['reviewer_name'] ?? 'User';
                            final initials = name
                                .trim()
                                .split(' ')
                                .where(
                                  (String w) => w.isNotEmpty,
                                ) // ← explicit String type
                                .take(2)
                                .map(
                                  (String w) => w[0].toUpperCase(),
                                ) // ← explicit String type
                                .join();
                            final rating = (r['rating'] ?? 0).toDouble();
                            final review = r['comment'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _starRow(rating),
                                  if (review.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(review),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _starRow(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, size: 18, color: Colors.black);
        } else if (i < rating && rating - i >= 0.5) {
          return const Icon(Icons.star_half, size: 18, color: Colors.black);
        } else {
          return const Icon(Icons.star_border, size: 18, color: Colors.black);
        }
      }),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (_) {
      return '';
    }
  }
}
