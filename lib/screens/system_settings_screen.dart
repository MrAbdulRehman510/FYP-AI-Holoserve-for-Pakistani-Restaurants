// System Settings Screen - Application configuration and user preferences management
// Provides theme switching, language selection, backup settings, and logout functionality
// Supports bilingual interface (English/Urdu) with RTL text direction

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Theme management provider for dark/light mode

// StatefulWidget for System Settings with dynamic language and theme controls
class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

// State class for System Settings with language and notification controls
class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  // State variables for user preferences
  bool notificationsEnabled = true; // Cloud backup toggle state
  String selectedLanguage = 'English'; // Current selected language

  // Localization map for bilingual support (English/Urdu)
  // Contains all UI text translations for both languages
  final Map<String, Map<String, String>> localizedText = {
    'English': {
      'appBar': 'System Settings',
      'appearance': 'Appearance & Language',
      'darkTheme': 'Light Theme Active',
      'lightTheme': 'Dark Theme Active',
      'language': 'Language / زبان',
      'security': 'Security & Data',
      'backup': 'Cloud Backup',
      'logout': 'Log Out',
      'logoutTitle': 'Logout',
      'logoutMsg': 'Are you sure you want to exit?',
      'yes': 'Yes, Logout',
      'no': 'No',
    },
    'Urdu': {
      'appBar': 'سسٹم کی ترتیبات',
      'appearance': 'ظاہری شکل اور زبان',
      'darkTheme': 'ڈارک تھیم فعال ہے',
      'lightTheme': 'لائٹ تھیم فعال ہے',
      'language': 'زبان / English',
      'security': 'سیکورٹی اور ڈیٹا',
      'backup': 'کلاؤڈ بیک اپ',
      'logout': 'لاگ آؤٹ',
      'logoutTitle': 'لاگ آؤٹ',
      'logoutMsg': 'کیا آپ واقعی باہر نکلنا چاہتے ہیں؟',
      'yes': 'جی ہاں، لاگ آؤٹ',
      'no': 'نہیں',
    },
  };

  // Helper method to get localized text based on selected language
  String t(String key) => localizedText[selectedLanguage]![key]!;

  // Theme-based color methods for consistent styling across light/dark modes
  Color primaryTextColor(bool isDarkMode) => isDarkMode ? Colors.white : Colors.black;
  Color secondaryTextColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF00838F);
  Color cardBgColor(bool isDarkMode) => isDarkMode
      ? const Color(0xFF111827).withValues(alpha: 0.8)
      : Colors.white.withValues(alpha: 0.9);

  // Background image selection based on theme mode
  String backgroundImage(bool isDarkMode) =>
      isDarkMode ? 'assets/images/bg.jpg' : 'assets/images/bg.jpg';

  // Logout confirmation dialog with localized text
  // Shows confirmation dialog before logging out user
  void handleLogout() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
        title: Text(
          t('logoutTitle'), // Localized logout title
          style: const TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          t('logoutMsg'), // Localized logout message
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t('no'), // Localized "No" text
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
          ),
          // Confirm logout button
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst), // Navigate to first route
            child: Text(
              t('yes'), // Localized "Yes" text
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Custom top bar with gradient background and settings icon
  // Supports RTL layout for Urdu language with proper text direction
  PreferredSizeWidget customTopBar(BuildContext context, String title, bool isDarkMode) {
    bool isUrdu = selectedLanguage == 'Urdu'; // Check if Urdu is selected
    return AppBar(
      automaticallyImplyLeading: false, // Remove default back button
      toolbarHeight: 90, // Custom height for better appearance
      backgroundColor: Colors.transparent, // Transparent to show gradient
      elevation: 0, // Remove shadow
      flexibleSpace: Container(
        // Gradient background container
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25), // Dark mode gradient
                    const Color(0xFF0A0F1C),
                  ]
                : [Colors.blue.withValues(alpha: 0.2), Colors.white], // Light mode gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24), // Rounded bottom corners
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr, // RTL support for Urdu
              children: [
                // Custom back button
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: primaryTextColor(isDarkMode), size: 20),
                  onPressed: () => Navigator.pop(context), // Navigate back
                ),
                const SizedBox(width: 12),
                // Screen title with localization
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor(isDarkMode),
                  ),
                ),
                const Spacer(), // Push settings icon to right
                // Settings tune icon
                Icon(Icons.tune_rounded, color: secondaryTextColor(isDarkMode)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable settings tile widget for consistent styling
  // Creates styled cards for each setting option with icon, title, and trailing widget
  Widget settingsTile({
    required String title, // Setting title text
    required Widget trailing, // Trailing widget (switch, dropdown, etc.)
    required IconData icon, // Leading icon
    required bool isDarkMode, // Theme mode for styling
  }) {
    bool isUrdu = selectedLanguage == 'Urdu'; // Check for RTL layout
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Space between tiles
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Internal padding
      decoration: BoxDecoration(
        color: cardBgColor(isDarkMode), // Theme-based card background
        borderRadius: BorderRadius.circular(15), // Rounded corners
        border: Border.all(color: secondaryTextColor(isDarkMode).withValues(alpha: 0.2)), // Subtle border
        boxShadow: isDarkMode
            ? [] // No shadow in dark mode
            : [const BoxShadow(color: Colors.black12, blurRadius: 5)], // Light shadow in light mode
      ),
      child: ListTile(
        leading: Icon(icon, color: secondaryTextColor(isDarkMode)), // Leading icon with theme color
        title: Text(
          title,
          style: TextStyle(color: primaryTextColor(isDarkMode), fontSize: 16),
          textAlign: isUrdu ? TextAlign.right : TextAlign.left, // RTL support
        ),
        trailing: trailing, // Custom trailing widget
      ),
    );
  }

  // Main build method - Creates the complete system settings screen
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isDarkMode = themeProvider.isDarkMode; // Current theme mode
        bool isUrdu = selectedLanguage == 'Urdu'; // Current language selection

        // Directionality widget for RTL support in Urdu
        return Directionality(
          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            extendBodyBehindAppBar: true, // Allow body to extend behind app bar
            backgroundColor: isDarkMode ? Colors.black : Colors.grey[100], // Theme-based background
            appBar: customTopBar(context, t('appBar'), isDarkMode), // Custom app bar with localized title
            body: Container(
              width: double.infinity, // Full width
              height: double.infinity, // Full height
              decoration: BoxDecoration(
                // Background image with theme-based color filter
                image: DecorationImage(
                  image: AssetImage(backgroundImage(isDarkMode)),
                  fit: BoxFit.cover,
                  colorFilter: isDarkMode
                      ? ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.7), // Dark overlay for dark mode
                          BlendMode.darken,
                        )
                      : ColorFilter.mode(
                          Colors.white.withValues(alpha: 0.8), // Light overlay for light mode
                          BlendMode.screen,
                        ),
                ),
              ),
              child: SingleChildScrollView( // Scrollable content
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 20), // Padding with top space for app bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance & Language Section Header
                    Text(
                      t('appearance'), // Localized section title
                      style: TextStyle(
                        color: secondaryTextColor(isDarkMode),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Dark/Light Theme Toggle Setting
                    settingsTile(
                      title: isDarkMode ? t('darkTheme') : t('lightTheme'), // Dynamic title based on current theme
                      icon: isDarkMode ? Icons.dark_mode : Icons.light_mode, // Dynamic icon
                      isDarkMode: isDarkMode,
                      trailing: Switch(
                        value: isDarkMode, // Current theme state
                        activeThumbColor: const Color(0xFF00E5FF), // Active switch color
                        onChanged: (val) => themeProvider.setTheme(val), // Toggle theme
                      ),
                    ),

                    // Language Selection Setting
                    settingsTile(
                      title: t('language'), // Localized language title
                      icon: Icons.translate, // Translation icon
                      isDarkMode: isDarkMode,
                      trailing: DropdownButton<String>(
                        value: selectedLanguage, // Current selected language
                        dropdownColor: isDarkMode
                            ? const Color(0xFF111827) // Dark dropdown background
                            : Colors.white, // Light dropdown background
                        items: ['English', 'Urdu']
                            .map((lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      color: primaryTextColor(isDarkMode),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => selectedLanguage = val!), // Update language
                      ),
                    ),

                    const SizedBox(height: 25),
                    // Security & Data Section Header
                    Text(
                      t('security'), // Localized section title
                      style: TextStyle(
                        color: secondaryTextColor(isDarkMode),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Cloud Backup Toggle Setting
                    settingsTile(
                      title: t('backup'), // Localized backup title
                      icon: Icons.cloud_upload, // Cloud upload icon
                      isDarkMode: isDarkMode,
                      trailing: Switch(
                        value: notificationsEnabled, // Backup toggle state
                        activeThumbColor: const Color(0xFF00E5FF), // Active switch color
                        onChanged: (val) => setState(() => notificationsEnabled = val), // Toggle backup
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Logout Button - Full width red button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: handleLogout, // Logout confirmation dialog
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, // Red background
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.white), // Logout icon
                            const SizedBox(width: 8),
                            Text(
                              t('logout'), // Localized logout text
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
