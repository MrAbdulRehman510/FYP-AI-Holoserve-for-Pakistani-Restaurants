// Analytics Dashboard Screen - Comprehensive business analytics with real-time data
// Displays hologram status, AI recommendations, alerts, charts, and activity logs
// Integrates with Firebase for live data streaming and test data generation

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

// Screen imports for navigation
import 'admin_promotions_screen.dart';
import 'customer_feedback_screen.dart';
import 'system_settings_screen.dart';
import 'admin_recommendations_screen.dart';
import 'alert_admin_screen.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../standard_toolbar.dart';

// StatefulWidget for Analytics Dashboard with real-time data updates
class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

// State class managing analytics data and UI interactions
class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  // Generate test data for analytics demonstration
  void seedData() async {
    var logs = FirebaseFirestore.instance.collection('logs');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generating Test Data..."),
        duration: Duration(seconds: 1),
      ),
    );

    for (int i = 0; i < 5; i++) {
      await logs.add({
        'type': 'view',
        'item_name': i % 2 == 0 ? 'Zinger' : 'Crispy Box',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Glass morphism decoration for cards with theme-based styling
  BoxDecoration _glassDecoration(BuildContext context) {
    return BoxDecoration(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppTheme.primaryTextColor(context).withValues(alpha: 0.1)),
    );
  }

  // Main build method with Firebase streaming and analytics display
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        appBar: StandardToolbar.build(
          context,
          "Business Analytics",
          actionIcon: Icons.auto_fix_high,
          onActionPressed: seedData,
        ),
        // Firebase stream for real-time analytics data
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('logs')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor(context)),
              );
            }

            // Process logs data for analytics calculations
            var logs = snapshot.data?.docs ?? [];
            Map<String, int> itemViewCount = {}; // Track menu item views
            Map<int, int> peakHoursCount = { // Track hourly activity
              for (var i in Iterable.generate(24)) i: 0,
            };

            // Process each log entry for analytics data
            for (var doc in logs) {
              var data = doc.data() as Map<String, dynamic>;
              String name = data['item_name'] ?? 'Unknown';
              Timestamp? ts = data['timestamp'] as Timestamp?;
              if (ts != null) {
                peakHoursCount[ts.toDate().hour] =
                    (peakHoursCount[ts.toDate().hour] ?? 0) + 1;
              }
              if (data['type'] == 'view') {
                itemViewCount[name] = (itemViewCount[name] ?? 0) + 1;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Device Live Status", context),
                  _buildHologramStatusCard(context),
                  const SizedBox(height: 20),

                  // --- NEW: AI & ALERTS LIVE CARDS ---
                  Row(
                    children: [
                      Expanded(child: _buildAIRecommendationCard(context)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildLiveAlertsCard(context)),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Menu Performance (Views)", context),
                  _buildBarChart(itemViewCount, context),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Customer Satisfaction", context),
                  _buildFeedbackSummaryCard(context),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Peak Activity Hours", context),
                  _buildLineChart(peakHoursCount, context),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Recent Activity Logs", context),
                  _buildActivityList(logs, context),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // AI recommendation summary card with Firebase stream
  Widget _buildAIRecommendationCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recommendations')
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: _glassDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology, color: AppTheme.accentColor(context), size: 30),
              const SizedBox(height: 10),
              Text(
                "AI Strategies",
                style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12),
              ),
              Text(
                "$count Active",
                style: TextStyle(
                  color: AppTheme.primaryTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Live alerts summary card with real-time count
  Widget _buildLiveAlertsCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: _glassDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.bolt,
                color: count > 0 ? Colors.orangeAccent : Colors.greenAccent,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                "System Alerts",
                style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12),
              ),
              Text(
                "$count Active",
                style: TextStyle(
                  color: AppTheme.primaryTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section title widget with accent color styling
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.accentColor(context),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Bar chart widget for menu performance visualization
  Widget _buildBarChart(Map<String, int> data, BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text("No Data", style: TextStyle(color: AppTheme.secondaryTextColor(context))),
        ),
      );
    }
    List<String> itemNames = data.keys.toList();
    List<BarChartGroupData> groups = List.generate(itemNames.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[itemNames[i]]!.toDouble(),
            color: AppTheme.accentColor(context),
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      decoration: _glassDecoration(context),
      child: BarChart(
        BarChartData(
          barGroups: groups,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  int i = val.toInt();
                  return Text(
                    i >= 0 && i < itemNames.length ? itemNames[i] : '',
                    style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Quick action chips for navigation to different screens
  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _actionChip(
          "Promotions",
          Icons.campaign,
          const AdminPromotionsScreen(),
          context,
        ),
        _actionChip(
          "AI Strategy",
          Icons.auto_awesome,
          const AIRecommendationsScreen(),
          context,
        ),
        _actionChip("Live Alerts", Icons.warning_amber, const AlertsScreen(), context),
        _actionChip(
          "Settings",
          Icons.settings_remote,
          const SystemSettingsScreen(),
          context,
        ),
      ],
    );
  }

  // Individual action chip with navigation functionality
  Widget _actionChip(String label, IconData icon, Widget screen, BuildContext context) {
    return ActionChip(
      backgroundColor: AppTheme.cardColor(context),
      avatar: Icon(icon, color: AppTheme.primaryTextColor(context), size: 16),
      label: Text(
        label,
        style: TextStyle(color: AppTheme.primaryTextColor(context), fontSize: 12),
      ),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }

  // Hologram device status card with real-time Firebase control
  Widget _buildHologramStatusCard(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('deviceControl')
          .doc('hologram_1')
          .snapshots(),
      builder: (context, snapshot) {
        bool isOn =
            snapshot.hasData &&
            snapshot.data!.exists &&
            (snapshot.data!.data() as Map)['command'] != 'SHUTDOWN';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _glassDecoration(context),
          child: Row(
            children: [
              Icon(
                Icons.layers,
                color: isOn ? Colors.greenAccent : Colors.redAccent,
                size: 40,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hologram Projection",
                    style: TextStyle(
                      color: AppTheme.primaryTextColor(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isOn ? "Status: ACTIVE" : "Status: OFFLINE",
                    style: TextStyle(
                      color: isOn ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Switch(
                value: isOn,
                onChanged: (val) {
                  FirebaseFirestore.instance
                      .collection('deviceControl')
                      .doc('hologram_1')
                      .set({
                        'command': val ? 'START_ANIMATION' : 'SHUTDOWN',
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Customer feedback summary card with average rating calculation
  Widget _buildFeedbackSummaryCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
      builder: (context, snapshot) {
        double avg = 0.0;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          avg =
              snapshot.data!.docs
                  .map((d) => (d['rating'] ?? 0).toDouble())
                  .reduce((a, b) => a + b) /
              snapshot.data!.docs.length;
        }
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerFeedbackScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _glassDecoration(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Average Rating",
                      style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                    ),
                    Row(
                      children: [
                        Text(
                          avg.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.amberAccent,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryTextColor(context),
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Line chart for peak hours visualization
  Widget _buildLineChart(Map<int, int> hours, BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(context),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: hours.entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                  .toList(),
              isCurved: true,
              color: AppTheme.accentColor(context),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accentColor(context).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent activity list showing latest 5 log entries
  Widget _buildActivityList(List<QueryDocumentSnapshot> logs, BuildContext context) {
    return Container(
      decoration: _glassDecoration(context),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length > 5 ? 5 : logs.length,
        itemBuilder: (context, index) {
          var data = logs[index].data() as Map<String, dynamic>;
          return ListTile(
            leading: Icon(Icons.history, color: AppTheme.accentColor(context)),
            title: Text(
              data['item_name'] ?? 'No Name',
              style: TextStyle(color: AppTheme.primaryTextColor(context)),
            ),
            subtitle: Text(
              "Type: ${data['type'] ?? 'N/A'}",
              style: TextStyle(color: AppTheme.secondaryTextColor(context)),
            ),
          );
        },
      ),
    );
  }
}