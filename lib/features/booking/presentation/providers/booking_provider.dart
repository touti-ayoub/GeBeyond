import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:gobeyond/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:gobeyond/features/booking/domain/repositories/booking_repository.dart';
import 'package:gobeyond/features/booking/domain/entities/booking.dart';

// ============================================
// INFRASTRUCTURE PROVIDERS
// ============================================

/// Database helper provider (singleton)
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// ============================================
// DATA SOURCE PROVIDERS
// ============================================

/// Booking local data source provider
final bookingLocalDataSourceProvider = Provider<BookingLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BookingLocalDataSource(dbHelper);
});

// ============================================
// REPOSITORY PROVIDERS
// ============================================

/// Booking repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final localDataSource = ref.watch(bookingLocalDataSourceProvider);
  return BookingRepositoryImpl(localDataSource: localDataSource);
});

// ============================================
// USE CASE / BUSINESS LOGIC PROVIDERS
// ============================================

/// Get user bookings provider
final userBookingsProvider = FutureProvider.family<List<Booking>, int>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getUserBookings(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

/// Get upcoming bookings provider
final upcomingBookingsProvider = FutureProvider.family<List<Booking>, int>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getUpcomingBookings(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

/// Get past bookings provider
final pastBookingsProvider = FutureProvider.family<List<Booking>, int>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getPastBookings(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bookings) => bookings,
  );
});

/// Get booking by ID provider
final bookingByIdProvider = FutureProvider.family<Booking, int>((ref, id) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBookingById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (booking) => booking,
  );
});

/// Get user booking stats provider
final userBookingStatsProvider = FutureProvider.family<Map<String, int>, int>((ref, userId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getUserBookingStats(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

// ============================================
// STATE NOTIFIER PROVIDERS (for mutations)
// ============================================

/// State class for booking operations
class BookingState {
  final bool isLoading;
  final String? error;
  final Booking? booking;

  BookingState({
    this.isLoading = false,
    this.error,
    this.booking,
  });

  BookingState copyWith({
    bool? isLoading,
    String? error,
    Booking? booking,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      booking: booking ?? this.booking,
    );
  }
}

/// StateNotifier for booking operations
class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingNotifier(this._repository) : super(BookingState());

  /// Create a new booking
  Future<void> createBooking(Booking booking) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.createBooking(booking);
    
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (createdBooking) {
        state = state.copyWith(
          isLoading: false,
          booking: createdBooking,
          error: null,
        );
      },
    );
  }

  /// Update a booking
  Future<void> updateBooking(Booking booking) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.updateBooking(booking);
    
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (updatedBooking) {
        state = state.copyWith(
          isLoading: false,
          booking: updatedBooking,
          error: null,
        );
      },
    );
  }

  /// Cancel a booking
  Future<void> cancelBooking(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.cancelBooking(id);
    
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (cancelledBooking) {
        state = state.copyWith(
          isLoading: false,
          booking: cancelledBooking,
          error: null,
        );
      },
    );
  }

  /// Delete a booking
  Future<void> deleteBooking(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _repository.deleteBooking(id);
    
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, booking: null, error: null);
      },
    );
  }

  /// Reset state
  void reset() {
    state = BookingState();
  }
}

/// Booking notifier provider
final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});
