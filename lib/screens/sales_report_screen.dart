// SalesReportScreen - Sales and revenue report screen for admins
// Responsibilities:
//   1. Calculates and displays total revenue and total order count
//   2. Shows a list of recent transactions with order ID, items, price, and time
//   3. Revenue is automatically summed from the orders list using fold
//   4. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   5. AppTheme methods provide all colors and decorations for theme consistency
// Note: All data is hardcoded mock orders - no Firebase connection used

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  // Mock orders list - each order has id, item count, price, time, and status
  static final List<Map<String, dynamic>> _orders = [
    {'id': 'ORD-A1B2C', 'items': 3, 'price': 1250, 'time': '09:15 AM', 'status': 'Delivered'},
    {'id': 'ORD-D3E4F', 'items': 1, 'price': 450, 'time': '10:30 AM', 'status': 'Delivered'},
    {'id': 'ORD-G5H6I', 'items': 5, 'price': 2800, 'time': '11:45 AM', 'status': 'Delivered'},
    {'id': 'ORD-J7K8L', 'items': 2, 'price': 900, 'time': '12:20 PM', 'status': 'Delivered'},
    {'id': 'ORD-M9N0O', 'items': 4, 'price': 1750, 'time': '01:10 PM', 'status': 'Pending'},
    {'id': 'ORD-P1Q2R', 'items': 2, 'price': 680, 'time': '02:05 PM', 'status': 'Delivered'},
    {'id': 'ORD-S3T4U', 'items': 6, 'price': 3200, 'time': '03:30 PM', 'status': 'Delivered'},
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
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryTextColor(context), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Icon(Icons.analytics_outlined, color: AppTheme.primaryTextColor(context)),
                const SizedBox(width: 12),
                Text('Sales Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.download_rounded, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals by folding over the orders list
    final totalRevenue = _orders.fold<int>(0, (sum, o) => sum + (o['price'] as int));
    final totalOrders = _orders.length;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _statsCard('Total Revenue', 'Rs $totalRevenue', Icons.account_balance_wallet, AppTheme.accentColor(context), context),
                    const SizedBox(width: 15),
                    _statsCard('Total Orders', '$totalOrders', Icons.shopping_bag, Colors.orangeAccent, context),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent Transactions', style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final o = _orders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
                            child: const Icon(Icons.receipt_long, color: Colors.greenAccent, size: 20),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('#${o['id']}', style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold)),
                                Text('${o['items']} Items', style: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6), fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rs ${o['price']}', style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold)),
                              Text(o['time'], style: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6), fontSize: 10)),
                            ],
                          ),
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

  Widget _statsCard(String label, String value, IconData icon, Color color, BuildContext context) {
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
            Text(label, style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 14)),
            const SizedBox(height: 5),
            FittedBox(child: Text(value, style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
