import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gobeyond/core/config/google_maps_config.dart';

/// A small reusable Map widget using MapTiler tiles (via flutter_map).
///
/// Provide [latitude] and [longitude] to center the map. If null, the map
/// centers on [fallbackCenter].
class MapTilerWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double zoom;
  final bool showMarker;
  final LatLng fallbackCenter;

  const MapTilerWidget({
    Key? key,
    this.latitude,
    this.longitude,
    this.zoom = MapTilerConfig.defaultZoom,
    this.showMarker = true,
    this.fallbackCenter = const LatLng(48.8566, 2.3522),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final center = (latitude != null && longitude != null)
        ? LatLng(latitude!, longitude!)
        : fallbackCenter;

    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: zoom,
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        TileLayer(
          urlTemplate: MapTilerConfig.tileUrlTemplate,
          userAgentPackageName: 'com.gobeyond.gobeyond_app',
          additionalOptions: const {'key': MapTilerConfig.apiKey},
        ),
        if (showMarker)
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 40,
                height: 40,
                builder: (ctx) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 36,
                ),
              ),
            ],
          ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              MapTilerConfig.attribution,
            ),
          ],
        ),
      ],
    );
  }
}

