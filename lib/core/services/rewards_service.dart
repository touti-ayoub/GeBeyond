import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gobeyond/core/database/database_helper.dart';
import 'package:gobeyond/features/rewards/data/models/reward_model.dart';
import 'package:gobeyond/features/rewards/domain/entities/reward.dart';

/// Rewards Service - Manages user rewards and loyalty points
class RewardsService extends ChangeNotifier {
  static final RewardsService _instance = RewardsService._internal();
  factory RewardsService() => _instance;
  RewardsService._internal();

  Database? _db;
  List<Reward> _rewards = [];
  int _totalPoints = 0;
  bool _isInitialized = false;

  // Getters
  List<Reward> get rewards => _rewards;
  int get totalPoints => _totalPoints;
  bool get isInitialized => _isInitialized;

  List<Reward> get activeRewards =>
      _rewards.where((r) => r.isActive).toList();

  List<Reward> get expiredRewards =>
      _rewards.where((r) => r.isExpired && !r.isRedeemed).toList();

  List<Reward> get redeemedRewards =>
      _rewards.where((r) => r.isRedeemed).toList();

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _db = await DatabaseHelper.instance.database;
    await loadRewards();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load rewards for a user
  Future<void> loadRewards({int userId = 1}) async {
    if (_db == null) await initialize();

    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'rewards',
        where: 'user_id = ? AND is_deleted = 0',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      _rewards = maps.map((map) => RewardModel.fromMap(map)).toList();

      // Calculate total points from all point-based rewards
      _totalPoints = _rewards
          .where((r) => !r.isRedeemed && !r.isDeleted)
          .fold(0, (sum, reward) => sum + reward.points);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading rewards: $e');
      }
    }
  }

  /// Create a new reward (usually done by the system when user earns points)
  Future<int?> createReward({
    required int userId,
    int points = 0,
    String? promoCode,
    double? discountPercent,
    String? description,
    DateTime? expiryDate,
  }) async {
    if (_db == null) await initialize();

    try {
      final reward = RewardModel(
        userId: userId,
        points: points,
        promoCode: promoCode,
        discountPercent: discountPercent,
        description: description,
        expiryDate: expiryDate,
        createdAt: DateTime.now(),
      );

      final id = await _db!.insert('rewards', reward.toMap());
      await loadRewards(userId: userId);
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating reward: $e');
      }
      return null;
    }
  }

  /// Award points to a user
  Future<bool> awardPoints({
    required int userId,
    required int points,
    required String description,
  }) async {
    final id = await createReward(
      userId: userId,
      points: points,
      description: description,
    );
    return id != null;
  }

  /// Create a promo code reward
  Future<bool> createPromoCode({
    required int userId,
    required String promoCode,
    required double discountPercent,
    required String description,
    required DateTime expiryDate,
  }) async {
    final id = await createReward(
      userId: userId,
      promoCode: promoCode,
      discountPercent: discountPercent,
      description: description,
      expiryDate: expiryDate,
    );
    return id != null;
  }

  /// Redeem a reward
  Future<bool> redeemReward(int id, {int userId = 1}) async {
    if (_db == null) await initialize();

    try {
      final reward = _rewards.firstWhere((r) => r.id == id);

      if (!reward.isActive) {
        if (kDebugMode) {
          print('Cannot redeem inactive reward');
        }
        return false;
      }

      final updated = RewardModel.fromEntity(reward.copyWith(
        isRedeemed: true,
        redeemedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await _db!.update(
        'rewards',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadRewards(userId: userId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error redeeming reward: $e');
      }
      return false;
    }
  }

  /// Delete a reward
  Future<bool> deleteReward(int id, {int userId = 1}) async {
    if (_db == null) await initialize();

    try {
      await _db!.update(
        'rewards',
        {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );

      await loadRewards(userId: userId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting reward: $e');
      }
      return false;
    }
  }

  /// Award points for a completed booking
  Future<void> awardPointsForBooking({
    required int userId,
    required double bookingAmount,
  }) async {
    // Award 1 point per $10 spent (adjust as needed)
    final points = (bookingAmount / 10).floor();
    if (points > 0) {
      await awardPoints(
        userId: userId,
        points: points,
        description: 'Earned from booking (\$${bookingAmount.toStringAsFixed(2)})',
      );
    }
  }

  /// Get member level based on total points
  String getMemberLevel() {
    if (_totalPoints >= 1000) {
      return 'Platinum';
    } else if (_totalPoints >= 500) {
      return 'Gold';
    } else if (_totalPoints >= 200) {
      return 'Silver';
    } else {
      return 'Bronze';
    }
  }

  /// Get points needed for next level
  int getPointsForNextLevel() {
    if (_totalPoints >= 1000) {
      return 0; // Already at max level
    } else if (_totalPoints >= 500) {
      return 1000 - _totalPoints;
    } else if (_totalPoints >= 200) {
      return 500 - _totalPoints;
    } else {
      return 200 - _totalPoints;
    }
  }

  /// Get progress percentage to next level
  double getProgressToNextLevel() {
    if (_totalPoints >= 1000) {
      return 1.0; // 100%
    } else if (_totalPoints >= 500) {
      return (_totalPoints - 500) / 500;
    } else if (_totalPoints >= 200) {
      return (_totalPoints - 200) / 300;
    } else {
      return _totalPoints / 200;
    }
  }
}

