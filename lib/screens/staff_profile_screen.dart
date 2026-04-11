// ============================================================
// StaffProfileScreen - Staff member ki profile screen
// Kaam:
//   1. Staff ki personal info dikhata hai (name, email, phone, ID, shift)
//   2. Profile picture camera ya gallery se set kar sakte ho
//   3. "Request Profile Edit" button se admin ko request bhej sakte ho
//   4. "My Requests" section mein sent requests ki status dikhti hai
//      (pending = orange, approved = green, rejected = red)
//   5. Consumer<ThemeProvider> se dark/light theme ke saath rebuild hota hai
//   6. AppTheme methods se saare colors aur decorations milte hain
// Note: Local mock data - Firebase nahi use hota
//       2 mock requests pehle se hain (1 approved, 1 rejected)
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../app_theme.dart';
import '../auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  final String _name = 'Ali Hassan';
  final String _email = 'ali.hassan@holoserve.com';
  final String _phone = '+92 301 9876543';
  final String _employeeId = 'STF-005';
  Uint8List? _profileImageBytes;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  // Mock requests list
  final List<Map<String, dynamic>> _requests = [
    {
      'requestedName': 'Ali Hassan Updated',
      'requestedPhone': '+92 301 1112233',
      'status': 'approved',
    },
    {
      'requestedName': 'Ali H.',
      'requestedPhone': '+92 301 0000000',
      'status': 'rejected',
    },
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _pickImage(BuildContext context) {
    if (kIsWeb) {
      _selectImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor(context),
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
              leading: Icon(
                Icons.camera_alt,
                color: AppTheme.accentColor(context),
              ),
              title: Text(
                'Camera',
                style: TextStyle(color: AppTheme.primaryTextColor(context)),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _selectImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppTheme.accentColor(context),
              ),
              title: Text(
                'Gallery',
                style: TextStyle(color: AppTheme.primaryTextColor(context)),
              ),
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

  void _showEditRequestDialog() {
    _nameCtrl.text = _name;
    _phoneCtrl.text = _phone;
    _reasonCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.send, color: AppTheme.accentColor(context)),
            const SizedBox(width: 10),
            Text(
              'Request Profile Edit',
              style: TextStyle(
                color: AppTheme.accentColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fill in the details you want to update.',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              _buildField(_nameCtrl, 'New Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildField(
                _phoneCtrl,
                'New Phone Number',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildField(_reasonCtrl, 'Reason for Change', Icons.note),
            ],
          ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor(context),
            ),
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty ||
                  _phoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              setState(() {
                _requests.insert(0, {
                  'requestedName': _nameCtrl.text.trim(),
                  'requestedPhone': _phoneCtrl.text.trim(),
                  'status': 'pending',
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request sent to Admin!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Send Request',
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

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
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

  Widget _profileCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.accentColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentColor(
              context,
            ).withValues(alpha: 0.2),
            child: Icon(icon, color: AppTheme.accentColor(context)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor(context),
                    fontSize: 15,
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

  PreferredSizeWidget _topBar(BuildContext context) {
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
                  'Staff Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(),
                Icon(Icons.person, color: AppTheme.accentColor(context)),
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
              appBar: _topBar(context),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: AppTheme.backgroundFilter(context),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage(context),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.blue,
                                    backgroundImage: _profileImageBytes != null
                                        ? MemoryImage(_profileImageBytes!)
                                        : null,
                                    child: _profileImageBytes == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: Colors.white,
                                      ),
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
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: const Text(
                                'STAFF',
                                style: TextStyle(
                                  color: Colors.blue,
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
                      _profileCard('Full Name', _name, Icons.person),
                      _profileCard('Email Address', _email, Icons.email),
                      _profileCard('Phone Number', _phone, Icons.phone),
                      _profileCard('Employee ID', _employeeId, Icons.badge),
                      _profileCard(
                        'Role',
                        'Restaurant Staff',
                        Icons.restaurant,
                      ),
                      _profileCard(
                        'Shift',
                        'Morning (8 AM - 4 PM)',
                        Icons.schedule,
                      ),
                      _profileCard(
                        'Join Date',
                        '20 Feb 2024',
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'To update your profile, send a request to Admin for approval.',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor(context),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showEditRequestDialog,
                          icon: const Icon(
                            Icons.edit_notifications,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Request Profile Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'My Requests',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_requests.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'No requests sent yet.',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor(context),
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        ..._requests.map((req) {
                          final status = req['status'] as String;
                          final statusColor = status == 'approved'
                              ? Colors.green
                              : status == 'rejected'
                              ? Colors.red
                              : Colors.orange;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  status == 'approved'
                                      ? Icons.check_circle
                                      : status == 'rejected'
                                      ? Icons.cancel
                                      : Icons.pending,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${req['requestedName']}',
                                        style: TextStyle(
                                          color: AppTheme.primaryTextColor(
                                            context,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Phone: ${req['requestedPhone']}',
                                        style: TextStyle(
                                          color: AppTheme.secondaryTextColor(
                                            context,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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
