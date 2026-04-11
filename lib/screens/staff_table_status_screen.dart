// ============================================================
// StaffTableStatusScreen - Tables ki status manage karne ka screen
// Kaam:
//   1. 6 tables ka grid dikhata hai
//   2. Table tap karne par status cycle hoti hai:
//      Free -> Occupied -> Reserved -> Free
//   3. Estimated wait time calculate hoti hai (occupied tables * 10 min)
//   4. Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   5. AppTheme methods se saare colors aur decorations milte hain
// Table Status Colors:
//   - Free     -> green
//   - Occupied -> red
//   - Reserved -> orange
// Note: Local mock data - Firebase nahi use hota
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

class StaffTableStatusScreen extends StatefulWidget {
  const StaffTableStatusScreen({super.key});

  @override
  State<StaffTableStatusScreen> createState() => _StaffTableStatusScreenState();
}

class _StaffTableStatusScreenState extends State<StaffTableStatusScreen> {
  // Table list - each table has an id, seat count, and current status
  final List<Map<String, dynamic>> _tables = [
    {'id': 'Table 01', 'seats': 2, 'status': 'Free'},
    {'id': 'Table 02', 'seats': 4, 'status': 'Occupied'},
    {'id': 'Table 03', 'seats': 2, 'status': 'Reserved'},
    {'id': 'Table 04', 'seats': 6, 'status': 'Free'},
    {'id': 'Table 05', 'seats': 4, 'status': 'Occupied'},
    {'id': 'Table 06', 'seats': 8, 'status': 'Free'},
  ];

  // Cycles table status on each tap: Free -> Occupied -> Reserved -> Free
  void _toggleStatus(int index) {
    setState(() {
      final current = _tables[index]['status'];
      if (current == 'Free') {
        _tables[index]['status'] = 'Occupied';
      } else if (current == 'Occupied') {
        _tables[index]['status'] = 'Reserved';
      } else {
        _tables[index]['status'] = 'Free'; // Reserved -> back to Free
      }
    });
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
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryTextColor(context), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Text('Table Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTextColor(context))),
                const Spacer(),
                Icon(Icons.table_restaurant, color: AppTheme.accentColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Estimated wait = occupied tables * 10 minutes (simple mock formula)
    final occupiedCount = _tables.where((t) => t['status'] == 'Occupied').length;
    final waitTime = occupiedCount * 10;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _topBar(context),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 120),
              // Wait time card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.accentColor(context).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time_filled, color: AppTheme.accentColor(context)),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimated Wait Time', style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12)),
                        Text('$waitTime Minutes', style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.0,
                  ),
                  itemCount: _tables.length,
                  itemBuilder: (context, index) {
                    final t = _tables[index];
                    final status = t['status'] as String;
                    // Pick icon and color based on table status
                    Color statusColor;
                    IconData statusIcon;
                    if (status == 'Occupied') {
                      statusColor = Colors.redAccent;    // Red = someone is sitting
                      statusIcon = Icons.person_pin;
                    } else if (status == 'Reserved') {
                      statusColor = Colors.orangeAccent; // Orange = booked ahead
                      statusIcon = Icons.event_seat;
                    } else {
                      statusColor = Colors.greenAccent;  // Green = available
                      statusIcon = Icons.check_circle_outline;
                    }

                    return GestureDetector(
                      onTap: () => _toggleStatus(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 2),
                          boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.1), blurRadius: 8)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(statusIcon, size: 35, color: statusColor),
                            const SizedBox(height: 8),
                            Text(t['id'], style: TextStyle(color: AppTheme.primaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('${t['seats']} Seats', style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                              child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
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
