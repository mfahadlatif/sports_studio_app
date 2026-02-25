import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

class LocationPickerSheet extends StatefulWidget {
  final String? initialAddress;
  const LocationPickerSheet({super.key, this.initialAddress});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  GoogleMapController? _mapController;
  LatLng _selectedLoc = const LatLng(31.5204, 74.3587); // Default Lahore
  String _selectedAddress = '';
  final _searchCtrl = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress ?? '';
    _searchCtrl.text = _selectedAddress;
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) return;
    setState(() => _isSearching = true);
    try {
      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': query, 'format': 'json', 'limit': 5},
      );
      if (res.statusCode == 200) {
        setState(() => _suggestions = res.data);
      }
    } catch (e) {
      print("Search error: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onSuggestionTap(dynamic item) {
    final lat = double.parse(item['lat']);
    final lon = double.parse(item['lon']);
    final address = item['display_name'];

    setState(() {
      _selectedLoc = LatLng(lat, lon);
      _selectedAddress = address;
      _suggestions = [];
      _searchCtrl.text = address;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLoc, 15));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Select Location', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) {
                    // Debounce search
                    _searchLocation(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            item['display_name'],
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _onSuggestionTap(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Map View
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLoc,
                    zoom: 14,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  onCameraMove: (pos) => _selectedLoc = pos.target,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLoc,
                    ),
                  },
                ),
                // Center pinpoint if we wanted to picker on drag
                /*
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ),
                */
              ],
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(
                    result: {
                      'address': _selectedAddress,
                      'lat': _selectedLoc.latitude,
                      'lng': _selectedLoc.longitude,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
