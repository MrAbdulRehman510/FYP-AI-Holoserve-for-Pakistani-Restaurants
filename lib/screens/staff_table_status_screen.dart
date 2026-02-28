// Staff Table Status Screen - Real-time table management for restaurant staff
// Displays table occupancy status with Firebase integration and test data generation
// Features interactive table grid with status toggling and wait time estimation

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';

// StatefulWidget for managing table status and occupancy
class StaffTableStatusScreen extends StatefulWidget {
  const StaffTableStatusScreen({super.key});

  @override
  State<StaffTableStatusScreen> createState() => _StaffTableStatusScreenState();
}

// State class managing table data and Firebase operations
class _StaffTableStatusScreenState extends State<StaffTableStatusScreen> {
  // Generate test table data for demonstration purposes
  Future<void> _generateTestTables() async {
    final CollectionReference tables = FirebaseFirestore.instance.collection(
      'tables',
    );

    // Sample table data with different statuses and seating capacities
    List<Map<String, dynamic>> dummyTables = [
      {'id': 'Table 01', 'seats': 2, 'status': 'Free'},
      {'id': 'Table 02', 'seats': 4, 'status': 'Occupied'},
      {'id': 'Table 03', 'seats': 2, 'status': 'Reserved'},
      {'id': 'Table 04', 'seats': 6, 'status': 'Free'},
      {'id': 'Table 05', 'seats': 4, 'status': 'Occupied'},
      {'id': 'Table 06', 'seats': 8, 'status': 'Free'},
    ];

    // Add each table to Firebase collection
    for (var table in dummyTables) {
      await tables.doc(table['id']).set(table);
    }

    // Show success feedback to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("6 Test Tables Generated Successfully!")),
      );
    }
  }

  // Toggle table status between Free -> Occupied -> Reserved -> Free
  Future<void> _toggleTableStatus(String docId, String currentStatus) async {
    String nextStatus;
    if (currentStatus == "Free") {
      nextStatus = "Occupied";
    } else if (currentStatus == "Occupied") {
      nextStatus = "Reserved";
    } else {
      nextStatus = "Free";
    }

    // Update table status in Firebase
    await FirebaseFirestore.instance.collection('tables').doc(docId).update({
      'status': nextStatus,
    });
  }

  // Custom app bar with table management theme and test data button
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
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
                    size: 20,
                  ),
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
                // Test data generation button in app bar
                IconButton(
                  icon: Icon(
                    Icons.add_business,
                    color: AppTheme.accentColor(context),
                  ),
                  onPressed: _generateTestTables,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main build method with Firebase streaming for real-time table status
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        extendBodyBehindAppBar: true,
        // Custom app bar with table management features
        appBar: customTopBar(context, "Table Management"),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          // Firebase stream for real-time table status updates
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tables')
                .orderBy('id')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AppTheme.accentColor(context)),
                );
              }

              // Show empty state with generation option if no tables exist
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Tables Found!",
                        style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _generateTestTables,
                        child: const Text("Generate Tables Now"),
                      ),
                    ],
                  ),
                );
              }

              var tableDocs = snapshot.data!.docs;
              // Calculate estimated wait time based on occupied tables
              int occupiedCount = tableDocs
                  .where((d) => d['status'] == 'Occupied')
                  .length;
              int waitTime = occupiedCount * 10; // 10 minutes per occupied table

              return Column(
                children: [
                  const SizedBox(height: 120), // Space for custom app bar
                  _buildWaitTimeCard(waitTime, context),
                  // Interactive table grid with status indicators
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: tableDocs.length,
                      itemBuilder: (context, index) {
                        var data =
                            tableDocs[index].data() as Map<String, dynamic>;
                        String docId = tableDocs[index].id;
                        String status = data['status'] ?? "Free";

                        // Determine status-based styling
                        Color statusColor;
                        IconData statusIcon;

                        if (status == "Occupied") {
                          statusColor = Colors.redAccent;
                          statusIcon = Icons.person_pin;
                        } else if (status == "Reserved") {
                          statusColor = Colors.orangeAccent;
                          statusIcon = Icons.event_seat;
                        } else {
                          statusColor = Colors.greenAccent;
                          statusIcon = Icons.check_circle_outline;
                        }

                        // Individual table card with tap-to-toggle functionality
                        return GestureDetector(
                          onTap: () => _toggleTableStatus(docId, status),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(statusIcon, size: 35, color: statusColor),
                                const SizedBox(height: 8),
                                Text(
                                  data['id'] ?? 'N/A',
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "${data['seats']} Seats",
                                  style: TextStyle(
                                    color: AppTheme.secondaryTextColor(context),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Status badge with color coding
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Wait time estimation card widget
  Widget _buildWaitTimeCard(int time, BuildContext context) {
    return Container(
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
              Text(
                "Estimated Wait Time",
                style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12),
              ),
              Text(
                "$time Minutes",
                style: TextStyle(
                  color: AppTheme.primaryTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}