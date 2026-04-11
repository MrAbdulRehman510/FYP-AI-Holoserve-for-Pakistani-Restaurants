// main.dart - Entry point of HoloServe Flutter Application
// Initializes Firebase for Android and Web platforms
// Sets up Provider state management for Theme and Authentication
// Starts app with SplashScreen as home

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core initialization
import 'package:flutter/foundation.dart'; // kIsWeb and kDebugMode flags
import 'package:provider/provider.dart'; // State management
import 'screens/splash_screen.dart'; // First screen shown on app launch
import 'theme_provider.dart'; // Dark/Light theme state management
import 'auth_provider.dart'; // User authentication state management

// App entry point - runs before any widget is shown
void main() async {
  // Step 1: Initialize Flutter engine before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: Initialize Firebase based on platform (Web or Android)
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDfglU2MuDVHFcbNLULRChThb2wsInhRx0",
            authDomain: "holoserve.firebaseapp.com",
            projectId: "holoserve",
            storageBucket: "holoserve.firebasestorage.app",
            messagingSenderId: "376228426676",
            appId: "1:376228426676:web:483a9985db8360ed8538e1",
            measurementId: "G-R06RYY8QHK",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }
    if (kDebugMode) {
      print("Firebase Connection Success: ${Firebase.app().name}");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Firebase Initialization Error: $e");
    }
  }

  // Step 3: Run app with MultiProvider for global state management
  runApp(
    MultiProvider(
      providers: [
        // ThemeProvider: manages dark/light theme across entire app
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // AuthProvider: manages user login state and role (admin/staff)
        // loadUserData() restores session from SharedPreferences on app start
        ChangeNotifierProvider(create: (context) => AuthProvider()..loadUserData()),
      ],
      child: const HoloServeApp(),
    ),
  );
}

// Root widget of the HoloServe application
class HoloServeApp extends StatelessWidget {
  const HoloServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to ThemeProvider to rebuild when theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {

        // Show loading screen while theme is being loaded from SharedPreferences
        if (!themeProvider.isInitialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF0A0F1C), // Dark background
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/splash_dark.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E5FF), // Cyan loading indicator
                  ),
                ),
              ),
            ),
          );
        }

        // Main app with full theme support
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Hide debug banner
          title: 'HoloServe', // App title
          theme: ThemeProvider.lightTheme, // Light theme data
          darkTheme: ThemeProvider.darkTheme, // Dark theme data
          themeMode: themeProvider.themeMode, // Current active theme
          home: const SplashScreen(), // Start with splash screen
        );
      },
    );
  }
}
