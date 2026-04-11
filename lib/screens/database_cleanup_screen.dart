// ============================================================
// DatabaseCleanupScreen - Reset aur naya admin banane ka screen
// Kaam:
//   1. "Reset & Create New Admin" button press karne par mock reset hota hai
//   2. 1 second delay ke baad LoginScreen par jaata hai
//   3. Cancel button se wapis jaate ho
//   4. Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   5. AppTheme.backgroundFilter() se theme-based background apply hoti hai
// Note: Firebase nahi use hota - sirf mock delay hai
//       Login screen se "Reset & Create New Admin" link se yahan aate hain
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import 'login_screen.dart';

class DatabaseCleanupScreen extends StatefulWidget {
  const DatabaseCleanupScreen({super.key});

  @override
  State<DatabaseCleanupScreen> createState() => _DatabaseCleanupScreenState();
}

class _DatabaseCleanupScreenState extends State<DatabaseCleanupScreen> {
  bool _isDeleting = false;
  String _status = '';

  Future<void> _deleteAllUsers() async {
    setState(() { _isDeleting = true; _status = 'Resetting...'; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _status = 'Done! All users deleted.');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          body: Container(
            decoration: AppTheme.backgroundFilter(context),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: AppTheme.accentColor(context),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'First-Time Setup',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This will delete all existing users from the database and let you create a fresh Admin account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_status.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentColor(context)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_isDeleting && _status != 'Done! All users deleted.')
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentColor(context),
                                ),
                              )
                            else
                              Icon(
                                _status.startsWith('Error')
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                color: _status.startsWith('Error')
                                    ? Colors.red
                                    : Colors.green,
                                size: 18,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _status,
                                style: TextStyle(
                                  color: AppTheme.primaryTextColor(context),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (!_isDeleting) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _deleteAllUsers,
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.white),
                          label: const Text(
                            'Reset & Create New Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: AppTheme.secondaryTextColor(context)),
                        ),
                      ),
                    ],
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
