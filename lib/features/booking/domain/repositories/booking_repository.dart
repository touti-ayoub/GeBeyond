import 'package:gobeyond/features/booking/domain/entities/booking.dart';
import 'package:dartz/dartz.dart';
import 'package:gobeyond/core/error/failures.dart';

/// Abstract repository interface for booking operations
/// This defines the contract that the data layer must implement
abstract class BookingRepository {
  /// Create a new booking
  Future<Either<Failure, Booking>> createBooking(Booking booking);

  /// Get a booking by ID
  Future<Either<Failure, Booking>> getBookingById(int id);

  /// Get all bookings for a user
  Future<Either<Failure, List<Booking>>> getUserBookings(
    int userId, {
    BookingStatus? status,
  });

  /// Get upcoming bookings for a user
  Future<Either<Failure, List<Booking>>> getUpcomingBookings(int userId);

  /// Get past bookings for a user
  Future<Either<Failure, List<Booking>>> getPastBookings(int userId);

  /// Update a booking
  Future<Either<Failure, Booking>> updateBooking(Booking booking);

  /// Cancel a booking
  Future<Either<Failure, Booking>> cancelBooking(int id);

  /// Complete a booking
  Future<Either<Failure, Booking>> completeBooking(int id);

  /// Delete a booking
  Future<Either<Failure, void>> deleteBooking(int id);

  /// Get booking by reference number
  Future<Either<Failure, Booking>> getBookingByReference(String reference);

  /// Get booking statistics for a user
  Future<Either<Failure, Map<String, int>>> getUserBookingStats(int userId);

  /// Sync pending bookings with remote server (for future implementation)
  Future<Either<Failure, void>> syncBookings();
}
