// LoginScreen - Main entry screen for user authentication
// Responsibilities:
//   1. Validates email (must end with @gmail.com) and password (min 6 chars)
//   2. First checks local hardcoded users list (works offline, faster)
//   3. Falls back to Firebase Firestore if not found locally
//   4. Saves logged-in user role to AuthProvider for session management
//   5. Navigates: Staff -> StaffPanel directly, Admin -> RoleScreen
//   6. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   7. AppTheme methods provide all colors and decorations for theme consistency
// Local Test Accounts:
//   Admin : admin@gmail.com / admin123
//   Staff : staff@gmail.com / staff123

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase database access
import 'role_screen.dart';           // Admin goes here after login
import 'staff_panel.dart';           // Staff goes here after login
import 'database_cleanup_screen.dart'; // First-time setup screen
import '../theme_provider.dart';     // Dark/light theme state
import '../app_theme.dart';          // Centralized theme colors and styles
import '../auth_provider.dart';      // User session and role management

// StatefulWidget needed for form validation state and loading indicator
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Text controllers for email and password input fields
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool _isLoading = false;   // Controls loading spinner on login button
  bool _obscurePass = true;  // Controls password visibility (eye icon toggle)
  String? emailError;        // Shown below email field if validation fails
  String? passError;         // Shown below password field if validation fails
  String? loginError;        // Shown if credentials are wrong

  @override
  void dispose() {
    // Always dispose controllers to free memory when screen is removed
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  // Hardcoded local users - allows login without Firebase connection
  // To add more users, append entries to this list
  final List<Map<String, String>> _localUsers = [
    {'email': 'admin@gmail.com', 'password': 'admin123', 'role': 'admin', 'name': 'Admin'},
    {'email': 'staff@gmail.com', 'password': 'staff123', 'role': 'staff', 'name': 'Staff Member'},
  ];

  // Main login function - validates inputs then authenticates user
  Future<void> validateAndLogin() async {
    // Run validation and update error messages in one setState call
    setState(() {
      loginError = null; // Clear previous login error
      final email = emailController.text.trim();
      emailError = !email.endsWith('@gmail.com') ? 'Email must end with @gmail.com' : null;
      passError = passController.text.length < 6 ? 'Password must be at least 6 characters' : null;
    });

    // Stop here if any validation failed
    if (emailError != null || passError != null) return;

    setState(() => _isLoading = true); // Show loading spinner on button
    try {
      final enteredEmail = emailController.text.trim();
      final enteredPass = passController.text;

      // Step 1: Check local hardcoded users first (faster, works offline)
      final localMatch = _localUsers.firstWhere(
        (u) => u['email'] == enteredEmail && u['password'] == enteredPass,
        orElse: () => {}, // Returns empty map if no match found
      );

      String role, name, email;

      if (localMatch.isNotEmpty) {
        // Local match found - use hardcoded credentials directly
        role = localMatch['role']!;
        name = localMatch['name']!;
        email = localMatch['email']!;
      } else {
        // Step 2: Fallback to Firebase Firestore if not found locally
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: enteredEmail)
            .where('password', isEqualTo: enteredPass)
            .get();

        if (query.docs.isEmpty) {
          // Not found in either local or Firebase - show error
          setState(() => loginError = 'Invalid email or password');
          return;
        }

        // Extract user data from the first matching Firebase document
        final userData = query.docs.first.data();
        role = userData['role'] ?? 'staff';
        name = userData['name'] ?? '';
        email = userData['email'] ?? '';
      }

      if (!mounted) return; // Widget may have been disposed during async call

      // Save logged-in user's role and info to AuthProvider for session management
      await Provider.of<AuthProvider>(context, listen: false)
          .loginWithRole(email, name, role);

      if (!mounted) return;

      // Navigate based on role: staff goes directly to panel, admin goes to role selector
      if (role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffPanel()),
        );
      } else {
        // Admin sees RoleScreen to choose between Admin and Staff panels
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleScreen(
              userEmail: email,
              userName: name,
              userRole: role,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => loginError = 'Error: $e'); // Show any unexpected errors
    } finally {
      if (mounted) setState(() => _isLoading = false); // Always hide loading spinner
    }
  }

  // Shows a dialog for password reset - UI only, no actual reset logic
  void showForgotPassDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.accentColor(context), width: 1),
        ),
        title: Text('Reset Password', style: TextStyle(color: AppTheme.accentColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your registered Gmail to receive a reset link.',
              style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 14),
            ),
            const SizedBox(height: 15),
            // Email input field for reset link
            TextField(
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
              decoration: InputDecoration(
                hintText: 'example@gmail.com',
                hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.mark_email_read, color: AppTheme.accentColor(context)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
              ),
            ),
          ],
        ),
        actions: [
          // Cancel - closes dialog without doing anything
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
          ),
          // Send Link - mock only, shows a snackbar confirmation
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor(context)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset link sent to your Gmail!')));
            },
            child: Text(
              'Send Link',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.black : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          body: Container(
            decoration: AppTheme.backgroundFilter(context), // Theme-based background image with overlay
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
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
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email input - validates @gmail.com format
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: AppTheme.primaryTextColor(context)),
                        decoration: InputDecoration(
                          hintText: 'yourname@gmail.com',
                          hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                          prefixIcon: Icon(Icons.email, color: AppTheme.accentColor(context)),
                          errorText: emailError, // Shows validation error below field
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentColor(context))),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password input - with eye icon to toggle visibility
                      TextField(
                        controller: passController,
                        obscureText: _obscurePass, // Hides/shows password text
                        style: TextStyle(color: AppTheme.primaryTextColor(context)),
                        decoration: InputDecoration(
                          hintText: '6+ digits password',
                          hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                          prefixIcon: Icon(Icons.lock, color: AppTheme.accentColor(context)),
                          // Eye icon toggles _obscurePass to show/hide password
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscurePass ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.secondaryTextColor(context)),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                          errorText: passError, // Shows validation error below field
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentColor(context))),
                        ),
                      ),

                      // Wrong credentials error - shown below password field
                      if (loginError != null) ...[
                        const SizedBox(height: 10),
                        Text(loginError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ],
                      const SizedBox(height: 25),

                      // Login button - disabled and shows spinner while loading
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : validateAndLogin, // Disabled during loading
                          child: _isLoading
                              ? SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: themeProvider.isDarkMode ? Colors.black : Colors.white))
                              : Text('Login',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode ? Colors.black : Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Forgot password link - opens reset dialog
                      TextButton(
                        onPressed: showForgotPassDialog,
                        child: Text('Forgot Password?',
                            style: TextStyle(
                                color: AppTheme.secondaryTextColor(context),
                                decoration: TextDecoration.underline)),
                      ),

                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 5),

                      // First-time setup button - navigates to DatabaseCleanupScreen
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DatabaseCleanupScreen()),
                        ),
                        icon: const Icon(Icons.settings_backup_restore, size: 16, color: Colors.grey),
                        label: const Text('Reset & Create New Admin',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
