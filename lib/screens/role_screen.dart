// Role Screen - User role selection interface after login
// Provides admin and staff role selection with authentication integration
// Sets user role in AuthProvider and navigates to appropriate dashboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard.dart'; // Admin dashboard for admin users
import 'staff_panel.dart'; // Staff panel for staff users
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles
import '../auth_provider.dart'; // Authentication and user role management

// StatelessWidget for Role Selection Screen with authentication integration
class RoleScreen extends StatelessWidget {
  final String userEmail; // User's actual email from login
  const RoleScreen({super.key, required this.userEmail});

  // Reusable widget for creating role selection cards
  // Each card represents a different user role (Admin/Staff) with navigation
  Widget roleCard(BuildContext context, String title, IconData icon) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            // Set user role and navigate to appropriate dashboard
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false, // Don't listen to changes during this operation
            );
            
            // Role-based authentication and navigation
            if (title == "Admin") {
              // Login as admin user and navigate to admin dashboard
              authProvider.login(userEmail, 'password');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            } else {
              // Login as staff user and navigate to staff panel
              authProvider.login(userEmail, 'password');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffPanel()),
              );
            }
          },
          child: Container(
            width: double.infinity, // Full width card
            padding: const EdgeInsets.all(24), // Internal padding
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context), // Theme-based card color
              borderRadius: BorderRadius.circular(20), // Rounded corners
              border: Border.all(
                color: AppTheme.accentColor(context).withValues(alpha: 0.4), // Accent border
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor(context).withValues(alpha: 0.2), // Soft shadow
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              children: [
                // Role icon
                Icon(icon, size: 50, color: AppTheme.accentColor(context)),
                const SizedBox(height: 15),
                // Role title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Main build method - Creates the complete role selection interface
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context), // Theme-based background
          extendBodyBehindAppBar: true, // Allow body to extend behind app bar
          body: Container(
            width: double.infinity, // Full width
            height: double.infinity, // Full height
            decoration: AppTheme.backgroundFilter(context), // Background decoration
            child: SingleChildScrollView( // Scrollable content
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // App logo with theme-based image
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? Colors.black.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      themeProvider.isDarkMode
                          ? 'assets/images/logo_dark.png'
                          : 'assets/images/logo_light.png',
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Role selection cards container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24), // Horizontal padding
                    child: Column(
                      children: [
                        // Admin role card with admin panel settings icon
                        roleCard(context, "Admin", Icons.admin_panel_settings),
                        const SizedBox(height: 20), // Space between cards
                        // Staff role card with person icon
                        roleCard(context, "Staff", Icons.person),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
