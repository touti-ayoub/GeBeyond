import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../database/database_helper.dart';
import 'package:flutter/foundation.dart';

/// Service to seed initial listings data into the database
class ListingsSeedService {
  static final ListingsSeedService _instance = ListingsSeedService._internal();
  factory ListingsSeedService() => _instance;
  ListingsSeedService._internal();

  final _dbHelper = DatabaseHelper.instance;
  bool _isSeeded = false;

  /// Seed mock listings if database is empty
  Future<void> seedListingsIfNeeded() async {
    if (_isSeeded) return;

    try {
      final db = await _dbHelper.database;

      // Check if listings already exist
      final count = sqflite.Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM listings')
      ) ?? 0;

      if (count > 0) {
        if (kDebugMode) {
          print('✅ Listings already seeded ($count listings)');
        }
        _isSeeded = true;
        return;
      }

      if (kDebugMode) {
        print('🌱 Seeding listings into database...');
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      // Seed mock listings
      final listings = [
        {
          'id': 1,
          'title': 'Luxury Beach Resort',
          'type': 'hotel',
          'location': 'Maldives',
          'price': 450.0,
          'rating': 4.8,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800']),
          'description': 'Stunning beachfront resort with private villas',
          'amenities': jsonEncode(['WiFi', 'Pool', 'Spa', 'Restaurant', 'Beach Access']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 2,
          'title': 'Mountain Retreat Lodge',
          'type': 'hotel',
          'location': 'Swiss Alps',
          'price': 320.0,
          'rating': 4.9,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800']),
          'description': 'Cozy mountain lodge with breathtaking views',
          'amenities': jsonEncode(['WiFi', 'Fireplace', 'Mountain View', 'Restaurant']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 3,
          'title': 'Paris Round Trip',
          'type': 'flight',
          'location': 'Paris, France',
          'price': 680.0,
          'rating': 4.6,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800']),
          'description': 'Direct flight to the city of lights',
          'amenities': jsonEncode(['WiFi', 'Meal', 'Entertainment']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 4,
          'title': 'City Center Boutique Hotel',
          'type': 'hotel',
          'location': 'Barcelona, Spain',
          'price': 180.0,
          'rating': 4.7,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800']),
          'description': 'Modern hotel in the heart of Barcelona',
          'amenities': jsonEncode(['WiFi', 'Rooftop Bar', 'City View', 'Gym']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 5,
          'title': 'Tokyo to Kyoto Bullet Train',
          'type': 'flight',
          'location': 'Japan',
          'price': 120.0,
          'rating': 4.9,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=800']),
          'description': 'High-speed rail experience through Japan',
          'amenities': jsonEncode(['WiFi', 'Reserved Seat', 'Scenic Views']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 6,
          'title': 'Scuba Diving Adventure',
          'type': 'experience',
          'location': 'Great Barrier Reef',
          'price': 250.0,
          'rating': 4.8,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800']),
          'description': 'Explore the underwater wonders',
          'amenities': jsonEncode(['Equipment Provided', 'Guide', 'Lunch']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 7,
          'title': 'Desert Safari Experience',
          'type': 'experience',
          'location': 'Dubai, UAE',
          'price': 150.0,
          'rating': 4.7,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1451337516015-6b6e9a44a8a3?w=800']),
          'description': 'Thrilling desert adventure with dinner',
          'amenities': jsonEncode(['4x4 Vehicle', 'BBQ Dinner', 'Camel Ride']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 8,
          'title': 'Northern Lights Tour',
          'type': 'experience',
          'location': 'Iceland',
          'price': 380.0,
          'rating': 5.0,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1483347756197-71ef80e95f73?w=800']),
          'description': 'Witness the magical aurora borealis',
          'amenities': jsonEncode(['Expert Guide', 'Transportation', 'Hot Drinks']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 9,
          'title': 'New York to London',
          'type': 'flight',
          'location': 'London, UK',
          'price': 520.0,
          'rating': 4.5,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800']),
          'description': 'Business class transatlantic flight',
          'amenities': jsonEncode(['WiFi', 'Lie-flat Seats', 'Premium Meals']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
        {
          'id': 10,
          'title': 'Safari Lodge',
          'type': 'hotel',
          'location': 'Serengeti, Tanzania',
          'price': 580.0,
          'rating': 4.9,
          'photos': jsonEncode(['https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800']),
          'description': 'Luxury safari experience with wildlife viewing',
          'amenities': jsonEncode(['All Inclusive', 'Safari Tours', 'Pool', 'Wildlife Viewing']),
          'created_at': now,
          'is_deleted': 0,
          'sync_status': 'synced',
        },
      ];

      // Insert all listings
      for (final listing in listings) {
        await db.insert('listings', listing);
      }

      if (kDebugMode) {
        print('✅ Successfully seeded ${listings.length} listings');
      }

      _isSeeded = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seeding listings: $e');
      }
    }
  }

  /// Get listing by ID from database
  Future<Map<String, dynamic>?> getListingById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'listings',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return {
        'id': row['id'],
        'title': row['title'],
        'type': row['type'],
        'location': row['location'],
        'price': row['price'],
        'rating': row['rating'],
        'image': _extractFirstPhoto(row['photos'] as String?),
        'description': row['description'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching listing: $e');
      }
      return null;
    }
  }

  String? _extractFirstPhoto(String? photos) {
    if (photos == null || photos.isEmpty) return null;
    try {
      if (photos.startsWith('[')) {
        final List<dynamic> photosList = jsonDecode(photos);
        return photosList.isNotEmpty ? photosList[0] : null;
      }
      return photos;
    } catch (e) {
      return null;
    }
  }
}

