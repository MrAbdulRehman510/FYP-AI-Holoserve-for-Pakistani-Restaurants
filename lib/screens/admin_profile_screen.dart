// ============================================================
// AdminProfileScreen - Admin ki personal profile screen
// Kaam:
//   1. Admin ki personal info dikhata hai (name, email, phone, ID)
//   2. Edit Profile dialog se name/email/phone update kar sakte ho
//   3. Change Password dialog se password update kar sakte ho
//   4. Profile picture camera ya gallery se set kar sakte ho
//   5. Staff Profile Requests section (abhi mock - no pending)
//   6. Add/Manage Staff button -> StaffManagementScreen
//   7. System Settings button -> SystemSettingsScreen
// Note: Firebase nahi use hota - sab local state mein hai
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../auth_provider.dart';
import 'system_settings_screen.dart';
import 'staff_management_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

// StatefulWidget - state needed for editable profile fields and dialogs
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  // Editable profile data
  String _name = 'Muhammad Ahmed Khan';
  String _email = 'admin@holoserve.com';
  String _phone = '+92 300 1234567';
  final String _employeeId = 'ADM-001';
  final String _department = 'IT Management';
  final String _joinDate = '15 Jan 2024';
  Uint8List? _profileImageBytes;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // Pick profile image from camera or gallery
  void _pickImage(BuildContext context) {
    if (kIsWeb) {
      // Web: directly open file picker
      _selectImage(ImageSource.gallery);
      return;
    }
    // Mobile: show camera/gallery options
    final accentColor = AppTheme.accentColor(context);
    final primaryColor = AppTheme.primaryTextColor(context);
    final cardColor = AppTheme.cardColor(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: Icon(Icons.camera_alt, color: accentColor),
              title: Text('Camera', style: TextStyle(color: primaryColor)),
              onTap: () {
                Navigator.pop(sheetContext);
                _selectImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: accentColor),
              title: Text('Gallery', style: TextStyle(color: primaryColor)),
              onTap: () {
                Navigator.pop(sheetContext);
                _selectImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 400,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (mounted) setState(() => _profileImageBytes = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not pick image. Try gallery instead.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Edit Profile Dialog
  void _showEditDialog() {
    _nameCtrl.text = _name;
    _emailCtrl.text = _email;
    _phoneCtrl.text = _phone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.accentColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(_nameCtrl, 'Full Name', Icons.person),
              const SizedBox(height: 15),
              _buildDialogField(_emailCtrl, 'Email Address', Icons.email),
              const SizedBox(height: 15),
              _buildDialogField(
                _phoneCtrl,
                'Phone Number',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor(context),
            ),
            onPressed: () {
              if (_nameCtrl.text.trim().isNotEmpty &&
                  _emailCtrl.text.trim().isNotEmpty &&
                  _phoneCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _name = _nameCtrl.text.trim();
                  _email = _emailCtrl.text.trim();
                  _phone = _phoneCtrl.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
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

  // Change Password Dialog
  void _showChangePasswordDialog() {
    _currentPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Change Password',
            style: TextStyle(
              color: AppTheme.accentColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                  _currentPassCtrl,
                  'Current Password',
                  Icons.lock,
                  obscure: true,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _newPassCtrl,
                  obscureText: _obscureNew,
                  style: TextStyle(color: AppTheme.primaryTextColor(context)),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.accentColor(context),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.secondaryTextColor(context),
                      ),
                      onPressed: () =>
                          setDialogState(() => _obscureNew = !_obscureNew),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.secondaryTextColor(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.accentColor(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirm,
                  style: TextStyle(color: AppTheme.primaryTextColor(context)),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(
                      color: AppTheme.secondaryTextColor(context),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.accentColor(context),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.secondaryTextColor(context),
                      ),
                      onPressed: () => setDialogState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.secondaryTextColor(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.accentColor(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.secondaryTextColor(context)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor(context),
              ),
              onPressed: () {
                if (_currentPassCtrl.text.isEmpty ||
                    _newPassCtrl.text.isEmpty ||
                    _confirmPassCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (_newPassCtrl.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (_newPassCtrl.text != _confirmPassCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Update',
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
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: AppTheme.primaryTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.secondaryTextColor(context)),
        prefixIcon: Icon(icon, color: AppTheme.accentColor(context)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accentColor(context)),
        ),
      ),
    );
  }

  Widget profileInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.accentColor(context).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor(context).withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentColor(
              context,
            ).withValues(alpha: 0.2),
            child: Icon(icon, color: AppTheme.accentColor(context)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                Icon(
                  Icons.admin_panel_settings,
                  color: AppTheme.accentColor(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor(context),
              extendBodyBehindAppBar: true,
              appBar: customTopBar(context, 'Admin Profile'),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: AppTheme.backgroundFilter(context),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage(context),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppTheme.accentColor(context),
                                    backgroundImage: _profileImageBytes != null
                                        ? MemoryImage(_profileImageBytes!)
                                        : null,
                                    child: _profileImageBytes == null
                                        ? const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor(context),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _name,
                              style: TextStyle(
                                color: AppTheme.primaryTextColor(context),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Personal Information',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      profileInfoCard('Full Name', _name, Icons.person),
                      profileInfoCard('Email Address', _email, Icons.email),
                      profileInfoCard('Phone Number', _phone, Icons.phone),
                      profileInfoCard('Employee ID', _employeeId, Icons.badge),

                      const SizedBox(height: 20),

                      Text(
                        'System Access',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      profileInfoCard(
                        'Role',
                        'System Administrator',
                        Icons.admin_panel_settings,
                      ),
                      profileInfoCard(
                        'Department',
                        _department,
                        Icons.business,
                      ),
                      profileInfoCard(
                        'Join Date',
                        _joinDate,
                        Icons.calendar_today,
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showEditDialog,
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Edit Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentColor(context),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showChangePasswordDialog,
                              icon: const Icon(Icons.lock, color: Colors.white),
                              label: const Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Staff Edit Requests Section
                      Text(
                        'Staff Profile Requests',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Staff Profile Requests - Mock Data
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No pending requests.',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor(context),
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StaffManagementScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.person_add, color: Colors.white),
                          label: const Text('Add / Manage Staff', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SystemSettingsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.settings, color: Colors.white),
                          label: const Text(
                            'System Settings',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
