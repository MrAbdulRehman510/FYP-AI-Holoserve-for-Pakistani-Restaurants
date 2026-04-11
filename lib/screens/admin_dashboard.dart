// AdminDashboard - Main control panel for admin users
// Responsibilities:
//   1. Displays all admin feature cards organized in sections
//   2. Manages hologram device on/off state with a local switch
//   3. Shows Advanced Controls section only to admin role (via AdminOnly widget)
// Sections:
//   - Management Center  : Menu, Alerts, Sales, Feedback, Admin Profile
//   - Hardware & Systems : Hologram device control card
//   - Advanced Controls  : Analytics, Promotions, Staff, AI Rules, Settings
// Note: Hologram state is local only - resets when screen is closed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analytics_screen.dart';          // Business analytics dashboard
import 'menu_management_screen.dart';     // Menu items and categories
import 'customer_feedback_screen.dart';   // Customer reviews (admin can delete)
import 'staff_management_screen.dart';    // Hire and manage staff members
import 'admin_promotions_screen.dart';    // Promotions and discount deals
import 'alert_admin_screen.dart';         // System alerts and notifications
import 'admin_recommendations_screen.dart'; // AI strategy rules
import 'hologram_script_screen.dart';     // Hologram voice script editor
import 'system_settings_screen.dart';     // App settings (theme, language, logout)
import 'sales_report_screen.dart';        // Sales and revenue reports
import 'admin_profile_screen.dart';       // Admin personal profile
import '../theme_provider.dart';          // Dark/light theme state
import '../app_theme.dart';               // Centralized theme colors and styles
import '../widgets/role_based_widget.dart'; // AdminOnly widget for role-based UI

