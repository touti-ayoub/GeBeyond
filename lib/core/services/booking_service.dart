import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';
import 'rewards_service.dart';
import 'stripe_payment_service.dart';
import 'email_service.dart';
import 'dart:convert';

/// Booking Service - Manages user bookings with SQLite persistence
class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final _dbHelper = DatabaseHelper.instance;
  final _authService = AuthService.instance;

  List<Map<String, dynamic>> _bookings = [];
  bool _isInitialized = false;

  // Getters
  List<Map<String, dynamic>> get bookings => _bookings;
  bool get isInitialized => _isInitialized;

  /// Initialize the service and load saved bookings
  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadBookings();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load bookings from database for current user
  Future<void> loadBookings() async {
    try {
      if (_authService.currentUser == null) {
        _bookings = [];
        notifyListeners();
        if (kDebugMode) {
          print('⚠️ Cannot load bookings: User not logged in');
        }
        return;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      if (kDebugMode) {
        print('📂 Loading bookings for user ID: $userId');
      }

      final results = await db.rawQuery('''
        SELECT b.*, l.title as listing_title, l.photos as listing_photos,
               l.location as listing_location, l.type as listing_type
        FROM bookings b
        INNER JOIN listings l ON b.listing_id = l.id
        WHERE b.user_id = ? AND b.is_deleted = 0
        ORDER BY b.created_at DESC
      ''', [userId]);

      if (kDebugMode) {
        print('📊 Found ${results.length} bookings in database');
      }

      _bookings = results.map((row) {
        // Parse photos JSON string to get first photo
        String? listingImage;
        try {
          final photos = row['listing_photos'] as String?;
          if (photos != null && photos.isNotEmpty) {
            // If photos is a JSON array, parse it
            if (photos.startsWith('[')) {
              final List<dynamic> photosList = jsonDecode(photos);
              listingImage = photosList.isNotEmpty ? photosList[0] : null;
            } else {
              listingImage = photos;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing listing photos: $e');
          }
        }

        return {
          'id': row['id'],
          'bookingNumber': row['booking_reference'] ?? 'BK${row['id']}',
          'listing': {
            'id': row['listing_id'],
            'title': row['listing_title'],
            'image': listingImage ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
            'location': row['listing_location'],
            'type': row['listing_type'],
          },
          'checkIn': DateTime.fromMillisecondsSinceEpoch(row['check_in'] as int).toIso8601String(),
          'checkOut': DateTime.fromMillisecondsSinceEpoch(row['check_out'] as int).toIso8601String(),
          'guests': row['guests'],
          'totalPrice': row['total_price'],
          'status': row['status'],
          'paymentMethod': row['payment_method'],
          'specialRequests': row['special_requests'],
          'bookedAt': DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int).toIso8601String(),
        };
      }).toList();

      if (kDebugMode) {
        print('✅ Loaded ${_bookings.length} bookings');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading bookings: $e');
      }
      _bookings = [];
      notifyListeners();
    }
  }

  /// Create a new booking with payment
  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> listing,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    String? paymentMethod,
    String? specialRequests,
    bool processPayment = true, // New parameter to control payment
  }) async {
    try {
      if (_authService.currentUser == null) {
        if (kDebugMode) {
          print('❌ User not logged in');
        }
        return {
          'success': false,
          'error': 'User not logged in',
        };
      }

      // Process payment first if required
      String? paymentIntentId;
      if (processPayment) {
        if (kDebugMode) {
          print('💳 Processing payment for \$$totalPrice');
        }

        final paymentService = StripePaymentService();
        final paymentResult = await paymentService.processPayment(
          amount: totalPrice,
          description: 'Booking: ${listing['title']}',
          metadata: {
            'listing_id': listing['id'].toString(),
            'listing_title': listing['title'],
            'check_in': checkIn.toIso8601String(),
            'check_out': checkOut.toIso8601String(),
            'guests': guests.toString(),
            'user_id': _authService.currentUser!.id.toString(),
          },
        );

        if (!paymentResult.success) {
          if (kDebugMode) {
            print('❌ Payment failed: ${paymentResult.error}');
          }
          return {
            'success': false,
            'error': paymentResult.error ?? 'Payment failed',
            'errorCode': paymentResult.errorCode,
          };
        }

        paymentIntentId = paymentResult.paymentIntentId;
        if (kDebugMode) {
          print('✅ Payment successful: $paymentIntentId');
        }
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;
      final listingId = listing['id'] as int;
      final now = DateTime.now();

      // Ensure listing exists in database
      final existingListing = await db.query(
        'listings',
        where: 'id = ?',
        whereArgs: [listingId],
        limit: 1,
      );

      if (existingListing.isEmpty) {
        // Insert the listing if it doesn't exist
        if (kDebugMode) {
          print('📝 Inserting listing into database: ${listing['title']}');
        }

        await db.insert('listings', {
          'id': listingId,
          'title': listing['title'],
          'type': listing['type'],
          'location': listing['location'],
          'price': listing['price'],
          'rating': listing['rating'] ?? 0.0,
          'photos': jsonEncode([listing['image']]),
          'description': listing['description'] ?? '',
          'amenities': jsonEncode([]),
          'created_at': now.millisecondsSinceEpoch,
          'is_deleted': 0,
          'sync_status': 'synced',
        });
      }

      // Generate booking reference
      final bookingRef = 'BK${now.millisecondsSinceEpoch}';

      if (kDebugMode) {
        print('📝 Creating booking: $bookingRef');
        print('   User ID: $userId');
        print('   Listing ID: $listingId');
        print('   Check-in: $checkIn');
        print('   Check-out: $checkOut');
        print('   Guests: $guests');
        print('   Total: \$$totalPrice');
        print('   Payment Intent: $paymentIntentId');
      }

      // Insert booking with payment info
      final bookingId = await db.insert('bookings', {
        'user_id': userId,
        'listing_id': listingId,
        'check_in': checkIn.millisecondsSinceEpoch,
        'check_out': checkOut.millisecondsSinceEpoch,
        'guests': guests,
        'total_price': totalPrice,
        'status': processPayment ? 'booked' : 'pending',
        'payment_method': paymentMethod ?? 'stripe',
        'booking_reference': bookingRef,
        'special_requests': specialRequests,
        'created_at': now.millisecondsSinceEpoch,
        'is_deleted': 0,
        'sync_status': 'synced',
      });

      if (kDebugMode) {
        print('✅ Booking created successfully with ID: $bookingId');
      }

      // Award points for booking only if payment was successful
      if (processPayment) {
        final rewardsService = RewardsService();
        await rewardsService.initialize();
        await rewardsService.awardPointsForBooking(
          userId: userId,
          bookingAmount: totalPrice,
        );

        // Send confirmation email
        try {
          if (kDebugMode) {
            print('📧 Sending booking confirmation email...');
          }

          final emailService = EmailService();
          final emailSent = await emailService.sendBookingConfirmation(
            recipientEmail: _authService.currentUser!.email,
            recipientName: _authService.currentUser!.name,
            bookingReference: bookingRef,
            listingTitle: listing['title'],
            listingLocation: listing['location'],
            checkIn: checkIn,
            checkOut: checkOut,
            guests: guests,
            totalPrice: totalPrice,
            paymentIntentId: paymentIntentId!,
          );

          if (emailSent && kDebugMode) {
            print('✅ Confirmation email sent successfully');
          } else if (!emailSent && kDebugMode) {
            print('⚠️ Email sending failed (booking still confirmed)');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Email error (booking still confirmed): $e');
          }
        }
      }

      // Reload bookings
      await loadBookings();

      if (kDebugMode) {
        print('✅ Bookings reloaded. Total bookings: ${_bookings.length}');
      }

      return {
        'success': true,
        'bookingId': bookingId,
        'bookingReference': bookingRef,
        'paymentIntentId': paymentIntentId,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating booking: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(int bookingId) async {
    try {
      if (_authService.currentUser == null) {
        return false;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      await db.update(
        'bookings',
        {
          'status': 'cancelled',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'sync_status': 'pending',
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [bookingId, userId],
      );

      await loadBookings();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling booking: $e');
      }
      return false;
    }
  }

  /// Complete a booking
  Future<bool> completeBooking(int bookingId) async {
    try {
      if (_authService.currentUser == null) {
        return false;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      await db.update(
        'bookings',
        {
          'status': 'completed',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'sync_status': 'pending',
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [bookingId, userId],
      );

      await loadBookings();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error completing booking: $e');
      }
      return false;
    }
  }

  /// Get upcoming bookings
  List<Map<String, dynamic>> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) {
      if (booking['status'] == 'cancelled') return false;
      final checkIn = DateTime.parse(booking['checkIn']);
      return checkIn.isAfter(now);
    }).toList();
  }

  /// Get past bookings
  List<Map<String, dynamic>> getPastBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) {
      final checkOut = DateTime.parse(booking['checkOut']);
      return checkOut.isBefore(now) || booking['status'] == 'cancelled';
    }).toList();
  }

  /// Get booking by ID
  Future<Map<String, dynamic>?> getBookingById(int bookingId) async {
    try {
      final booking = _bookings.firstWhere(
        (b) => b['id'] == bookingId,
        orElse: () => {},
      );
      return booking.isEmpty ? null : booking;
    } catch (e) {
      return null;
    }
  }

  /// Clear all bookings (soft delete)
  Future<void> clearAllBookings() async {
    try {
      if (_authService.currentUser == null) {
        return;
      }

      final db = await _dbHelper.database;
      final userId = _authService.currentUser!.id!;

      await db.update(
        'bookings',
        {
          'is_deleted': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'sync_status': 'pending',
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      await loadBookings();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing bookings: $e');
      }
    }
  }

  /// Get total bookings count
  int get totalBookings => _bookings.length;

  /// Get completed bookings count
  int get completedBookings =>
      _bookings.where((b) => b['status'] == 'completed').length;
}
