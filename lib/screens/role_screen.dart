// RoleScreen - Role selection screen shown after successful login
// Responsibilities:
//   1. Shows Admin card and Staff card to admin users
//   2. Shows only Staff card to staff users
//   3. Navigates to AdminDashboard or StaffPanel based on selected card
//   4. Blocks staff from accessing admin panel with a snackbar error
//   5. Overrides back button to go to LoginScreen instead of going back
//   6. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   7. AppTheme methods provide all colors and decorations for theme consistency
// Note: userEmail, userName, userRole are passed from LoginScreen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard.dart'; // Destination when Admin card is tapped
import 'staff_panel.dart'; // Destination when Staff card is tapped
import '../theme_provider.dart'; // Dark/light theme state
import '../app_theme.dart'; // Centralized theme colors and styles
import '../auth_provider.dart'; // User session and role management
import 'login_screen.dart'; // Back button destination

// StatelessWidget - no local state needed, all data comes from constructor
class RoleScreen extends StatelessWidget {
  // User details passed from LoginScreen after successful authentication
  final String userEmail; // Logged-in user's email address
  final String userName; // Logged-in user's display name
  final String userRole; // Logged-in user's role: 'admin' or 'staff'

  const RoleScreen({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.userRole,
  });

  // Builds a role selection card (Admin or Staff)
  // isAllowed controls whether the card is interactive or locked
  // Admin users: both cards allowed | Staff users: only staff card allowed
  Widget roleCard(
    BuildContext context,
    String title,
    IconData icon,
    String role,
  ) {
    // Admin can tap both cards; staff can only tap the staff card
    final isAllowed = userRole.toLowerCase() == 'admin'
        ? true
        : userRole.toLowerCase() == role.toLowerCase();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () async {
            // Block access if this role is not allowed for the current user
            if (!isAllowed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Access denied. Staff cannot access Admin panel.',
                  ),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            // Save the selected role to AuthProvider for session-wide access control
            await Provider.of<AuthProvider>(
              context,
              listen: false,
            ).loginWithRole(userEmail, userName, role.toLowerCase());

            if (!context.mounted) return; // Safety check after async call

            // Navigate to the correct panel based on selected role
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => role.toLowerCase() == 'admin'
                    ? const AdminDashboard() // Admin goes to admin control panel
                    : const StaffPanel(), // Staff goes to staff control panel
              ),
            );
          },
          // AnimatedContainer provides a subtle press animation (200ms)
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              // Allowed cards have a bright colored border; locked cards have a dim border
              border: Border.all(
                color: isAllowed
                    ? AppTheme.accentColor(context).withValues(alpha: 0.6)
                    : AppTheme.secondaryTextColor(
                        context,
                      ).withValues(alpha: 0.2),
                width: isAllowed ? 2 : 1,
              ),
              // Allowed cards have a soft glow shadow; locked cards have no shadow
              boxShadow: isAllowed
                  ? [
                      BoxShadow(
                        color: AppTheme.accentColor(
                          context,
                        ).withValues(alpha: 0.2),
                        blurRadius: 15,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                // Role icon - colored for allowed, dimmed for locked
                Icon(
                  icon,
                  size: 50,
                  color: isAllowed
                      ? AppTheme.accentColor(context)
                      : AppTheme.secondaryTextColor(
                          context,
                        ).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 15),

                // Role title text - colored for allowed, dimmed for locked
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isAllowed
                        ? AppTheme.primaryTextColor(context)
                        : AppTheme.secondaryTextColor(
                            context,
                          ).withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 8),

                // Access badge - shows "Your Role" for allowed, "No Access" for locked
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAllowed
                        ? AppTheme.accentColor(context).withValues(alpha: 0.1)
                        : Colors.redAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAllowed ? 'Your Role' : 'No Access',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAllowed
                          ? AppTheme.accentColor(context)
                          : Colors.redAccent.withValues(alpha: 0.5),
                    ),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopScope(
          canPop:
              false, // Disable default back button to prevent going back to login state
          // Custom back handler - always goes to LoginScreen instead of popping
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppTheme.backgroundColor(context),
            extendBodyBehindAppBar: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: AppTheme.backgroundFilter(
                context,
              ), // Theme-based background
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // App logo - switches between dark and light version
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
                    const SizedBox(height: 24),

                    // Welcome heading
                    Text(
                      'Welcome to HoloServe',
                      style: TextStyle(
                        color: AppTheme.accentColor(context),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Shows the logged-in user's name
                    Text(
                      'Logged in as: $userName',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Role badge - capitalizes first letter of role for display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor(
                          context,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Role: ${userRole[0].toUpperCase()}${userRole.substring(1)}',
                        style: TextStyle(
                          color: AppTheme.accentColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role selection cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Admin card - only shown to admin users
                          if (userRole.toLowerCase() == 'admin')
                            roleCard(
                              context,
                              'Admin',
                              Icons.admin_panel_settings,
                              'admin',
                            ),
                          if (userRole.toLowerCase() == 'admin')
                            const SizedBox(height: 20),

                          // Staff card - shown to all users
                          roleCard(context, 'Staff', Icons.person, 'staff'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
