// Staff Order History Screen - Display order history for staff users
// Shows completed and pending orders with status indicators
// Features consistent design with custom app bar and order cards

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatelessWidget for displaying staff order history
class StaffOrderHistoryScreen extends StatelessWidget {
  const StaffOrderHistoryScreen({super.key});

  // Custom app bar with order history theme and consistent styling
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
                Icon(Icons.history_rounded, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with order history display
  @override
  Widget build(BuildContext context) {
    // Sample order data with different statuses and details
    final List<Map<String, dynamic>> orders = [
      {
        "id": "#ORD-9921",
        "table": "T-2",
        "amount": "Rs. 2,500",
        "status": "Delivered",
        "time": "10 mins ago",
      },
      {
        "id": "#ORD-9920",
        "table": "T-4",
        "amount": "Rs. 1,850",
        "status": "Pending",
        "time": "25 mins ago",
      },
      {
        "id": "#ORD-9919",
        "table": "T-1",
        "amount": "Rs. 4,200",
        "status": "Delivered",
        "time": "1 hour ago",
      },
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        // Custom app bar with order history theme
        appBar: customTopBar(context, "Order History"),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: ListView.builder(
            // Adjusted padding for custom app bar spacing
            padding: const EdgeInsets.fromLTRB(20, 130, 20, 20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              bool isDelivered = order['status'] == "Delivered";

              // Individual order card with status-based styling
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        (isDelivered ? Colors.greenAccent : Colors.orangeAccent)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Status indicator icon
                    CircleAvatar(
                      backgroundColor:
                          (isDelivered ? Colors.greenAccent : Colors.orangeAccent)
                          .withValues(alpha: 0.1),
                      child: Icon(
                        isDelivered
                            ? Icons.check_circle_outline
                            : Icons.pending_actions,
                        color: isDelivered
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Order details section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['id'],
                            style: TextStyle(
                              color: AppTheme.primaryTextColor(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Table: ${order['table']} • ${order['time']}",
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount and status section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order['amount'],
                          style: TextStyle(
                            color: AppTheme.primaryTextColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['status'],
                          style: TextStyle(
                            color: isDelivered
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}