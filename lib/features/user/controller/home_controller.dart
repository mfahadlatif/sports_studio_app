import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

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

  final RxList<dynamic> filteredGrounds = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPremiumGrounds();
    fetchHotDeals();
    fetchUserDashboardStats();
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
    _applyFilters();
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

    filteredGrounds.value = result;
  }
}
