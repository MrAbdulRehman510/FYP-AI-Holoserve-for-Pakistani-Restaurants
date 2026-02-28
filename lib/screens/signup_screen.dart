// Signup Screen - User registration interface with comprehensive validation
// Provides account creation functionality with form validation, password confirmation, and Gmail requirement
// Includes success feedback and navigation to login screen after registration

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart'; // Login screen for navigation after signup
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles

// StatefulWidget for Signup Screen with form validation and registration
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// State class for Signup Screen with form controllers and comprehensive validation
class _SignupScreenState extends State<SignupScreen> {
  // Text editing controllers for all form inputs
  final TextEditingController nameController = TextEditingController(); // Full name input
  final TextEditingController emailController = TextEditingController(); // Email input
  final TextEditingController passController = TextEditingController(); // Password input
  final TextEditingController confirmPassController = TextEditingController(); // Password confirmation

  // Error message variables for form validation
  String? nameError; // Name validation error
  String? emailError; // Email validation error
  String? passError; // Password validation error
  String? confirmPassError; // Password confirmation error

  // Comprehensive form validation method with multiple field checks
  // Validates name, email format, password strength, and password confirmation
  void validateAndSignup() {
    setState(() {
      // Get trimmed input values
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passController.text;
      String confirmPassword = confirmPassController.text;

      // Name validation - required field check
      nameError = name.isEmpty ? "Name is required" : null;
      
      // Email validation - must end with @gmail.com
      if (!email.endsWith('@gmail.com')) {
        emailError = "Email must end with @gmail.com";
      } else {
        emailError = null; // Clear error if validation passes
      }

      // Password strength validation - minimum 6 characters
      if (password.length < 6) {
        passError = "Password must be at least 6 characters";
      } else {
        passError = null; // Clear error if validation passes
      }

      // Password confirmation validation - must match original password
      if (password != confirmPassword) {
        confirmPassError = "Passwords do not match";
      } else {
        confirmPassError = null; // Clear error if passwords match
      }
    });

    // Proceed with registration if all validations pass
    if (nameError == null && emailError == null && passError == null && confirmPassError == null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Color(0xFF00E5FF), // Accent color background
        ),
      );
      // Navigate to login screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // Main build method - Creates the complete signup screen interface
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context), // Theme-based background
          body: Container(
            decoration: AppTheme.backgroundFilter(context),
            child: Center(
                child: SingleChildScrollView( // Scrollable content for keyboard
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Screen title
                        Text(
                          "Create Account", // Title text
                          style: TextStyle(
                            color: AppTheme.accentColor(context),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Full Name Input Field with validation
                        TextField(
                          controller: nameController, // Name controller
                          style: TextStyle(color: AppTheme.primaryTextColor(context)),
                          decoration: InputDecoration(
                            hintText: "Full Name", // Placeholder text
                            hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                            prefixIcon: Icon(
                              Icons.person, // Person icon
                              color: AppTheme.accentColor(context),
                            ),
                            errorText: nameError, // Show validation error
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentColor(context)), // Accent color when focused
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Email Input Field with Gmail validation
                        TextField(
                          controller: emailController, // Email controller
                          style: TextStyle(color: AppTheme.primaryTextColor(context)),
                          keyboardType: TextInputType.emailAddress, // Email keyboard type
                          decoration: InputDecoration(
                            hintText: "yourname@gmail.com", // Placeholder text
                            hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                            prefixIcon: Icon(
                              Icons.email, // Email icon
                              color: AppTheme.accentColor(context),
                            ),
                            errorText: emailError, // Show validation error
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentColor(context)), // Accent color when focused
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Password Input Field with strength validation
                        TextField(
                          controller: passController, // Password controller
                          obscureText: true, // Hide password text
                          style: TextStyle(color: AppTheme.primaryTextColor(context)),
                          decoration: InputDecoration(
                            hintText: "6+ digits password", // Placeholder text
                            hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                            prefixIcon: Icon(
                              Icons.lock, // Lock icon
                              color: AppTheme.accentColor(context),
                            ),
                            errorText: passError, // Show validation error
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentColor(context)), // Accent color when focused
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Confirm Password Input Field with matching validation
                        TextField(
                          controller: confirmPassController, // Confirm password controller
                          obscureText: true, // Hide password text
                          style: TextStyle(color: AppTheme.primaryTextColor(context)),
                          decoration: InputDecoration(
                            hintText: "Confirm password", // Placeholder text
                            hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
                            prefixIcon: Icon(
                              Icons.lock_outline, // Lock outline icon
                              color: AppTheme.accentColor(context),
                            ),
                            errorText: confirmPassError, // Show validation error
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.accentColor(context)), // Accent color when focused
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Sign Up Button - Full width with theme styling
                        SizedBox(
                          width: double.infinity, // Full width button
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor(context), // Theme accent color
                              padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14), // Rounded corners
                              ),
                            ),
                            onPressed: validateAndSignup, // Call validation method
                            child: Text(
                              "Sign Up", // Button text
                              style: TextStyle(
                                fontSize: 18,
                                color: themeProvider.isDarkMode ? Colors.black : Colors.white, // Dynamic text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Login Navigation Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ", // Prompt text
                              style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to login screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                "Login", // Navigation text
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