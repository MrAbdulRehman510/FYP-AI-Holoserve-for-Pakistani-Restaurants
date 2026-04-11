// AdminPromotionsScreen - Promotions and discount deals management screen
// Responsibilities:
//   1. Displays a list of mock promotions with title, promo code, and discount
//   2. "Create New Promotion" button opens an add dialog
//   3. Tapping a promotion card opens an edit dialog pre-filled with its data
//   4. Long pressing a promotion card deletes it from the list
//   5. Tapping the status badge toggles between Active and Expired
// Note: All data is local mock data - resets when the app is closed

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class AdminPromotionsScreen extends StatefulWidget {
  const AdminPromotionsScreen({super.key});

  @override
  State<AdminPromotionsScreen> createState() => _AdminPromotionsScreenState();
}

class _AdminPromotionsScreenState extends State<AdminPromotionsScreen> {
  final _titleCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  final List<Map<String, dynamic>> _promotions = [
    {'title': 'Weekend Special', 'code': 'WKND20', 'discount': '20% OFF', 'status': 'Active'},
    {'title': 'Family Deal', 'code': 'FAM15', 'discount': '15% OFF', 'status': 'Active'},
    {'title': 'Happy Hour', 'code': 'HAPPY10', 'discount': '10% OFF', 'status': 'Expired'},
    {'title': 'Student Discount', 'code': 'STU25', 'discount': '25% OFF', 'status': 'Active'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _codeCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(int index) {
    final name = _promotions[index]['title'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Promotion', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Delete "$name"?', style: TextStyle(color: AppTheme.primaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _promotions.removeAt(index));
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

  // Opens add/edit dialog for a promotion
  // If index is null -> adding new promotion
  // If index is provided -> editing existing promotion at that index
  void _openDialog({int? index}) {
    _titleCtrl.text = index != null ? _promotions[index]['title'] : '';
    _codeCtrl.text = index != null ? _promotions[index]['code'] : '';
    _discountCtrl.text = index != null ? _promotions[index]['discount'] : '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(index == null ? 'New Promotion' : 'Update Promotion', style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_titleCtrl, 'Deal Title', Icons.title),
            const SizedBox(height: 12),
            _field(_codeCtrl, 'Promo Code', Icons.confirmation_number),
            const SizedBox(height: 12),
            _field(_discountCtrl, 'Discount (e.g. 20% OFF)', Icons.discount_outlined),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor(context)),
            onPressed: () {
              if (_titleCtrl.text.trim().isNotEmpty && _codeCtrl.text.trim().isNotEmpty && _discountCtrl.text.trim().isNotEmpty) {
                setState(() {
                  final item = {'title': _titleCtrl.text.trim(), 'code': _codeCtrl.text.trim(), 'discount': _discountCtrl.text.trim(), 'status': 'Active'};
                  if (index == null) {
                    _promotions.add(item);      // New promotion - append
                  } else {
                    _promotions[index] = item;  // Edit - replace at index
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

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppTheme.primaryTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
        prefixIcon: Icon(icon, color: AppTheme.accentColor(context)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor(context))),
      ),
    );
  }

  PreferredSizeWidget _topBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.arrow_back, color: AppTheme.primaryTextColor(context)), onPressed: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                Text('Promotions & Deals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.stars_rounded, color: AppTheme.accentColor(context)),
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
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _openDialog(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: AppTheme.accentColor(context), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: themeProvider.isDarkMode ? Colors.black : Colors.white),
                        const SizedBox(width: 10),
                        Text('Create New Promotion', style: TextStyle(color: themeProvider.isDarkMode ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('Tap to edit | Long press to delete', style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _promotions.length,
                  itemBuilder: (context, index) {
                    final p = _promotions[index];
                    final isActive = p['status'] == 'Active';
                    return GestureDetector(
                      onTap: () => _openDialog(index: index),
                      onLongPress: () => _confirmDelete(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: (isActive ? Colors.orangeAccent : AppTheme.secondaryTextColor(context)).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['title'], style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text('Code: ${p['code']}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 14)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(p['discount'], style: TextStyle(color: AppTheme.accentColor(context), fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  // Tap status badge to toggle Active <-> Expired
                                  onTap: () => setState(() => _promotions[index]['status'] = isActive ? 'Expired' : 'Active'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: (isActive ? Colors.green : Colors.red).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(5)),
                                    child: Text(p['status'], style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
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
