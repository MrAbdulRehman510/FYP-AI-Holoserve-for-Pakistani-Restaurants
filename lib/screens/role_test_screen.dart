// Role Test Screen - Testing interface for role-based access control system
// Demonstrates role-based widget visibility and user authentication testing
// Provides buttons to test different user roles and their permissions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../widgets/role_based_widget.dart';
import '../app_theme.dart';

// StatelessWidget for testing role-based functionality
class RoleTestScreen extends StatelessWidget {
  const RoleTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Role Testing Screen'),
        backgroundColor: AppTheme.accentColor(context),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current user information display card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current User Details:',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // User authentication status information
                      Text('Name: ${authProvider.currentUser?.name ?? 'Not logged in'}'),
                      Text('Email: ${authProvider.currentUser?.email ?? 'N/A'}'),
                      Text('Role: ${authProvider.currentUser?.role ?? 'N/A'}'),
                      Text('Is Admin: ${authProvider.isAdmin}'),
                      Text('Is Staff: ${authProvider.isStaff}'),
                      Text('Is Logged In: ${authProvider.isLoggedIn}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Role-based visibility testing section header
                Text(
                  'Role-Based Visibility Tests:',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Admin-only content visibility test
                AdminOnly(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.green, size: 40),
                        SizedBox(height: 10),
                        Text(
                          '🔒 ADMIN ONLY CONTENT',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('This is only visible to Admin users'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Staff-only content visibility test
                StaffOnly(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.people, color: Colors.blue, size: 40),
                        SizedBox(height: 10),
                        Text(
                          '👥 STAFF ONLY CONTENT',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('This is only visible to Staff users'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Role-based widget demonstration with different content per role
                RoleBasedWidget(
                  adminWidget: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: const Text(
                      '👑 Admin sees this content',
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  staffWidget: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      '⚡ Staff sees this content',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Role testing buttons section header
                Text(
                  'Test Different Roles:',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Role switching buttons for testing authentication
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.login('admin@test.com', 'password');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Login as Admin', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await authProvider.login('staff@test.com', 'password');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Login as Staff', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Logout button for testing session management
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authProvider.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Logout', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}