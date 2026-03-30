import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapLocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  LatLng? _pickedLocation;
  String _address = '';
  bool _isReverseGeocoding = false;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pickedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      _reverseGeocode(_pickedLocation!);
    } else {
      // Default to a central location (e.g. Lahore, Pakistan - matching website center)
      _pickedLocation = const LatLng(31.5204, 74.3587);
      _reverseGeocode(_pickedLocation!);
    }
  }

  Future<void> _reverseGeocode(LatLng location) async {
    setState(() {
      _isReverseGeocoding = true;
      _pickedLocation = location;
    });

    try {
      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': location.latitude,
          'lon': location.longitude,
          'addressdetails': 1,
        },
      );

      if (mounted) {
        final data = res.data;
        setState(() {
          _address = data['display_name'] ?? 'Unknown location';
        });
      }
    } catch (e) {
      debugPrint('❌ [ReverseGeocode] Error: $e');
      if (mounted) {
        setState(() => _address = 'Unknown location');
      }
    } finally {
      if (mounted) {
        setState(() => _isReverseGeocoding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pin Location', style: AppTextStyles.h3.copyWith(fontSize: 18)),
        centerTitle: true,
        actions: [
          if (_pickedLocation != null)
            TextButton(
              onPressed: _isReverseGeocoding
                  ? null
                  : () {
                      Navigator.pop(context, {
                        'address': _address,
                        'lat': _pickedLocation!.latitude,
                        'lng': _pickedLocation!.longitude,
                      });
                    },
              child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLocation ?? const LatLng(31.5204, 74.3587),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _reverseGeocode,
            markers: _pickedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: _pickedLocation!,
                    ),
                  },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
          ),
          
          // Address Overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isReverseGeocoding
                              ? const LinearProgressIndicator()
                              : Text(
                                  _address.isEmpty ? 'Tap map to select location' : _address,
                                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap on the map to pin your sports complex location',
                      style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Confirm Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isReverseGeocoding || _pickedLocation == null
                  ? null
                  : () {
                      Navigator.pop(context, {
                        'address': _address,
                        'lat': _pickedLocation!.latitude,
                        'lng': _pickedLocation!.longitude,
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isReverseGeocoding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Confirm Pin Location',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
