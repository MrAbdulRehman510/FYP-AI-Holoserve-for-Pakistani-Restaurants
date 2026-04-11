// AnalyticsDashboard - Business analytics overview screen for admins
// Responsibilities:
//   1. Shows hologram device live status card (always ACTIVE - mock)
//   2. Displays mini stat cards: AI Strategies count and System Alerts count
//   3. Provides quick navigation chips to related screens
//   4. Renders a bar chart of menu item view counts
//   5. Shows a tappable feedback card with average rating (navigates to feedback screen)
//   6. Renders a line chart of peak customer activity hours
//   7. Lists recent activity logs (views and recommendations)
//   8. Uses Consumer<ThemeProvider> to rebuild when dark/light theme changes
//   9. AppTheme methods provide all colors, gradients, and decorations
// Note: All data is hardcoded mock data - no Firebase connection used

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Bar chart and line chart widgets
import 'package:provider/provider.dart';
import 'admin_promotions_screen.dart'; // Quick chip destination
import 'customer_feedback_screen.dart'; // Feedback card destination
import 'system_settings_screen.dart'; // Quick chip destination
import 'admin_recommendations_screen.dart'; // Quick chip destination
import 'alert_admin_screen.dart'; // Quick chip destination
import '../theme_provider.dart'; // Dark/light theme state
import '../app_theme.dart'; // Centralized theme colors and styles
import '../standard_toolbar.dart'; // Reusable gradient app bar

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  bool _hologramActive = true; // Hologram toggle state

  // Mock data: menu item name -> number of times viewed by customers today
  static const Map<String, int> _itemViews = {
    'Zinger': 45,
    'Crispy Box': 30,
    'Pizza': 25,
    'Fries': 20,
  };

  // Mock data: hour of day (24h format) -> number of active customers at that hour
  // Used to plot the peak activity line chart
  static const Map<int, int> _peakHours = {
    9: 5,
    10: 8,
    11: 12,
    12: 20, // Lunch peak - highest midday activity
    13: 18,
    14: 15,
    15: 10,
    16: 7,
    17: 9,
    18: 14,
    19: 22, // Dinner peak - highest evening activity
    20: 18,
  };

  // Mock activity logs: each entry records an item name and the action type
  // type: 'view' = customer viewed item | 'recommendation' = AI suggested item
  static const List<Map<String, String>> _logs = [
    {'item': 'Zinger Burger', 'type': 'view'},
    {'item': 'Crispy Box', 'type': 'view'},
    {'item': 'Pizza', 'type': 'recommendation'},
    {'item': 'Fries', 'type': 'view'},
    {'item': 'Coke', 'type': 'view'},
  ];

  BoxDecoration _glass(BuildContext context) => BoxDecoration(
    color: AppTheme.cardColor(context),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: AppTheme.primaryTextColor(context).withValues(alpha: 0.1),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final statusColor = _hologramActive
            ? Colors.greenAccent
            : Colors.redAccent;
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor(context),
          appBar: StandardToolbar.build(
            context,
            'Business Analytics',
            actionIcon: Icons.auto_fix_high,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Device Live Status
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Device Live Status',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Hologram card built inline so setState triggers a rebuild
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.layers, color: statusColor, size: 40),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hologram Projection',
                            style: TextStyle(
                              color: AppTheme.primaryTextColor(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _hologramActive
                                ? 'Status: ACTIVE'
                                : 'Status: OFFLINE',
                            style: TextStyle(color: statusColor),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _hologramActive = !_hologramActive),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 64,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            gradient: LinearGradient(
                              colors: _hologramActive
                                  ? [
                                      const Color(0xFF00C853),
                                      const Color(0xFF69F0AE),
                                    ]
                                  : [
                                      const Color(0xFFB71C1C),
                                      const Color(0xFFFF5252),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.7),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // top shine for 3D effect
                              Positioned(
                                top: 3,
                                left: 6,
                                right: 6,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.5),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                              // sliding circle
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: _hologramActive
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: statusColor.withValues(
                                            alpha: 0.6,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _hologramActive
                                          ? Icons.power
                                          : Icons.power_off,
                                      size: 14,
                                      color: _hologramActive
                                          ? const Color(0xFF00C853)
                                          : const Color(0xFFB71C1C),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section: Quick stat mini cards side by side
                Row(
                  children: [
                    Expanded(
                      child: _miniCard(
                        'AI Strategies',
                        '4 Active',
                        Icons.psychology,
                        context,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      // Orange icon to visually distinguish alerts from AI strategies
                      child: _miniCard(
                        'System Alerts',
                        '5 Active',
                        Icons.bolt,
                        context,
                        iconColor: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Section: Quick navigation chips
                _quickActions(context),
                const SizedBox(height: 20),

                // Section: Bar chart - menu item view counts
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Menu Performance (Views)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _barChart(context),
                const SizedBox(height: 25),

                // Section: Customer satisfaction rating card
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Customer Satisfaction',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _feedbackCard(context),
                const SizedBox(height: 25),

                // Section: Line chart - peak activity hours
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Peak Activity Hours',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _lineChart(context),
                const SizedBox(height: 25),

                // Section: Recent activity log list
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Recent Activity Logs',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _activityList(context),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  // Small stat card showing an icon, a label, and a value
  // Used for AI Strategies and System Alerts counts
  // iconColor is optional - falls back to theme accent color if not provided
  Widget _miniCard(
    String title,
    String value,
    IconData icon,
    BuildContext context, {
    Color? iconColor, // Optional custom icon color
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _glass(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                iconColor ??
                AppTheme.accentColor(context), // Use custom or default accent
            size: 30,
          ),
          const SizedBox(height: 10),
          // Label text (e.g. "AI Strategies")
          Text(
            title,
            style: TextStyle(
              color: AppTheme.secondaryTextColor(context),
              fontSize: 12,
            ),
          ),
          // Value text (e.g. "4 Active")
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Row of quick navigation chips - each chip navigates to a related screen
  Widget _quickActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip(
          'Promotions',
          Icons.campaign,
          const AdminPromotionsScreen(),
          context,
        ),
        _chip(
          'AI Strategy',
          Icons.auto_awesome,
          const AIRecommendationsScreen(),
          context,
        ),
        _chip(
          'Live Alerts',
          Icons.warning_amber,
          const AlertsScreen(),
          context,
        ),
        _chip(
          'Settings',
          Icons.settings_remote,
          const SystemSettingsScreen(),
          context,
        ),
      ],
    );
  }

  // Reusable chip widget - tapping pushes the given screen onto the navigation stack
  Widget _chip(
    String label,
    IconData icon,
    Widget screen,
    BuildContext context,
  ) {
    return ActionChip(
      backgroundColor: AppTheme.cardColor(context),
      avatar: Icon(icon, color: AppTheme.primaryTextColor(context), size: 16),
      label: Text(
        label,
        style: TextStyle(
          color: AppTheme.primaryTextColor(context),
          fontSize: 12,
        ),
      ),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
  }

  // Bar chart showing how many times each menu item was viewed
  // X-axis: item names | Y-axis: view count (hidden labels)
  Widget _barChart(BuildContext context) {
    // Convert map keys to list so we can use index for x-axis label lookup
    final items = _itemViews.keys.toList();

    // Build one BarChartGroupData per menu item
    // x = item index, toY = view count (bar height)
    final groups = List.generate(
      items.length,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _itemViews[items[i]]!.toDouble(), // Bar height = view count
            color: AppTheme.accentColor(context),
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      decoration: _glass(context),
      child: BarChart(
        BarChartData(
          barGroups: groups,
          borderData: FlBorderData(show: false), // No chart border frame
          gridData: const FlGridData(show: false), // No background grid lines
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                // Map x index back to item name for the bottom axis label
                getTitlesWidget: (val, _) => Text(
                  val.toInt() < items.length ? items[val.toInt()] : '',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor(context),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            // Hide left, top, and right axis labels - only bottom labels needed
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }

  // Tappable card showing the average customer rating (4.2 stars)
  // Tapping navigates to the full CustomerFeedbackScreen
  Widget _feedbackCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerFeedbackScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _glass(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Rating',
                  style: TextStyle(color: AppTheme.secondaryTextColor(context)),
                ),
                // Large rating number with star icon
                const Row(
                  children: [
                    Text(
                      '4.2',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.star, color: Colors.amberAccent, size: 30),
                  ],
                ),
              ],
            ),
            // Arrow indicating the card is tappable
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.secondaryTextColor(context),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // Smooth line chart showing customer activity levels across hours of the day
  // Data points: FlSpot(hour, activityCount) from _peakHours map
  // All axis labels are hidden - chart is a visual trend overview only
  Widget _lineChart(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: _glass(context),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false), // No background grid
          borderData: FlBorderData(show: false), // No border frame
          titlesData: const FlTitlesData(
            // All axis labels hidden - chart is decorative trend overview
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              // Convert _peakHours map entries to chart data points
              // FlSpot(x: hour, y: activityCount)
              spots: _peakHours.entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                  .toList(),
              isCurved:
                  true, // Smooth bezier curve instead of sharp line segments
              color: AppTheme.accentColor(context),
              // Shaded area below the line adds visual depth to the chart
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

  // Non-scrollable list of recent activity logs embedded inside the main scroll view
  // shrinkWrap: true allows ListView to size itself to its content inside a Column
  // NeverScrollableScrollPhysics prevents nested scroll conflicts
  Widget _activityList(BuildContext context) {
    return Container(
      decoration: _glass(context),
      child: ListView.builder(
        shrinkWrap: true, // Size to content, not full screen height
        physics:
            const NeverScrollableScrollPhysics(), // Parent handles scrolling
        itemCount: _logs.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.history, color: AppTheme.accentColor(context)),
          title: Text(
            _logs[index]['item']!,
            style: TextStyle(color: AppTheme.primaryTextColor(context)),
          ),
          subtitle: Text(
            'Type: ${_logs[index]['type']}',
            style: TextStyle(color: AppTheme.secondaryTextColor(context)),
          ),
        ),
      ),
    );
  }
}
