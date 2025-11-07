import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'rewards_service.dart';

/// Booking Service - Manages user bookings with SharedPreferences
class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  SharedPreferences? _prefs;
  List<Map<String, dynamic>> _bookings = [];
  bool _isInitialized = false;

  // Getters
  List<Map<String, dynamic>> get bookings => _bookings;
  bool get isInitialized => _isInitialized;

  // Storage key
  static const String _keyBookings = 'user_bookings';

  /// Initialize the service and load saved bookings
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await loadBookings();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load bookings from SharedPreferences
  Future<void> loadBookings() async {
    if (_prefs == null) {
      await initialize();
      return;
    }

    final String? bookingsJson = _prefs!.getString(_keyBookings);
    if (bookingsJson != null) {
      final List<dynamic> decoded = jsonDecode(bookingsJson);
      _bookings = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      _bookings = [];
    }

    notifyListeners();
  }

  /// Save bookings to SharedPreferences
  Future<void> _saveBookings() async {
    if (_prefs == null) await initialize();

    final String encoded = jsonEncode(_bookings);
    await _prefs!.setString(_keyBookings, encoded);
    notifyListeners();
  }

  /// Create a new booking
  Future<bool> createBooking({
    required Map<String, dynamic> listing,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
  }) async {
    try {
      final booking = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'bookingNumber': 'BK${DateTime.now().millisecondsSinceEpoch}',
        'listing': listing,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'guests': guests,
        'totalPrice': totalPrice,
        'status': 'confirmed',
        'bookedAt': DateTime.now().toIso8601String(),
      };

      _bookings.insert(0, booking); // Add to beginning
      await _saveBookings();

      // Automatically award points for this booking
      final rewardsService = RewardsService();
      await rewardsService.initialize();
      await rewardsService.awardPointsForBooking(
        userId: 1,
        bookingAmount: totalPrice,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating booking: $e');
      }
      return false;
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(int bookingId) async {
    try {
      final index = _bookings.indexWhere((b) => b['id'] == bookingId);
      if (index != -1) {
        _bookings[index]['status'] = 'cancelled';
        await _saveBookings();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling booking: $e');
      }
      return false;
    }
  }

  /// Get upcoming bookings
  List<Map<String, dynamic>> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) {
      if (booking['status'] == 'cancelled') return false;
      final checkIn = DateTime.parse(booking['checkIn']);
      return checkIn.isAfter(now);
    }).toList();
  }

  /// Get past bookings
  List<Map<String, dynamic>> getPastBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) {
      final checkOut = DateTime.parse(booking['checkOut']);
      return checkOut.isBefore(now) || booking['status'] == 'cancelled';
    }).toList();
  }

  /// Clear all bookings
  Future<void> clearAllBookings() async {
    _bookings = [];
    await _saveBookings();
  }
}
