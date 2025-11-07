import 'package:gobeyond/features/booking/domain/entities/booking.dart';

/// Data layer model that extends the domain entity
/// Handles serialization/deserialization to/from SQLite
class BookingModel extends Booking {
  const BookingModel({
    super.id,
    required super.userId,
    required super.listingId,
    required super.checkIn,
    required super.checkOut,
    required super.guests,
    required super.totalPrice,
    super.status,
    super.paymentMethod,
    super.bookingReference,
    super.specialRequests,
    required super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.syncStatus,
  });

  /// Create BookingModel from domain entity
  factory BookingModel.fromEntity(Booking booking) {
    return BookingModel(
      id: booking.id,
      userId: booking.userId,
      listingId: booking.listingId,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      guests: booking.guests,
      totalPrice: booking.totalPrice,
      status: booking.status,
      paymentMethod: booking.paymentMethod,
      bookingReference: booking.bookingReference,
      specialRequests: booking.specialRequests,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
      isDeleted: booking.isDeleted,
      syncStatus: booking.syncStatus,
    );
  }

  /// Create BookingModel from SQLite Map
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      listingId: map['listing_id'] as int,
      checkIn: DateTime.fromMillisecondsSinceEpoch(map['check_in'] as int),
      checkOut: DateTime.fromMillisecondsSinceEpoch(map['check_out'] as int),
      guests: map['guests'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: BookingStatus.fromString(map['status'] as String),
      paymentMethod: map['payment_method'] as String?,
      bookingReference: map['booking_reference'] as String?,
      specialRequests: map['special_requests'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      isDeleted: (map['is_deleted'] as int) == 1,
      syncStatus: SyncStatus.fromString(map['sync_status'] as String),
    );
  }

  /// Convert BookingModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'check_in': checkIn.millisecondsSinceEpoch,
      'check_out': checkOut.millisecondsSinceEpoch,
      'guests': guests,
      'total_price': totalPrice,
      'status': status.value,
      'payment_method': paymentMethod,
      'booking_reference': bookingReference,
      'special_requests': specialRequests,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus.value,
    };
  }

  /// Create BookingModel from JSON (for future API integration)
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      listingId: json['listing_id'] as int,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      guests: json['guests'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: BookingStatus.fromString(json['status'] as String),
      paymentMethod: json['payment_method'] as String?,
      bookingReference: json['booking_reference'] as String?,
      specialRequests: json['special_requests'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isDeleted: json['is_deleted'] == true || json['is_deleted'] == 1,
      syncStatus: SyncStatus.fromString(json['sync_status'] as String? ?? 'synced'),
    );
  }

  /// Convert BookingModel to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'guests': guests,
      'total_price': totalPrice,
      'status': status.value,
      'payment_method': paymentMethod,
      'booking_reference': bookingReference,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'sync_status': syncStatus.value,
    };
  }

  /// Convert to domain entity
  Booking toEntity() {
    return Booking(
      id: id,
      userId: userId,
      listingId: listingId,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      totalPrice: totalPrice,
      status: status,
      paymentMethod: paymentMethod,
      bookingReference: bookingReference,
      specialRequests: specialRequests,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      syncStatus: syncStatus,
    );
  }
}
