import 'package:flutter/material.dart';

/// Simple wishlist service to manage favorite listings
/// In a production app, this would integrate with a database or API
class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final List<Map<String, dynamic>> _wishlistItems = [];

  List<Map<String, dynamic>> get wishlistItems => List.unmodifiable(_wishlistItems);

  bool isInWishlist(int id) {
    return _wishlistItems.any((item) => item['id'] == id);
  }

  void addToWishlist(Map<String, dynamic> listing) {
    // Check if already in wishlist
    if (!isInWishlist(listing['id'])) {
      final now = DateTime.now();
      final item = Map<String, dynamic>.from(listing);
      item['savedDate'] = 'Added just now';
      _wishlistItems.insert(0, item); // Add to beginning
      notifyListeners();
    }
  }

  void removeFromWishlist(int id) {
    _wishlistItems.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void removeAtIndex(int index) {
    if (index >= 0 && index < _wishlistItems.length) {
      _wishlistItems.removeAt(index);
      notifyListeners();
    }
  }

  void restoreAtIndex(int index, Map<String, dynamic> item) {
    if (index >= 0 && index <= _wishlistItems.length) {
      _wishlistItems.insert(index, item);
      notifyListeners();
    }
  }

  void clearAll() {
    _wishlistItems.clear();
    notifyListeners();
  }

  double getTotalPrice() {
    return _wishlistItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] as num).toDouble(),
    );
  }
}
