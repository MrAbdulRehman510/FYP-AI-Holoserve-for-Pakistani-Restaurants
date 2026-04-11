// CustomerFeedbackScreen - Customer reviews and ratings screen
// Responsibilities:
//   1. Displays a list of mock customer feedback with name, comment, and star rating
//   2. Shows total feedback count and calculated average rating at the top
//   3. Admin mode (canDelete: true): shows Admin badge and delete button per review
//   4. Staff mode (canDelete: false): shows View Only badge, no delete option
//   5. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   6. AppTheme.backgroundFilter() applies theme-based background image and overlay
// Usage:
//   Admin : CustomerFeedbackScreen(canDelete: true)  - can remove reviews
//   Staff : CustomerFeedbackScreen()                 - read only
// Note: All data is local mock data - no Firebase connection used

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  final bool canDelete;
  const CustomerFeedbackScreen({super.key, this.canDelete = false});

  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  // Mock feedback list - each entry has customer name, comment, and star rating
  final List<Map<String, dynamic>> _feedbacks = [
    {'name': 'Ali Khan', 'comment': 'Zabardast service! Food was amazing.', 'rating': 5.0},
    {'name': 'Zainab', 'comment': 'Food was cold, but taste was good.', 'rating': 3.0},
    {'name': 'Hamza', 'comment': 'Excellent atmosphere and staff.', 'rating': 4.0},
    {'name': 'Sara Ahmed', 'comment': 'Highly recommended for families!', 'rating': 5.0},
    {'name': 'Osama', 'comment': 'Price is a bit high but worth it.', 'rating': 4.0},
    {'name': 'Fatima', 'comment': 'Great hologram experience, very unique!', 'rating': 5.0},
    {'name': 'Usman', 'comment': 'Service was slow but food quality was top notch.', 'rating': 3.0},
  ];

  PreferredSizeWidget _topBar(BuildContext context) {
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
                  icon: Icon(Icons.arrow_back,
                      color: AppTheme.primaryTextColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Text('Customer Feedback',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                // Show delete badge only for admin
                if (widget.canDelete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Admin',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('View Only',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_feedbacks.isEmpty) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _topBar(context),
          body: Container(
            decoration: AppTheme.backgroundFilter(context),
            child: Center(
              child: Text('No feedback yet.',
                  style: TextStyle(color: AppTheme.secondaryTextColor(context))),
            ),
          ),
        ),
      );
    }

    // Calculate average rating by summing all ratings and dividing by count
    final double avg = _feedbacks
            .map((f) => f['rating'] as double)
            .reduce((a, b) => a + b) /
        _feedbacks.length;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 110),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: AppTheme.accentColor(context).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCol('Total Feedback', '${_feedbacks.length}', context),
                      _statCol('Avg Rating', avg.toStringAsFixed(1), context),
                      if (widget.canDelete)
                        _statCol('Role', 'Admin', context),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _feedbacks.length,
                  itemBuilder: (context, index) {
                    final f = _feedbacks[index];
                    final name = f['name'] as String;
                    final rating = f['rating'] as double;
                    final comment = f['comment'] as String;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primaryTextColor(context)
                                .withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.accentColor(context)
                                    .withValues(alpha: 0.1),
                                child: Text(name[0],
                                    style: TextStyle(
                                        color: AppTheme.accentColor(context))),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          color: AppTheme.primaryTextColor(context),
                                          fontWeight: FontWeight.bold)),
                                  Text('Verified Customer',
                                      style: TextStyle(
                                          color:
                                              AppTheme.secondaryTextColor(context),
                                          fontSize: 10)),
                                ],
                              ),
                              const Spacer(),
                              // Generate 5 star icons - filled if index < rating, outlined otherwise
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < rating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(comment,
                              style: TextStyle(
                                  color: AppTheme.secondaryTextColor(context),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic)),
                          // Show delete button only for admin
                          if (widget.canDelete) ...[
                            Divider(
                                color: AppTheme.primaryTextColor(context)
                                    .withValues(alpha: 0.1),
                                height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    setState(() => _feedbacks.removeAt(index)),
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 18),
                                label: const Text('Remove',
                                    style: TextStyle(
                                        color: Colors.redAccent, fontSize: 12)),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _statCol(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: AppTheme.secondaryTextColor(context), fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: AppTheme.primaryTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
