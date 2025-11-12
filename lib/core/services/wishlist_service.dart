import 'package:flutter/material.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import 'auth_service.dart';

/// Wishlist service with SQLite persistence
class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final _dbHelper = DatabaseHelper.instance;
  final _authService = AuthService.instance;

  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isInitialized = false;

  List<Map<String, dynamic>> get wishlistItems => List.unmodifiable(_wishlistItems);

  /// Initialize and load wishlist from database
  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadWishlist();
    _isInitialized = true;
  }

  /// Load wishlist from database for current user
  Future<void> loadWishlist() async {
    try {
      if (_authService.currentUser == null) {
        _wishlistItems = [];
        notifyListeners();
        return;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      final results = await db.rawQuery('''
        SELECT l.*, w.created_at as saved_at
        FROM wishlists w
        INNER JOIN listings l ON w.listing_id = l.id
        WHERE w.user_id = ? AND w.is_deleted = 0 AND l.is_deleted = 0
        ORDER BY w.created_at DESC
      ''', [userId]);

      _wishlistItems = results.map((row) {
        final item = Map<String, dynamic>.from(row);

        // Extract first photo from photos JSON array
        String? imageUrl;
        try {
          final photos = row['photos'] as String?;
          if (photos != null && photos.isNotEmpty) {
            if (photos.startsWith('[')) {
              final List<dynamic> photosList = jsonDecode(photos);
              imageUrl = photosList.isNotEmpty ? photosList[0] : null;
            } else {
              imageUrl = photos;
            }
          }
        } catch (e) {
          print('Error parsing photos: $e');
        }

        // Set image field with fallback
        item['image'] = imageUrl ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800';

        // Format saved date
        final savedAt = DateTime.fromMillisecondsSinceEpoch(row['saved_at'] as int);
        final now = DateTime.now();
        final difference = now.difference(savedAt);

        if (difference.inDays < 1) {
          if (difference.inHours < 1) {
            item['savedDate'] = 'Added ${difference.inMinutes} minutes ago';
          } else {
            item['savedDate'] = 'Added ${difference.inHours} hours ago';
          }
        } else if (difference.inDays < 7) {
          item['savedDate'] = 'Added ${difference.inDays} days ago';
        } else {
          item['savedDate'] = 'Added on ${savedAt.month}/${savedAt.day}/${savedAt.year}';
        }

        return item;
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading wishlist: $e');
      _wishlistItems = [];
      notifyListeners();
    }
  }

  /// Check if listing is in wishlist
  bool isInWishlist(int listingId) {
    return _wishlistItems.any((item) => item['id'] == listingId);
  }

  /// Add listing to wishlist
  Future<bool> addToWishlist(Map<String, dynamic> listing) async {
    try {
      if (_authService.currentUser == null) {
        print('User not logged in');
        return false;
      }

      final listingId = listing['id'] as int;

      // Check if already in wishlist
      if (isInWishlist(listingId)) {
        return true;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      // Insert into database
      await db.insert('wishlists', {
        'user_id': userId,
        'listing_id': listingId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'is_deleted': 0,
        'sync_status': 'synced',
      });

      // Reload wishlist
      await loadWishlist();
      return true;
    } catch (e) {
      print('Error adding to wishlist: $e');
      return false;
    }
  }

  /// Remove listing from wishlist
  Future<bool> removeFromWishlist(int listingId) async {
    try {
      if (_authService.currentUser == null) {
        return false;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      // Soft delete from database
      await db.update(
        'wishlists',
        {
          'is_deleted': 1,
          'sync_status': 'pending',
        },
        where: 'user_id = ? AND listing_id = ?',
        whereArgs: [userId, listingId],
      );

      // Reload wishlist
      await loadWishlist();
      return true;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  /// Remove at specific index (for UI operations)
  Future<void> removeAtIndex(int index) async {
    if (index >= 0 && index < _wishlistItems.length) {
      final listingId = _wishlistItems[index]['id'] as int;
      await removeFromWishlist(listingId);
    }
  }

  /// Restore at index (for undo operations)
  Future<void> restoreAtIndex(int index, Map<String, dynamic> item) async {
    await addToWishlist(item);
  }

  /// Clear all wishlist items
  Future<bool> clearAll() async {
    try {
      if (_authService.currentUser == null) {
        return false;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      // Soft delete all wishlist items for current user
      await db.update(
        'wishlists',
        {
          'is_deleted': 1,
          'sync_status': 'pending',
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Reload wishlist
      await loadWishlist();
      return true;
    } catch (e) {
      print('Error clearing wishlist: $e');
      return false;
    }
  }

  /// Get total price of wishlist items
  double getTotalPrice() {
    return _wishlistItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] as num).toDouble(),
    );
  }

  /// Get wishlist count
  int get count => _wishlistItems.length;
}
