// ============================================================
// StaffManagementScreen - Staff members ko manage karne ka screen
// Kaam:
//   1. Mock staff list dikhata hai (5 default members)
//   2. Naya staff add kar sakte ho (name, email, password, role)
//   3. Status tap karne par Active/Inactive toggle hota hai
//   4. Long press karne par staff delete ho jaata hai
//   5. Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   6. AppTheme methods se saare colors aur decorations milte hain
// Note: Ye sirf local mock data hai - Firebase nahi use hota
//       App band hone par data reset ho jaata hai
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../standard_toolbar.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  // Mock staff list - each member has name, email, job role, and active status
  final List<Map<String, dynamic>> _staff = [
    {'name': 'Ahmed Raza', 'email': 'ahmed@gmail.com', 'jobRole': 'Manager', 'status': 'Active'},
    {'name': 'Sara Khan', 'email': 'sara@gmail.com', 'jobRole': 'Chef', 'status': 'Active'},
    {'name': 'Bilal Hassan', 'email': 'bilal@gmail.com', 'jobRole': 'Waiter', 'status': 'Active'},
    {'name': 'Nadia Ali', 'email': 'nadia@gmail.com', 'jobRole': 'Waiter', 'status': 'Inactive'},
    {'name': 'Usman Tariq', 'email': 'usman@gmail.com', 'jobRole': 'Cleaner', 'status': 'Active'},
  ];

  // Opens dialog to add a new staff member with name, email, password, and role
  // Uses StatefulBuilder so the password toggle and role dropdown work inside the dialog
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'Waiter';
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: AppTheme.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.accentColor(context)),
          ),
          title: Text('Add Staff Member',
              style: TextStyle(color: AppTheme.accentColor(context), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, 'Full Name', Icons.person, context),
                const SizedBox(height: 12),
                _field(emailCtrl, 'Email', Icons.email, context),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: obscure,
                  style: TextStyle(color: AppTheme.primaryTextColor(context)),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                    prefixIcon: Icon(Icons.lock, color: AppTheme.accentColor(context)),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.secondaryTextColor(context)),
                      onPressed: () => setDialog(() => obscure = !obscure),
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.accentColor(context))),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  dropdownColor: AppTheme.cardColor(context),
                  style: TextStyle(color: AppTheme.primaryTextColor(context)),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
                    prefixIcon: Icon(Icons.work, color: AppTheme.accentColor(context)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.accentColor(context))),
                  ),
                  items: ['Manager', 'Chef', 'Waiter', 'Cleaner']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setDialog(() => role = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor(context)),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                setState(() {
                  _staff.add({
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'jobRole': role,
                    'status': 'Active',
                  });
                });
                Navigator.pop(ctx);
              },
              child: Text('Add',
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
                          ? Colors.black
                          : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Shows confirmation dialog before removing a staff member from the list
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Staff',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Remove "${_staff[index]['name']}" from staff?',
            style: TextStyle(color: AppTheme.primaryTextColor(ctx))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.secondaryTextColor(ctx))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _staff.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, BuildContext context) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: AppTheme.primaryTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
        prefixIcon: Icon(icon, color: AppTheme.accentColor(context)),
        enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3))),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentColor(context))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        extendBodyBehindAppBar: true,
        appBar: StandardToolbar.build(context, 'Staff Management',
            actionIcon: Icons.person_add_alt_1),
        body: Container(
          decoration: AppTheme.backgroundFilter(context),
          child: Column(
            children: [
              const SizedBox(height: 110),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor(context),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: themeProvider.isDarkMode ? Colors.black : Colors.white),
                        const SizedBox(width: 10),
                        Text('Hire New Staff',
                            style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Tap status to toggle  •  Long press to delete',
                  style: TextStyle(color: AppTheme.secondaryTextColor(context), fontSize: 12)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _staff.length,
                  itemBuilder: (context, index) {
                    final s = _staff[index];
                    final isActive = s['status'] == 'Active';
                    return GestureDetector(
                      onLongPress: () => _confirmDelete(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: AppTheme.accentColor(context).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppTheme.accentColor(context).withValues(alpha: 0.1),
                              child: Icon(Icons.person, color: AppTheme.accentColor(context)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'],
                                      style: TextStyle(
                                          color: AppTheme.primaryTextColor(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text(s['jobRole'],
                                      style: TextStyle(
                                          color: AppTheme.secondaryTextColor(context),
                                          fontSize: 13)),
                                  Text(s['email'],
                                      style: TextStyle(
                                          color: AppTheme.secondaryTextColor(context)
                                              .withValues(alpha: 0.6),
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            // Tap status badge to toggle Active <-> Inactive
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _staff[index]['status'] = isActive ? 'Inactive' : 'Active'),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isActive ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                      color: isActive ? Colors.green : Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
    );
  }
}
