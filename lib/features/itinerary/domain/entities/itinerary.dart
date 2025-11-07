import 'package:equatable/equatable.dart';

/// Domain entity representing an itinerary (trip plan)
class Itinerary extends Equatable {
  final int? id;
  final int userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? destination;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final SyncStatus syncStatus;

  const Itinerary({
    this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.destination,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.synced,
  });

  /// Calculate the number of days
  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Check if itinerary is active
  bool get isActive {
    return !isDeleted;
  }

  /// Check if itinerary is in the past
  bool get isPast {
    return endDate.isBefore(DateTime.now());
  }

  /// Check if itinerary is upcoming
  bool get isUpcoming {
    return startDate.isAfter(DateTime.now()) && isActive;
  }

  /// Check if itinerary is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now) && isActive;
  }

  /// Create a copy with updated fields
  Itinerary copyWith({
    int? id,
    int? userId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    SyncStatus? syncStatus,
  }) {
    return Itinerary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      notes: notes ?? this.notes,
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
        title,
        startDate,
        endDate,
        destination,
        notes,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
      ];
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

