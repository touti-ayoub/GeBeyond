import 'package:dartz/dartz.dart';
import 'package:gobeyond/core/error/exceptions.dart';
import 'package:gobeyond/core/error/failures.dart';
import 'package:gobeyond/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:gobeyond/features/booking/data/models/booking_model.dart';
import 'package:gobeyond/features/booking/domain/entities/booking.dart';
import 'package:gobeyond/features/booking/domain/repositories/booking_repository.dart';

/// Concrete implementation of BookingRepository
/// Handles data operations and error handling
class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource localDataSource;
  // final BookingRemoteDataSource remoteDataSource; // For future API integration
  // final NetworkInfo networkInfo; // For connectivity checks

  BookingRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Booking>> createBooking(Booking booking) async {
    try {
      final bookingModel = BookingModel.fromEntity(booking);
      final result = await localDataSource.createBooking(bookingModel);
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(int id) async {
    try {
      final result = await localDataSource.getBookingById(id);
      if (result == null) {
        return const Left(NotFoundFailure(message: 'Booking not found'));
      }
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings(
    int userId, {
    BookingStatus? status,
  }) async {
    try {
      final results = await localDataSource.getUserBookings(
        userId,
        status: status,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUpcomingBookings(int userId) async {
    try {
      final results = await localDataSource.getUpcomingBookings(userId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getPastBookings(int userId) async {
    try {
      final results = await localDataSource.getPastBookings(userId);
      return Right(results.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBooking(Booking booking) async {
    try {
      final bookingModel = BookingModel.fromEntity(booking);
      final result = await localDataSource.updateBooking(bookingModel);
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(int id) async {
    try {
      final result = await localDataSource.cancelBooking(id);
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> completeBooking(int id) async {
    try {
      final result = await localDataSource.completeBooking(id);
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBooking(int id) async {
    try {
      await localDataSource.deleteBooking(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingByReference(String reference) async {
    try {
      final result = await localDataSource.getBookingByReference(reference);
      if (result == null) {
        return const Left(NotFoundFailure(message: 'Booking not found'));
      }
      return Right(result.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserBookingStats(int userId) async {
    try {
      final stats = await localDataSource.getUserBookingStats(userId);
      return Right(stats);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncBookings() async {
    try {
      // Get all bookings pending sync
      final pendingBookings = await localDataSource.getPendingSyncBookings();
      
      // Future implementation: Send to remote API
      // if (await networkInfo.isConnected) {
      //   for (final booking in pendingBookings) {
      //     try {
      //       await remoteDataSource.syncBooking(booking);
      //       await localDataSource.markAsSynced(booking.id!);
      //     } catch (e) {
      //       // Handle sync error, maybe mark as conflict
      //     }
      //   }
      // }

      // For now, just return success
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure(message: e.toString()));
    }
  }
}
