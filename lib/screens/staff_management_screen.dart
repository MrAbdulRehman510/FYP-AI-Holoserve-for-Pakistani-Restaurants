// Staff Management Screen - Admin interface for managing staff members
// Provides functionality to add new staff, view staff list, and manage staff profiles
// Includes dynamic staff list with add/remove capabilities and profile navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles
import 'staff_profile_screen.dart'; // Staff profile viewing screen

// StatefulWidget for Staff Management with dynamic staff list
class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

// State class for Staff Management with staff list and operations
class _StaffManagementScreenState extends State<StaffManagementScreen> {
  // Mock data for staff members with name, role, and status
  // In a real app, this would come from a database or API
  List<Map<String, String>> staffList = [
    {"name": "Ali Ahmed", "role": "Manager", "status": "Active"},
    {"name": "Sara Khan", "role": "Chef", "status": "On Leave"},
    {"name": "Zain Malik", "role": "Waiter", "status": "Active"},
  ];

  // Method to add new staff member with dialog form
  // Shows dialog with name input and role selection dropdown
  void addStaffMember() {
    TextEditingController nameCtrl = TextEditingController(); // Name input controller
    String selectedRole = 'Waiter'; // Default role selection

    showDialog(
      context: context, // Current context for dialog
      builder: (context) => StatefulBuilder(
        // StatefulBuilder for dynamic dropdown updates within dialog
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor(context), // Theme-based dialog background
          title: Text(
            "Add Staff Member",
            style: TextStyle(color: AppTheme.accentColor(context)), // Accent color title
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Minimum height for content
            children: [
              // Name input field
              TextField(
                controller: nameCtrl, // Text controller for name
                style: TextStyle(color: AppTheme.primaryTextColor(context)),
                decoration: InputDecoration(
                  hintText: "Full Name", // Placeholder text
                  hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                ),
              ),
              const SizedBox(height: 20),
              // Role selection dropdown
              DropdownButton<String>(
                value: selectedRole, // Current selected role
                dropdownColor: AppTheme.cardColor(context), // Theme-based dropdown color
                isExpanded: true, // Full width dropdown
                style: TextStyle(color: AppTheme.primaryTextColor(context)),
                items: ['Manager', 'Chef', 'Waiter', 'Cleaner'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Role option text
                  );
                }).toList(),
                onChanged: (newValue) {
                  setDialogState(() {
                    selectedRole = newValue!; // Update selected role
                  });
                },
              ),
            ],
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text(
                "Cancel",
                style: TextStyle(color: AppTheme.secondaryTextColor(context)),
              ),
            ),
            // Add button
            TextButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) { // Validate name input
                  setState(() {
                    // Add new staff member to list
                    staffList.add({
                      "name": nameCtrl.text,
                      "role": selectedRole,
                      "status": "Active", // Default status for new staff
                    });
                  });
                  Navigator.pop(context); // Close dialog after adding
                }
              },
              child: Text(
                "Add",
                style: TextStyle(color: AppTheme.accentColor(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom top bar with gradient background and person add icon
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
                  icon: Icon(Icons.arrow_back, color: AppTheme.primaryTextColor(context)),
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
                // Person add icon
                Icon(Icons.person_add_alt_1, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method - Creates the complete staff management interface
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true, // Allow body to extend behind app bar
        appBar: customTopBar(context, "Staff Management"), // Custom app bar
        body: Container(
          decoration: AppTheme.backgroundFilter(context), // Background decoration
          child: Column(
            children: [
              const SizedBox(height: 110), // Space for app bar
              // Add New Staff Button - Full width button at top
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor(context), // Theme accent color
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    minimumSize: const Size(double.infinity, 50), // Full width, fixed height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  onPressed: addStaffMember, // Call add staff method
                  icon: const Icon(Icons.add), // Add icon
                  label: const Text(
                    "Hire New Staff", // Button text
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Staff List - Scrollable list of staff members
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Horizontal padding
                  itemCount: staffList.length, // Number of staff members
                  itemBuilder: (context, index) {
                    final staff = staffList[index]; // Current staff member data
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15), // Space between cards
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context), // Theme-based card color
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                        border: Border.all(
                          color: AppTheme.accentColor(context).withValues(alpha: 0.2), // Subtle border
                        ),
                      ),
                      child: ListTile(
                        // Staff avatar with person icon
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accentColor(context).withValues(alpha: 0.1), // Light background
                          child: Icon(
                            Icons.person,
                            color: AppTheme.accentColor(context), // Accent color icon
                          ),
                        ),
                        // Staff name as title
                        title: Text(
                          staff['name']!, // Staff member name
                          style: TextStyle(
                            color: AppTheme.primaryTextColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Staff role and status as subtitle
                        subtitle: Text(
                          "${staff['role']} • ${staff['status']}", // Role and status with bullet separator
                          style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                        ),
                        // Action buttons (profile view and delete)
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Minimum width for trailing
                          children: [
                            // Profile view button
                            IconButton(
                              icon: Icon(
                                Icons.person,
                                color: AppTheme.accentColor(context),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StaffProfileScreen(), // Navigate to staff profile
                                ),
                              ),
                            ),
                            // Delete staff button
                            IconButton(
                              icon: const Icon(
                                Icons.delete_sweep,
                                color: Colors.redAccent, // Red color for delete action
                              ),
                              onPressed: () {
                                setState(() {
                                  staffList.removeAt(index); // Remove staff from list
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}