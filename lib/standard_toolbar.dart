// StandardToolbar - Reusable App Bar widget used across multiple screens
// Provides consistent top bar styling with gradient background
// Includes back button, screen title, and optional action icon
// Used in: Analytics Screen, Menu Management Screen, and other screens
// Reduces code duplication by centralizing app bar logic

import 'package:flutter/material.dart';
import 'app_theme.dart'; // App-wide theme constants and styles

// Static utility class - no instantiation needed, call build() directly
class StandardToolbar {

  // Build method - creates a styled PreferredSizeWidget (AppBar)
  // Parameters:
  //   context: BuildContext for theme access
  //   title: Screen title text shown in the toolbar
  //   actionIcon: Optional icon shown on the right side (e.g. settings icon)
  //   onActionPressed: Optional callback when action icon is tapped
  static PreferredSizeWidget build(
    BuildContext context,
    String title, {
    IconData? actionIcon, // Optional right-side icon
    VoidCallback? onActionPressed, // Optional callback for right-side icon
  }) {
    return AppBar(
      automaticallyImplyLeading: false, // Disable default back button
      toolbarHeight: 90, // Taller than default for better appearance
      backgroundColor: Colors.transparent, // Transparent to show gradient
      elevation: 0, // No shadow
      flexibleSpace: Container(
        // Gradient background container
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context), // Theme-based gradient
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24), // Rounded bottom-left corner
            bottomRight: Radius.circular(24), // Rounded bottom-right corner
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Back button - navigates to previous screen
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context), // Theme text color
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context), // Go back
                ),
                const SizedBox(width: 12),
                // Screen title text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context), // Theme text color
                  ),
                ),
                const Spacer(), // Push action icon to the right
                // Optional action icon on the right side
                if (actionIcon != null)
                  IconButton(
                    icon: Icon(
                      actionIcon,
                      color: AppTheme.accentColor(context), // Accent color icon
                    ),
                    onPressed: onActionPressed ?? () {}, // Use callback or empty function
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
