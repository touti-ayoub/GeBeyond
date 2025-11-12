/// MapTiler Configuration
///
/// This file replaces the previous Google Maps config and provides a
/// minimal configuration object for using MapTiler tile layers (e.g. with
/// the flutter_map package).
///
/// NOTE: You provided this MapTiler API key: HZ857a88BK5luxR8VqeM
/// Keep this key secret in production (store it in native secure storage
/// or environment variables). For quick testing it's placed here.
class MapTilerConfig {
  // ============================================
  // 🗺️ MAPTILER API KEY - REPLACE/STORE SECURELY
  // ============================================
  /// MapTiler API Key (TEST / QUICK USE)
  static const String apiKey = 'HZ857a88BK5luxR8VqeM';

  /// Default map settings
  static const double defaultZoom = 15.0;
  static const double detailZoom = 16.0;

  /// Enable/disable maps (for testing without API key)
  static const bool enableMaps = true;

  // Tile URL template for MapTiler (Streets style). Use with a tile layer
  // package like `flutter_map` (leaflet) or as a raster tile overlay when
  // using other map packages.
  // Example tile URL:
  // https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=YOUR_KEY
  static String get tileUrlTemplate =>
      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey';

  // If you prefer a different style, replace `streets` with e.g.:
  // - streets
  // - hybrid
  // - satellite
  // - outdoors
  // See MapTiler styles in your MapTiler account for exact names.

  // Optional: attribution string to show on the map UI
  static const String attribution =
      '© MapTiler © OpenStreetMap contributors';
}

// ============================================
// USAGE NOTES
// ============================================
// 1) Recommended approach: use `flutter_map` (Leaflet) with the tile template
//    - Add dependency in pubspec.yaml:
//        flutter_map: ^5.0.0
//    - Minimal example widget:
//
//    import 'package:flutter_map/flutter_map.dart';
//    import 'package:latlong2/latlong.dart';
//    import 'core/config/google_maps_config.dart' as cfg; // or import the file path
//
//    FlutterMap(
//      options: MapOptions(
//        center: LatLng(48.8566, 2.3522),
//        zoom: cfg.MapTilerConfig.defaultZoom,
//      ),
//      children: [
//        TileLayer(
//          urlTemplate: cfg.MapTilerConfig.tileUrlTemplate,
//          userAgentPackageName: 'com.gobeyond.gobeyond_app',
//          additionalOptions: { 'key': cfg.MapTilerConfig.apiKey },
//          attributionBuilder: (_) => Text(cfg.MapTilerConfig.attribution),
//        ),
//      ],
//    )
//
// 2) If you previously used `google_maps_flutter`, you will need to replace
//    the Google Maps widget usage with `flutter_map` or configure a custom
//    tile overlay. It's usually simpler to switch to `flutter_map` when using
//    MapTiler tiles.
//
// 3) Android & iOS: No special manifest entries are required for MapTiler
//    raster tiles, but ensure you have INTERNET permission in Android
//    (already present for most Flutter apps). For iOS ensure App Transport
//    Settings allow the map tiles or use https (MapTiler URLs are https).
//
// 4) Security: For production, don't hardcode the API key in source. Use
//    native build-time environment variables, secure storage or server-side
//    proxy to avoid exposing the key in clients.
//
// If you want, I can:
// - Add `flutter_map` and `latlong2` to `pubspec.yaml` and update a map
//   screen to use MapTiler tiles, or
// - Convert existing Google Maps usage to `flutter_map` with MapTiler.
// Tell me which you'd prefer and I'll make the changes.
