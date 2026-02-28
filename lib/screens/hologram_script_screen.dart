// Hologram Script Screen - Manage voice scripts for hologram device
// Allows editing of welcome messages, goodbye messages, and promotional announcements
// Integrates with Firebase for real-time script updates and device synchronization

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for managing hologram voice scripts
class HologramScriptScreen extends StatefulWidget {
  const HologramScriptScreen({super.key});

  @override
  State<HologramScriptScreen> createState() => _HologramScriptScreenState();
}

// State class managing script editing and Firebase synchronization
class _HologramScriptScreenState extends State<HologramScriptScreen> {
  // Text controllers for different script types
  final Map<String, TextEditingController> _controllers = {
    'welcomeMessage': TextEditingController(),
    'goodbyeMessage': TextEditingController(),
    'promoAnnouncement': TextEditingController(),
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentScripts(); // Load existing scripts on initialization
  }

  // Custom app bar with voice theme and gradient styling
  PreferredSizeWidget customTopBar(BuildContext context, String title) {
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
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
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
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_voice_rounded,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Load existing scripts from Firebase on screen initialization
  void _loadCurrentScripts() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('scripts')
          .doc('hologram_config')
          .get();
      if (doc.exists) {
        // Populate controllers with existing script data
        setState(() {
          _controllers['welcomeMessage']!.text = doc['welcomeMessage'] ?? "";
          _controllers['goodbyeMessage']!.text = doc['goodbyeMessage'] ?? "";
          _controllers['promoAnnouncement']!.text =
              doc['promoAnnouncement'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error loading scripts: $e");
    }
  }

  // Update all scripts in Firebase with loading state management
  Future<void> _updateScripts() async {
    setState(() => _isLoading = true);
    try {
      // Save all script data to Firebase
      await FirebaseFirestore.instance
          .collection('scripts')
          .doc('hologram_config')
          .set({
            'welcomeMessage': _controllers['welcomeMessage']!.text,
            'goodbyeMessage': _controllers['goodbyeMessage']!.text,
            'promoAnnouncement': _controllers['promoAnnouncement']!.text,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
      // Show success feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hologram Scripts Updated Successfully! ✅"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating scripts: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Main build method with script editing interface
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        // Custom app bar with voice scripting theme
        appBar: customTopBar(context, "Voice Scripting"),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 120), // Space for custom app bar
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Script editing boxes for different message types
                      _buildScriptBox(
                        "Welcome Message",
                        "welcomeMessage",
                        Icons.waving_hand,
                        context,
                      ),
                      _buildScriptBox(
                        "Goodbye Message",
                        "goodbyeMessage",
                        Icons.exit_to_app,
                        context,
                      ),
                      _buildScriptBox(
                        "Promo/Announcement",
                        "promoAnnouncement",
                        Icons.campaign,
                        context,
                      ),
                      const SizedBox(height: 30),
                      // Update button with loading state
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updateScripts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor(context),
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: AppTheme.accentColor(
                            context,
                          ).withValues(alpha: 0.4),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "UPDATE HOLOGRAM LIVE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
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

  // Individual script editing box with icon and text field
  Widget _buildScriptBox(
    String label,
    String key,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor(context).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Script type header with icon
          Row(
            children: [
              Icon(icon, color: AppTheme.accentColor(context), size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryTextColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Multi-line text field for script content
          TextField(
            controller: _controllers[key],
            maxLines: 3,
            style: TextStyle(
              color: AppTheme.primaryTextColor(context),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: "What should the hologram say?",
              hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              fillColor: AppTheme.backgroundColor(
                context,
              ).withValues(alpha: 0.3),
              filled: true,
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }
}
