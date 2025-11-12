import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/core/services/auth_service.dart';
import 'package:gobeyond/features/itinerary/data/models/itinerary_model.dart';
import 'package:gobeyond/features/itinerary/data/models/itinerary_item_model.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary_item.dart';

/// Itinerary Service - Manages user itineraries with authentication
class ItineraryService extends ChangeNotifier {
  static final ItineraryService _instance = ItineraryService._internal();
  factory ItineraryService() => _instance;
  ItineraryService._internal();

  Database? _db;
  final _authService = AuthService.instance;
  List<Itinerary> _itineraries = [];
  Map<int, List<ItineraryItem>> _itineraryItems = {};
  bool _isInitialized = false;

  // Getters
  List<Itinerary> get itineraries => _itineraries;
  bool get isInitialized => _isInitialized;

  List<ItineraryItem> getItemsForItinerary(int itineraryId) {
    return _itineraryItems[itineraryId] ?? [];
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _db = await DatabaseHelper.instance.database;
    await loadItineraries();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load itineraries for current user
  Future<void> loadItineraries() async {
    if (_db == null) await initialize();

    try {
      if (_authService.currentUser == null) {
        _itineraries = [];
        _itineraryItems = {};
        notifyListeners();
        return;
      }

      final userId = _authService.currentUser!.id!;

      final List<Map<String, dynamic>> maps = await _db!.query(
        'itineraries',
        where: 'user_id = ? AND is_deleted = 0',
        whereArgs: [userId],
        orderBy: 'start_date DESC',
      );

      _itineraries = maps.map((map) => ItineraryModel.fromMap(map)).toList();

      // Load items for each itinerary
      for (final itinerary in _itineraries) {
        if (itinerary.id != null) {
          await _loadItemsForItinerary(itinerary.id!);
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading itineraries: $e');
      }
    }
  }

  /// Load items for a specific itinerary
  Future<void> _loadItemsForItinerary(int itineraryId) async {
    if (_db == null) return;

    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'itinerary_items',
        where: 'itinerary_id = ? AND is_deleted = 0',
        whereArgs: [itineraryId],
        orderBy: 'scheduled_time ASC',
      );

      _itineraryItems[itineraryId] =
          maps.map((map) => ItineraryItemModel.fromMap(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading itinerary items: $e');
      }
    }
  }

  /// Create a new itinerary
  Future<int?> createItinerary({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? destination,
    String? notes,
  }) async {
    if (_db == null) await initialize();

    if (_authService.currentUser == null) {
      if (kDebugMode) {
        print('User not logged in');
      }
      return null;
    }

    try {
      final userId = _authService.currentUser!.id!;
      final now = DateTime.now();
      final itinerary = ItineraryModel(
        userId: userId,
        title: title,
        startDate: startDate,
        endDate: endDate,
        destination: destination,
        notes: notes,
        createdAt: now,
      );

      final id = await _db!.insert('itineraries', itinerary.toMap());
      await loadItineraries();
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating itinerary: $e');
      }
      return null;
    }
  }

  /// Update an itinerary
  Future<bool> updateItinerary({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    String? notes,
  }) async {
    if (_db == null) await initialize();

    if (_authService.currentUser == null) {
      return false;
    }

    try {
      final existing = _itineraries.firstWhere((i) => i.id == id);
      final updated = ItineraryModel.fromEntity(existing.copyWith(
        title: title,
        startDate: startDate,
        endDate: endDate,
        destination: destination,
        notes: notes,
        updatedAt: DateTime.now(),
      ));

      await _db!.update(
        'itineraries',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadItineraries();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating itinerary: $e');
      }
      return false;
    }
  }

  /// Delete an itinerary
  Future<bool> deleteItinerary(int id) async {
    if (_db == null) await initialize();

    if (_authService.currentUser == null) {
      return false;
    }

    try {
      await _db!.update(
        'itineraries',
        {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadItineraries();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting itinerary: $e');
      }
      return false;
    }
  }

  /// Add an item to an itinerary
  Future<int?> addItem({
    required int itineraryId,
    int? bookingId,
    required ItemType itemType,
    required String title,
    String? description,
    DateTime? scheduledTime,
    String? location,
  }) async {
    if (_db == null) await initialize();

    try {
      final item = ItineraryItemModel(
        itineraryId: itineraryId,
        bookingId: bookingId,
        itemType: itemType,
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        location: location,
        createdAt: DateTime.now(),
      );

      final id = await _db!.insert('itinerary_items', item.toMap());
      await _loadItemsForItinerary(itineraryId);
      notifyListeners();
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding itinerary item: $e');
      }
      return null;
    }
  }

  /// Update an itinerary item
  Future<bool> updateItem({
    required int id,
    required int itineraryId,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? location,
  }) async {
    if (_db == null) await initialize();

    try {
      final items = _itineraryItems[itineraryId] ?? [];
      final existing = items.firstWhere((i) => i.id == id);
      final updated = ItineraryItemModel.fromEntity(existing.copyWith(
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        location: location,
      ));

      await _db!.update(
        'itinerary_items',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadItemsForItinerary(itineraryId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating itinerary item: $e');
      }
      return false;
    }
  }

  /// Delete an itinerary item
  Future<bool> deleteItem(int id, int itineraryId) async {
    if (_db == null) await initialize();

    try {
      await _db!.update(
        'itinerary_items',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadItemsForItinerary(itineraryId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting itinerary item: $e');
      }
      return false;
    }
  }

  /// Get upcoming itineraries
  List<Itinerary> getUpcomingItineraries() {
    return _itineraries.where((i) => i.isUpcoming).toList();
  }

  /// Get ongoing itineraries
  List<Itinerary> getOngoingItineraries() {
    return _itineraries.where((i) => i.isOngoing).toList();
  }

  /// Get past itineraries
  List<Itinerary> getPastItineraries() {
    return _itineraries.where((i) => i.isPast).toList();
  }
}

