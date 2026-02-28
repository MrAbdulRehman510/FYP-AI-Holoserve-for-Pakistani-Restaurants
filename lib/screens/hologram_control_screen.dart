// Hologram Control Screen - Device control panel for hologram projection system
// Manages power, volume, language settings, and voice script configuration
// Integrates with Firebase for real-time device state management

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'hologram_script_screen.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for hologram device control interface
class HologramControlScreen extends StatefulWidget {
  const HologramControlScreen({super.key});

  @override
  State<HologramControlScreen> createState() => _HologramControlScreenState();
}

// State class managing device controls and Firebase integration
class _HologramControlScreenState extends State<HologramControlScreen> {
  // Firebase document reference for device settings
  final DocumentReference deviceRef = FirebaseFirestore.instance
      .collection('settings')
      .doc('hologramDevice');

  // Custom app bar with device control theme
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
                  Icons.settings_input_component_rounded,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with Firebase streaming for real-time device status
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          extendBodyBehindAppBar: true,
          appBar: customTopBar(context, "Hologram Control Panel"),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundFilter(context),
            // Firebase stream for real-time device state monitoring
            child: StreamBuilder<DocumentSnapshot>(
              stream: deviceRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentColor(context),
                    ),
                  );
                }

                // Show error state if device document doesn't exist
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildErrorState();
                }

                // Extract device settings from Firebase data
                var data = snapshot.data!.data() as Map<String, dynamic>;
                bool powerOn = data['powerOn'] ?? false;
                double volume = (data['volume'] ?? 50).toDouble();
                String language = data['language'] ?? 'English';

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 140),
                      // Animated device status icon
                      TweenAnimationBuilder(
                        tween: ColorTween(
                          begin: AppTheme.secondaryTextColor(
                            context,
                          ).withValues(alpha: 0.3),
                          end: powerOn
                              ? AppTheme.accentColor(context)
                              : AppTheme.secondaryTextColor(
                                  context,
                                ).withValues(alpha: 0.3),
                        ),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, Color? color, child) {
                          return Icon(
                            Icons.vibration_rounded,
                            size: 120,
                            color: color,
                          );
                        },
                      ),
                      // Device status text
                      Text(
                        powerOn ? "SYSTEM ACTIVE" : "SYSTEM OFFLINE",
                        style: TextStyle(
                          color: powerOn
                              ? AppTheme.accentColor(context)
                              : AppTheme.secondaryTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Voice script settings navigation card
                      _buildControlCard(
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HologramScriptScreen(),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.accentColor(context),
                            child: Icon(
                              Icons.description,
                              color: themeProvider.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          title: Text(
                            "Voice Script Settings",
                            style: TextStyle(
                              color: AppTheme.primaryTextColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Edit Welcome & Promo messages",
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(context),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.secondaryTextColor(
                              context,
                            ).withValues(alpha: 0.5),
                            size: 16,
                          ),
                        ),
                      ),
                      // Master power control switch
                      _buildControlCard(
                        child: SwitchListTile(
                          title: Text(
                            "Master Power",
                            style: TextStyle(
                              color: AppTheme.primaryTextColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            powerOn
                                ? "Projection is Running"
                                : "Projection Stopped",
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(context),
                            ),
                          ),
                          value: powerOn,
                          activeThumbColor: AppTheme.accentColor(context),
                          onChanged: (val) =>
                              deviceRef.update({'powerOn': val}),
                        ),
                      ),
                      // Volume control slider
                      _buildControlCard(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Audio Volume",
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${volume.toInt()}%",
                                    style: TextStyle(
                                      color: AppTheme.accentColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Volume slider with real-time updates
                            Slider(
                              value: volume,
                              min: 0,
                              max: 100,
                              activeColor: AppTheme.accentColor(context),
                              inactiveColor: AppTheme.secondaryTextColor(
                                context,
                              ).withValues(alpha: 0.2),
                              onChanged: (val) =>
                                  deviceRef.update({'volume': val.toInt()}),
                            ),
                          ],
                        ),
                      ),
                      // Language selection dropdown
                      _buildControlCard(
                        child: ListTile(
                          leading: Icon(
                            Icons.language,
                            color: AppTheme.accentColor(context),
                          ),
                          title: Text(
                            "Hologram Language",
                            style: TextStyle(
                              color: AppTheme.primaryTextColor(context),
                            ),
                          ),
                          trailing: DropdownButton<String>(
                            value: language,
                            dropdownColor: AppTheme.cardColor(context),
                            underline: const SizedBox(),
                            items: ['English', 'Urdu', 'Arabic'].map((
                              String val,
                            ) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(
                                  val,
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor(context),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                deviceRef.update({'language': val}),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Reusable control card wrapper with consistent styling
  Widget _buildControlCard({required Widget child}) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child2) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.secondaryTextColor(
                context,
              ).withValues(alpha: 0.1),
            ),
          ),
          child: child,
        );
      },
    );
  }

  // Error state widget for missing device document
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 60,
          ),
          const SizedBox(height: 10),
          const Text(
            "Device Document Not Found!",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          // Initialize device button for first-time setup
          ElevatedButton(
            onPressed: () => deviceRef.set({
              'powerOn': false,
              'volume': 50,
              'language': 'English',
            }),
            child: const Text("Initialize Device"),
          ),
        ],
      ),
    );
  }
}
