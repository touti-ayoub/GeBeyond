import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobeyond/core/database/database_helper.dart';

/// Utility class to manage app data and reset for new accounts
class DataResetService {
  static final DataResetService _instance = DataResetService._internal();
  factory DataResetService() => _instance;
  DataResetService._internal();

  /// Clear all user data - use when logging out or switching accounts
  /// NOTE: This does NOT delete users from database, only clears their data
  Future<void> clearAllData() async {
    try {
      if (kDebugMode) {
        print('Clearing current user session data...');
      }

      // Clear SharedPreferences (session data)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // DO NOT delete from database - data should persist!
      // Only the session is cleared, user can login again to see their data

      if (kDebugMode) {
        print('User session cleared successfully (data preserved in database)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing session: $e');
      }
    }
  }

  /// Clear only booking data for current user
  Future<void> clearBookings(int userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'bookings',
      {'is_deleted': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Clear only rewards data for current user
  Future<void> clearRewards(int userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('rewards', where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Clear only wishlist data for current user
  Future<void> clearWishlist(int userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('wishlists', where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Clear only itineraries data for current user
  Future<void> clearItineraries(int userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('itineraries', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('itinerary_items',
        where: 'itinerary_id IN (SELECT id FROM itineraries WHERE user_id = ?)',
        whereArgs: [userId]);
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
  /// WARNING: This deletes ALL data including users!
  Future<void> factoryReset() async {
    try {
      if (kDebugMode) {
        print('⚠️ FACTORY RESET: Deleting ALL data from database...');
      }

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Delete entire database
      await DatabaseHelper.instance.deleteDatabase();

      if (kDebugMode) {
        print('✅ Factory reset complete - database deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during factory reset: $e');
      }
    }
  }
}

