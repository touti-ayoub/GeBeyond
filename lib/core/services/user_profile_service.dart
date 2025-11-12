import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'package:intl/intl.dart';

/// User Profile Service - Manages user profile data with SharedPreferences
class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final _authService = AuthService.instance;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // User profile data
  String _name = 'Guest User';
  String _email = '';
  String _phone = '';
  String _bio = 'Travel enthusiast exploring the world 🌍';
  String _joinDate = 'January 2024';
  String _memberLevel = 'Bronze Member';
  int _points = 0;
  int _trips = 0;
  int _countries = 0;
  int _reviews = 0;

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get bio => _bio;
  String get joinDate => _joinDate;
  String get memberLevel => _memberLevel;
  int get points => _points;
  int get trips => _trips;
  int get countries => _countries;
  int get reviews => _reviews;
  bool get isInitialized => _isInitialized;

  // Storage keys
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';
  static const String _keyBio = 'user_bio';
  static const String _keyJoinDate = 'user_join_date';
  static const String _keyMemberLevel = 'user_member_level';
  static const String _keyPoints = 'user_points';
  static const String _keyTrips = 'user_trips';
  static const String _keyCountries = 'user_countries';
  static const String _keyReviews = 'user_reviews';

  /// Initialize the service and load saved data
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await loadProfile();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load profile data from SharedPreferences and AuthService
  Future<void> loadProfile() async {
    if (_prefs == null) {
      await initialize();
      return;
    }

    // Load from AuthService if user is logged in
    if (_authService.isLoggedIn && _authService.currentUser != null) {
      final user = _authService.currentUser!;
      _name = user.name;
      _email = user.email;
      _phone = user.phone ?? '';

      // Format join date from user creation date
      _joinDate = DateFormat('MMMM yyyy').format(user.createdAt);

      if (kDebugMode) {
        print('📊 Profile loaded from AuthService: $_name');
      }
    } else {
      // Fallback to SharedPreferences if no user logged in
      _name = _prefs!.getString(_keyName) ?? 'Guest User';
      _email = _prefs!.getString(_keyEmail) ?? '';
      _phone = _prefs!.getString(_keyPhone) ?? '';
      _joinDate = _prefs!.getString(_keyJoinDate) ?? DateFormat('MMMM yyyy').format(DateTime.now());
    }

    // Load other data from SharedPreferences
    _bio = _prefs!.getString(_keyBio) ?? 'Travel enthusiast exploring the world 🌍';
    _memberLevel = _prefs!.getString(_keyMemberLevel) ?? 'Bronze Member';
    _points = _prefs!.getInt(_keyPoints) ?? 0;
    _trips = _prefs!.getInt(_keyTrips) ?? 0;
    _countries = _prefs!.getInt(_keyCountries) ?? 0;
    _reviews = _prefs!.getInt(_keyReviews) ?? 0;

    notifyListeners();
  }

  /// Save profile data to SharedPreferences
  Future<bool> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String bio,
  }) async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      // Validate data
      if (name.isEmpty || email.isEmpty) {
        return false;
      }

      // Save to SharedPreferences
      await _prefs!.setString(_keyName, name);
      await _prefs!.setString(_keyEmail, email);
      await _prefs!.setString(_keyPhone, phone);
      await _prefs!.setString(_keyBio, bio);

      // Update local state
      _name = name;
      _email = email;
      _phone = phone;
      _bio = bio;

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile: $e');
      }
      return false;
    }
  }

  /// Update points (for rewards system)
  Future<void> updatePoints(int newPoints) async {
    if (_prefs == null) await initialize();

    _points = newPoints;
    await _prefs!.setInt(_keyPoints, newPoints);
    notifyListeners();
  }

  /// Update member level
  Future<void> updateMemberLevel(String level) async {
    if (_prefs == null) await initialize();

    _memberLevel = level;
    await _prefs!.setString(_keyMemberLevel, level);
    notifyListeners();
  }

  /// Update join date
  Future<void> updateJoinDate(String date) async {
    if (_prefs == null) await initialize();

    _joinDate = date;
    await _prefs!.setString(_keyJoinDate, date);
    notifyListeners();
  }

  /// Update stats
  Future<void> updateStats({int? trips, int? countries, int? reviews}) async {
    if (_prefs == null) await initialize();

    if (trips != null) {
      _trips = trips;
      await _prefs!.setInt(_keyTrips, trips);
    }
    if (countries != null) {
      _countries = countries;
      await _prefs!.setInt(_keyCountries, countries);
    }
    if (reviews != null) {
      _reviews = reviews;
      await _prefs!.setInt(_keyReviews, reviews);
    }

    notifyListeners();
  }

  /// Clear all profile data
  Future<void> clearProfile() async {
    if (_prefs == null) await initialize();

    await _prefs!.remove(_keyName);
    await _prefs!.remove(_keyEmail);
    await _prefs!.remove(_keyPhone);
    await _prefs!.remove(_keyBio);
    await _prefs!.remove(_keyJoinDate);
    await _prefs!.remove(_keyMemberLevel);
    await _prefs!.remove(_keyPoints);
    await _prefs!.remove(_keyTrips);
    await _prefs!.remove(_keyCountries);
    await _prefs!.remove(_keyReviews);

    // Reset to defaults
    _name = 'Sarah Johnson';
    _email = 'sarah.johnson@email.com';
    _phone = '+1 (555) 123-4567';
    _bio = 'Travel enthusiast exploring the world 🌍';
    _joinDate = 'January 2024';
    _memberLevel = 'Bronze Member';
    _points = 0;
    _trips = 0;
    _countries = 0;
    _reviews = 0;

    notifyListeners();
  }

  /// Get profile as Map
  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'email': _email,
      'phone': _phone,
      'bio': _bio,
      'joinDate': _joinDate,
      'memberLevel': _memberLevel,
      'points': _points,
      'trips': _trips,
      'countries': _countries,
      'reviews': _reviews,
    };
  }
}
