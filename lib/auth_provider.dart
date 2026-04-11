// AuthProvider - User Authentication and Session Management
// Manages current user state (logged in / logged out)
// Determines user role (admin or staff) based on email
// Saves and restores session using SharedPreferences
// Used by all screens to check user role and access control

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Local storage for session
import 'models/user.dart'; // User model class

// ChangeNotifier allows all listening widgets to rebuild on state change
class AuthProvider extends ChangeNotifier {
  User? _currentUser; // Currently logged in user (null if not logged in)
  bool _isLoggedIn = false; // Login state flag

  // Public getters for accessing auth state
  User? get currentUser => _currentUser; // Get current user object
  bool get isLoggedIn => _isLoggedIn; // Check if user is logged in
  bool get isAdmin => _currentUser?.isAdmin ?? false; // Check if user is admin
  bool get isStaff => _currentUser?.isStaff ?? false; // Check if user is staff

  // Login method - determines role based on email prefix
  // admin@ email = Admin role, anything else = Staff role
  Future<void> login(String email, String password) async {
    if (email.toLowerCase().startsWith('admin@')) {
      _currentUser = User(id: '1', name: 'Admin User', email: email, role: 'admin');
    } else {
      _currentUser = User(id: '2', name: 'Staff User', email: email, role: 'staff');
    }
    _isLoggedIn = true;
    await _saveUserData();
    notifyListeners();
  }

  // Login with known role from Firebase
  Future<void> loginWithRole(String email, String name, String role) async {
    _currentUser = User(
      id: role == 'admin' ? '1' : '2',
      name: name,
      email: email,
      role: role,
    );
    _isLoggedIn = true;
    await _saveUserData();
    notifyListeners();
  }

  // Logout method - clears user data and session
  Future<void> logout() async {
    _currentUser = null; // Clear user object
    _isLoggedIn = false; // Mark as logged out
    await _clearUserData(); // Remove session from SharedPreferences
    notifyListeners(); // Notify all listening widgets to rebuild
  }

  // Save user session data to SharedPreferences for persistence
  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', _currentUser!.role); // Save role
      await prefs.setString('user_email', _currentUser!.email); // Save email
      await prefs.setString('user_name', _currentUser!.name); // Save name
      await prefs.setBool('is_logged_in', true); // Mark as logged in
    }
  }

  // Clear all user session data from SharedPreferences on logout
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role'); // Remove saved role
    await prefs.remove('user_email'); // Remove saved email
    await prefs.remove('user_name'); // Remove saved name
    await prefs.setBool('is_logged_in', false); // Mark as logged out
  }

  // Load saved session on app start - restores previous login state
  // Called in main.dart when AuthProvider is created
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn =
        prefs.getBool('is_logged_in') ?? false; // Check if was logged in

    if (_isLoggedIn) {
      // Restore user data from SharedPreferences
      final role = prefs.getString('user_role') ?? 'staff';
      final email = prefs.getString('user_email') ?? '';
      final name = prefs.getString('user_name') ?? '';

      // Recreate user object from saved data
      _currentUser = User(
        id: role == 'admin' ? '1' : '2',
        name: name,
        email: email,
        role: role,
      );
    }
    notifyListeners(); // Notify widgets after loading
  }
}
