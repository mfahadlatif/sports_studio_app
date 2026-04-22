import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> premiumGrounds = <dynamic>[].obs;
  final RxList<dynamic> hotDeals = <dynamic>[].obs;
  final RxMap<String, dynamic> dashboardStats = <String, dynamic>{}.obs;

  // Search & Advanced Filter State
  final RxString searchQuery = ''.obs;
  final RxString locationQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final Rx<RangeValues> priceRange = const RangeValues(0, 20000).obs;
  final RxDouble minRating = 0.0.obs;
  final RxList<String> selectedAmenities = <String>[].obs;
  final RxString sortBy = 'Rating: High to Low'.obs;
  final RxString selectedCity = 'All Cities'.obs;
  final RxBool isNearbyActive = false.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxString currentLocationAddress = ''.obs;

  final List<String> pakistanCities = [
    'All Cities',
    'Karachi', 'Lahore', 'Faisalabad', 'Rawalpindi', 'Gujranwala', 'Peshawar', 'Multan', 'Hyderabad', 'Islamabad', 'Quetta',
    'Bahawalpur', 'Sargodha', 'Sialkot', 'Sukkur', 'Larkana', 'Sheikhupura', 'Rahim Yar Khan', 'Jhang', 'Dera Ghazi Khan',
    'Gujrat', 'Sahiwal', 'Wah Cantonment', 'Mardan', 'Kasur', 'Okara', 'Mingora', 'Nawabshah', 'Chiniot', 'Kotri', 'Kāmoke',
    'Hafizabad', 'Sadiqabad', 'Mirpur Khas', 'Burewala', 'Kohat', 'Khanewal', 'Shikarpur', 'Muzaffargarh', 'Jhelum', 'Muridke',
    'Abbottabad', 'Gojra', 'Pakpattan', 'Jaranwala', 'Tando Adam', 'Khairpur', 'Dera Ismail Khan', 'Vehari', 'Nowshera',
    'Kot Radha Kishan', 'Khushab', 'Charsadda', 'Kamalia', 'Tando Allahyar', 'Mianwali', 'Jacobabad', 'Bahawalnagar', 'Attock',
    'Ahmedpur East', 'Kot Adu', 'Chakwal', 'Haripur', 'Chaman', 'Muzaffarābād', 'Tank', 'Mansehra', 'Layyah', 'Narowal',
    'Khuzdar', 'Battagram', 'Upper Dir', 'Swabi', 'Dera Murad Jamali', 'Jamshoro', 'Ghotki', 'Rajanpur', 'Shujaabad',
    'Haveli Lakha', 'Kabal', 'Kandhkot', 'Karor Lal Esan', 'Kashmore', 'Killa Abdullah', 'Kot Ghulam Muhammad', 'Kotli',
    'Kulachi', 'Kurram', 'Lakki Marwat', 'Loralai', 'Lodhran', 'Malakand', 'Mandi Bahauddin', 'Mastung', 'Matiari', 'Mehar',
    'Mian Channu', 'Mirpur', 'Mirpur Sakro', 'Mohenjo-daro', 'Moro', 'Nasirabad', 'Naushahro Feroze', 'Orakzai', 'Parachinar',
    'Pishin', 'Qambar', 'Qila Saifullah', 'Ranipur', 'Risalpur', 'Rohri', 'Sambrial', 'Sanghar', 'Sarai Alamgir', 'Sehwan Sharif',
    'Shahdadkot', 'Shahdadpur', 'Shahpur Chakar', 'Shangla', 'Shikar Pur', 'South Waziristan', 'Swat', 'Tando Bago',
    'Tando Mohammad Khan', 'Tangi', 'Thari Mirwah', 'Thatta', 'Thull', 'Timergara', 'Toba Tek Singh', 'Turbat', 'Umerkot',
    'Upper Kohistan', 'Ziarat',
  ];

  final RxList<dynamic> filteredGrounds = <dynamic>[].obs;
  final RxList<dynamic> publicEvents = <dynamic>[].obs;
  final RxList<dynamic> filteredEvents = <dynamic>[].obs;
  final RxBool isLoadingEvents = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchPremiumGrounds(),
      fetchHotDeals(),
      fetchUserDashboardStats(),
      fetchPublicEvents(),
    ]);
  }

  Future<void> fetchPublicEvents() async {
    isLoadingEvents.value = true;
    try {
      final response = await ApiClient().dio.get('/events');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        publicEvents.value = data;
        _applyFilters();
      }
    } catch (e) {
      print('Failed to fetch public events: $e');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> fetchUserDashboardStats() async {
    try {
      final res = await ApiClient().dio.get('/user/dashboard/stats');
      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map) {
          dashboardStats.assignAll(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      // Non-blocking. Keep UI usable with fallback stats.
    }
  }

  Future<void> fetchPremiumGrounds() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/public/grounds');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        premiumGrounds.value = data;
        _applyFilters();
      }
    } catch (e) {
      print('Failed to fetch premium grounds: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHotDeals() async {
    try {
      final response = await ApiClient().dio.get('/public/deals');
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] as List? ?? []);
        hotDeals.value = data;
    } catch (e) {
      print('Failed to fetch hot deals: $e');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void updateLocationQuery(String query) {
    locationQuery.value = query;
    _applyFilters();
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void updatePriceRange(RangeValues values) {
    priceRange.value = values;
    _applyFilters();
  }

  void updateMinRating(double value) {
    minRating.value = value;
    _applyFilters();
  }

  void toggleAmenity(String id) {
    if (selectedAmenities.contains(id)) {
      selectedAmenities.remove(id);
    } else {
      selectedAmenities.add(id);
    }
    _applyFilters();
  }

  void updateSort(String sort) {
    sortBy.value = sort;
    _applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    locationQuery.value = '';
    selectedCategory.value = 'All';
    priceRange.value = const RangeValues(0, 20000);
    minRating.value = 0.0;
    selectedAmenities.clear();
    sortBy.value = 'Rating: High to Low';
    selectedCity.value = 'All Cities';
    isNearbyActive.value = false;
    currentLocationAddress.value = '';
    _applyFilters();
  }

  void updateCity(String city) {
    selectedCity.value = city;
    _applyFilters();
  }

  Future<void> toggleNearby(bool active) async {
    isNearbyActive.value = active;
    if (active) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return;
        }
        
        currentPosition.value = await Geolocator.getCurrentPosition();
        
        try {
          final placemarks = await placemarkFromCoordinates(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            // E.g. "Clifton, Karachi"
            final components = [place.subLocality, place.locality].where((e) => e != null && e.isNotEmpty).toList();
            currentLocationAddress.value = components.join(', ');
          }
        } catch (_) {
          // Geocoding failed, ignore
        }
      } catch (e) {
        isNearbyActive.value = false;
        currentLocationAddress.value = '';
        print('Error getting location: $e');
      }
    } else {
      currentLocationAddress.value = '';
    }
    _applyFilters();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final c = math.cos;
    final a = 0.5 - c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _applyFilters() {
    var result = premiumGrounds.toList();

    // 1. Category Filter
    if (selectedCategory.value != 'All') {
      result = result.where((ground) {
        final type = ground['type']?.toString().toLowerCase() ?? '';
        return type == selectedCategory.value.toLowerCase();
      }).toList();
    }

    // 1b. City Filter
    if (selectedCity.value != 'All Cities') {
      final cityText = selectedCity.value.toLowerCase();
      result = result.where((ground) {
        final complex = ground['complex'] ?? {};
        final address = (complex['address'] ?? ground['location'] ?? '').toString().toLowerCase();
        return address.contains(cityText);
      }).toList();
    }

    // 2. Search Text Filter
    if (searchQuery.value.isNotEmpty) {
      final text = searchQuery.value.toLowerCase();
      result = result.where((ground) {
        final name = ground['name']?.toString().toLowerCase() ?? '';
        final complex = ground['complex'] ?? {};
        final address = complex['address']?.toString().toLowerCase() ?? '';

        return name.contains(text) || address.contains(text);
      }).toList();
    }

    // 2b. Location Filter (separate field)
    if (locationQuery.value.isNotEmpty) {
      final queryText = locationQuery.value.toLowerCase();
      final queryParts = queryText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 2)
          .toList();

      result = result.where((ground) {
        final complex = ground['complex'] ?? {};
        final address = (complex['address'] ?? ground['location'] ?? '').toString().toLowerCase();
        
        if (address.contains(queryText) || queryText.contains(address)) return true;

        for (var part in queryParts) {
          if (address.contains(part)) return true;
        }
        return false;
      }).toList();
    }

    // 3. Price Filter
    result = result.where((ground) {
      final price =
          double.tryParse(ground['price_per_hour']?.toString() ?? '0') ?? 0;
      return price >= priceRange.value.start && price <= priceRange.value.end;
    }).toList();

    // 3b. Minimum Rating filter
    if (minRating.value > 0) {
      result = result.where((ground) {
        final ratingVal =
            double.tryParse((ground['rating'] ?? ground['avg_rating'] ?? '0').toString()) ?? 0;
        return ratingVal >= minRating.value;
      }).toList();
    }

    // 4. Amenities Filter
    if (selectedAmenities.isNotEmpty) {
      result = result.where((ground) {
        final amenitiesList = ground['amenities'] as List? ?? [];
        final amenities =
            amenitiesList.map((e) => e.toString().toLowerCase()).toList();
        return selectedAmenities.every(
          (id) => amenities.contains(id.toLowerCase()),
        );
      }).toList();
    }

    // 5. Sorting
    if (sortBy.value == 'Price: Low to High') {
      result.sort(
        (a, b) => (double.tryParse(a['price_per_hour'].toString()) ?? 0)
            .compareTo(double.tryParse(b['price_per_hour'].toString()) ?? 0),
      );
    } else if (sortBy.value == 'Price: High to Low') {
      result.sort(
        (a, b) => (double.tryParse(b['price_per_hour'].toString()) ?? 0)
            .compareTo(double.tryParse(a['price_per_hour'].toString()) ?? 0),
      );
    } else if (sortBy.value == 'Rating: High to Low') {
      result.sort(
        (a, b) => (double.tryParse(b['avg_rating']?.toString() ?? '0') ?? 0)
            .compareTo(
              double.tryParse(a['avg_rating']?.toString() ?? '0') ?? 0,
            ),
      );
    }

    // 6. Nearby (Distance) Sorting & Filtering
    if (isNearbyActive.value && currentPosition.value != null) {
      final pos = currentPosition.value!;
      
      // Filter by 50km radius
      result = result.where((ground) {
        final complex = ground['complex'] ?? {};
        final lat = double.tryParse((complex['latitude'] ?? ground['latitude'] ?? '0').toString()) ?? 0;
        final lng = double.tryParse((complex['longitude'] ?? ground['longitude'] ?? '0').toString()) ?? 0;
        if (lat == 0 && lng == 0) return false;
        
        final dist = _calculateDistance(pos.latitude, pos.longitude, lat, lng);
        return dist <= 50.0; // 50km radius
      }).toList();

      // Sort by closest distance
      result.sort((a, b) {
        final complexA = a['complex'] ?? {};
        final complexB = b['complex'] ?? {};
        
        final latA = double.tryParse((complexA['latitude'] ?? a['latitude'] ?? '0').toString()) ?? 0;
        final lngA = double.tryParse((complexA['longitude'] ?? a['longitude'] ?? '0').toString()) ?? 0;
        
        final latB = double.tryParse((complexB['latitude'] ?? b['latitude'] ?? '0').toString()) ?? 0;
        final lngB = double.tryParse((complexB['longitude'] ?? b['longitude'] ?? '0').toString()) ?? 0;

        if ((latA == 0 && lngA == 0) || (latB == 0 && lngB == 0)) return 0;

        final distA = _calculateDistance(pos.latitude, pos.longitude, latA, lngA);
        final distB = _calculateDistance(pos.latitude, pos.longitude, latB, lngB);
        
        return distA.compareTo(distB);
      });
    }

    filteredGrounds.value = result;

    // --- Filter Events ---
    var eventResult = publicEvents.toList();

    // 1. City Filter for Events
    if (selectedCity.value != 'All Cities') {
      final cityText = selectedCity.value.toLowerCase();
      eventResult = eventResult.where((event) {
        final address = (event['location'] ?? '').toString().toLowerCase();
        return address.contains(cityText);
      }).toList();
    }

    // 2. Nearby sorting and filtering for Events
    if (isNearbyActive.value && currentPosition.value != null) {
      final pos = currentPosition.value!;
      
      eventResult = eventResult.where((event) {
        final lat = double.tryParse((event['latitude'] ?? '0').toString()) ?? 0;
        final lng = double.tryParse((event['longitude'] ?? '0').toString()) ?? 0;
        if (lat == 0 && lng == 0) return false;
        
        final dist = _calculateDistance(pos.latitude, pos.longitude, lat, lng);
        return dist <= 50.0;
      }).toList();

      eventResult.sort((a, b) {
        final latA = double.tryParse((a['latitude'] ?? '0').toString()) ?? 0;
        final lngA = double.tryParse((a['longitude'] ?? '0').toString()) ?? 0;
        final latB = double.tryParse((b['latitude'] ?? '0').toString()) ?? 0;
        final lngB = double.tryParse((b['longitude'] ?? '0').toString()) ?? 0;

        if ((latA == 0 && lngA == 0) || (latB == 0 && lngB == 0)) return 0;

        final distA = _calculateDistance(pos.latitude, pos.longitude, latA, lngA);
        final distB = _calculateDistance(pos.latitude, pos.longitude, latB, lngB);
        return distA.compareTo(distB);
      });
    }

    filteredEvents.value = eventResult;
  }
}
