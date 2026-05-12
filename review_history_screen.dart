import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewHistoryScreen extends StatelessWidget {
  const ReviewHistoryScreen({super.key});

  Stream<List<Map<String, dynamic>>> _getMyReviews() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('My Reviews',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getMyReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text('No reviews yet',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your reviews will appear here',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final rating = (review['rating'] as num).toDouble();
              final date = DateTime.parse(review['createdAt']);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade200, blurRadius: 8)
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name + date
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              review['foodName'] ?? 'Food Item',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 18,
                              color: i < rating
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${rating.toInt()}/5',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          review['comment'] ?? '',
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
