// Admin Dashboard - Main control center for administrators
// Provides access to all admin features: menu management, analytics, staff control, system settings
// Includes role-based access control and hologram device management

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart'; // For hologram device control
import 'package:provider/provider.dart';
import 'analytics_screen.dart';
import 'menu_management_screen.dart';

import 'staff_management_screen.dart';
import 'admin_promotions_screen.dart';
import 'alert_admin_screen.dart';
import 'admin_recommendations_screen.dart';
import 'hologram_script_screen.dart';
import 'system_settings_screen.dart';

import 'add_new_admin_screen.dart';
import 'sales_report_screen.dart';
import 'admin_profile_screen.dart';

import '../theme_provider.dart';
import '../app_theme.dart';
import '../auth_provider.dart';
import '../widgets/role_based_widget.dart';

// StatelessWidget for Admin Dashboard with comprehensive management features
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // Custom top bar with gradient background and notification access
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
                IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    color: AppTheme.accentColor(context),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for creating admin action cards with navigation
  // Each card represents a different admin function with icon, title, and color
  Widget adminActionCard(
    String title, // Card title (e.g., "Manage Menu")
    IconData icon, // Icon to display in circle avatar
    Color color, // Theme color for card styling
    VoidCallback onTap, // Function to execute when card is tapped
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.secondaryTextColor(
                    context,
                  ).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hologram Control Card - Real-time device management with Firebase integration
  // Displays hologram device status and provides on/off control with live updates
  Widget _buildHologramControlCard(BuildContext context) {
    // StreamBuilder for real-time Firebase data updates
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('deviceControl') // Firebase collection for device control
          .doc('hologram_1') // Specific hologram device document
          .snapshots(), // Real-time updates
      builder: (context, snapshot) {
        // Determine device status from Firebase data
        bool isOn = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          isOn = snapshot.data!['command'] != 'SHUTDOWN'; // Check if device is active
        }

        // Dynamic color based on device status (green = on, red = off)
        Color statusColor = isOn ? Colors.greenAccent : Colors.redAccent;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HologramScriptScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.vibration, color: statusColor, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "3D Hologram Unit",
                        style: TextStyle(
                          color: AppTheme.primaryTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOn ? "LIVE & PROJECTING" : "OFFLINE / SLEEP",
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                      Text(
                        "Tap to open script manager",
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: isOn,
                    onChanged: (val) {
                      FirebaseFirestore.instance
                          .collection('deviceControl')
                          .doc('hologram_1')
                          .set({
                            'command': val ? 'START_ANIMATION' : 'SHUTDOWN',
                            'timestamp': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                    },
                    activeTrackColor: Colors.greenAccent.withValues(alpha: 0.4),
                    activeThumbColor: Colors.greenAccent,
                    inactiveThumbColor: Colors.redAccent,
                    inactiveTrackColor: Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Block staff from accessing admin dashboard
        if (authProvider.isStaff) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor(context),
            body: Container(
              decoration: AppTheme.backgroundFilter(context),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 80, color: Colors.redAccent),
                    const SizedBox(height: 20),
                    Text(
                      "Access Denied",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Staff members cannot access Admin Dashboard",
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor(context),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor(context),
                      ),
                      child: Text(
                        "Go Back",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show full admin dashboard for admin users
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor(context),
              extendBodyBehindAppBar: true,
              appBar: customTopBar(context, "Admin Dashboard"),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: AppTheme.backgroundFilter(context),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Management Center",
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Debug: Show current user role
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor(
                                  context,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Current Role: ${authProvider.currentUser?.role ?? 'None'}",
                                style: TextStyle(
                                  color: AppTheme.accentColor(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),

                        adminActionCard(
                          "Manage Menu",
                          Icons.restaurant_menu,
                          Colors.amberAccent,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MenuManagementScreen(),
                            ),
                          ),
                        ),

                        adminActionCard(
                          "Alerts & Notifications",
                          Icons.notification_important,
                          Colors.redAccent,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlertsScreen(),
                            ),
                          ),
                        ),

                        adminActionCard(
                          "Sales Reports",
                          Icons.bar_chart,
                          Colors.greenAccent,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SalesReportScreen(),
                            ),
                          ),
                        ),

                        adminActionCard(
                          "Admin Profile",
                          Icons.account_circle,
                          Colors.purpleAccent,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminProfileScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Divider(
                          color: AppTheme.secondaryTextColor(
                            context,
                          ).withValues(alpha: 0.3),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Hardware & Systems",
                            style: TextStyle(
                              color: AppTheme.accentColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 🔥 The New Card Integrated Here
                        _buildHologramControlCard(context),

                        // Admin-only advanced controls
                        AdminOnly(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Advanced Controls",
                                style: TextStyle(
                                  color: AppTheme.accentColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              adminActionCard(
                                "Business Analytics",
                                Icons.analytics_outlined,
                                AppTheme.accentColor(context),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AnalyticsDashboard(),
                                  ),
                                ),
                              ),
                              adminActionCard(
                                "Promotions & Deals",
                                Icons.local_offer_outlined,
                                Colors.orangeAccent,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminPromotionsScreen(),
                                  ),
                                ),
                              ),
                              adminActionCard(
                                "Staff Management",
                                Icons.people_alt_outlined,
                                Colors.blueAccent,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const StaffManagementScreen(),
                                  ),
                                ),
                              ),
                              adminActionCard(
                                "AI Strategy Rules",
                                Icons.psychology,
                                AppTheme.accentColor(context),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AIRecommendationsScreen(),
                                  ),
                                ),
                              ),
                              adminActionCard(
                                "System Settings",
                                Icons.settings,
                                Colors.purpleAccent,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SystemSettingsScreen(),
                                  ),
                                ),
                              ),
                              adminActionCard(
                                "👤 Add New Admin",
                                Icons.person_add,
                                Colors.teal,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddNewAdminScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        Center(
                          child: Text(
                            "HoloServe Admin v1.0",
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
