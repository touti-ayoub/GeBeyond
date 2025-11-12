import 'package:flutter/material.dart';

/// Simple coordinate class to replace google_maps_flutter LatLng
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

/// Location Helper - Provides coordinates for locations
class LocationHelper {
  /// Get coordinates for a location name
  /// In a real app, you would use Geocoding API to convert location names to coordinates
  /// For now, we'll use predefined coordinates for common locations
  static LatLng? getCoordinates(String location) {
    // Normalize location string
    final normalizedLocation = location.toLowerCase().trim();

    // Check for matches
    for (final entry in _locationCoordinates.entries) {
      if (normalizedLocation.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Default location if not found (Paris)
    return const LatLng(48.8566, 2.3522);
  }

  /// Predefined coordinates for common travel destinations
  static final Map<String, LatLng> _locationCoordinates = {
    // Europe
    'Paris': const LatLng(48.8566, 2.3522),
    'France': const LatLng(48.8566, 2.3522),
    'London': const LatLng(51.5074, -0.1278),
    'UK': const LatLng(51.5074, -0.1278),
    'Rome': const LatLng(41.9028, 12.4964),
    'Italy': const LatLng(41.9028, 12.4964),
    'Barcelona': const LatLng(41.3851, 2.1734),
    'Spain': const LatLng(41.3851, 2.1734),
    'Amsterdam': const LatLng(52.3676, 4.9041),
    'Netherlands': const LatLng(52.3676, 4.9041),
    'Berlin': const LatLng(52.5200, 13.4050),
    'Germany': const LatLng(52.5200, 13.4050),
    'Prague': const LatLng(50.0755, 14.4378),
    'Czech': const LatLng(50.0755, 14.4378),
    'Vienna': const LatLng(48.2082, 16.3738),
    'Austria': const LatLng(48.2082, 16.3738),
    'Athens': const LatLng(37.9838, 23.7275),
    'Greece': const LatLng(37.9838, 23.7275),
    'Santorini': const LatLng(36.3932, 25.4615),

    // Asia
    'Tokyo': const LatLng(35.6762, 139.6503),
    'Japan': const LatLng(35.6762, 139.6503),
    'Dubai': const LatLng(25.2048, 55.2708),
    'UAE': const LatLng(25.2048, 55.2708),
    'Bangkok': const LatLng(13.7563, 100.5018),
    'Thailand': const LatLng(13.7563, 100.5018),
    'Singapore': const LatLng(1.3521, 103.8198),
    'Bali': const LatLng(-8.4095, 115.1889),
    'Indonesia': const LatLng(-8.4095, 115.1889),
    'Hong Kong': const LatLng(22.3193, 114.1694),
    'Seoul': const LatLng(37.5665, 126.9780),
    'Korea': const LatLng(37.5665, 126.9780),
    'Beijing': const LatLng(39.9042, 116.4074),
    'China': const LatLng(39.9042, 116.4074),
    'Shanghai': const LatLng(31.2304, 121.4737),
    'Mumbai': const LatLng(19.0760, 72.8777),
    'India': const LatLng(19.0760, 72.8777),
    'Delhi': const LatLng(28.7041, 77.1025),

    // Americas
    'New York': const LatLng(40.7128, -74.0060),
    'USA': const LatLng(40.7128, -74.0060),
    'Los Angeles': const LatLng(34.0522, -118.2437),
    'San Francisco': const LatLng(37.7749, -122.4194),
    'Miami': const LatLng(25.7617, -80.1918),
    'Las Vegas': const LatLng(36.1699, -115.1398),
    'Toronto': const LatLng(43.6532, -79.3832),
    'Canada': const LatLng(43.6532, -79.3832),
    'Mexico': const LatLng(19.4326, -99.1332),
    'Cancun': const LatLng(21.1619, -86.8515),
    'Rio': const LatLng(-22.9068, -43.1729),
    'Brazil': const LatLng(-22.9068, -43.1729),
    'Buenos Aires': const LatLng(-34.6037, -58.3816),
    'Argentina': const LatLng(-34.6037, -58.3816),

    // Middle East
    'Istanbul': const LatLng(41.0082, 28.9784),
    'Turkey': const LatLng(41.0082, 28.9784),
    'Cairo': const LatLng(30.0444, 31.2357),
    'Egypt': const LatLng(30.0444, 31.2357),
    'Jerusalem': const LatLng(31.7683, 35.2137),
    'Israel': const LatLng(31.7683, 35.2137),

    // Africa
    'Marrakech': const LatLng(31.6295, -7.9811),
    'Morocco': const LatLng(31.6295, -7.9811),
    'Cape Town': const LatLng(-33.9249, 18.4241),
    'South Africa': const LatLng(-33.9249, 18.4241),
    'Nairobi': const LatLng(-1.2921, 36.8219),
    'Kenya': const LatLng(-1.2921, 36.8219),

    // Oceania
    'Sydney': const LatLng(-33.8688, 151.2093),
    'Australia': const LatLng(-33.8688, 151.2093),
    'Melbourne': const LatLng(-37.8136, 144.9631),
    'Auckland': const LatLng(-36.8485, 174.7633),
    'New Zealand': const LatLng(-36.8485, 174.7633),
    'Fiji': const LatLng(-17.7134, 178.0650),

    // Islands & Beach Destinations
    'Maldives': const LatLng(3.2028, 73.2207),
    'Seychelles': const LatLng(-4.6796, 55.4920),
    'Mauritius': const LatLng(-20.1609, 57.5012),
    'Hawaii': const LatLng(21.3099, -157.8581),
    'Caribbean': const LatLng(18.2208, -66.5901),
    'Bora Bora': const LatLng(-16.5004, -151.7415),
  };

  /// Get nearby places for a location (mock data)
  static List<Map<String, dynamic>> getNearbyPlaces(String location) {
    final normalizedLocation = location.toLowerCase();

    if (normalizedLocation.contains('paris')) {
      return [
        {'name': 'Eiffel Tower', 'distance': '1.2 km', 'icon': Icons.location_city},
        {'name': 'Louvre Museum', 'distance': '2.5 km', 'icon': Icons.museum},
        {'name': 'Notre-Dame', 'distance': '3.0 km', 'icon': Icons.church},
        {'name': 'Arc de Triomphe', 'distance': '1.8 km', 'icon': Icons.architecture},
      ];
    } else if (normalizedLocation.contains('maldives')) {
      return [
        {'name': 'Malé Airport', 'distance': '5 km', 'icon': Icons.flight},
        {'name': 'Diving Center', 'distance': '500 m', 'icon': Icons.scuba_diving},
        {'name': 'Beach Club', 'distance': '200 m', 'icon': Icons.beach_access},
        {'name': 'Water Sports', 'distance': '300 m', 'icon': Icons.surfing},
      ];
    } else if (normalizedLocation.contains('bali')) {
      return [
        {'name': 'Ubud Rice Terraces', 'distance': '10 km', 'icon': Icons.landscape},
        {'name': 'Tanah Lot Temple', 'distance': '15 km', 'icon': Icons.temple_hindu},
        {'name': 'Beach Club', 'distance': '2 km', 'icon': Icons.beach_access},
        {'name': 'Monkey Forest', 'distance': '12 km', 'icon': Icons.nature},
      ];
    } else {
      // Generic nearby places
      return [
        {'name': 'Airport', 'distance': '10 km', 'icon': Icons.flight},
        {'name': 'City Center', 'distance': '3 km', 'icon': Icons.location_city},
        {'name': 'Shopping Mall', 'distance': '2 km', 'icon': Icons.shopping_bag},
        {'name': 'Restaurant Area', 'distance': '500 m', 'icon': Icons.restaurant},
      ];
    }
  }
}

