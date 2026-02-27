import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> premiumGrounds = <dynamic>[].obs;

  // Search & Advanced Filter State
  final RxString searchQuery = ''.obs;
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
  }

  Future<void> fetchPremiumGrounds() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/public/grounds');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          premiumGrounds.value = data['data'];
          _applyFilters();
        }
      }
    } catch (e) {
      print('Failed to fetch premium grounds: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
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
        final location = ground['location']?.toString().toLowerCase() ?? '';
        final complex = ground['complex'] ?? {};
        final address = complex['address']?.toString().toLowerCase() ?? '';

        return name.contains(text) ||
            location.contains(text) ||
            address.contains(text);
      }).toList();
    }

    // 3. Price Filter
    result = result.where((ground) {
      final price =
          double.tryParse(ground['price_per_hour']?.toString() ?? '0') ?? 0;
      return price >= priceRange.value.start && price <= priceRange.value.end;
    }).toList();

    // 4. Amenities Filter
    if (selectedAmenities.isNotEmpty) {
      result = result.where((ground) {
        final amenities = ground['amenities'] as List? ?? [];
        return selectedAmenities.every((id) => amenities.contains(id));
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
