// Add New Admin Screen - User account creation form for admin and staff roles
// Provides form validation, role selection, and user registration functionality
// Includes comprehensive input validation and success feedback

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles

// StatefulWidget for Add New Admin form with validation and role selection
class AddNewAdminScreen extends StatefulWidget {
  const AddNewAdminScreen({super.key});

  @override
  State<AddNewAdminScreen> createState() => _AddNewAdminScreenState();
}

// State class for Add New Admin form with form controllers and validation
class _AddNewAdminScreenState extends State<AddNewAdminScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers for form inputs
  final _nameController = TextEditingController(); // Full name input
  final _emailController = TextEditingController(); // Email address input
  final _passwordController = TextEditingController(); // Password input
  
  // Form state variables
  String _selectedRole = 'admin'; // Default role selection (admin/staff)
  bool _isLoading = false; // Loading state for form submission

  // Dispose method to clean up text controllers and prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose(); // Clean up name controller
    _emailController.dispose(); // Clean up email controller
    _passwordController.dispose(); // Clean up password controller
    super.dispose();
  }

  // Form submission method with validation and simulated API call
  // Validates form inputs, shows loading state, and provides success feedback
  Future<void> _addNewAdmin() async {
    if (_formKey.currentState!.validate()) { // Validate all form fields
      setState(() => _isLoading = true); // Show loading state
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isLoading = false); // Hide loading state
      
      // Show success message if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedRole.toUpperCase()} ${_nameController.text} added successfully!'),
            backgroundColor: Colors.green, // Success color
          ),
        );
        
        // Clear form after successful submission
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() => _selectedRole = 'admin'); // Reset to default role
      }
    }
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
                // Person add icon
                Icon(Icons.person_add, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method - Creates the complete add new admin form
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context), // Theme-based background
          extendBodyBehindAppBar: true, // Allow body to extend behind app bar
          appBar: customTopBar(context, "Add New Admin"), // Custom app bar
          body: Container(
            width: double.infinity, // Full width
            height: double.infinity, // Full height
            decoration: AppTheme.backgroundFilter(context), // Background decoration
            child: SingleChildScrollView( // Scrollable content
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 20), // Padding with top space for app bar
              child: Form(
                key: _formKey, // Form key for validation
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form header title
                    Text(
                      'Create New User Account',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Full Name Input Field with validation
                    TextFormField(
                      controller: _nameController, // Name controller
                      style: TextStyle(color: AppTheme.primaryTextColor(context)),
                      decoration: InputDecoration(
                        labelText: 'Full Name', // Field label
                        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                        prefixIcon: Icon(Icons.person, color: AppTheme.accentColor(context)), // Person icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context).withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name'; // Required field validation
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email Address Input Field with validation
                    TextFormField(
                      controller: _emailController, // Email controller
                      style: TextStyle(color: AppTheme.primaryTextColor(context)),
                      keyboardType: TextInputType.emailAddress, // Email keyboard type
                      decoration: InputDecoration(
                        labelText: 'Email Address', // Field label
                        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                        prefixIcon: Icon(Icons.email, color: AppTheme.accentColor(context)), // Email icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context).withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address'; // Required field validation
                        }
                        if (!value.contains('@')) {
                          return 'Please enter valid email'; // Email format validation
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Input Field with validation
                    TextFormField(
                      controller: _passwordController, // Password controller
                      style: TextStyle(color: AppTheme.primaryTextColor(context)),
                      obscureText: true, // Hide password text
                      decoration: InputDecoration(
                        labelText: 'Password', // Field label
                        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                        prefixIcon: Icon(Icons.lock, color: AppTheme.accentColor(context)), // Lock icon
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context).withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.accentColor(context), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password'; // Required field validation
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters'; // Minimum length validation
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Role Selection Section
                    Text(
                      'Select Role:',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Role Dropdown with admin/staff options
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRole, // Current selected role
                        isExpanded: true, // Full width dropdown
                        underline: const SizedBox(), // Remove default underline
                        dropdownColor: AppTheme.cardColor(context), // Theme-based dropdown color
                        style: TextStyle(color: AppTheme.primaryTextColor(context)),
                        items: const [
                          // Admin role option
                          DropdownMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.green), // Admin icon
                                SizedBox(width: 10),
                                Text('Admin (Full Access)'), // Admin description
                              ],
                            ),
                          ),
                          // Staff role option
                          DropdownMenuItem(
                            value: 'staff',
                            child: Row(
                              children: [
                                Icon(Icons.people, color: Colors.blue), // Staff icon
                                SizedBox(width: 10),
                                Text('Staff (Limited Access)'), // Staff description
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value!); // Update selected role
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Submit Button with loading state
                    SizedBox(
                      width: double.infinity, // Full width button
                      height: 50, // Fixed height
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addNewAdmin, // Disable when loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor(context), // Theme color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white) // Loading indicator
                            : Text(
                                'Add ${_selectedRole.toUpperCase()}', // Dynamic button text
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Role Permissions Information Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor(context).withValues(alpha: 0.1), // Light accent background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.3)), // Accent border
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Information header
                          Text(
                            'Role Permissions:',
                            style: TextStyle(
                              color: AppTheme.primaryTextColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Role descriptions
                          Text(
                            '• Admin: Full system access, can manage all features\n• Staff: Limited access, can only view assigned data',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
  }
}