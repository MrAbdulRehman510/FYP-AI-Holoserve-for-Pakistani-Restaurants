// HologramControlScreen - Hologram device control panel for staff
// Responsibilities:
//   1. Master Power switch - toggles hologram projection on/off (local state)
//   2. Animated icon changes color based on power state (accent = on, dim = off)
//   3. Audio Volume slider - adjustable from 0% to 100% (local state)
//   4. Language dropdown - English / Urdu / Arabic selection (local state)
//   5. Voice Script Settings card - navigates to HologramScriptScreen
//   6. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   7. AppTheme methods provide all colors and decorations for theme consistency
// Note: All state is local - resets when screen is closed, no Firebase used

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hologram_script_screen.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class HologramControlScreen extends StatefulWidget {
  const HologramControlScreen({super.key});

  @override
  State<HologramControlScreen> createState() => _HologramControlScreenState();
}

class _HologramControlScreenState extends State<HologramControlScreen> {
  // Local state - all resets when screen is closed (no Firebase persistence)
  bool _powerOn = false;   // Master power switch state
  double _volume = 50;     // Audio volume 0-100
  String _language = 'English'; // Selected hologram language

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
                Text('Hologram Control Panel',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.settings_input_component_rounded,
                    color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          extendBodyBehindAppBar: true,
          appBar: _topBar(context),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundFilter(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 140),
                  // Animated icon color: accent when on, dim when off
                  TweenAnimationBuilder(
                    tween: ColorTween(
                      begin: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3),
                      end: _powerOn ? AppTheme.accentColor(context) : AppTheme.secondaryTextColor(context).withValues(alpha: 0.3),
                    ),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, Color? color, child) {
                      return Icon(Icons.vibration_rounded, size: 120, color: color);
                    },
                  ),
                  Text(
                    _powerOn ? 'SYSTEM ACTIVE' : 'SYSTEM OFFLINE',
                    style: TextStyle(
                      color: _powerOn ? AppTheme.accentColor(context) : AppTheme.secondaryTextColor(context).withValues(alpha: 0.5),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Voice Script Card
                  _card(child: ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HologramScriptScreen())),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accentColor(context),
                      child: Icon(Icons.description, color: themeProvider.isDarkMode ? Colors.black : Colors.white),
                    ),
                    title: Text('Voice Script Settings', style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold)),
                    subtitle: Text('Edit Welcome & Promo messages', style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12)),
                    trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.5), size: 16),
                  )),

                  // Power Switch
                  _card(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Master Power', style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold)),
                            Text(_powerOn ? 'Projection is Running' : 'Projection Stopped', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _powerOn = !_powerOn),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 64,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(34),
                              gradient: LinearGradient(
                                colors: _powerOn
                                    ? [const Color(0xFF00C853), const Color(0xFF69F0AE)]
                                    : [const Color(0xFFB71C1C), const Color(0xFFFF5252)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_powerOn ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.7),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: (_powerOn ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 3, left: 6, right: 6,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: [Colors.white.withValues(alpha: 0.5), Colors.transparent],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: _powerOn ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_powerOn ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _powerOn ? Icons.power : Icons.power_off,
                                        size: 14,
                                        color: _powerOn ? const Color(0xFF00C853) : const Color(0xFFB71C1C),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

                  // Volume Slider
                  _card(child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Audio Volume', style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold)),
                            Text('${_volume.toInt()}%', style: TextStyle(color: AppTheme.accentColor(context))),
                          ],
                        ),
                      ),
                      Slider(
                        value: _volume,
                        min: 0,
                        max: 100,
                        activeColor: AppTheme.accentColor(context),
                        inactiveColor: AppTheme.secondaryTextColor(context).withValues(alpha: 0.2),
                        onChanged: (val) => setState(() => _volume = val),
                      ),
                    ],
                  )),

                  // Language Dropdown
                  _card(child: ListTile(
                    leading: Icon(Icons.language, color: AppTheme.accentColor(context)),
                    title: Text('Hologram Language', style: TextStyle(color: AppTheme.primaryTextColor(context))),
                    trailing: DropdownButton<String>(
                      value: _language,
                      dropdownColor: AppTheme.cardColor(context),
                      underline: const SizedBox(),
                      items: ['English', 'Urdu', 'Arabic'].map((val) => DropdownMenuItem(
                        value: val,
                        child: Text(val, style: TextStyle(color: AppTheme.primaryTextColor(context))),
                      )).toList(),
                      onChanged: (val) => setState(() => _language = val!),
                    ),
                  )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Reusable card container used by all control tiles on this screen
  Widget _card({required Widget child}) {
    return Consumer<ThemeProvider>(
      builder: (context, _, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.1)),
        ),
        child: child,
      ),
    );
  }
}
