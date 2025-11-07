import 'package:gobeyond/features/itinerary/domain/entities/itinerary.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary_item.dart';

/// Data layer model that extends the domain entity
class ItineraryItemModel extends ItineraryItem {
  const ItineraryItemModel({
    super.id,
    required super.itineraryId,
    super.bookingId,
    required super.itemType,
    required super.title,
    super.description,
    super.scheduledTime,
    super.location,
    required super.createdAt,
    super.isDeleted,
    super.syncStatus,
  });

  /// Create ItineraryItemModel from domain entity
  factory ItineraryItemModel.fromEntity(ItineraryItem item) {
    return ItineraryItemModel(
      id: item.id,
      itineraryId: item.itineraryId,
      bookingId: item.bookingId,
      itemType: item.itemType,
      title: item.title,
      description: item.description,
      scheduledTime: item.scheduledTime,
      location: item.location,
      createdAt: item.createdAt,
      isDeleted: item.isDeleted,
      syncStatus: item.syncStatus,
    );
  }

  /// Create ItineraryItemModel from SQLite Map
  factory ItineraryItemModel.fromMap(Map<String, dynamic> map) {
    return ItineraryItemModel(
      id: map['id'] as int?,
      itineraryId: map['itinerary_id'] as int,
      bookingId: map['booking_id'] as int?,
      itemType: ItemType.fromString(map['item_type'] as String),
      title: map['title'] as String,
      description: map['description'] as String?,
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduled_time'] as int)
          : null,
      location: map['location'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isDeleted: (map['is_deleted'] as int) == 1,
      syncStatus: SyncStatus.fromString(map['sync_status'] as String),
    );
  }

  /// Convert ItineraryItemModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itinerary_id': itineraryId,
      'booking_id': bookingId,
      'item_type': itemType.value,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime?.millisecondsSinceEpoch,
      'location': location,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus.value,
    };
  }

  /// Create ItineraryItemModel from JSON (for future API integration)
  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    return ItineraryItemModel(
      id: json['id'] as int?,
      itineraryId: json['itinerary_id'] as int,
      bookingId: json['booking_id'] as int?,
      itemType: ItemType.fromString(json['item_type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
      syncStatus: SyncStatus.fromString(json['sync_status'] as String? ?? 'synced'),
    );
  }

  /// Convert ItineraryItemModel to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itinerary_id': itineraryId,
      'booking_id': bookingId,
      'item_type': itemType.value,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'is_deleted': isDeleted,
      'sync_status': syncStatus.value,
    };
  }
}

