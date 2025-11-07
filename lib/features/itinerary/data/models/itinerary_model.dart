import 'package:gobeyond/features/itinerary/domain/entities/itinerary.dart';

/// Data layer model that extends the domain entity
class ItineraryModel extends Itinerary {
  const ItineraryModel({
    super.id,
    required super.userId,
    required super.title,
    required super.startDate,
    required super.endDate,
    super.destination,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.syncStatus,
  });

  /// Create ItineraryModel from domain entity
  factory ItineraryModel.fromEntity(Itinerary itinerary) {
    return ItineraryModel(
      id: itinerary.id,
      userId: itinerary.userId,
      title: itinerary.title,
      startDate: itinerary.startDate,
      endDate: itinerary.endDate,
      destination: itinerary.destination,
      notes: itinerary.notes,
      createdAt: itinerary.createdAt,
      updatedAt: itinerary.updatedAt,
      isDeleted: itinerary.isDeleted,
      syncStatus: itinerary.syncStatus,
    );
  }

  /// Create ItineraryModel from SQLite Map
  factory ItineraryModel.fromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      destination: map['destination'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      isDeleted: (map['is_deleted'] as int) == 1,
      syncStatus: SyncStatus.fromString(map['sync_status'] as String),
    );
  }

  /// Convert ItineraryModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'destination': destination,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus.value,
    };
  }

  /// Create ItineraryModel from JSON (for future API integration)
  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      destination: json['destination'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      syncStatus: SyncStatus.fromString(json['sync_status'] as String? ?? 'synced'),
    );
  }

  /// Convert ItineraryModel to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'destination': destination,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'sync_status': syncStatus.value,
    };
  }
}

