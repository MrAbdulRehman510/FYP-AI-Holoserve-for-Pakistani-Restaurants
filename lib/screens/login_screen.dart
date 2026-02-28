// Login Screen - User authentication interface with Gmail validation
// Provides secure login functionality with email validation, password verification, and forgot password feature
// Includes form validation and navigation to role selection screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'role_screen.dart'; // Role selection screen after login
import 'signup_screen.dart'; // Account creation screen
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles

// StatefulWidget for Login Screen with form validation and authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State class for Login Screen with form controllers and validation logic
class _LoginScreenState extends State<LoginScreen> {
  // Text editing controllers for form inputs
  final TextEditingController emailController =
      TextEditingController(); // Email input controller
  final TextEditingController passController =
      TextEditingController(); // Password input controller

  // Error message variables for form validation
  String? emailError; // Email validation error message
  String? passError; // Password validation error message

  // Email and password validation method with Gmail requirement
  // Validates email format (must end with @gmail.com) and password length (minimum 6 characters)
  void validateAndLogin() {
    setState(() {
      String email = emailController.text.trim(); // Get trimmed email input

      // Gmail validation - email must end with @gmail.com
      if (!email.endsWith('@gmail.com') || email.length <= 10) {
        emailError = "Email must end with @gmail.com";
      } else {
        emailError = null; // Clear error if validation passes
      }

      // Password length validation - minimum 6 characters required
      if (passController.text.length < 6) {
        passError = "Password must be at least 6 characters";
      } else {
        passError = null; // Clear error if validation passes
      }
    });

    // Navigate to role selection if all validations pass
    if (emailError == null && passError == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoleScreen(userEmail: emailController.text.trim()),
        ),
      );
    }
  }

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
        title: Text(
          "Reset Password",
          style: TextStyle(color: AppTheme.accentColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter your registered Gmail to receive a reset link.",
              style: TextStyle(
                color: AppTheme.secondaryTextColor(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
              decoration: InputDecoration(
                hintText: "example@gmail.com",
                hintStyle: TextStyle(
                  color: AppTheme.secondaryTextColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.mark_email_read,
                  color: AppTheme.accentColor(context),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.secondaryTextColor(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppTheme.secondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor(context),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reset link sent to your Gmail!")),
              );
            },
            child: Text(
              "Send Link",
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main build method - Creates the complete login screen interface
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(
            context,
          ), // Theme-based background
          body: Container(
            decoration: AppTheme.backgroundFilter(context),
            child: Center(
              child: SingleChildScrollView(
                // Scrollable content for keyboard
                child: Padding(
                  padding: const EdgeInsets.all(24), // Screen padding
                  child: Column(
                    children: [
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
                              ? "assets/images/logo_dark.png"
                              : "assets/images/logo_light.png",
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Input Field with Gmail validation
                      TextField(
                        controller: emailController, // Email controller
                        style: TextStyle(
                          color: AppTheme.primaryTextColor(context),
                        ),
                        keyboardType:
                            TextInputType.emailAddress, // Email keyboard type
                        decoration: InputDecoration(
                          hintText: "yourname@gmail.com", // Placeholder text
                          hintStyle: TextStyle(
                            color: AppTheme.secondaryTextColor(
                              context,
                            ).withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.email, // Email icon
                            color: AppTheme.accentColor(context),
                          ),
                          errorText: emailError, // Show validation error
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.secondaryTextColor(
                                context,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.accentColor(context),
                            ), // Accent color when focused
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password Input Field with length validation
                      TextField(
                        controller: passController, // Password controller
                        obscureText: true, // Hide password text
                        style: TextStyle(
                          color: AppTheme.primaryTextColor(context),
                        ),
                        decoration: InputDecoration(
                          hintText: "6+ digits password", // Placeholder text
                          hintStyle: TextStyle(
                            color: AppTheme.secondaryTextColor(
                              context,
                            ).withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.lock, // Lock icon
                            color: AppTheme.accentColor(context),
                          ),
                          errorText: passError, // Show validation error
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.secondaryTextColor(
                                context,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.accentColor(context),
                            ), // Accent color when focused
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Login Button - Full width with theme styling
                      SizedBox(
                        width: double.infinity, // Full width button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor(
                              context,
                            ), // Theme accent color
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ), // Vertical padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // Rounded corners
                            ),
                          ),
                          onPressed: validateAndLogin, // Call validation method
                          child: Text(
                            "Login", // Button text
                            style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.isDarkMode
                                  ? Colors.black
                                  : Colors.white, // Dynamic text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Forgot Password Button
                      TextButton(
                        onPressed:
                            showForgotPassDialog, // Show forgot password dialog
                        child: Text(
                          "Forgot Password?", // Button text
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor(context),
                            decoration:
                                TextDecoration.underline, // Underlined text
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sign Up Navigation Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ", // Prompt text
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(context),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to signup screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up", // Navigation text
                              style: TextStyle(
                                color: AppTheme.accentColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
