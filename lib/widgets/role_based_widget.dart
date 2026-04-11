// Role Based Widget - Reusable widgets for role-based UI rendering
// Shows different content based on whether user is Admin or Staff
// Uses AuthProvider to check current user role
// Three widget types:
//   1. RoleBasedWidget - shows different widget for admin vs staff
//   2. AdminOnly - shows content only to admin users
//   3. StaffOnly - shows content only to staff users

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart'; // Authentication provider for role checking

// RoleBasedWidget - Renders different widget based on user role
// adminWidget: shown to admin users
// staffWidget: shown to staff users
// fallbackWidget: shown if neither condition matches (optional)
class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget; // Widget to show for admin role
  final Widget? staffWidget; // Widget to show for staff role
  final Widget? fallbackWidget; // Widget to show if no role matches

  const RoleBasedWidget({
    super.key,
    this.adminWidget,
    this.staffWidget,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show admin widget if user is admin
        if (authProvider.isAdmin && adminWidget != null) {
          return adminWidget!;
        }
        // Show staff widget if user is staff
        else if (authProvider.isStaff && staffWidget != null) {
          return staffWidget!;
        }
        // Show fallback or empty box if no match
        else {
          return fallbackWidget ?? const SizedBox.shrink();
        }
      },
    );
  }
}

// AdminOnly - Wraps any widget to make it visible only to admin users
// Used in Admin Dashboard to hide advanced controls from staff
// Returns empty SizedBox if user is not admin
class AdminOnly extends StatelessWidget {
  final Widget child; // Widget to show only to admin

  const AdminOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show child only if user is admin, otherwise show nothing
        return authProvider.isAdmin ? child : const SizedBox.shrink();
      },
    );
  }
}

// StaffOnly - Wraps any widget to make it visible only to staff users
// Returns empty SizedBox if user is not staff
class StaffOnly extends StatelessWidget {
  final Widget child; // Widget to show only to staff

  const StaffOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show child only if user is staff, otherwise show nothing
        return authProvider.isStaff ? child : const SizedBox.shrink();
      },
    );
  }
}
