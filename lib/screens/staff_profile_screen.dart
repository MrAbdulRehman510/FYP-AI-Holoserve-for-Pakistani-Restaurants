// Staff Profile Screen - Displays staff user information with limited access
// Shows staff personal/work details and provides restricted profile management options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../auth_provider.dart';

// StatelessWidget for Staff Profile Screen with restricted access
class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  // Custom top bar with gradient background and person icon
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
                // Person icon for staff
                Icon(Icons.person, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileInfoCard(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.accentColor(context).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor(context).withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentColor(
              context,
            ).withValues(alpha: 0.2),
            child: Icon(icon, color: AppTheme.accentColor(context)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor(context),
              extendBodyBehindAppBar: true,
              appBar: customTopBar(context, "Staff Profile"),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: AppTheme.backgroundFilter(context),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            // ignore: prefer_const_constructors
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              authProvider.currentUser?.name ?? 'Staff User',
                              style: TextStyle(
                                color: AppTheme.primaryTextColor(context),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: const Text(
                                'STAFF',
                                style: TextStyle(
                                  color: Colors.blue,
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
                        'Ali Hassan',
                        Icons.person,
                        context,
                      ),
                      profileInfoCard(
                        'Email Address',
                        'ali.hassan@holoserve.com',
                        Icons.email,
                        context,
                      ),
                      profileInfoCard(
                        'Phone Number',
                        '+92 301 9876543',
                        Icons.phone,
                        context,
                      ),
                      profileInfoCard(
                        'Employee ID',
                        'STF-005',
                        Icons.badge,
                        context,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Work Information',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      profileInfoCard(
                        'Role',
                        'Restaurant Staff',
                        Icons.restaurant,
                        context,
                      ),
                      profileInfoCard(
                        'Department',
                        'Food Service',
                        Icons.fastfood,
                        context,
                      ),
                      profileInfoCard(
                        'Shift',
                        'Morning (8 AM - 4 PM)',
                        Icons.schedule,
                        context,
                      ),
                      profileInfoCard(
                        'Join Date',
                        '20 Feb 2024',
                        Icons.calendar_today,
                        context,
                      ),
                      profileInfoCard(
                        'Last Login',
                        'Today, 08:15 AM',
                        Icons.access_time,
                        context,
                      ),

                      const SizedBox(height: 20),

                      // Limited Access Notice
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info,
                              color: Colors.orange,
                              size: 30,
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Limited Access Account',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Staff members have restricted access to system features',
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
                                    title: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: AppTheme.primaryTextColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                    content: Text(
                                      'Profile editing is restricted for staff members. Please contact your administrator for any changes.',
                                      style: TextStyle(
                                        color: AppTheme.secondaryTextColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'OK',
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
                                backgroundColor: Colors.blue,
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
                                          Icons.help,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Staff Help Center',
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
                                          'Need assistance? Here are your options:',
                                          style: TextStyle(
                                            color: AppTheme.secondaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          '📞 Call Admin: +92 300 1234567',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '📧 Email: admin@holoserve.com',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '🕐 Support Hours: 8 AM - 10 PM',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor(
                                              context,
                                            ),
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
                              icon: const Icon(Icons.help, color: Colors.white),
                              label: const Text(
                                'Help',
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
