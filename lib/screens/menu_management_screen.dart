// Menu Management Screen - Firebase-integrated menu and category management system
// Provides functionality to add categories, create/edit menu items, and manage restaurant menu
// Includes real-time Firebase synchronization and dynamic category-based organization

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore for data management
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Theme management provider
import '../app_theme.dart'; // App-wide theme constants and styles
import '../standard_toolbar.dart'; // Standardized toolbar component

// StatefulWidget for Menu Management with Firebase integration
class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

// State class for Menu Management with Firebase operations
class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // Method to add new category to Firebase with validation
  // Shows dialog for category name input and saves to Firestore
  Future<void> _addNewCategory() async {
    TextEditingController catCtrl =
        TextEditingController(); // Category name controller
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1C), // Dark dialog background
        title: const Text(
          "Add New Category", // Dialog title
          style: TextStyle(color: Color(0xFF00E5FF)), // Accent color title
        ),
        content: TextField(
          controller: catCtrl, // Text controller for category name
          style: const TextStyle(color: Colors.white), // White text color
          decoration: const InputDecoration(
            hintText: "Category Name (e.g. Pizza)", // Placeholder text
            hintStyle: TextStyle(color: Colors.white24), // Light hint color
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          // Add category button
          ElevatedButton(
            onPressed: () async {
              if (catCtrl.text.isNotEmpty) {
                // Validate input
                // Save category to Firebase
                await FirebaseFirestore.instance
                    .collection('categories') // Categories collection
                    .doc(
                      catCtrl.text.trim(),
                    ) // Use category name as document ID
                    .set({
                      'name': catCtrl.text.trim(), // Category name
                      'timestamp':
                          FieldValue.serverTimestamp(), // Creation timestamp
                    });
                // Close dialog if widget is still mounted
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add"), // Button text
          ),
        ],
      ),
    );
  }

  // Method to create new menu item or update existing item in Firebase
  // Handles both creation and editing operations based on docId parameter
  Future<void> updateOrCreateItem(
    String? docId, // Document ID for editing (null for new item)
    String category, // Category name for the item
    String name, // Item name
    int price, // Item price
  ) async {
    if (docId != null) {
      // Update existing item
      await FirebaseFirestore.instance.collection('menu').doc(docId).update({
        'name': name, // Updated item name
        'price': price, // Updated item price
      });
    } else {
      // Create new item
      await FirebaseFirestore.instance.collection('menu').add({
        'name': name, // Item name
        'price': price, // Item price
        'category': category, // Category assignment
        'available': true, // Default availability status
        'timestamp': FieldValue.serverTimestamp(), // Creation timestamp
      });
    }
  }

  // Dialog for editing or adding menu items with form validation
  // Shows themed dialog with name and price input fields
  void showEditDialog({
    String? docId, // Document ID for editing (null for new item)
    required String category, // Category for the item
    String oldName = "", // Existing name for editing
    int oldPrice = 0, // Existing price for editing
  }) {
    // Text controllers with existing values for editing
    TextEditingController nameCtrl = TextEditingController(text: oldName);
    TextEditingController priceCtrl = TextEditingController(
      text: oldPrice == 0 ? "" : oldPrice.toString(), // Empty for new items
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1C), // Dark dialog background
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xFF00E5FF),
            width: 1,
          ), // Accent border
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        title: Text(
          docId == null
              ? "Add Item to $category"
              : "Edit Item", // Dynamic title
          style: const TextStyle(
            color: Color(0xFF00E5FF),
          ), // Accent color title
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Minimum height for content
          children: [
            // Item name input field
            TextField(
              controller: nameCtrl, // Name controller
              style: const TextStyle(color: Colors.white), // White text
              decoration: const InputDecoration(
                labelText: "Name", // Field label
                labelStyle: TextStyle(
                  color: Colors.white60,
                ), // Light label color
              ),
            ),
            // Item price input field
            TextField(
              controller: priceCtrl, // Price controller
              style: const TextStyle(color: Colors.white), // White text
              decoration: const InputDecoration(
                labelText: "Price", // Field label
                labelStyle: TextStyle(
                  color: Colors.white60,
                ), // Light label color
              ),
              keyboardType: TextInputType.number, // Numeric keyboard
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Close dialog
            child: const Text("Back", style: TextStyle(color: Colors.white54)),
          ),
          // Save button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF), // Accent background
            ),
            onPressed: () async {
              // Validate inputs before saving
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                await updateOrCreateItem(
                  docId, // Document ID (null for new)
                  category, // Category name
                  nameCtrl.text, // Item name
                  int.parse(priceCtrl.text), // Item price
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext); // Close dialog
                }
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.black),
            ), // Button text
          ),
        ],
      ),
    );
  }

  // Reusable widget for building menu item tiles with edit/delete functionality
  // Creates styled list tiles for each menu item with action buttons
  Widget buildItemTile(
    String name, // Item name
    int price, // Item price
    String category, { // Item category
    String? docId, // Document ID for Firebase operations
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2), // Vertical spacing
          decoration: BoxDecoration(
            color: AppTheme.secondaryTextColor(
              context,
            ).withValues(alpha: 0.05), // Light background
          ),
          child: ListTile(
            // Food icon
            leading: Icon(
              Icons.fastfood_rounded,
              color: AppTheme.accentColor(context),
              size: 18,
            ),
            // Item name as title
            title: Text(
              name,
              style: TextStyle(
                color: AppTheme.primaryTextColor(context),
                fontSize: 14,
              ),
            ),
            // Item price as subtitle
            subtitle: Text(
              "Rs $price", // Price with currency
              style: TextStyle(
                color: AppTheme.secondaryTextColor(context),
                fontSize: 12,
              ),
            ),
            // Action buttons (edit and delete)
            trailing: Wrap(
              children: [
                // Edit button
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppTheme.accentColor(context),
                    size: 18,
                  ),
                  onPressed: () => showEditDialog(
                    docId: docId, // Pass document ID for editing
                    category: category, // Pass category
                    oldName: name, // Pass existing name
                    oldPrice: price, // Pass existing price
                  ),
                ),
                // Delete button (only for existing items)
                if (docId != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent, // Red color for delete
                      size: 18,
                    ),
                    onPressed: () => FirebaseFirestore.instance
                        .collection('menu')
                        .doc(docId)
                        .delete(), // Delete item from Firebase
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Main build method - Creates the complete menu management interface
  @override
  Widget build(BuildContext context) {
    // Consumer for ThemeProvider to access theme settings
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(
            context,
          ), // Theme-based background
          extendBodyBehindAppBar: true, // Allow body to extend behind app bar
          appBar: StandardToolbar.build(
            context,
            "Menu Management", // Screen title
            actionIcon: Icons.restaurant_menu, // Menu icon
          ),
          body: Container(
            decoration: AppTheme.backgroundFilter(
              context,
            ), // Background decoration
            child: Column(
              children: [
                const SizedBox(height: 110), // Space for app bar
                // Add New Category Button - Full width button at top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: _addNewCategory, // Call add category method
                    child: Container(
                      width: double.infinity, // Full width
                      height: 48, // Fixed height
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor(
                          context,
                        ), // Theme accent color
                        borderRadius: BorderRadius.circular(
                          25,
                        ), // Rounded corners
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Add New Category", // Button text
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Menu Categories and Items List - Firebase StreamBuilder
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('categories') // Categories collection
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> catSnapshot) {
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('menu') // Menu items collection
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> menuSnapshot) {
                          // Show loading indicator while fetching data
                          if (!catSnapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accentColor(context),
                              ),
                            );
                          }

                          // Create display map for organizing items by category
                          Map<String, List<Widget>> displayMap = {};

                          // Initialize categories
                          for (var doc in catSnapshot.data!.docs) {
                            displayMap[doc.id] =
                                []; // Empty list for each category
                          }

                          // Populate categories with menu items
                          if (menuSnapshot.hasData) {
                            for (var doc in menuSnapshot.data!.docs) {
                              var data = doc.data() as Map<String, dynamic>;
                              String cat =
                                  data['category'] ??
                                  'Others'; // Default category
                              if (displayMap.containsKey(cat)) {
                                displayMap[cat]!.add(
                                  buildItemTile(
                                    data['name'], // Item name
                                    data['price'], // Item price
                                    cat, // Category
                                    docId: doc.id, // Document ID
                                  ),
                                );
                              }
                            }
                          }

                          // Build expandable category list
                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            children: displayMap.keys.map((category) {
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ), // Space between categories
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor(
                                    context,
                                  ), // Theme-based card color
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Rounded corners
                                  border: Border.all(
                                    color: AppTheme.secondaryTextColor(
                                      context,
                                    ).withValues(alpha: 0.1), // Subtle border
                                  ),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    category, // Category name
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    ...displayMap[category]!, // Category items
                                    // Add Item Button for each category
                                    TextButton.icon(
                                      onPressed: () => showEditDialog(
                                        category: category,
                                      ), // Add new item to category
                                      icon: Icon(
                                        Icons.add,
                                        color: AppTheme.accentColor(context),
                                      ),
                                      label: Text(
                                        "Add Item", // Button text
                                        style: TextStyle(
                                          color: AppTheme.accentColor(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
