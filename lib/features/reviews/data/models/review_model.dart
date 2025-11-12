import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    super.id,
    required super.userId,
    required super.listingId,
    super.bookingId,
    required super.rating,
    super.comment,
    super.images,
    super.pros,
    super.cons,
    super.tripType,
    required super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.syncStatus,
    super.userName,
    super.userPhoto,
    super.helpfulCount,
    super.notHelpfulCount,
  });

  /// Convert from database map
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      listingId: map['listing_id'] as int,
      bookingId: map['booking_id'] as int?,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      images: _parseStringList(map['images']),
      pros: _parseStringList(map['pros']),
      cons: _parseStringList(map['cons']),
      tripType: map['trip_type'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      isDeleted: (map['is_deleted'] as int) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      userName: map['user_name'] as String?,
      userPhoto: map['user_photo'] as String?,
      helpfulCount: map['helpful_count'] as int? ?? 0,
      notHelpfulCount: map['not_helpful_count'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'images': _stringifyList(images),
      'pros': _stringifyList(pros),
      'cons': _stringifyList(cons),
      'trip_type': tripType,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
    };
  }

  /// Helper to parse string list from database
  static List<String> _parseStringList(dynamic value) {
    if (value == null || value == '') return [];
    if (value is String) {
      // Assume comma-separated values
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  /// Helper to convert list to comma-separated string
  static String _stringifyList(List<String> list) {
    return list.join(',');
  }

  /// Create a copy with updated fields
  @override
  ReviewModel copyWith({
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
    return ReviewModel(
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
}