// StatefulWidget needed because hologram on/off state changes locally
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  // Tracks hologram device power state - local only, not saved to Firebase
  // true = LIVE & PROJECTING | false = OFFLINE / SLEEP
  bool _hologramOn = false;

  // Builds the custom gradient app bar with back button and notification bell
  // title: text shown in the center of the app bar
  PreferredSizeWidget customTopBar(BuildContext context, String title) {
    return AppBar(
      automaticallyImplyLeading: false, // Disable default back button
      toolbarHeight: 90,                // Taller than default for better appearance
      backgroundColor: Colors.transparent, // Transparent to show gradient behind
      elevation: 0,                     // No shadow
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context), // Theme-based gradient
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),  // Rounded bottom corners
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Back button - navigates to previous screen (RoleScreen)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: AppTheme.primaryTextColor(context), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                // Screen title text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(), // Push notification icon to the right
                // Notification bell - tapping opens AlertsScreen
                IconButton(
                  icon: Icon(Icons.notifications_active,
                      color: AppTheme.accentColor(context)),
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

  // Reusable action card widget used for every feature on the dashboard
  // Parameters:
  //   title  : Feature name shown on the card
  //   icon   : Icon shown in the colored circle avatar
  //   color  : Accent color for border, shadow, and avatar background
  //   onTap  : Navigation callback executed when card is tapped
  Widget adminActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: onTap, // Navigate to the corresponding screen
          child: Container(
            margin: const EdgeInsets.only(bottom: 15), // Space between cards
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)), // Colored border
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.1), // Soft colored shadow
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: Row(
              children: [
                // Colored circle with feature icon
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 20),
                // Feature title text
                Text(title,
                    style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                const Spacer(), // Push arrow to the right
                // Forward arrow indicating the card is tappable
                Icon(Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.secondaryTextColor(context)
                        .withValues(alpha: 0.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hologram device control card with live status indicator and power switch
  // Tapping the card body opens HologramScriptScreen to edit voice scripts
  // The switch toggles _hologramOn which changes the card color and status text
  Widget _buildHologramControlCard(BuildContext context) {
    // Status color: green when on, red when off
    final statusColor = _hologramOn ? Colors.greenAccent : Colors.redAccent;
    return GestureDetector(
      // Tap card body to open script manager
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const HologramScriptScreen())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
                color: statusColor.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2)
          ],
        ),
        child: Row(
          children: [
            // Status icon circle - color matches current power state
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child: Icon(Icons.vibration, color: statusColor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device name
                  Text('3D Hologram Unit',
                      style: TextStyle(
                          color: AppTheme.primaryTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // Status text changes based on _hologramOn state
                  Text(_hologramOn ? 'LIVE & PROJECTING' : 'OFFLINE / SLEEP',
                      style: TextStyle(color: statusColor, fontSize: 12)),
                  // Hint text to open script manager
                  Text('Tap to open script manager',
                      style: TextStyle(
                          color: AppTheme.secondaryTextColor(context)
                              .withValues(alpha: 0.5),
                          fontSize: 10)),
                ],
              ),
            ),
            // Power switch - toggles _hologramOn and rebuilds card with new color
            Transform.scale(
              scale: 1.2, // Slightly larger switch for better touch target
              child: Switch(
                value: _hologramOn,
                onChanged: (val) => setState(() => _hologramOn = val),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          extendBodyBehindAppBar: true, // Body extends behind the transparent app bar
          appBar: customTopBar(context, 'Admin Dashboard'),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundFilter(context), // Theme-based background
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 20), // Top padding for app bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ---- Section 1: Management Center ----
                    // Core daily management features accessible to all admins
                    const Text('Management Center',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    // Menu management - add/edit/delete menu items and categories
                    adminActionCard(
                        'Manage Menu',
                        Icons.restaurant_menu,
                        Colors.amberAccent,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MenuManagementScreen()))),

                    // Alerts - view system notifications and warnings
                    adminActionCard(
                        'Alerts & Notifications',
                        Icons.notification_important,
                        Colors.redAccent,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AlertsScreen()))),

                    // Sales reports - view revenue and order history
                    adminActionCard(
                        'Sales Reports',
                        Icons.bar_chart,
                        Colors.greenAccent,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SalesReportScreen()))),

                    // Customer feedback - admin can delete reviews (canDelete: true)
                    adminActionCard(
                        'Customer Feedback',
                        Icons.rate_review_outlined,
                        Colors.amberAccent,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CustomerFeedbackScreen(canDelete: true)))),

                    // Admin profile - view and edit personal info
                    adminActionCard(
                        'Admin Profile',
                        Icons.account_circle,
                        Colors.purpleAccent,
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AdminProfileScreen()))),

                    // ---- Section 2: Hardware & Systems ----
                    // Physical device controls
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Hardware & Systems',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),

                    // Hologram device card with power switch and script manager link
                    _buildHologramControlCard(context),

                    // ---- Section 3: Advanced Controls ----
                    // Only visible to users with admin role (AdminOnly widget hides for staff)
                    AdminOnly(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Advanced Controls',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          // Business analytics - charts and performance metrics
                          adminActionCard(
                              'Business Analytics',
                              Icons.analytics_outlined,
                              AppTheme.accentColor(context),
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AnalyticsDashboard()))),

                          // Promotions - create and manage discount deals
                          adminActionCard(
                              'Promotions & Deals',
                              Icons.local_offer_outlined,
                              Colors.orangeAccent,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AdminPromotionsScreen()))),

                          // Staff management - hire, activate, deactivate staff
                          adminActionCard(
                              'Staff Management',
                              Icons.people_alt_outlined,
                              Colors.blueAccent,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const StaffManagementScreen()))),

                          // AI strategy rules - configure recommendation triggers
                          adminActionCard(
                              'AI Strategy Rules',
                              Icons.psychology,
                              AppTheme.accentColor(context),
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AIRecommendationsScreen()))),

                          // System settings - theme, language, cloud backup, logout
                          adminActionCard(
                              'System Settings',
                              Icons.settings,
                              Colors.purpleAccent,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SystemSettingsScreen()))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    // App version footer shown at the bottom of the dashboard
                    Center(
                      child: Text(
                        'HoloServe Admin v1.0',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context)
                              .withValues(alpha: 0.5),
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
  }
}
