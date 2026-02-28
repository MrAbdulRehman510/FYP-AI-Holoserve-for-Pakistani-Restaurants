import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget;
  final Widget? staffWidget;
  final Widget? fallbackWidget;

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
        if (authProvider.isAdmin && adminWidget != null) {
          return adminWidget!;
        } else if (authProvider.isStaff && staffWidget != null) {
          return staffWidget!;
        } else {
          return fallbackWidget ?? const SizedBox.shrink();
        }
      },
    );
  }
}

class AdminOnly extends StatelessWidget {
  final Widget child;

  const AdminOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isAdmin ? child : const SizedBox.shrink();
      },
    );
  }
}

class StaffOnly extends StatelessWidget {
  final Widget child;

  const StaffOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isStaff ? child : const SizedBox.shrink();
      },
    );
  }
}