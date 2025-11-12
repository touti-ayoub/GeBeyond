import '../database/database_helper.dart';
import '../../features/reviews/data/models/review_model.dart';
import '../../features/reviews/domain/entities/review.dart';

class ReviewsService {
  final _dbHelper = DatabaseHelper.instance;

  /// Add a new review
  Future<int> addReview(Review review) async {
    final db = await _dbHelper.database;
    final model = ReviewModel(
      userId: review.userId,
      listingId: review.listingId,
      bookingId: review.bookingId,
      rating: review.rating,
      comment: review.comment,
      images: review.images,
      pros: review.pros,
      cons: review.cons,
      tripType: review.tripType,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
      syncStatus: 'pending',
    );

    final id = await db.insert('reviews', model.toMap());

    // Update listing's average rating
    await _updateListingRating(review.listingId);

    return id;
  }

  /// Get all reviews for a listing
  Future<List<Review>> getReviewsByListing(int listingId) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT r.*, u.name as user_name, u.profile_photo as user_photo
      FROM reviews r
      LEFT JOIN users u ON r.user_id = u.id
      WHERE r.listing_id = ? AND r.is_deleted = 0
      ORDER BY r.created_at DESC
    ''', [listingId]);

    return results.map((map) => ReviewModel.fromMap(map)).toList();
  }

  /// Get review statistics for a listing
  Future<ReviewStats> getReviewStats(int listingId) async {
    final db = await _dbHelper.database;

    // Get total reviews and average rating
    final summary = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        AVG(rating) as average
      FROM reviews
      WHERE listing_id = ? AND is_deleted = 0
    ''', [listingId]);

    final total = summary.first['total'] as int;
    final average = (summary.first['average'] as num?)?.toDouble() ?? 0.0;

    // Get rating distribution
    final distribution = await db.rawQuery('''
      SELECT rating, COUNT(*) as count
      FROM reviews
      WHERE listing_id = ? AND is_deleted = 0
      GROUP BY rating
    ''', [listingId]);

    final ratingDist = <int, int>{};
    for (var row in distribution) {
      ratingDist[(row['rating'] as num).toInt()] = row['count'] as int;
    }

    // Get trip type distribution
    final tripTypes = await db.rawQuery('''
      SELECT trip_type, COUNT(*) as count
      FROM reviews
      WHERE listing_id = ? AND is_deleted = 0 AND trip_type IS NOT NULL
      GROUP BY trip_type
    ''', [listingId]);

    final tripTypeDist = <String, int>{};
    for (var row in tripTypes) {
      final tripType = row['trip_type'] as String?;
      if (tripType != null) {
        tripTypeDist[tripType] = row['count'] as int;
      }
    }

    return ReviewStats(
      totalReviews: total,
      averageRating: average,
      ratingDistribution: ratingDist,
      tripTypeDistribution: tripTypeDist,
    );
  }

  /// Update a review
  Future<void> updateReview(Review review) async {
    if (review.id == null) return;

    final db = await _dbHelper.database;
    final model = ReviewModel(
      id: review.id,
      userId: review.userId,
      listingId: review.listingId,
      bookingId: review.bookingId,
      rating: review.rating,
      comment: review.comment,
      images: review.images,
      pros: review.pros,
      cons: review.cons,
      tripType: review.tripType,
      createdAt: review.createdAt,
      updatedAt: DateTime.now(),
      isDeleted: review.isDeleted,
      syncStatus: 'pending',
    );

    await db.update(
      'reviews',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );

    // Update listing's average rating
    await _updateListingRating(review.listingId);
  }

  /// Delete a review (soft delete)
  Future<void> deleteReview(int reviewId, int listingId) async {
    final db = await _dbHelper.database;
    await db.update(
      'reviews',
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'sync_status': 'pending',
      },
      where: 'id = ?',
      whereArgs: [reviewId],
    );

    // Update listing's average rating
    await _updateListingRating(listingId);
  }

  /// Mark review as helpful
  Future<void> markHelpful(int reviewId, bool isHelpful) async {
    final db = await _dbHelper.database;
    final field = isHelpful ? 'helpful_count' : 'not_helpful_count';

    await db.rawUpdate('''
      UPDATE reviews
      SET $field = $field + 1
      WHERE id = ?
    ''', [reviewId]);
  }

  /// Get user's reviews
  Future<List<Review>> getUserReviews(int userId) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT r.*, l.title as listing_title, l.type as listing_type
      FROM reviews r
      LEFT JOIN listings l ON r.listing_id = l.id
      WHERE r.user_id = ? AND r.is_deleted = 0
      ORDER BY r.created_at DESC
    ''', [userId]);

    return results.map((map) => ReviewModel.fromMap(map)).toList();
  }

  /// Check if user has reviewed a listing
  Future<bool> hasUserReviewed(int userId, int listingId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'reviews',
      where: 'user_id = ? AND listing_id = ? AND is_deleted = 0',
      whereArgs: [userId, listingId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Get user's review for a listing
  Future<Review?> getUserReviewForListing(int userId, int listingId) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'reviews',
      where: 'user_id = ? AND listing_id = ? AND is_deleted = 0',
      whereArgs: [userId, listingId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return ReviewModel.fromMap(results.first);
  }

  /// Update listing's average rating
  Future<void> _updateListingRating(int listingId) async {
    final stats = await getReviewStats(listingId);
    final db = await _dbHelper.database;

    await db.update(
      'listings',
      {
        'rating': stats.averageRating,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [listingId],
    );
  }

  /// Get recent reviews (for dashboard/home)
  Future<List<Review>> getRecentReviews({int limit = 10}) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT r.*, u.name as user_name, u.profile_photo as user_photo,
             l.title as listing_title, l.type as listing_type
      FROM reviews r
      LEFT JOIN users u ON r.user_id = u.id
      LEFT JOIN listings l ON r.listing_id = l.id
      WHERE r.is_deleted = 0
      ORDER BY r.created_at DESC
      LIMIT ?
    ''', [limit]);

    return results.map((map) => ReviewModel.fromMap(map)).toList();
  }

  /// Search reviews by keyword
  Future<List<Review>> searchReviews(String query, {int? listingId}) async {
    final db = await _dbHelper.database;

    final whereClause = listingId != null
        ? 'r.listing_id = ? AND r.comment LIKE ? AND r.is_deleted = 0'
        : 'r.comment LIKE ? AND r.is_deleted = 0';

    final whereArgs = listingId != null
        ? [listingId, '%$query%']
        : ['%$query%'];

    final results = await db.rawQuery('''
      SELECT r.*, u.name as user_name, u.profile_photo as user_photo
      FROM reviews r
      LEFT JOIN users u ON r.user_id = u.id
      WHERE $whereClause
      ORDER BY r.created_at DESC
    ''', whereArgs);

    return results.map((map) => ReviewModel.fromMap(map)).toList();
  }
}

