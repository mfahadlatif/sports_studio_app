import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoritesController extends GetxController {
  final RxBool isLoadingFavorites = false.obs;
  final RxList<Favorite> favorites = <Favorite>[].obs;
  final RxList<Ground> favoriteGrounds = <Ground>[].obs;
  final RxString searchQuery = ''.obs;

  final FavoriteApiService _favoriteApiService = FavoriteApiService();

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    // Check if user is logged in before fetching
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token == null) return;

    isLoadingFavorites.value = true;
    try {
      final favoriteList = await _favoriteApiService.getUserFavorites();

      favorites.assignAll(favoriteList);

      // Extract grounds from favorites safely
      final grounds = favoriteList
          .map((fav) => fav.ground)
          .whereType<Ground>()
          .toList();
      favoriteGrounds.assignAll(grounds);
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch favorites: $e');
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  bool isFavorite(int groundId) {
    return favorites.any((favorite) => favorite.groundId == groundId);
  }

  Future<void> toggleFavorite(int groundId) async {
    try {
      if (isFavorite(groundId)) {
        await _favoriteApiService.removeFavorite(groundId);
        AppUtils.showSuccess(message: 'Removed from favorites');

        // Remove from local lists
        favorites.removeWhere((fav) => fav.groundId == groundId);
        favoriteGrounds.removeWhere((ground) => ground.id == groundId);
      } else {
        await _favoriteApiService.addFavorite(groundId);
        AppUtils.showSuccess(message: 'Added to favorites');

        // Refresh favorites to get the updated list with ground details
        await fetchFavorites();
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to update favorite: $e');
    }
  }

  Future<void> addToFavorites(int groundId) async {
    if (isFavorite(groundId)) {
      AppUtils.showError(message: 'Ground already in favorites');
      return;
    }

    try {
      await _favoriteApiService.addFavorite(groundId);
      AppUtils.showSuccess(message: 'Added to favorites');
      await fetchFavorites();
    } catch (e) {
      AppUtils.showError(message: 'Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(int groundId) async {
    if (!isFavorite(groundId)) {
      AppUtils.showError(message: 'Ground not in favorites');
      return;
    }

    try {
      await _favoriteApiService.removeFavorite(groundId);
      AppUtils.showSuccess(message: 'Removed from favorites');

      // Remove from local lists
      favorites.removeWhere((fav) => fav.groundId == groundId);
      favoriteGrounds.removeWhere((ground) => ground.id == groundId);
    } catch (e) {
      AppUtils.showError(message: 'Failed to remove from favorites: $e');
    }
  }

  void filterFavorites() {
    if (searchQuery.value.isEmpty) {
      return;
    }

    var filtered = favoriteGrounds.where((ground) {
      return ground.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          (ground.description?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);
    }).toList();

    // Update filtered list (you might want to create a separate filtered list variable)
    favoriteGrounds.assignAll(filtered);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterFavorites();
  }

  void clearFilters() {
    searchQuery.value = '';
    fetchFavorites();
  }

  int get favoritesCount {
    return favorites.length;
  }

  Favorite? getFavoriteByGroundId(int groundId) {
    try {
      return favorites.firstWhere((fav) => fav.groundId == groundId);
    } catch (e) {
      return null;
    }
  }

  Ground? getFavoriteGroundById(int groundId) {
    try {
      return favoriteGrounds.firstWhere((ground) => ground.id == groundId);
    } catch (e) {
      return null;
    }
  }
}
