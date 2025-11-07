import 'package:equatable/equatable.dart';

/// Domain entity representing a booking
/// This is the clean business object used throughout the app
class Booking extends Equatable {
  final int? id;
  final int userId;
  final int listingId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final BookingStatus status;
  final String? paymentMethod;
  final String? bookingReference;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final SyncStatus syncStatus;

  const Booking({
    this.id,
    required this.userId,
    required this.listingId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    this.status = BookingStatus.booked,
    this.paymentMethod,
    this.bookingReference,
    this.specialRequests,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.synced,
  });

  /// Calculate the number of nights
  int get numberOfNights {
    return checkOut.difference(checkIn).inDays;
  }

  /// Check if booking is active
  bool get isActive {
    return status == BookingStatus.booked && !isDeleted;
  }

  /// Check if booking is in the past
  bool get isPast {
    return checkOut.isBefore(DateTime.now());
  }

  /// Check if booking is upcoming
  bool get isUpcoming {
    return checkIn.isAfter(DateTime.now()) && isActive;
  }

  /// Create a copy with updated fields
  Booking copyWith({
    int? id,
    int? userId,
    int? listingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? totalPrice,
    BookingStatus? status,
    String? paymentMethod,
    String? bookingReference,
    String? specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    SyncStatus? syncStatus,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listingId: listingId ?? this.listingId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingReference: bookingReference ?? this.bookingReference,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        listingId,
        checkIn,
        checkOut,
        guests,
        totalPrice,
        status,
        paymentMethod,
        bookingReference,
        specialRequests,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
      ];
}

enum BookingStatus {
  booked,
  cancelled,
  completed;

  String get value {
    switch (this) {
      case BookingStatus.booked:
        return 'booked';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'booked':
        return BookingStatus.booked;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.booked;
    }
  }
}

enum SyncStatus {
  synced,
  pending,
  conflict;

  String get value {
    switch (this) {
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.conflict:
        return 'conflict';
    }
  }

  static SyncStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'conflict':
        return SyncStatus.conflict;
      default:
        return SyncStatus.synced;
    }
  }
}
