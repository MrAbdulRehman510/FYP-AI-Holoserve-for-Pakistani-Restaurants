// SplashScreen - First screen shown when the app launches
// Responsibilities:
//   1. Displays the app logo for 3 seconds
//   2. Automatically navigates to LoginScreen after the delay
//   3. Shows dark or light splash image based on current theme
//   4. Uses Consumer<ThemeProvider> to rebuild if theme changes during splash
//   5. ThemeProvider.isDarkMode determines which logo asset to display
// Note: No user interaction on this screen - it auto-navigates

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // For reading current dark/light theme
import 'login_screen.dart'; // Destination after splash delay

// StatefulWidget needed because initState is used to trigger navigation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigate(); // Start the 3-second timer as soon as screen loads
  }

  // Waits 3 seconds then replaces this screen with LoginScreen
  // Uses pushReplacement so user cannot go back to splash
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3)); // 3 second splash delay
    if (!mounted) return; // Safety check - widget may have been disposed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds if theme changes during splash (rare but safe)
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          // Background color matches the splash image theme
          backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(), // Push logo to vertical center

                // App logo - switches between dark and light version based on theme
                Image.asset(
                  themeProvider.isDarkMode
                      ? 'assets/images/splash_dark.png'  // Dark mode logo
                      : 'assets/images/splash_light.png', // Light mode logo
                  width: MediaQuery.of(context).size.width * 0.6, // 60% of screen width
                  fit: BoxFit.contain,
                ),

                const Spacer(), // Push footer to bottom

                // Developer credit shown at the bottom of splash screen
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Developed by Team Innovators',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
