import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../../features/auth/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for user signup, login, and session management
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final _dbHelper = DatabaseHelper.instance;
  User? _currentUser;

  /// Get current logged-in user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Initialize auth service and restore session
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');

    if (userId != null) {
      _currentUser = await getUserById(userId);
    }
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final db = await _dbHelper.database;
      print('📝 Starting registration for: $email');

      // Check if email already exists
      final existingUser = await db.query(
        'users',
        where: 'email = ? AND is_deleted = 0',
        whereArgs: [email.toLowerCase()],
        limit: 1,
      );

      if (existingUser.isNotEmpty) {
        print('❌ Email already exists: $email');
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Hash password
      final hashedPassword = _hashPassword(password);
      print('🔐 Password hashed successfully');

      // Insert new user
      final userId = await db.insert('users', {
        'name': name,
        'email': email.toLowerCase(),
        'password': hashedPassword,
        'phone': phone,
        'profile_photo': null,
        'role': 'user',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': null,
        'is_deleted': 0,
        'sync_status': 'synced',
      });

      print('✅ User registered successfully with ID: $userId');

      // Create user object
      _currentUser = User(
        id: userId,
        name: name,
        email: email.toLowerCase(),
        password: hashedPassword,
        phone: phone,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      // Save session
      await _saveSession(userId);
      print('💾 Session saved for user: $userId');

      return {
        'success': true,
        'message': 'Account created successfully',
        'user': _currentUser,
      };
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      print('🔑 Attempting login for: $email');

      // Hash password for comparison
      final hashedPassword = _hashPassword(password);
      print('🔐 Password hashed for comparison');

      // Find user by email and password
      final results = await db.query(
        'users',
        where: 'email = ? AND password = ? AND is_deleted = 0',
        whereArgs: [email.toLowerCase(), hashedPassword],
        limit: 1,
      );

      if (results.isEmpty) {
        print('❌ Login failed: Invalid credentials for $email');

        // Debug: Check if user exists with this email
        final emailCheck = await db.query(
          'users',
          where: 'email = ? AND is_deleted = 0',
          whereArgs: [email.toLowerCase()],
          limit: 1,
        );

        if (emailCheck.isEmpty) {
          print('   - Email not found in database');
        } else {
          print('   - Email exists but password doesn\'t match');
        }

        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }

      print('✅ User found, logging in...');

      // Create user object
      final userData = results.first;
      _currentUser = User(
        id: userData['id'] as int,
        name: userData['name'] as String,
        email: userData['email'] as String,
        password: userData['password'] as String,
        phone: userData['phone'] as String?,
        profilePhoto: userData['profile_photo'] as String?,
        role: UserRole.fromString(userData['role'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(userData['created_at'] as int),
        updatedAt: userData['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(userData['updated_at'] as int)
            : null,
      );

      // Save session
      await _saveSession(_currentUser!.id!);
      print('💾 Session saved. User logged in: ${_currentUser!.name}');

      return {
        'success': true,
        'message': 'Login successful',
        'user': _currentUser,
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  /// Get user by ID
  Future<User?> getUserById(int userId) async {
    try {
      final db = await _dbHelper.database;

      final results = await db.query(
        'users',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final userData = results.first;
      return User(
        id: userData['id'] as int,
        name: userData['name'] as String,
        email: userData['email'] as String,
        password: userData['password'] as String,
        phone: userData['phone'] as String?,
        profilePhoto: userData['profile_photo'] as String?,
        role: UserRole.fromString(userData['role'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(userData['created_at'] as int),
        updatedAt: userData['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(userData['updated_at'] as int)
            : null,
      );
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profilePhoto,
  }) async {
    if (_currentUser == null) return false;

    try {
      final db = await _dbHelper.database;

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'sync_status': 'pending',
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (profilePhoto != null) updateData['profile_photo'] = profilePhoto;

      await db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      // Update current user object
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        profilePhoto: profilePhoto ?? _currentUser!.profilePhoto,
        updatedAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'No user logged in',
      };
    }

    try {
      final db = await _dbHelper.database;

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (hashedCurrentPassword != _currentUser!.password) {
        return {
          'success': false,
          'message': 'Current password is incorrect',
        };
      }

      // Hash new password
      final hashedNewPassword = _hashPassword(newPassword);

      // Update password
      await db.update(
        'users',
        {
          'password': hashedNewPassword,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'sync_status': 'pending',
        },
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      // Update current user object
      _currentUser = _currentUser!.copyWith(
        password: hashedNewPassword,
        updatedAt: DateTime.now(),
      );

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to change password: $e',
      };
    }
  }

  /// Delete user account (soft delete)
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      final db = await _dbHelper.database;

      await db.update(
        'users',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'sync_status': 'pending',
        },
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      await logout();
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  /// Save session to SharedPreferences
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', userId);
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        where: 'email = ? AND is_deleted = 0',
        whereArgs: [email.toLowerCase()],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        where: 'is_deleted = 0',
        orderBy: 'created_at DESC',
      );

      return results.map((userData) {
        return User(
          id: userData['id'] as int,
          name: userData['name'] as String,
          email: userData['email'] as String,
          password: userData['password'] as String,
          phone: userData['phone'] as String?,
          profilePhoto: userData['profile_photo'] as String?,
          role: UserRole.fromString(userData['role'] as String),
          createdAt: DateTime.fromMillisecondsSinceEpoch(userData['created_at'] as int),
          updatedAt: userData['updated_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(userData['updated_at'] as int)
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }
}

