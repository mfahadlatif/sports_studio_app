import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapLocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  LatLng? _pickedLocation;
  String _address = '';
  bool _isReverseGeocoding = false;
  final Completer<GoogleMapController> _controller = Completer();

  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounce;

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);
    try {
      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'accept-language': 'en',
        },
        options: Options(headers: {'User-Agent': 'SportsStudioApp/1.0'}),
      );

      if (mounted) {
        setState(() {
          _suggestions = res.data is List ? res.data : [];
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchLocations(query);
    });
  }

  Future<void> _moveToLocation(double lat, double lng, String address) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));

    setState(() {
      _pickedLocation = LatLng(lat, lng);
      _address = address;
      _suggestions = [];
      _searchCtrl.clear();
    });
    FocusScope.of(context).unfocus();
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
          'accept-language': 'en',
        },
        options: Options(headers: {'User-Agent': 'SportsStudioApp/1.0'}),
      );

      if (mounted) {
        final data = res.data;
        setState(() {
          _address = data['display_name'] ?? 'Selected location';
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
        title: Text(
          'Pin Location',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
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
              child: const Text(
                'CONFIRM',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

          // Search & Address Overlay
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _isLoadingSuggestions
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _suggestions = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Suggestions List
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                          title: Text(
                            item['display_name'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            final lat =
                                double.tryParse(item['lat'].toString()) ?? 0.0;
                            final lng =
                                double.tryParse(item['lon'].toString()) ?? 0.0;
                            _moveToLocation(
                              lat,
                              lng,
                              item['display_name'] ?? '',
                            );
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Address Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _isReverseGeocoding
                                  ? const LinearProgressIndicator()
                                  : Text(
                                      _address.isEmpty
                                          ? 'Tap map to select location'
                                          : _address,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap on the map to pin your sports complex location',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isReverseGeocoding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm Pin Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
