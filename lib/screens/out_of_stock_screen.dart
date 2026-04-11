// ============================================================
// StaffOutOfStockScreen - Stock availability manage karne ka screen
// Kaam:
//   1. Menu items ki availability dikhata hai (In Stock / Out of Stock)
//   2. Switch toggle karne par item available/unavailable hota hai
//   3. Item tap karne par name aur price edit kar sakte ho
//   4. Item long press karne par delete hota hai
//   5. Out of stock items par strikethrough text aur red border
//   6. Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   7. AppTheme methods se saare colors aur decorations milte hain
// Note: Local mock data - Firebase nahi use hota
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../standard_toolbar.dart';

class StaffOutOfStockScreen extends StatefulWidget {
  const StaffOutOfStockScreen({super.key});

  @override
  State<StaffOutOfStockScreen> createState() => _StaffOutOfStockScreenState();
}

class _StaffOutOfStockScreenState extends State<StaffOutOfStockScreen> {
  // Menu data: category -> list of items, each with name, price, and availability flag
  final Map<String, List<Map<String, dynamic>>> _menu = {
    'Burgers': [
      {'name': 'Zinger Burger', 'price': 450, 'available': true},
      {'name': 'Crispy Burger', 'price': 380, 'available': false},
      {'name': 'Double Patty', 'price': 550, 'available': true},
    ],
    'Pizza': [
      {'name': 'Margherita', 'price': 700, 'available': true},
      {'name': 'BBQ Chicken', 'price': 850, 'available': true},
    ],
    'Drinks': [
      {'name': 'Coke 500ml', 'price': 120, 'available': true},
      {'name': 'Sprite 500ml', 'price': 120, 'available': false},
      {'name': 'Mineral Water', 'price': 80, 'available': true},
    ],
    'Sides': [
      {'name': 'French Fries', 'price': 200, 'available': true},
      {'name': 'Coleslaw', 'price': 150, 'available': true},
    ],
  };

  // Opens edit dialog pre-filled with current item name and price
  void _showEditDialog(String category, int index) {
    final item = _menu[category]![index];
    final nameCtrl = TextEditingController(text: item['name']);
    final priceCtrl = TextEditingController(text: item['price'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.accentColor(context)),
        ),
        title: Text(
          'Edit Item',
          style: TextStyle(
            color: AppTheme.accentColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Item Name',
                labelStyle: TextStyle(
                  color: AppTheme.secondaryTextColor(context),
                ),
                prefixIcon: Icon(
                  Icons.fastfood,
                  color: AppTheme.accentColor(context),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.secondaryTextColor(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor(context)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Price (Rs)',
                labelStyle: TextStyle(
                  color: AppTheme.secondaryTextColor(context),
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: AppTheme.accentColor(context),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.secondaryTextColor(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor(context)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor(context),
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty &&
                  priceCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _menu[category]![index]['name'] = nameCtrl.text.trim();
                  _menu[category]![index]['price'] =
                      int.tryParse(priceCtrl.text) ?? item['price'];
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item updated!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color:
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).isDarkMode
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shows confirmation dialog before deleting an item from the category
  void _confirmDelete(String category, int index) {
    final name = _menu[category]![index]['name'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Item',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Delete "$name"?',
          style: TextStyle(color: AppTheme.primaryTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _menu[category]!.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$name" deleted'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 1),
                ),
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
        appBar: StandardToolbar.build(
          context,
          'Stock Management',
          actionIcon: Icons.inventory_2_outlined,
        ),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 110),
              Text(
                'Tap to edit  •  Long press to delete  •  Toggle availability',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
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
                        border: Border.all(
                          color: AppTheme.accentColor(
                            context,
                          ).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  color: AppTheme.accentColor(context),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  category.toUpperCase(),
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...items.asMap().entries.map((e) {
                            final i = e.key;
                            final item = e.value;
                            final available = item['available'] as bool;
                            return GestureDetector(
                              onTap: () => _showEditDialog(category, i),
                              onLongPress: () => _confirmDelete(category, i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor(
                                    context,
                                  ).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: available
                                        ? AppTheme.accentColor(
                                            context,
                                          ).withValues(alpha: 0.15)
                                        : Colors.redAccent.withValues(
                                            alpha: 0.3,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.fastfood_rounded,
                                      color: available
                                          ? AppTheme.accentColor(context)
                                          : Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              color: available
                                                  ? AppTheme.primaryTextColor(
                                                      context,
                                                    )
                                                  : AppTheme.secondaryTextColor(
                                                      context,
                                                    ),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              // Strikethrough text for out-of-stock items
                                              decoration: available
                                                  ? TextDecoration.none
                                                  : TextDecoration.lineThrough,
                                            ),
                                          ),
                                          Text(
                                            available
                                                ? 'In Stock'
                                                : 'Out of Stock',
                                            style: TextStyle(
                                              color: available
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Rs ${item['price']}',
                                      style: TextStyle(
                                        color: AppTheme.accentColor(context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: available,
                                      activeThumbColor: AppTheme.accentColor(
                                        context,
                                      ),
                                      activeTrackColor: AppTheme.accentColor(
                                        context,
                                      ).withValues(alpha: 0.3),
                                      inactiveThumbColor: Colors.redAccent,
                                      onChanged: (val) {
                                        setState(
                                          () =>
                                              _menu[category]![i]['available'] =
                                                  val,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${item['name']} is now ${val ? 'Available' : 'Out of Stock'}',
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
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
