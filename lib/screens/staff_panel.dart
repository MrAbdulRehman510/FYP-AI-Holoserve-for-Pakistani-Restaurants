// Staff Panel - Operational control panel for staff members
// Provides access to staff-specific functions: menu management, hologram control, feedback, etc.
// Includes quick actions for daily staff operations and profile access

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Screen imports for staff functionality
import 'out_of_stock_screen.dart'; // Stock availability management
import 'hologram_control_screen.dart'; // Hologram device control
import 'customer_feedback_screen.dart'; // Customer feedback viewing
import 'staff_table_status_screen.dart'; // Table status management
import 'staff_order_history_screen.dart'; // Order history viewing
import 'menu_management_screen.dart'; // Menu management interface
import 'staff_profile_screen.dart'; // Staff profile access
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles

// StatefulWidget for Staff Panel with operational controls
class StaffPanel extends StatefulWidget {
  const StaffPanel({super.key});

  @override
  State<StaffPanel> createState() => _StaffPanelState();
}

// State class for Staff Panel with hologram control and action management
class _StaffPanelState extends State<StaffPanel> {
  // State variable for hologram device status
  bool isHologramActive = false; // Tracks whether hologram projector is active

  // Custom top bar with gradient background and notification icon
  PreferredSizeWidget customTopBar(BuildContext context, String title) {
    return AppBar(
      automaticallyImplyLeading: false, // Remove default back button
      toolbarHeight: 90, // Custom height for better appearance
      backgroundColor: Colors.transparent, // Transparent to show gradient
      elevation: 0, // Remove shadow
      flexibleSpace: Container(
        // Gradient background container
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context), // Theme-based gradient
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24), // Rounded bottom corners
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Custom back button
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context), // Navigate back
                ),
                const SizedBox(width: 12),
                // Screen title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(), // Push notification icon to right
                // Notification icon (non-interactive for staff)
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

  // Reusable widget for creating staff action cards with navigation
  // Each card represents a different staff function with icon, title, and color
  Widget staffActionCard(
    String title, // Card title (e.g., "Menu Management")
    IconData icon, // Icon to display in circle avatar
    Color color, // Theme color for card styling
    VoidCallback onTap, // Function to execute when card is tapped
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: onTap, // Handle card tap
          child: Container(
            margin: const EdgeInsets.only(bottom: 15), // Space between cards
            padding: const EdgeInsets.all(20), // Internal padding
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context), // Theme-based card color
              borderRadius: BorderRadius.circular(20), // Rounded corners
              border: Border.all(color: color.withValues(alpha: 0.3)), // Colored border
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1), // Soft shadow
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon circle avatar
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2), // Light background
                  child: Icon(icon, color: color), // Themed icon
                ),
                const SizedBox(width: 20), // Space between icon and text
                // Card title
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(), // Push arrow to right
                // Forward arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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

  // Main build method - Creates the complete staff control panel
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context), // Theme-based background
          extendBodyBehindAppBar: true, // Allow body to extend behind app bar
          appBar: customTopBar(context, "Staff Control Panel"), // Custom app bar
          body: Container(
            width: double.infinity, // Full width
            height: double.infinity, // Full height
            decoration: AppTheme.backgroundFilter(context), // Background decoration
            child: SingleChildScrollView( // Scrollable content
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 20), // Padding with top space for app bar
                child: Column(
                  children: [
                    // Section header for quick actions
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Quick Actions",
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          letterSpacing: 1, // Letter spacing for better readability
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Menu Management Action Card
                    staffActionCard(
                      "Menu Management", // Card title
                      Icons.restaurant_menu, // Restaurant menu icon
                      Colors.orangeAccent, // Orange accent color
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuManagementScreen(),
                          ),
                        );
                      },
                    ),

                    // Update Availability Action Card
                    staffActionCard(
                      "Update Availability", // Card title
                      Icons.event_available, // Availability icon
                      Colors.blueAccent, // Blue accent color
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StaffOutOfStockScreen(),
                          ),
                        );
                      },
                    ),

                    // Hologram Projector Control Card with dynamic state
                    staffActionCard(
                      "Hologram Projector", // Card title
                      isHologramActive
                          ? Icons.stop_circle // Stop icon when active
                          : Icons.play_circle_fill, // Play icon when inactive
                      isHologramActive
                          ? Colors.redAccent // Red when active
                          : AppTheme.accentColor(context), // Theme accent when inactive
                      () {
                        setState(() {
                          isHologramActive = !isHologramActive; // Toggle hologram state
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HologramControlScreen(),
                          ),
                        );
                      },
                    ),

                    // Customer Feedback Action Card
                    staffActionCard(
                      "Customer Feedback", // Card title
                      Icons.rate_review_outlined, // Review icon
                      Colors.amberAccent, // Amber accent color
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerFeedbackScreen(),
                          ),
                        );
                      },
                    ),

                    // Table Status Action Card
                    staffActionCard(
                      "Table Status", // Card title
                      Icons.table_restaurant, // Table restaurant icon
                      Colors.purpleAccent, // Purple accent color
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StaffTableStatusScreen(),
                          ),
                        );
                      },
                    ),
                    
                    // Order History Action Card
                    staffActionCard(
                      "Order History", // Card title
                      Icons.history, // History icon
                      Colors.greenAccent, // Green accent color
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StaffOrderHistoryScreen(),
                          ),
                        );
                      },
                    ),

                    // Staff Profile Action Card
                    staffActionCard(
                      "My Profile", // Card title
                      Icons.person, // Person icon
                      Colors.tealAccent, // Teal accent color
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StaffProfileScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    // App version footer
                    Text(
                      "Staff Terminal Active • 2026",
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                        fontSize: 12,
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
