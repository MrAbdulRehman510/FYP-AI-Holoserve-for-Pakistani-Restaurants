// Sales Report Screen - Displays revenue analytics and transaction history
// Shows total revenue, order count, and recent transactions with Firebase integration
// Includes test data generation functionality for demonstration purposes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatelessWidget for Sales Report with Firebase streaming
class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  // Generate sample order data for testing purposes
  void _generateSampleOrder(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'total_price': 1250,
        'item_count': 2,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sample Order Added Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Custom app bar with gradient background and analytics styling
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
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.primaryTextColor(context),
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
                Icon(
                  Icons.download_rounded,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Statistics card widget for displaying revenue and order metrics
  Widget statsCard(String label, String value, IconData icon, Color color) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Main build method with Firebase streaming for real-time sales data
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          extendBodyBehindAppBar: true,
          appBar: customTopBar(context, "Sales Reports"),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.accentColor(context),
            onPressed: () => _generateSampleOrder(context),
            child: Icon(
              Icons.add_shopping_cart,
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundFilter(context),
            // Firebase stream for real-time order data
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentColor(context),
                    ),
                  );
                }

                // Calculate total revenue and order count from Firebase data
                double totalRevenue = 0;
                int totalOrders = 0;
                var orderDocs = snapshot.data?.docs ?? [];

                // Process each order document for calculations
                for (var doc in orderDocs) {
                  var data = doc.data() as Map<String, dynamic>;
                  totalRevenue += (data['total_price'] ?? 0).toDouble();
                  totalOrders++;
                }

                return Column(
                  children: [
                    const SizedBox(height: 120),
                    // Statistics cards row showing key metrics
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          statsCard(
                            "Total Revenue",
                            "Rs ${totalRevenue.toStringAsFixed(0)}",
                            Icons.account_balance_wallet,
                            AppTheme.accentColor(context),
                          ),
                          const SizedBox(width: 15),
                          statsCard(
                            "Total Orders",
                            "$totalOrders",
                            Icons.shopping_bag,
                            Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recent Transactions",
                          style: TextStyle(
                            color: AppTheme.primaryTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Transaction list section
                    Expanded(
                      child: orderDocs.isEmpty
                          ? Center(
                              child: Text(
                                "No transactions found\nTap the + button to add test data",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor(context),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: orderDocs.length,
                              itemBuilder: (context, index) {
                                var data = orderDocs[index].data() as Map<String, dynamic>;
                                
                                // Format timestamp for display
                                String formattedTime = "N/A";
                                if (data['timestamp'] != null) {
                                  DateTime date = (data['timestamp'] as Timestamp).toDate();
                                  formattedTime = DateFormat('hh:mm a').format(date);
                                }

                                // Individual transaction card
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor(context),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                                        child: const Icon(
                                          Icons.receipt_long,
                                          color: Colors.greenAccent,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order #${orderDocs[index].id.substring(0, 5).toUpperCase()}",
                                            style: TextStyle(
                                              color: AppTheme.primaryTextColor(context),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${data['item_count'] ?? 1} Items",
                                            style: TextStyle(
                                              color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Rs ${data['total_price']}",
                                            style: TextStyle(
                                              color: AppTheme.accentColor(context),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
