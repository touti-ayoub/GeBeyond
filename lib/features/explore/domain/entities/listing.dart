import 'package:equatable/equatable.dart';

/// Domain entity representing a listing (hotel, flight, experience)
class Listing extends Equatable {
  final int? id;
  final String title;
  final ListingType type;
  final String location;
  final double price;
  final String? description;
  final double rating;
  final List<String> photos;
  final List<String> amenities;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final SyncStatus syncStatus;

  const Listing({
    this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.price,
    this.description,
    this.rating = 0.0,
    this.photos = const [],
    this.amenities = const [],
    this.availableFrom,
    this.availableTo,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.synced,
  });

  /// Check if listing is available
  bool get isAvailable {
    final now = DateTime.now();
    if (availableFrom != null && now.isBefore(availableFrom!)) {
      return false;
    }
    if (availableTo != null && now.isAfter(availableTo!)) {
      return false;
    }
    return !isDeleted;
  }

  /// Get price per night/unit display
  String get priceDisplay {
    switch (type) {
      case ListingType.hotel:
        return '\$${price.toStringAsFixed(2)}/night';
      case ListingType.flight:
        return '\$${price.toStringAsFixed(2)}';
      case ListingType.experience:
        return '\$${price.toStringAsFixed(2)}/person';
    }
  }

  Listing copyWith({
    int? id,
    String? title,
    ListingType? type,
    String? location,
    double? price,
    String? description,
    double? rating,
    List<String>? photos,
    List<String>? amenities,
    DateTime? availableFrom,
    DateTime? availableTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    SyncStatus? syncStatus,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      location: location ?? this.location,
      price: price ?? this.price,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      photos: photos ?? this.photos,
      amenities: amenities ?? this.amenities,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        location,
        price,
        description,
        rating,
        photos,
        amenities,
        availableFrom,
        availableTo,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
      ];
}

enum ListingType {
  hotel,
  flight,
  experience;

  String get value {
    switch (this) {
      case ListingType.hotel:
        return 'hotel';
      case ListingType.flight:
        return 'flight';
      case ListingType.experience:
        return 'experience';
    }
  }

  static ListingType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hotel':
        return ListingType.hotel;
      case 'flight':
        return ListingType.flight;
      case 'experience':
        return ListingType.experience;
      default:
        return ListingType.hotel;
    }
  }
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
