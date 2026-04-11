// User Model - Data class representing a HoloServe user
// Stores user information: id, name, email, and role
// Role can be 'admin' (full access) or 'staff' (limited access)
// Used by AuthProvider to manage current logged-in user

class User {
  final String id; // Unique user identifier
  final String name; // User's full name
  final String email; // User's email address
  final String role; // User role: 'admin' or 'staff'

  // Constructor - all fields are required
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Computed property - returns true if user role is admin
  bool get isAdmin => role == 'admin';

  // Computed property - returns true if user role is staff
  bool get isStaff => role == 'staff';

  // Factory constructor - creates User from a Map (e.g. from Firestore or SharedPreferences)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '', // Default empty string if id missing
      name: map['name'] ?? '', // Default empty string if name missing
      email: map['email'] ?? '', // Default empty string if email missing
      role: map['role'] ?? 'staff', // Default to staff if role missing
    );
  }

  // Convert User object to Map (e.g. for saving to Firestore or SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
