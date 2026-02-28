// Customer Feedback Screen - Display and manage customer reviews and ratings
// Shows feedback statistics, filtering options, and individual review management
// Integrates with Firebase for real-time feedback data and test data generation

import 'dart:math'; // For random test data generation
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for managing customer feedback and reviews
class CustomerFeedbackScreen extends StatefulWidget {
  const CustomerFeedbackScreen({super.key});

  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

// State class managing feedback filtering and display logic
class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  double? filterRating; // Current rating filter
  String sortBy = 'newest'; // Sorting preference

  // Generate test feedback data for demonstration purposes
  Future<void> addTestFeedback() async {
    final names = ["Ali Khan", "Zainab", "Hamza", "Sara Ahmed", "Osama"];
    final comments = [
      "Zabardast service!",
      "Food was cold, but taste was good.",
      "Excellent atmosphere and staff.",
      "Highly recommended for families!",
      "Price is a bit high but worth it.",
    ];

    // Add random feedback to Firebase
    await FirebaseFirestore.instance.collection('feedbacks').add({
      'customerName': names[Random().nextInt(names.length)],
      'comment': comments[Random().nextInt(comments.length)],
      'rating': (Random().nextInt(5) + 1).toDouble(), // 1 to 5 Stars
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Custom app bar with feedback theme and filtering options
  PreferredSizeWidget customTopBar(BuildContext context, String title) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppTheme.primaryTextColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(),

                // Test data generation button
                IconButton(
                  icon: const Icon(
                    Icons.auto_fix_high,
                    color: Colors.amberAccent,
                  ),
                  tooltip: "Add Test Feedback",
                  onPressed: () {
                    addTestFeedback();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Test Feedback Added!")),
                    );
                  },
                ),

                // Rating filter dropdown menu
                PopupMenuButton<double?>(
                  icon: Icon(Icons.filter_list, color: AppTheme.accentColor(context)),
                  onSelected: (val) => setState(() => filterRating = val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text("All Ratings"),
                    ),
                    const PopupMenuItem(value: 5.0, child: Text("5 Stars ⭐")),
                    const PopupMenuItem(value: 4.0, child: Text("4+ Stars ⭐")),
                    const PopupMenuItem(
                      value: 2.0,
                      child: Text("Below 3 Stars ⚠️"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with feedback management interface
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: customTopBar(context, "Customer Feedback"),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
        child: Column(
          children: [
            const SizedBox(height: 110),

            // Dynamic feedback statistics header
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedbacks')
                  .snapshots(),
              builder: (context, snapshot) {
                int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor(context).withAlpha(25),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppTheme.accentColor(context).withAlpha(76),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("Total Feedback", total.toString()),
                        _buildStatColumn(
                          "Sorting",
                          sortBy == 'newest' ? "Newest First" : "Oldest",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Firebase stream for real-time feedback list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feedbacks')
                    .orderBy('timestamp', descending: sortBy == 'newest')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00E5FF),
                      ),
                    );
                  }

                  // Show empty state if no feedback exists
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No feedback found!",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  // Apply rating filter to feedback list
                  if (filterRating != null) {
                    if (filterRating == 2.0) {
                      // Show low ratings (3 stars or below)
                      docs = docs
                          .where((d) => (d['rating'] as num) <= 3.0)
                          .toList();
                    } else {
                      // Show ratings equal or above filter value
                      docs = docs
                          .where((d) => (d['rating'] as num) >= filterRating!)
                          .toList();
                    }
                  }

                  // Build scrollable list of feedback cards
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      String name = data['customerName'] ?? 'Anonymous';
                      double rating = (data['rating'] as num).toDouble();
                      String comment = data['comment'] ?? '';
                      String docId = docs[index].id;

                      // Individual feedback card
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryTextColor(context).withAlpha(13)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer info and rating row
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.accentColor(context).withAlpha(25),
                                  child: Text(
                                    name[0],
                                    style: TextStyle(
                                      color: AppTheme.accentColor(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: AppTheme.primaryTextColor(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Verified Customer",
                                      style: TextStyle(
                                        color: AppTheme.secondaryTextColor(context),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Star rating display
                                Row(
                                  children: List.generate(
                                    5,
                                    (sIndex) => Icon(
                                      sIndex < rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Customer comment text
                            Text(
                              comment,
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor(context),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Divider(color: AppTheme.primaryTextColor(context).withAlpha(25), height: 20),
                            // Delete feedback button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => FirebaseFirestore.instance
                                    .collection('feedbacks')
                                    .doc(docId)
                                    .delete(),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Remove",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Statistics column widget for feedback summary
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.primaryTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
