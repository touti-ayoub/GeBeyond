import 'package:equatable/equatable.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary.dart';

/// Domain entity representing a reward
class Reward extends Equatable {
  final int? id;
  final int userId;
  final int points;
  final String? promoCode;
  final double? discountPercent;
  final String? description;
  final DateTime? expiryDate;
  final bool isRedeemed;
  final DateTime? redeemedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final SyncStatus syncStatus;

  const Reward({
    this.id,
    required this.userId,
    this.points = 0,
    this.promoCode,
    this.discountPercent,
    this.description,
    this.expiryDate,
    this.isRedeemed = false,
    this.redeemedAt,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.synced,
  });

  /// Check if reward is active (not expired, not redeemed, not deleted)
  bool get isActive {
    if (isDeleted || isRedeemed) return false;
    if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  /// Check if reward is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Get days until expiry (null if no expiry or already expired)
  int? get daysUntilExpiry {
    if (expiryDate == null || isExpired) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Create a copy with updated fields
  Reward copyWith({
    int? id,
    int? userId,
    int? points,
    String? promoCode,
    double? discountPercent,
    String? description,
    DateTime? expiryDate,
    bool? isRedeemed,
    DateTime? redeemedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    SyncStatus? syncStatus,
  }) {
    return Reward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      promoCode: promoCode ?? this.promoCode,
      discountPercent: discountPercent ?? this.discountPercent,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redeemedAt: redeemedAt ?? this.redeemedAt,
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
        points,
        promoCode,
        discountPercent,
        description,
        expiryDate,
        isRedeemed,
        redeemedAt,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
      ];
}

