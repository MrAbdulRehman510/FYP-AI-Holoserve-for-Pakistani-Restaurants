import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStaff => _currentUser?.isStaff ?? false;

  Future<void> login(String email, String password) async {
    // Mock login logic - replace with actual authentication
    // Check if email starts with 'admin' to determine admin role
    if (email.toLowerCase().startsWith('admin@')) {
      _currentUser = User(
        id: '1',
        name: 'Admin User',
        email: email,
        role: 'admin',
      );
    } else {
      _currentUser = User(
        id: '2',
        name: 'Staff User',
        email: email,
        role: 'staff',
      );
    }
    
    _isLoggedIn = true;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _clearUserData();
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', _currentUser!.role);
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setString('user_name', _currentUser!.name);
      await prefs.setBool('is_logged_in', true);
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (_isLoggedIn) {
      final role = prefs.getString('user_role') ?? 'staff';
      final email = prefs.getString('user_email') ?? '';
      final name = prefs.getString('user_name') ?? '';
      
      _currentUser = User(
        id: role == 'admin' ? '1' : '2',
        name: name,
        email: email,
        role: role,
      );
    }
    notifyListeners();
  }
}