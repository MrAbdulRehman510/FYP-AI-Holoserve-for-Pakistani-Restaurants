// AlertsScreen - System alerts and notifications screen
// Responsibilities:
//   1. Displays a list of mock system alerts with type, title, message, and time
//   2. Each alert type has a distinct icon and color for quick identification
//   3. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   4. AppTheme.backgroundFilter() applies theme-based background image and overlay
// Alert Types and Colors:
//   - out of stock   -> orange  -> inventory running low warning
//   - high traffic   -> blue    -> rush hour / high order volume alert
//   - device offline -> red     -> hardware or sensor failure alert
//   - info (default) -> accent  -> general system information
// Note: All data is hardcoded mock data - no Firebase connection used

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  PreferredSizeWidget _topBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: AppTheme.primaryTextColor(context), size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Notifications & Alerts',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.notifications_active,
                    color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {'type': 'out of stock', 'title': 'Stock Low!', 'message': 'Zinger Burger buns are running low.', 'time': '10:30 AM'},
      {'type': 'high traffic', 'title': 'Rush Hour', 'message': 'High orders detected in the last 10 mins.', 'time': '12:15 PM'},
      {'type': 'device offline', 'title': 'Camera Error', 'message': 'AI Vision Sensor in Kitchen is offline.', 'time': '01:05 PM'},
      {'type': 'info', 'title': 'System Update', 'message': 'AI Strategy has been optimized.', 'time': '02:00 PM'},
      {'type': 'out of stock', 'title': 'Low Inventory', 'message': 'Chicken patties stock is below threshold.', 'time': '03:20 PM'},
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 110, left: 16, right: 16, bottom: 16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final a = alerts[index];
              return _alertTile(a['type']!, a['title']!, a['message']!, a['time']!, context);
            },
          ),
        ),
      ),
    );
  }

  Widget _alertTile(String type, String title, String message, String time, BuildContext context) {
    Color iconColor;
    IconData iconData;
    switch (type.toLowerCase()) {
      case 'out of stock':
        iconColor = Colors.orangeAccent;
        iconData = Icons.inventory_2_outlined;
        break;
      case 'device offline':
        iconColor = Colors.redAccent;
        iconData = Icons.wifi_off_rounded;
        break;
      case 'high traffic':
        iconColor = Colors.blueAccent;
        iconData = Icons.trending_up_rounded;
        break;
      default:
        iconColor = AppTheme.accentColor(context);
        iconData = Icons.notifications_active_outlined;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.1),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: AppTheme.primaryTextColor(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(time,
                        style: TextStyle(
                            color: AppTheme.secondaryTextColor(context),
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(message,
                    style: TextStyle(
                        color: AppTheme.secondaryTextColor(context),
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
