// Alert Admin Screen - Displays system notifications and alerts
// Shows real-time alerts from Firebase with fallback to dummy data
// Categorizes alerts by type with appropriate icons and colors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatelessWidget for displaying system alerts and notifications
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  // Custom app bar with notification theme and gradient styling
  PreferredSizeWidget customTopBar(BuildContext context, String title) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_active,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with Firebase streaming for real-time alerts
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        extendBodyBehindAppBar:
            true, // Taake gradient top bar ke pichay nazar aaye
        appBar: customTopBar(context, "Notifications & Alerts"),
        // Firebase stream for real-time alert notifications
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('alerts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor(context)),
              );
            }

            // Show dummy alerts if Firebase data is empty
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildDummyAlerts(context);
            }

            // Build list from Firebase alert data
            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 110,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String type = data['type'] ?? 'info';
                String title = data['title'] ?? 'Alert';
                String message = data['message'] ?? '';

                // Format timestamp for display
                String time = "Just now";
                if (data['timestamp'] != null) {
                  time = DateFormat(
                    'jm',
                  ).format((data['timestamp'] as Timestamp).toDate());
                }

                return alertTile(type, title, message, time, context);
              },
            );
          },
        ),
      ),
    );
  }

  // Build dummy alerts for demonstration when Firebase is empty
  Widget _buildDummyAlerts(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 110, left: 16, right: 16, bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            "Simulated AI Alerts (Offline Mode)",
            style: TextStyle(
              color: AppTheme.secondaryTextColor(context),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        // Sample alert tiles for different alert types
        alertTile(
          'out of stock',
          'Stock Low!',
          'Zinger Burger buns are running low.',
          '10:30 AM',
          context,
        ),
        alertTile(
          'high traffic',
          'Rush Hour',
          'High orders detected in the last 10 mins.',
          '12:15 PM',
          context,
        ),
        alertTile(
          'device offline',
          'Camera Error',
          'AI Vision Sensor in Kitchen is offline.',
          '01:05 PM',
          context,
        ),
        alertTile(
          'info',
          'System Update',
          'AI Strategy has been optimized.',
          '02:00 PM',
          context,
        ),
      ],
    );
  }

  // Individual alert tile with type-based styling and icons
  Widget alertTile(String type, String title, String message, String time, BuildContext context) {
    Color iconColor;
    IconData iconData;

    // Determine icon and color based on alert type
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

    // Alert card with icon, title, message, and timestamp
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
          // Alert type icon with colored background
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.1),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          // Alert content with title, message, and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}