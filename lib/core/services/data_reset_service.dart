import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/core/services/booking_service.dart';
import 'package:gobeyond/core/services/rewards_service.dart';
import 'package:gobeyond/core/services/wishlist_service.dart';
import 'package:gobeyond/core/services/user_profile_service.dart';

/// Utility class to manage app data and reset for new accounts
class DataResetService {
  static final DataResetService _instance = DataResetService._internal();
  factory DataResetService() => _instance;
  DataResetService._internal();

  /// Clear all user data - use when logging out or switching accounts
  Future<void> clearAllData() async {
    try {
      if (kDebugMode) {
        print('Clearing all user data...');
      }

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear SQLite database
      final db = await DatabaseHelper.instance.database;

      // Clear all tables
      await db.delete('users');
      await db.delete('listings');
      await db.delete('bookings');
      await db.delete('itineraries');
      await db.delete('itinerary_items');
      await db.delete('feedbacks');
      await db.delete('rewards');
      await db.delete('wishlists');

      // Reset all services
      final bookingService = BookingService();
      final rewardsService = RewardsService();
      final wishlistService = WishlistService();
      final profileService = UserProfileService();

      // Reload services to reflect empty state
      await bookingService.loadBookings();
      await rewardsService.loadRewards();
      wishlistService.clearAll();
      await profileService.loadProfile();

      if (kDebugMode) {
        print('All user data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing data: $e');
      }
    }
  }

  /// Clear only booking data
  Future<void> clearBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_bookings');
    await BookingService().loadBookings();
  }

  /// Clear only rewards data
  Future<void> clearRewards() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('rewards');
    await RewardsService().loadRewards();
  }

  /// Clear only wishlist data
  Future<void> clearWishlist() async {
    WishlistService().clearAll();
  }

  /// Clear only itineraries data
  Future<void> clearItineraries() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('itineraries');
    await db.delete('itinerary_items');
  }

  /// Check if this is a first-time user (no existing data)
  Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUsedApp = prefs.getBool('has_used_app') ?? false;
    return !hasUsedApp;
  }

  /// Mark app as used (call after onboarding/first launch)
  Future<void> markAppAsUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_used_app', true);
  }

  /// Reset to factory defaults (for testing/development)
  Future<void> factoryReset() async {
    await clearAllData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_used_app');
  }
}

