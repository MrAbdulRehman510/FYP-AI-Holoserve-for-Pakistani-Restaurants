// HologramScriptScreen - Hologram voice script editor screen
// Responsibilities:
//   1. Allows editing of 3 hologram voice scripts:
//      - Welcome Message    : Played when a customer approaches
//      - Goodbye Message    : Played when a customer leaves
//      - Promo/Announcement : Played to advertise current deals
//   2. "UPDATE HOLOGRAM LIVE" button simulates saving with an 800ms loading delay
//      then shows a success snackbar (mock - no real device communication)
//   3. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   4. AppTheme methods provide all colors and decorations for theme consistency
// Note: Scripts are stored in local TextEditingControllers only
//       Changes are lost when the screen is closed - no Firebase persistence

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class HologramScriptScreen extends StatefulWidget {
  const HologramScriptScreen({super.key});

  @override
  State<HologramScriptScreen> createState() => _HologramScriptScreenState();
}

class _HologramScriptScreenState extends State<HologramScriptScreen> {
  // Controllers keyed by script name - makes it easy to access by key in _scriptBox
  final Map<String, TextEditingController> _controllers = {
    'welcomeMessage': TextEditingController(text: 'Welcome to HoloServe! Experience the future of dining.'),
    'goodbyeMessage': TextEditingController(text: 'Thank you for visiting! We hope to see you again soon.'),
    'promoAnnouncement': TextEditingController(text: 'Special offer today: 20% off on all combo meals!'),
  };

  bool _isLoading = false;

  @override
  void dispose() {
    _controllers.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }

  PreferredSizeWidget _topBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
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
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: AppTheme.primaryTextColor(context), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Text('Voice Scripting',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.keyboard_voice_rounded,
                    color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mock save - shows loading spinner for 800ms then shows success snackbar
  // In a real app this would push scripts to the hologram device/Firebase
  void _saveScripts() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hologram Scripts Updated Successfully! ✅')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 120),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _scriptBox('Welcome Message', 'welcomeMessage', Icons.waving_hand, context),
                      _scriptBox('Goodbye Message', 'goodbyeMessage', Icons.exit_to_app, context),
                      _scriptBox('Promo/Announcement', 'promoAnnouncement', Icons.campaign, context),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveScripts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor(context),
                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                  strokeWidth: 2,
                                ))
                            : const Text('UPDATE HOLOGRAM LIVE',
                                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds a single script editing card with label, icon, and multiline text field
  // key is used to look up the correct TextEditingController from _controllers map
  Widget _scriptBox(String label, String key, IconData icon, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentColor(context), size: 22),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _controllers[key],
            maxLines: 3,
            style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'What should the hologram say?',
              hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              fillColor: AppTheme.backgroundColor(context).withValues(alpha: 0.3),
              filled: true,
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }
}
