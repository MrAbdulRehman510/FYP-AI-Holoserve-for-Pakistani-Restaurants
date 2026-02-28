// Admin Profile Screen - Displays admin user information and profile management options
// This screen shows admin details, system access info, and provides edit/settings functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../auth_provider.dart';
import 'system_settings_screen.dart';

// StatelessWidget for Admin Profile Screen
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  // Custom top bar with gradient background and admin icon
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
                const Spacer(), // Push icon to right
                // Admin panel icon
                Icon(
                  Icons.admin_panel_settings,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for displaying profile information cards
  // Creates styled cards with icon, title, and value for profile data
  Widget profileInfoCard(
    String title, // Field name (e.g., "Full Name")
    String value, // Field value (e.g., "Muhammad Ahmed Khan")
    IconData icon, // Icon to display in circle avatar
    BuildContext context, // Context for theme access
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Space between cards
      padding: const EdgeInsets.all(20), // Internal padding
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context), // Theme-based card color
        borderRadius: BorderRadius.circular(15), // Rounded corners
        border: Border.all(
          color: AppTheme.accentColor(context).withValues(alpha: 0.2), // Subtle border
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor(context).withValues(alpha: 0.1), // Soft shadow
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle avatar
          CircleAvatar(
            backgroundColor: AppTheme.accentColor(
              context,
            ).withValues(alpha: 0.2), // Light background for icon
            child: Icon(icon, color: AppTheme.accentColor(context)), // Themed icon
          ),
          const SizedBox(width: 20), // Space between icon and text
          // Text content column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field title (smaller, secondary color)
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                // Field value (larger, primary color)
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main build method - Creates the complete admin profile screen
  @override
  Widget build(BuildContext context) {
    // Consumer for AuthProvider to access current user data
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Consumer for ThemeProvider to access theme settings
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor(context), // Theme-based background
              extendBodyBehindAppBar: true, // Allow body to extend behind app bar
              appBar: customTopBar(context, "Admin Profile"), // Custom app bar
              body: Container(
                width: double.infinity, // Full width
                height: double.infinity, // Full height
                decoration: AppTheme.backgroundFilter(context), // Background decoration
                child: SingleChildScrollView( // Scrollable content
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 20), // Padding with top space for app bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Section - Admin avatar, name, and role badge
                      Center(
                        child: Column(
                          children: [
                            // Admin avatar with admin panel icon
                            CircleAvatar(
                              radius: 50, // Large avatar
                              backgroundColor: AppTheme.accentColor(context), // Theme color background
                              child: const Icon(
                                Icons.admin_panel_settings, // Admin icon
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Admin name from auth provider or default
                            Text(
                              authProvider.currentUser?.name ?? 'Admin User',
                              style: TextStyle(
                                color: AppTheme.primaryTextColor(context),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Admin role badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2), // Light green background
                                borderRadius: BorderRadius.circular(20), // Rounded badge
                                border: Border.all(color: Colors.green), // Green border
                              ),
                              child: const Text(
                                'ADMIN', // Role text
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Personal Information',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      profileInfoCard(
                        'Full Name',
                        'Muhammad Ahmed Khan',
                        Icons.person,
                        context,
                      ),
                      profileInfoCard(
                        'Email Address',
                        'admin@holoserve.com',
                        Icons.email,
                        context,
                      ),
                      profileInfoCard(
                        'Phone Number',
                        '+92 300 1234567',
                        Icons.phone,
                        context,
                      ),
                      profileInfoCard(
                        'Employee ID',
                        'ADM-001',
                        Icons.badge,
                        context,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'System Access',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      profileInfoCard(
                        'Role',
                        'System Administrator',
                        Icons.admin_panel_settings,
                        context,
                      ),
                      profileInfoCard(
                        'Department',
                        'IT Management',
                        Icons.business,
                        context,
                      ),
                      profileInfoCard(
                        'Join Date',
                        '15 Jan 2024',
                        Icons.calendar_today,
                        context,
                      ),
                      profileInfoCard(
                        'Last Login',
                        'Today, 09:30 AM',
                        Icons.access_time,
                        context,
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppTheme.cardColor(
                                      context,
                                    ),
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Edit Admin Profile',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Admin profile editing options:',
                                          style: TextStyle(
                                            color: AppTheme.secondaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          '✏️ Update personal information',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '🔐 Change password',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '📱 Update contact details',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        const Text(
                                          'Full editing functionality coming soon!',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            color: AppTheme.accentColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentColor(context),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SystemSettingsScreen(),
                                ),
                              ),
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Settings',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
