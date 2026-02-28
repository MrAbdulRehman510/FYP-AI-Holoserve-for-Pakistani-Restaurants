// Staff Dashboard - Limited access dashboard for staff members
// Provides restricted functionality compared to admin dashboard with profile access only
// Includes role-based access control and staff-specific features

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles
import '../auth_provider.dart'; // Authentication and user role management
import 'staff_profile_screen.dart'; // Staff profile viewing screen

import 'alert_admin_screen.dart'; // Alerts and notifications screen

// StatelessWidget for Staff Dashboard with limited access controls
class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  // Custom top bar with gradient background and notification access
  // Similar to admin but with staff-specific styling and limited functionality
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
                // Notification access button
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

  // Reusable widget for creating staff action cards with limited functionality
  // Similar to admin cards but with staff-specific styling and restricted access
  Widget staffActionCard(
    String title, // Card title (e.g., "Staff Profile")
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

  // Main build method - Creates the complete staff dashboard with limited access
  @override
  Widget build(BuildContext context) {
    // Consumer for AuthProvider to access current user data and role
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Consumer for ThemeProvider to access theme settings
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor(context), // Theme-based background
              extendBodyBehindAppBar: true, // Allow body to extend behind app bar
              appBar: customTopBar(context, "Staff Dashboard"), // Custom app bar
              body: Container(
                width: double.infinity, // Full width
                height: double.infinity, // Full height
                decoration: AppTheme.backgroundFilter(context), // Background decoration
                child: SingleChildScrollView( // Scrollable content
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20), // Padding with top space for app bar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header for staff panel
                        Text(
                          "Staff Panel",
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Welcome message showing current user info and role
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor(
                              context,
                            ).withValues(alpha: 0.1), // Light accent background
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Welcome ${authProvider.currentUser?.name ?? 'Staff'} (${authProvider.currentUser?.role ?? 'staff'})",
                            style: TextStyle(
                              color: AppTheme.accentColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Staff Profile Access Card - Only available functionality for staff
                        staffActionCard(
                          "Staff Profile", // Card title
                          Icons.person, // Person icon for profile
                          Colors.orangeAccent, // Orange accent color
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StaffProfileScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Limited Access Warning Section - Informs staff of restrictions
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1), // Light red background
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3), // Red border
                            ),
                          ),
                          child: Column(
                            children: [
                              // Lock icon indicating restricted access
                              const Icon(
                                Icons.lock,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              // Limited access title
                              const Text(
                                "Limited Access",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Explanation of staff restrictions
                              Text(
                                "Staff members have restricted access to system features",
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor(context),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        // App version footer
                        Center(
                          child: Text(
                            "HoloServe Staff v1.0",
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
