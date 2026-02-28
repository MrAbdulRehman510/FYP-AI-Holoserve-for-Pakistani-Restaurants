// Admin Promotions Screen - Manage promotional deals and discount codes
// Allows admins to create, edit, and delete promotional campaigns
// Features dialog-based editing and real-time status updates

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for managing promotional deals and campaigns
class AdminPromotionsScreen extends StatefulWidget {
  const AdminPromotionsScreen({super.key});

  @override
  State<AdminPromotionsScreen> createState() => _AdminPromotionsScreenState();
}

// State class managing promotions data and user interactions
class _AdminPromotionsScreenState extends State<AdminPromotionsScreen> {
  // Sample promotional deals data with status tracking
  final List<Map<String, dynamic>> deals = [
    {
      "title": "Weekend Feast",
      "discount": "20% OFF",
      "code": "WEEKEND20",
      "status": "Active",
    },
    {
      "title": "Student Deal",
      "discount": "15% OFF",
      "code": "STUDENTHOLO",
      "status": "Active",
    },
    {
      "title": "Night Owl",
      "discount": "10% OFF",
      "code": "NIGHT10",
      "status": "Expired",
    },
  ];

  // Text controllers for promotion dialog form inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // Custom app bar with gradient styling and promotional theme
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
                Icon(Icons.stars_rounded, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Open dialog for creating new promotion or editing existing one
  void _openPromotionDialog({int? index}) {
    // Pre-fill form fields if editing existing promotion
    if (index != null) {
      _titleController.text = deals[index]['title'];
      _codeController.text = deals[index]['code'];
    } else {
      _titleController.clear();
      _codeController.clear();
    }

    // Show modal dialog with form for promotion details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        title: Text(
          index == null ? "New Promotion" : "Update Promotion",
          style: TextStyle(color: AppTheme.primaryTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPopupField("Deal Title", _titleController, context),
            const SizedBox(height: 10),
            _buildPopupField("Promo Code", _codeController, context),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor(context),
            ),
            // Save button with add/update logic
            onPressed: () {
              setState(() {
                if (index == null) {
                  // Add new promotion
                  deals.add({
                    "title": _titleController.text,
                    "discount": "NEW DEAL",
                    "code": _codeController.text,
                    "status": "Active",
                  });
                } else {
                  // Update existing promotion
                  deals[index]['title'] = _titleController.text;
                  deals[index]['code'] = _codeController.text;
                }
              });
              Navigator.pop(context);
            },
            child: Text("Confirm", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }

  // Delete promotion with confirmation feedback
  void _deleteDeal(int index) {
    String deletedTitle = deals[index]['title'];
    setState(() => deals.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$deletedTitle Deleted"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Text field widget for dialog form inputs
  Widget _buildPopupField(String hint, TextEditingController controller, BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.primaryTextColor(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
        filled: true,
        fillColor: AppTheme.primaryTextColor(context).withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Main build method with promotion management interface
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        // Custom app bar with promotional theme
        appBar: customTopBar(context, "Promotions & Deals"),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              // Safe space for the taller top bar
              const SizedBox(height: 120),

              // Create new promotion button with gradient styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _openPromotionDialog(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentColor(context), AppTheme.accentColor(context).withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor(context).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        const SizedBox(width: 10),
                        Text(
                          "Create New Promotion",
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Instructions for user interaction
              const SizedBox(height: 10),
              Text(
                "Long press to delete | Tap to edit",
                style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Scrollable list of promotional deals
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    bool isActive = deal['status'] == "Active";

                    // Individual promotion card with tap and long press handlers
                    return GestureDetector(
                      onTap: () => _openPromotionDialog(index: index), // Edit
                      onLongPress: () => _deleteDeal(index), // Delete
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (isActive ? Colors.orangeAccent : AppTheme.secondaryTextColor(context))
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deal['title'],
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Code: ${deal['code']}",
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  deal['discount'],
                                  style: TextStyle(
                                    color: AppTheme.accentColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isActive ? Colors.green : Colors.red)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    deal['status'],
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.red,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}