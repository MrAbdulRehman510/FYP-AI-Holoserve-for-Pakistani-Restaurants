// SignupScreen - New admin account creation screen
// Responsibilities:
//   1. Collects name, email, password, and confirm password
//   2. Validates all fields before allowing submission
//   3. On success, shows a snackbar and navigates back to LoginScreen
//   4. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   5. AppTheme methods provide all colors and decorations for theme consistency
// Note: This is a mock screen - no Firebase account is actually created
//       It is only used for first-time setup demonstration
// Validation Rules:
//   Name     : Cannot be empty
//   Email    : Must end with @gmail.com
//   Password : Minimum 6 characters
//   Confirm  : Must match password

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';      // Navigates here after successful signup
import '../theme_provider.dart'; // Dark/light theme state
import '../app_theme.dart';      // Centralized theme colors and styles

// StatefulWidget needed for form validation state and password visibility toggles
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  // Text controllers for each form field
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool _obscurePass = true;    // Controls password field visibility
  bool _obscureConfirm = true; // Controls confirm password field visibility

  // Validation error messages - null means no error for that field
  String? nameError;
  String? emailError;
  String? passError;
  String? confirmPassError;

  @override
  void dispose() {
    // Dispose all controllers to free memory when screen is removed
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  // Validates all fields and processes signup if valid
  void _signup() {
    // Run all validations in a single setState to avoid multiple rebuilds
    setState(() {
      nameError = nameController.text.trim().isEmpty ? 'Name is required' : null;
      emailError = !emailController.text.trim().endsWith('@gmail.com')
          ? 'Email must end with @gmail.com'
          : null;
      passError = passController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
      // Confirm password must exactly match the password field
      confirmPassError = passController.text != confirmPassController.text
          ? 'Passwords do not match'
          : null;
    });

    // Stop if any validation failed - errors are shown below each field
    if (nameError != null || emailError != null || passError != null || confirmPassError != null) return;

    // All validations passed - show success and go to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Admin account created! Please login.'),
          backgroundColor: Colors.green),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  // Reusable text field builder used for all form inputs
  // Parameters:
  //   ctrl       : TextEditingController for this field
  //   hint       : Placeholder text shown when field is empty
  //   icon       : Leading icon shown on the left
  //   obscure    : Whether this is a password field (hides text)
  //   hasToggle  : Whether to show the eye icon for visibility toggle
  //   isObscured : Current visibility state (true = hidden)
  //   onToggle   : Callback when eye icon is tapped
  //   type       : Keyboard type (text, email, etc.)
  //   error      : Validation error message shown below field
  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    bool hasToggle = false,
    bool isObscured = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
    String? error,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure ? isObscured : false, // Only hide text if obscure is true
      keyboardType: type,
      style: TextStyle(color: AppTheme.primaryTextColor(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: AppTheme.accentColor(context)),
        // Eye icon only shown for password fields (hasToggle = true)
        suffixIcon: hasToggle
            ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.secondaryTextColor(context),
                ),
                onPressed: onToggle,
              )
            : null,
        errorText: error, // Validation error shown below the field
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentColor(context)),
        ),
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
            decoration: AppTheme.backgroundFilter(context), // Theme-based background
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

                      // Screen title
                      Text(
                        'Create Admin Account',
                        style: TextStyle(
                          color: AppTheme.accentColor(context),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Info badge indicating this is for first-time admin setup only
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'First-time setup — Admin only',
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full name input field
                      _buildField(nameController, 'Full Name', Icons.person, error: nameError),
                      const SizedBox(height: 15),

                      // Email input field - validates @gmail.com format
                      _buildField(emailController, 'yourname@gmail.com', Icons.email,
                          type: TextInputType.emailAddress, error: emailError),
                      const SizedBox(height: 15),

                      // Password field with eye icon toggle
                      _buildField(passController, '6+ characters password', Icons.lock,
                          obscure: true,
                          hasToggle: true,
                          isObscured: _obscurePass,
                          onToggle: () => setState(() => _obscurePass = !_obscurePass),
                          error: passError),
                      const SizedBox(height: 15),

                      // Confirm password field - must match password field
                      _buildField(confirmPassController, 'Confirm password', Icons.lock_outline,
                          obscure: true,
                          hasToggle: true,
                          isObscured: _obscureConfirm,
                          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          error: confirmPassError),
                      const SizedBox(height: 30),

                      // Submit button - triggers _signup() validation and processing
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _signup,
                          child: Text(
                            'Create Admin Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
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
