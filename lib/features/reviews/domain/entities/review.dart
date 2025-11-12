import 'package:equatable/equatable.dart';

/// Domain entity representing a review/feedback
class Review extends Equatable {
  final int? id;
  final int userId;
  final int listingId;
  final int? bookingId;
  final double rating; // 1.0 to 5.0
  final String? comment;
  final List<String> images; // Review photos
  final List<String> pros; // Positive aspects
  final List<String> cons; // Negative aspects
  final String? tripType; // solo, family, couple, business
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final String syncStatus;

  // User details (denormalized for easy display)
  final String? userName;
  final String? userPhoto;

  // Helpfulness tracking
  final int helpfulCount;
  final int notHelpfulCount;

  const Review({
    this.id,
    required this.userId,
    required this.listingId,
    this.bookingId,
    required this.rating,
    this.comment,
    this.images = const [],
    this.pros = const [],
    this.cons = const [],
    this.tripType,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = 'synced',
    this.userName,
    this.userPhoto,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
  });

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  /// Get star rating as integer
  int get starRating => rating.round();

  /// Check if review has images
  bool get hasImages => images.isNotEmpty;

  /// Check if review is detailed (has pros/cons)
  bool get isDetailed => pros.isNotEmpty || cons.isNotEmpty;

  /// Get helpfulness percentage
  double get helpfulPercentage {
    final total = helpfulCount + notHelpfulCount;
    if (total == 0) return 0.0;
    return (helpfulCount / total) * 100;
  }

  Review copyWith({
    int? id,
    int? userId,
    int? listingId,
    int? bookingId,
    double? rating,
    String? comment,
    List<String>? images,
    List<String>? pros,
    List<String>? cons,
    String? tripType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? syncStatus,
    String? userName,
    String? userPhoto,
    int? helpfulCount,
    int? notHelpfulCount,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      listingId: listingId ?? this.listingId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      tripType: tripType ?? this.tripType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        listingId,
        bookingId,
        rating,
        comment,
        images,
        pros,
        cons,
        tripType,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
        userName,
        userPhoto,
        helpfulCount,
        notHelpfulCount,
      ];
}

/// Review statistics for a listing
class ReviewStats extends Equatable {
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution; // {5: 120, 4: 45, 3: 10, 2: 5, 1: 2}
  final Map<String, int> tripTypeDistribution; // {'family': 50, 'couple': 30, ...}

  const ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.tripTypeDistribution,
  });

  /// Get percentage for a specific rating
  double getRatingPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  @override
  List<Object?> get props => [
        totalReviews,
        averageRating,
        ratingDistribution,
        tripTypeDistribution,
      ];
}

