// MenuManagementScreen - Menu categories and items management screen
// Responsibilities:
//   1. Displays all menu categories with their items and prices
//   2. "Add New Category" button creates a new empty category
//   3. "Add Item" button inside each category adds a new item
//   4. Tapping an item opens an edit dialog to update name and price
//   5. Long pressing an item deletes it from the category
//   6. The delete_sweep icon on a category header removes the entire category
//   7. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   8. AppTheme methods provide all colors and decorations for theme consistency
// Note: All data is local mock data - resets when the app is closed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../standard_toolbar.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // Menu data structure: category name -> list of items (each item has name and price)
  // This is local mock data - resets when the app is closed
  final Map<String, List<Map<String, dynamic>>> _menu = {
    'Burgers': [
      {'name': 'Zinger Burger', 'price': 450},
      {'name': 'Crispy Burger', 'price': 380},
      {'name': 'Double Patty', 'price': 550},
    ],
    'Pizza': [
      {'name': 'Margherita', 'price': 700},
      {'name': 'BBQ Chicken', 'price': 850},
    ],
    'Drinks': [
      {'name': 'Coke 500ml', 'price': 120},
      {'name': 'Sprite 500ml', 'price': 120},
      {'name': 'Mineral Water', 'price': 80},
    ],
    'Sides': [
      {'name': 'French Fries', 'price': 200},
      {'name': 'Coleslaw', 'price': 150},
    ],
  };

  // Opens a dialog to add a new category - adds empty item list under that category name
  void _addCategory() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New Category', style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: AppTheme.primaryTextColor(context)),
          decoration: InputDecoration(
            hintText: 'Category Name',
            hintStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
            prefixIcon: Icon(Icons.category, color: AppTheme.accentColor(context)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor(context))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(context)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor(context)),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _menu[ctrl.text.trim()] = []);
                Navigator.pop(ctx);
              }
            },
            child: Text('Add', style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Colors.black : Colors.white)),
          ),
        ],
      ),
    );
  }

  // Opens add/edit dialog for a menu item
  // If index is null -> adding new item to category
  // If index is provided -> editing existing item at that index
  void _showItemDialog({required String category, int? index}) {
    final nameCtrl = TextEditingController(text: index != null ? _menu[category]![index]['name'] : '');
    final priceCtrl = TextEditingController(text: index != null ? _menu[category]![index]['price'].toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.accentColor(context))),
        title: Text(index == null ? 'Add Item to $category' : 'Edit Item', style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Item Name',
                labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                prefixIcon: Icon(Icons.fastfood, color: AppTheme.accentColor(context)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor(context))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Price (Rs)',
                labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                prefixIcon: Icon(Icons.attach_money, color: AppTheme.accentColor(context)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor(context))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor(context)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  final item = {'name': nameCtrl.text.trim(), 'price': int.tryParse(priceCtrl.text) ?? 0};
                  if (index == null) {
                    _menu[category]!.add(item);      // New item - append to list
                  } else {
                    _menu[category]![index] = item;  // Edit - replace at index
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: Text('Save', style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Colors.black : Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(String category, int index) {
    final name = _menu[category]![index]['name'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Delete "$name"?', style: TextStyle(color: AppTheme.primaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _menu[category]!.removeAt(index));
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

  void _confirmDeleteCategory(String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Delete "$category" and all its items?', style: TextStyle(color: AppTheme.primaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _menu.remove(category));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$category" deleted'), backgroundColor: Colors.red, duration: const Duration(seconds: 1)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        extendBodyBehindAppBar: true,
        appBar: StandardToolbar.build(context, 'Menu Management', actionIcon: Icons.restaurant_menu),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 110),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _addCategory,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppTheme.accentColor(context), borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: themeProvider.isDarkMode ? Colors.black : Colors.white),
                        const SizedBox(width: 10),
                        Text('Add New Category', style: TextStyle(color: themeProvider.isDarkMode ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Tap item to edit | Long press to delete', style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: _menu.entries.map((entry) {
                    final category = entry.key;
                    final items = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                            child: Row(
                              children: [
                                Icon(Icons.folder_open, color: AppTheme.accentColor(context), size: 20),
                                const SizedBox(width: 10),
                                Text(category.toUpperCase(), style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20),
                                  onPressed: () => _confirmDeleteCategory(category),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...items.asMap().entries.map((e) {
                            final i = e.key;
                            final item = e.value;
                            return GestureDetector(
                              onTap: () => _showItemDialog(category: category, index: i),
                              onLongPress: () => _confirmDeleteItem(category, i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor(context).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.15)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.fastfood_rounded, color: AppTheme.accentColor(context), size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(item['name'], style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 14, fontWeight: FontWeight.w500))),
                                    Text('Rs ${item['price']}', style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () => _showItemDialog(category: category),
                            icon: Icon(Icons.add, color: AppTheme.accentColor(context)),
                            label: Text('Add Item', style: TextStyle(color: AppTheme.accentColor(context))),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
