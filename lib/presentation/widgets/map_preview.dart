import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'glass_container.dart';

class MapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;

  const MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('venue'),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: title),
              ),
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            liteModeEnabled: true, // Lite mode for performance in preview
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GlassContainer(
              padding: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(12),
              child: const Row(
                children: [
                  Icon(Icons.directions, color: AppColors.primary, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Get Directions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
