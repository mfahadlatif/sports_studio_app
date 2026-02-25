import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> premiumGrounds = <dynamic>[].obs;

  // Search State
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
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

  void _applyFilters() {
    var result = premiumGrounds.toList();

    if (selectedCategory.value != 'All') {
      result = result.where((ground) {
        final type = ground['type']?.toString().toLowerCase() ?? '';
        return type == selectedCategory.value.toLowerCase();
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final text = searchQuery.value.toLowerCase();
      result = result.where((ground) {
        final name = ground['name']?.toString().toLowerCase() ?? '';
        final location = ground['location']?.toString().toLowerCase() ?? '';
        // Might also be inside complex.address
        final complex = ground['complex'] ?? {};
        final address = complex['address']?.toString().toLowerCase() ?? '';

        return name.contains(text) ||
            location.contains(text) ||
            address.contains(text);
      }).toList();
    }

    filteredGrounds.value = result;
  }
}
