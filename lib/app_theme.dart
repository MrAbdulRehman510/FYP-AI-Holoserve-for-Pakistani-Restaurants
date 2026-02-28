import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AppTheme {
  static Color backgroundColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? const Color(0xFF0A0F1C) : Colors.grey[100]!;
  }
  
  static Color cardColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark 
        ? const Color(0xFF111827).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.9);
  }
  
  static Color primaryTextColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? Colors.white : Colors.black;
  }
  
  static Color secondaryTextColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? Colors.white70 : Colors.black87;
  }
  
  static Color accentColor(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? const Color(0xFF00E5FF) : const Color(0xFF00838F);
  }
  
  static LinearGradient appBarGradient(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF00E5FF).withValues(alpha: 0.25),
              const Color(0xFF0A0F1C),
            ]
          : [
              Colors.blue.withValues(alpha: 0.2),
              Colors.white,
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static String backgroundImage(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return isDark ? 'assets/images/bg_dark.jpg' : 'assets/images/bg_light.jpg';
  }
  
  static BoxFit getResponsiveBoxFit(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return BoxFit.cover; // Mobile
    if (screenWidth < 1200) return BoxFit.contain; // Tablet
    return BoxFit.cover; // Desktop
  }
  
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
        image: AssetImage(backgroundImage(context)),
        fit: responsiveFit,
        alignment: Alignment.center,
        colorFilter: isDark 
            ? ColorFilter.mode(
                Colors.black.withValues(alpha: 0.7),
                BlendMode.darken,
              )
            : ColorFilter.mode(
                Colors.white.withValues(alpha: 0.8),
                BlendMode.screen,
              ),
      ),
    );
  }
}