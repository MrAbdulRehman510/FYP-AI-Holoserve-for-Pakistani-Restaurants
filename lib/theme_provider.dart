// ThemeProvider - Dark/Light Theme State Management
// Manages the current theme mode (dark or light) for the entire app
// Saves theme preference to SharedPreferences so it persists after app restart
// Default theme is Light Mode
// Used by main.dart to set MaterialApp theme
// Used by all screens via Consumer<ThemeProvider> to get current theme

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Local storage for theme persistence

// ChangeNotifier allows all listening widgets to rebuild when theme changes
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme is light
  bool _isInitialized =
      false; // Flag to check if theme has been loaded from storage

  // Public getters
  ThemeMode get themeMode => _themeMode; // Current theme mode (light/dark)
  bool get isDarkMode =>
      _themeMode == ThemeMode.dark; // True if dark mode is active
  bool get isInitialized =>
      _isInitialized; // True after theme is loaded from SharedPreferences

  // Constructor - automatically loads saved theme on app start
  ThemeProvider() {
    _loadTheme(); // Load saved theme preference from SharedPreferences
  }

  // Toggle between dark and light theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode
              .light // Switch to light if currently dark
        : ThemeMode.dark; // Switch to dark if currently light
    _saveTheme(); // Save new preference to SharedPreferences
    notifyListeners(); // Rebuild all listening widgets
  }

  // Set theme directly - used by System Settings screen switch
  // isDark: true = dark mode, false = light mode
  void setTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(); // Save preference to SharedPreferences
    notifyListeners(); // Rebuild all listening widgets
  }

  // Load saved theme from SharedPreferences on app start
  // Called in constructor so theme is ready before first screen renders
  _loadTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isDark =
          prefs.getBool('isDarkMode') ?? false; // Default to light if not saved
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      _themeMode = ThemeMode.light; // Fallback to light theme on error
    }
    _isInitialized = true; // Mark as initialized so splash screen can proceed
    notifyListeners(); // Rebuild app with loaded theme
  }

  // Save current theme preference to SharedPreferences
  // Called whenever theme changes so it persists after app restart
  _saveTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(
        'isDarkMode',
        isDarkMode,
      ); // Save true for dark, false for light
    } catch (e) {
      // Ignore save errors silently
    }
  }

  // Light Theme Data - used when light mode is active
  // Primary color: Teal (#00838F)
  // Background: Light grey
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light, // Light mode
    primaryColor: const Color(0xFF00838F), // Teal primary color
    scaffoldBackgroundColor: Colors.grey[100], // Light grey background
    fontFamily: 'Roboto', // Default font
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00838F), // Teal
      secondary: Color(0xFF00838F), // Teal
      surface: Colors.white, // White surface
      // ignore: deprecated_member_use
      background: Color(0xFFF5F5F5), // Light grey background
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // White app bar
      foregroundColor: Colors.black, // Black text/icons
      elevation: 0, // No shadow
    ),
    cardTheme: const CardThemeData(
      color: Colors.white, // White cards
      elevation: 2, // Slight shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // Rounded corners
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // White input background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
  );

  // Dark Theme Data - used when dark mode is active
  // Primary color: Cyan (#00E5FF)
  // Background: Dark navy (#0A0F1C)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // Dark mode
    primaryColor: const Color(0xFF00E5FF), // Cyan primary color
    scaffoldBackgroundColor: const Color(0xFF0A0F1C), // Dark navy background
    fontFamily: 'Roboto', // Default font
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00E5FF), // Cyan
      secondary: Color(0xFF00E5FF), // Cyan
      surface: Color(0xFF111827), // Dark card surface
      // ignore: deprecated_member_use
      background: Color(0xFF0A0F1C), // Dark navy background
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111827), // Dark app bar
      foregroundColor: Colors.white, // White text/icons
      elevation: 0, // No shadow
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF111827), // Dark cards
      elevation: 0, // No shadow in dark mode
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // Rounded corners
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF111827), // Dark input background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none, // No border in dark mode
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
  );
}
