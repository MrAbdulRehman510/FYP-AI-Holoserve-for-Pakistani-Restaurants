// Staff Out of Stock Screen - Inventory management for staff users
// Allows staff to toggle item availability status with real-time updates
// Features category-based organization and visual stock indicators

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for managing inventory stock status
class StaffOutOfStockScreen extends StatefulWidget {
  const StaffOutOfStockScreen({super.key});

  @override
  State<StaffOutOfStockScreen> createState() => _StaffOutOfStockScreenState();
}

// State class managing menu item availability data
class _StaffOutOfStockScreenState extends State<StaffOutOfStockScreen> {
  // Sample menu data organized by categories with availability status
  Map<String, List<Map<String, dynamic>>> menuData = {
    "Burgers": [
      {"name": "Zinger Burger", "available": true},
      {"name": "Beef Burger", "available": true},
    ],
    "Drinks": [
      {"name": "Coke", "available": true},
      {"name": "Mint Margarita", "available": false},
    ],
  };

  // Custom app bar with inventory management theme
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
                  icon: Icon(Icons.arrow_back, color: AppTheme.primaryTextColor(context)),
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
                  Icons.inventory_2_outlined,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with category-based inventory display
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: customTopBar(context, "Stock Management"),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
            children: menuData.keys.map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category header with styling
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.accentColor(context),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Menu items in category with availability toggles
                  ...menuData[category]!.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: item['available']
                              ? AppTheme.primaryTextColor(context).withValues(alpha: 0.05)
                              : Colors.redAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            color: item['available']
                                ? AppTheme.primaryTextColor(context)
                                : AppTheme.secondaryTextColor(context),
                            decoration: item['available']
                                ? TextDecoration.none
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          item['available'] ? "In Stock" : "Out of Stock",
                          style: TextStyle(
                            color: item['available']
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                        // Toggle switch for availability status
                        trailing: Switch(
                          value: item['available'],
                          activeThumbColor: AppTheme.accentColor(context),
                          activeTrackColor: AppTheme.accentColor(context).withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.redAccent,
                          onChanged: (val) {
                            setState(() {
                              item['available'] = val;
                            });
                            // Show status change feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${item['name']} is now ${val ? 'Available' : 'Out of Stock'}",
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppTheme.cardColor(context),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}