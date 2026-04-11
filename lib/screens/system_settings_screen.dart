// ============================================================
// SystemSettingsScreen - App ki settings ka screen
// Kaam:
//   1. Dark/Light theme toggle karna
//   2. Language dropdown (English/Urdu) - sirf UI, koi translation nahi
//   3. Cloud Backup toggle (mock - sirf UI)
//   4. Logout button - confirmation dialog dikhata hai
//   5. Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   6. ThemeProvider.setTheme() se theme change hoti hai aur SharedPreferences mein save hoti hai
//   7. Local helper methods (primaryTextColor, cardBgColor) AppTheme ki jagah use hote hain
// Note: Firebase nahi use hota - sab local state mein hai
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  // Local state for settings - these reset when the screen is closed
  bool notificationsEnabled = true; // Controls Cloud Backup toggle
  String selectedLanguage = 'English'; // Language dropdown selection

  Color primaryTextColor(bool isDarkMode) =>
      isDarkMode ? Colors.white : Colors.black;
  Color secondaryTextColor(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF00838F);
  Color cardBgColor(bool isDarkMode) => isDarkMode
      ? const Color(0xFF111827).withValues(alpha: 0.8)
      : Colors.white.withValues(alpha: 0.9);

  String backgroundImage(bool isDarkMode) =>
      isDarkMode ? 'assets/images/bg_dark.jpg' : 'assets/images/bg_light.jpg';

  // Shows confirmation dialog before logging out - only pops the current screen (mock)
  void handleLogout() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
        title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
        content: Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Yes, Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget customTopBar(
    BuildContext context,
    String title,
    bool isDarkMode,
  ) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color(0xFF00E5FF).withValues(alpha: 0.25),
                    const Color(0xFF0A0F1C),
                  ]
                : [Colors.blue.withValues(alpha: 0.2), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: primaryTextColor(isDarkMode),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor(isDarkMode),
                  ),
                ),
                const Spacer(),
                Icon(Icons.tune_rounded, color: secondaryTextColor(isDarkMode)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable settings row - icon on left, title in middle, custom trailing widget on right
  Widget settingsTile({
    required String title,
    required Widget trailing,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: cardBgColor(isDarkMode),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: secondaryTextColor(isDarkMode).withValues(alpha: 0.2),
        ),
        boxShadow: isDarkMode
            ? []
            : [const BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: ListTile(
        leading: Icon(icon, color: secondaryTextColor(isDarkMode)),
        title: Text(
          title,
          style: TextStyle(color: primaryTextColor(isDarkMode), fontSize: 16),
        ),
        trailing: trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isDarkMode = themeProvider.isDarkMode;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
          appBar: customTopBar(context, 'System Settings', isDarkMode),
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
                        Colors.black.withValues(
                          alpha: 0.7,
                        ), // Dark overlay for dark mode
                        BlendMode.darken,
                      )
                    : ColorFilter.mode(
                        Colors.white.withValues(
                          alpha: 0.8,
                        ), // Light overlay for light mode
                        BlendMode.screen,
                      ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance & Language',
                    style: TextStyle(
                      color: secondaryTextColor(isDarkMode),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  settingsTile(
                    title: isDarkMode
                        ? 'Light Theme Active'
                        : 'Dark Theme Active',
                    icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    isDarkMode: isDarkMode,
                    trailing: Switch(
                      value: isDarkMode,
                      activeThumbColor: const Color(0xFF00E5FF),
                      onChanged: (val) => themeProvider.setTheme(val),
                    ),
                  ),
                  settingsTile(
                    title: 'Language / زبان',
                    icon: Icons.translate,
                    isDarkMode: isDarkMode,
                    trailing: DropdownButton<String>(
                      value: selectedLanguage,
                      dropdownColor: isDarkMode
                          ? const Color(0xFF111827)
                          : Colors.white,
                      items: ['English', 'Urdu']
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                lang,
                                style: TextStyle(
                                  color: primaryTextColor(isDarkMode),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedLanguage = val!),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Security & Data',
                    style: TextStyle(
                      color: secondaryTextColor(isDarkMode),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  settingsTile(
                    title: 'Cloud Backup',
                    icon: Icons.cloud_upload,
                    isDarkMode: isDarkMode,
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeThumbColor: const Color(0xFF00E5FF),
                      onChanged: (val) =>
                          setState(() => notificationsEnabled = val),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
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
        );
      },
    );
  }
}
