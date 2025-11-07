import 'package:sqflite/sqflite.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/booking/data/models/booking_model.dart';
import 'package:gobeyond/features/booking/domain/entities/booking.dart';

/// Local data source for Booking operations using SQLite
class BookingLocalDataSource {
  final DatabaseHelper _dbHelper;

  BookingLocalDataSource(this._dbHelper);

  static const String _tableName = 'bookings';

  /// Create a new booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    final db = await _dbHelper.database;
    
    final bookingMap = booking.toMap();
    bookingMap.remove('id'); // Remove id for auto-increment
    
    final id = await db.insert(
      _tableName,
      bookingMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return booking.copyWith(id: id) as BookingModel;
  }

  /// Get a booking by ID
  Future<BookingModel?> getBookingById(int id) async {
    final db = await _dbHelper.database;
    
    final results = await db.query(
      _tableName,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return BookingModel.fromMap(results.first);
  }

  /// Get all bookings for a user
  Future<List<BookingModel>> getUserBookings(
    int userId, {
    BookingStatus? status,
    bool includeDeleted = false,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (!includeDeleted) {
      whereClause += ' AND is_deleted = 0';
    }

    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status.value);
    }

    final results = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'check_in DESC',
    );

    return results.map((map) => BookingModel.fromMap(map)).toList();
  }

  /// Get upcoming bookings for a user
  Future<List<BookingModel>> getUpcomingBookings(int userId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final results = await db.query(
      _tableName,
      where: 'user_id = ? AND check_in > ? AND status = ? AND is_deleted = 0',
      whereArgs: [userId, now, BookingStatus.booked.value],
      orderBy: 'check_in ASC',
    );

    return results.map((map) => BookingModel.fromMap(map)).toList();
  }

  /// Get past bookings for a user
  Future<List<BookingModel>> getPastBookings(int userId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final results = await db.query(
      _tableName,
      where: 'user_id = ? AND check_out < ? AND is_deleted = 0',
      whereArgs: [userId, now],
      orderBy: 'check_out DESC',
    );

    return results.map((map) => BookingModel.fromMap(map)).toList();
  }

  /// Get all bookings for a specific listing
  Future<List<BookingModel>> getListingBookings(int listingId) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      _tableName,
      where: 'listing_id = ? AND is_deleted = 0',
      whereArgs: [listingId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => BookingModel.fromMap(map)).toList();
  }

  /// Update a booking
  Future<BookingModel> updateBooking(BookingModel booking) async {
    final db = await _dbHelper.database;
    
    if (booking.id == null) {
      throw Exception('Cannot update booking without id');
    }

    final updatedBooking = booking.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending, // Mark as pending sync
    ) as BookingModel;

    await db.update(
      _tableName,
      updatedBooking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );

    return updatedBooking;
  }

  /// Cancel a booking (soft update)
  Future<BookingModel> cancelBooking(int id) async {
    final booking = await getBookingById(id);
    if (booking == null) {
      throw Exception('Booking not found');
    }

    return await updateBooking(
      booking.copyWith(
        status: BookingStatus.cancelled,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      ) as BookingModel,
    );
  }

  /// Complete a booking
  Future<BookingModel> completeBooking(int id) async {
    final booking = await getBookingById(id);
    if (booking == null) {
      throw Exception('Booking not found');
    }

    return await updateBooking(
      booking.copyWith(
        status: BookingStatus.completed,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      ) as BookingModel,
    );
  }

  /// Soft delete a booking
  Future<void> deleteBooking(int id) async {
    final db = await _dbHelper.database;
    
    await db.update(
      _tableName,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'sync_status': SyncStatus.pending.value,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard delete a booking (use with caution)
  Future<void> hardDeleteBooking(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all bookings pending sync
  Future<List<BookingModel>> getPendingSyncBookings() async {
    final db = await _dbHelper.database;

    final results = await db.query(
      _tableName,
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.value],
    );

    return results.map((map) => BookingModel.fromMap(map)).toList();
  }

  /// Mark booking as synced
  Future<void> markAsSynced(int id) async {
    final db = await _dbHelper.database;

    await db.update(
      _tableName,
      {'sync_status': SyncStatus.synced.value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Search bookings by reference
  Future<BookingModel?> getBookingByReference(String reference) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      _tableName,
      where: 'booking_reference = ? AND is_deleted = 0',
      whereArgs: [reference],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return BookingModel.fromMap(results.first);
  }

  /// Get booking statistics for a user
  Future<Map<String, int>> getUserBookingStats(int userId) async {
    final db = await _dbHelper.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE user_id = ? AND is_deleted = 0',
      [userId],
    );

    final bookedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE user_id = ? AND status = ? AND is_deleted = 0',
      [userId, BookingStatus.booked.value],
    );

    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE user_id = ? AND status = ? AND is_deleted = 0',
      [userId, BookingStatus.completed.value],
    );

    final cancelledResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE user_id = ? AND status = ? AND is_deleted = 0',
      [userId, BookingStatus.cancelled.value],
    );

    return {
      'total': totalResult.first['count'] as int,
      'booked': bookedResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'cancelled': cancelledResult.first['count'] as int,
    };
  }

  /// Delete all bookings (for testing/cleanup)
  Future<void> deleteAllBookings() async {
    final db = await _dbHelper.database;
    await db.delete(_tableName);
  }
}
