// Admin Recommendations Screen - AI-powered menu recommendation system
// Allows admins to create and manage AI-driven food pairing suggestions
// Features auto-generation of recommendations and Firebase integration

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For random AI suggestions
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for managing AI recommendation rules
class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

// State class managing recommendation logic and form inputs
class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  // Text controllers for recommendation form inputs
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _suggestController = TextEditingController();
  bool _isSaving = false;

  // Generate AI-powered recommendation suggestions automatically
  void _generateAIRecommendation() {
    // Predefined AI food pairing suggestions for realistic recommendations
    final List<Map<String, String>> aiSuggestions = [
      {'trigger': 'Zinger Burger', 'suggest': 'Fries, Coke, Coleslaw'},
      {'trigger': 'Pizza', 'suggest': 'Garlic Bread, Dip, Sprite'},
      {'trigger': 'Chicken Tikka', 'suggest': 'Naan, Mint Chutney, Salad'},
      {'trigger': 'Coffee', 'suggest': 'Croissant, Chocolate Cookie'},
      {'trigger': 'Pasta', 'suggest': 'Extra Cheese, White Sauce'},
    ];

    // Randomly select and populate form with AI suggestion
    final random = Random();
    final pick = aiSuggestions[random.nextInt(aiSuggestions.length)];

    setState(() {
      _itemController.text = pick['trigger']!;
      _suggestController.text = pick['suggest']!;
    });

    // Show confirmation feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("AI Suggestion loaded! You can edit before saving."),
        backgroundColor: AppTheme.accentColor(context),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Custom app bar with AI theme and auto-suggestion button
  PreferredSizeWidget customTopBar(BuildContext context, String title) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(),
                // AI auto-suggestion button in app bar
                IconButton(
                  icon: Icon(
                    Icons.auto_awesome,
                    color: AppTheme.accentColor(context),
                  ),
                  onPressed: _generateAIRecommendation,
                  tooltip: "Get AI Suggestion",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with recommendation management interface
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        // Enable keyboard resize to prevent overflow
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: customTopBar(context, "AI Strategy"),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 110),

                // Recommendation input form section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentColor(context).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(_itemController, "Trigger (e.g. Pizza)", context),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _suggestController,
                          "Suggest (e.g. Coke, Fries)",
                          context,
                        ),
                        const SizedBox(height: 20),
                        // Save recommendation button
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveRule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor(context),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "SAVE RULE",
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Live Recommendations",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Live recommendations list from Firebase
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('recommendations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentColor(context),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    // Show empty state if no recommendations exist
                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          "No rules found in Database",
                          style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                        ),
                      );
                    }

                    // Build list of recommendation rules
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var data = docs[index].data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTextColor(context).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              data['triggerItem'] ?? '',
                              style: TextStyle(
                                color: AppTheme.accentColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Suggests: ${(data['suggest'] as List).join(', ')}",
                              style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                            ),
                            // Delete recommendation button
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_sweep,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => docs[index].reference.delete(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text field widget for recommendation form inputs
  Widget _buildTextField(TextEditingController controller, String label, BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppTheme.primaryTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 14),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryTextColor(context).withValues(alpha: 0.1)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentColor(context)),
        ),
      ),
    );
  }

  // Save recommendation rule to Firebase with validation
  Future<void> _saveRule() async {
    if (_itemController.text.isEmpty || _suggestController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      // Save to Firebase with structured data
      await FirebaseFirestore.instance.collection('recommendations').add({
        'triggerItem': _itemController.text.trim(),
        'suggest': _suggestController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Clear form after successful save
      _itemController.clear();
      _suggestController.clear();
    } finally {
      setState(() => _isSaving = false);
    }
  }
}