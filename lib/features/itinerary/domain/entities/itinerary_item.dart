import 'package:equatable/equatable.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary.dart';

/// Domain entity representing an item in an itinerary
class ItineraryItem extends Equatable {
  final int? id;
  final int itineraryId;
  final int? bookingId;
  final ItemType itemType;
  final String title;
  final String? description;
  final DateTime? scheduledTime;
  final String? location;
  final DateTime createdAt;
  final bool isDeleted;
  final SyncStatus syncStatus;

  const ItineraryItem({
    this.id,
    required this.itineraryId,
    this.bookingId,
    required this.itemType,
    required this.title,
    this.description,
    this.scheduledTime,
    this.location,
    required this.createdAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.synced,
  });

  bool get isActive {
    return !isDeleted;
  }

  bool get isPast {
    if (scheduledTime == null) return false;
    return scheduledTime!.isBefore(DateTime.now());
  }

  ItineraryItem copyWith({
    int? id,
    int? itineraryId,
    int? bookingId,
    ItemType? itemType,
    String? title,
    String? description,
    DateTime? scheduledTime,
    String? location,
    DateTime? createdAt,
    bool? isDeleted,
    SyncStatus? syncStatus,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      bookingId: bookingId ?? this.bookingId,
      itemType: itemType ?? this.itemType,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itineraryId,
        bookingId,
        itemType,
        title,
        description,
        scheduledTime,
        location,
        createdAt,
        isDeleted,
        syncStatus,
      ];
}

enum ItemType {
  booking,
  activity,
  note;

  String get value {
    switch (this) {
      case ItemType.booking:
        return 'booking';
      case ItemType.activity:
        return 'activity';
      case ItemType.note:
        return 'note';
    }
  }

  static ItemType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'booking':
        return ItemType.booking;
      case 'activity':
        return ItemType.activity;
      case 'note':
        return ItemType.note;
      default:
        return ItemType.note;
    }
  }
}

