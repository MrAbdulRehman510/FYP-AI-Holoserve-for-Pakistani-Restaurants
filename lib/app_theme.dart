// AppTheme - Centralized Theme Helper Class
// Provides static methods that return theme-based colors, gradients, and decorations
// All methods read current theme from ThemeProvider and return appropriate values
// Used by every screen to maintain consistent styling across dark and light modes
//
// Available methods:
//   backgroundColor()  - Screen background color
//   cardColor()        - Card/container background color
//   primaryTextColor() - Main text color (white in dark, black in light)
//   secondaryTextColor()- Secondary text color (white70 in dark, black87 in light)
//   accentColor()      - Accent/highlight color (cyan in dark, teal in light)
//   appBarGradient()   - Top bar gradient decoration
//   backgroundImage()  - Theme-based background image path
//   backgroundFilter() - Full background decoration with image and overlay

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For reading ThemeProvider
import 'theme_provider.dart'; // Theme state management

// Static utility class - no instantiation needed, call methods directly
class AppTheme {

  // Returns screen background color based on current theme
  // Dark: Dark navy (#0A0F1C) | Light: Light grey
  static Color backgroundColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? const Color(0xFF0A0F1C) : Colors.grey[100]!;
  }

  // Returns card/container background color based on current theme
  // Dark: Dark grey with 80% opacity | Light: White with 90% opacity
  static Color cardColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark
        ? const Color(0xFF111827).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.9);
  }

  // Returns primary text color based on current theme
  // Dark: White | Light: Black
  static Color primaryTextColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? Colors.white : Colors.black;
  }

  // Returns secondary/subtitle text color based on current theme
  // Dark: White70 (slightly transparent) | Light: Black87 (slightly transparent)
  static Color secondaryTextColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? Colors.white70 : Colors.black87;
  }

  // Returns accent/highlight color based on current theme
  // Dark: Cyan (#00E5FF) | Light: Teal (#00838F)
  static Color accentColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? const Color(0xFF00E5FF) : const Color(0xFF00838F);
  }

  // Returns app bar gradient decoration based on current theme
  // Dark: Cyan to dark navy gradient | Light: Light blue to white gradient
  static LinearGradient appBarGradient(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF00E5FF).withValues(alpha: 0.25), // Transparent cyan
              const Color(0xFF0A0F1C), // Dark navy
            ]
          : [
              Colors.blue.withValues(alpha: 0.2), // Transparent blue
              Colors.white, // White
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Returns background image path based on current theme
  // Dark: bg_dark.jpg | Light: bg_light.jpg
  static String backgroundImage(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? 'assets/images/bg_dark.jpg' : 'assets/images/bg_light.jpg';
  }

  // Returns responsive BoxFit based on screen width
  // Mobile (<600px): cover | Tablet (<1200px): contain | Desktop: cover
  static BoxFit getResponsiveBoxFit(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return BoxFit.cover; // Mobile - fill screen
    if (screenWidth < 1200) return BoxFit.contain; // Tablet - show full image
    return BoxFit.cover; // Desktop - fill screen
  }

  // Returns full background BoxDecoration with theme-based image and color overlay
  // Dark: bg_dark.jpg with black 70% overlay (darken blend)
  // Light: bg_light.jpg with white 80% overlay (screen blend)
  // Used by all screens as body container decoration
  static BoxDecoration backgroundFilter(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive BoxFit based on screen size
    BoxFit responsiveFit;
    if (screenWidth < 600) {
      responsiveFit = BoxFit.cover; // Mobile
    } else if (screenWidth < 1200) {
      responsiveFit = BoxFit.cover; // Tablet
    } else {
      responsiveFit = BoxFit.cover; // Desktop/Laptop
    }

    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(backgroundImage(context)), // Theme-based image
        fit: responsiveFit, // Responsive fit
        alignment: Alignment.center,
        colorFilter: isDark
            ? ColorFilter.mode(
                Colors.black.withValues(alpha: 0.7), // Dark overlay for dark mode
                BlendMode.darken,
              )
            : ColorFilter.mode(
                Colors.white.withValues(alpha: 0.8), // Light overlay for light mode
                BlendMode.screen,
              ),
      ),
    );
  }
}
