// AIRecommendationsScreen - AI strategy rules management screen
// Responsibilities:
//   1. Displays a list of AI recommendation rules (trigger item -> suggested items)
//   2. Manual add: user types a trigger and comma-separated suggestions, then saves
//   3. AI generate: tapping the star icon picks a random suggestion from the pool
//      and fills the input fields - user can edit before saving
//   4. Tapping a rule card opens an edit dialog pre-filled with current values
//   5. Delete icon on each rule removes it from the list
// Example Rule: "Pizza" triggers suggestions ["Garlic Bread", "Dip", "Sprite"]
// Note: All data is local mock data - no Firebase connection used

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../theme_provider.dart';
import '../app_theme.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final _itemCtrl = TextEditingController();
  final _suggestCtrl = TextEditingController();

  // Active AI rules: each rule has a trigger item and a list of suggested items
  final List<Map<String, dynamic>> _rules = [
    {'trigger': 'Zinger Burger', 'suggest': ['Fries', 'Coke', 'Coleslaw']},
    {'trigger': 'Pizza', 'suggest': ['Garlic Bread', 'Dip', 'Sprite']},
    {'trigger': 'Chicken Tikka', 'suggest': ['Naan', 'Mint Chutney', 'Salad']},
    {'trigger': 'Coffee', 'suggest': ['Croissant', 'Chocolate Cookie']},
  ];

  // Pre-defined AI suggestions pool - randomly picked when user taps the AI icon
  final _aiSuggestions = [
    {'trigger': 'Zinger Burger', 'suggest': 'Fries, Coke, Coleslaw'},
    {'trigger': 'Pizza', 'suggest': 'Garlic Bread, Dip, Sprite'},
    {'trigger': 'Chicken Tikka', 'suggest': 'Naan, Mint Chutney, Salad'},
    {'trigger': 'Coffee', 'suggest': 'Croissant, Chocolate Cookie'},
    {'trigger': 'Pasta', 'suggest': 'Extra Cheese, White Sauce'},
  ];

  @override
  void dispose() {
    _itemCtrl.dispose();
    _suggestCtrl.dispose();
    super.dispose();
  }

  // Picks a random suggestion from _aiSuggestions and fills the input fields
  // User can then edit before saving as a new rule
  void _generateAI() {
    final pick = _aiSuggestions[Random().nextInt(_aiSuggestions.length)];
    setState(() {
      _itemCtrl.text = pick['trigger']!;
      _suggestCtrl.text = pick['suggest']!;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('AI Suggestion loaded! You can edit before saving.'), backgroundColor: AppTheme.accentColor(context), duration: const Duration(seconds: 2)),
    );
  }

  // Saves the current input fields as a new rule
  // Splits the suggest field by comma to build the suggestions list
  void _saveRule() {
    if (_itemCtrl.text.isEmpty || _suggestCtrl.text.isEmpty) return;
    setState(() {
      _rules.add({
        'trigger': _itemCtrl.text.trim(),
        // Split comma-separated suggestions into a list and trim whitespace
        'suggest': _suggestCtrl.text.split(',').map((e) => e.trim()).toList()
      });
      _itemCtrl.clear();
      _suggestCtrl.clear();
    });
  }

  void _confirmDelete(int index) {
    final name = _rules[index]['trigger'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Rule', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Delete "$name" rule?', style: TextStyle(color: AppTheme.primaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _rules.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$name" deleted'), backgroundColor: Colors.red, duration: const Duration(seconds: 1)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Opens edit dialog for an existing rule - pre-fills fields with current values
  void _showEditDialog(int index) {
    final triggerCtrl = TextEditingController(text: _rules[index]['trigger']);
    // Join list back to comma-separated string for editing
    final suggestCtrl = TextEditingController(text: (_rules[index]['suggest'] as List).join(', '));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.accentColor(ctx))),
        title: Text('Edit Rule', style: TextStyle(color: AppTheme.accentColor(ctx), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(triggerCtrl, 'Trigger (e.g. Pizza)', ctx),
            const SizedBox(height: 10),
            _buildField(suggestCtrl, 'Suggest (e.g. Coke, Fries)', ctx),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor(ctx)),
            onPressed: () {
              if (triggerCtrl.text.trim().isNotEmpty && suggestCtrl.text.trim().isNotEmpty) {
                setState(() => _rules[index] = {'trigger': triggerCtrl.text.trim(), 'suggest': suggestCtrl.text.split(',').map((e) => e.trim()).toList()});
                Navigator.pop(ctx);
              }
            },
            child: Text('Save', style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, BuildContext ctx) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppTheme.primaryTextColor(ctx)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(ctx), fontSize: 14),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryTextColor(ctx).withValues(alpha: 0.1))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor(ctx))),
      ),
    );
  }

  PreferredSizeWidget _topBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryTextColor(context), size: 18), onPressed: () => Navigator.pop(context)),
                Text('AI Strategy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                IconButton(icon: Icon(Icons.auto_awesome, color: AppTheme.accentColor(context)), onPressed: _generateAI, tooltip: 'Get AI Suggestion'),
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
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.backgroundFilter(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 110),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildField(_itemCtrl, 'Trigger (e.g. Pizza)', context),
                        const SizedBox(height: 10),
                        _buildField(_suggestCtrl, 'Suggest (e.g. Coke, Fries)', context),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveRule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor(context),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('SAVE RULE', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Live Recommendations', style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _rules.length,
                  itemBuilder: (context, index) {
                    final r = _rules[index];
                    return GestureDetector(
                      onTap: () => _showEditDialog(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTextColor(context).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(r['trigger'], style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold)),
                          subtitle: Text('Suggests: ${(r['suggest'] as List).join(', ')}', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                            onPressed: () => _confirmDelete(index),
                          ),
                        ),
                      ),
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
}
