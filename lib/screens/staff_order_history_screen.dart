// ============================================================
// StaffOrderHistoryScreen - Staff ke liye order history ka screen
// Kaam: Mock orders ki list dikhata hai
// Order Status:
//   - Delivered -> green color
//   - Pending   -> orange color
//   Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   AppTheme.backgroundFilter() se theme-based background apply hoti hai
// Note: Hardcoded mock data - Firebase nahi use hota
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class StaffOrderHistoryScreen extends StatelessWidget {
  const StaffOrderHistoryScreen({super.key});

  static final List<Map<String, dynamic>> _orders = [
    {'id': 'ORD-A1B2C', 'items': 3, 'price': 1250, 'time': '09:15 AM', 'status': 'Delivered'},
    {'id': 'ORD-D3E4F', 'items': 1, 'price': 450, 'time': '10:30 AM', 'status': 'Delivered'},
    {'id': 'ORD-G5H6I', 'items': 5, 'price': 2800, 'time': '11:45 AM', 'status': 'Delivered'},
    {'id': 'ORD-J7K8L', 'items': 2, 'price': 900, 'time': '12:20 PM', 'status': 'Pending'},
    {'id': 'ORD-M9N0O', 'items': 4, 'price': 1750, 'time': '01:10 PM', 'status': 'Delivered'},
    {'id': 'ORD-P1Q2R', 'items': 2, 'price': 680, 'time': '02:05 PM', 'status': 'Delivered'},
    {'id': 'ORD-S3T4U', 'items': 6, 'price': 3200, 'time': '03:30 PM', 'status': 'Pending'},
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
                const SizedBox(width: 12),
                Text('Order History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.history_rounded, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 130, 20, 20),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final o = _orders[index];
              final isDelivered = o['status'] == 'Delivered';
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (isDelivered ? Colors.greenAccent : Colors.orangeAccent).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (isDelivered ? Colors.greenAccent : Colors.orangeAccent).withValues(alpha: 0.1),
                      child: Icon(isDelivered ? Icons.check_circle_outline : Icons.pending_actions, color: isDelivered ? Colors.greenAccent : Colors.orangeAccent),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#${o['id']}', style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${o['items']} Items • ${o['time']}', style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs ${o['price']}', style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold)),
                        Text(o['status'], style: TextStyle(color: isDelivered ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
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
