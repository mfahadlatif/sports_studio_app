import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class FavoritesController extends GetxController {
  final RxBool isLoadingFavorites = false.obs;
  final RxList<Favorite> favorites = <Favorite>[].obs;
  final RxList<Ground> favoriteGrounds = <Ground>[].obs;
  final RxString searchQuery = ''.obs;

  final GroundApiService _groundApiService = GroundApiService();
  static const String _prefsKey = 'saved_ground_ids';

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<List<int>> _getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final idsStrings = prefs.getStringList(_prefsKey) ?? [];
    return idsStrings.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
  }

  Future<void> _saveIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, ids.map((id) => id.toString()).toList());
  }

  Future<void> fetchFavorites() async {
    isLoadingFavorites.value = true;
    try {
      final ids = await _getSavedIds();
      
      final futures = ids.map((id) async {
        try {
          return await _groundApiService.getGroundBySlug(id.toString());
        } catch (e) {
          return null; // Ignore failed fetches
        }
      });
      
      final results = await Future.wait(futures);
      final newGrounds = results.whereType<Ground>().toList();
      
      final newFavorites = newGrounds.map((ground) {
        return Favorite(id: 0, userId: 0, groundId: ground.id, ground: ground);
      }).toList();

      favorites.assignAll(newFavorites);
      favoriteGrounds.assignAll(newGrounds);
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch saved grounds: $e');
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  bool isFavorite(int groundId) {
    return favorites.any((favorite) => favorite.groundId == groundId);
  }

  Future<void> toggleFavorite(dynamic groundInput) async {
    int groundId;
    if (groundInput is int) {
      groundId = groundInput;
    } else if (groundInput is Map) {
      groundId = int.tryParse(groundInput['id'].toString()) ?? 0;
    } else if (groundInput is Ground) {
      groundId = groundInput.id;
    } else {
      return;
    }

    if (groundId == 0) return;

    try {
      final ids = await _getSavedIds();
      
      if (ids.contains(groundId)) {
        // Remove
        ids.remove(groundId);
        await _saveIds(ids);
        AppUtils.showSuccess(message: 'Removed from saved grounds');

        // Optimistically update
        favorites.removeWhere((fav) => fav.groundId == groundId);
        favoriteGrounds.removeWhere((ground) => ground.id == groundId);
      } else {
        // Add
        ids.add(groundId);
        await _saveIds(ids);
        AppUtils.showSuccess(message: 'Added to saved grounds');

        // Optimistically update memory if we have the object
        if (groundInput is Ground) {
           favoriteGrounds.add(groundInput);
           favorites.add(Favorite(id: 0, userId: 0, groundId: groundId, ground: groundInput));
        } else {
           // We only have ID, so fetch the ground details to keep the UI valid
           try {
              final ground = await _groundApiService.getGroundBySlug(groundId.toString());
              favoriteGrounds.add(ground);
              favorites.add(Favorite(id: 0, userId: 0, groundId: groundId, ground: ground));
           } catch (e) {
              // Ignore if we couldn't fetch details immediately
           }
        }
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to update saved ground');
    }
  }

  Future<void> addToFavorites(int groundId) async {
    if (isFavorite(groundId)) {
      AppUtils.showError(message: 'Ground already saved');
      return;
    }
    await toggleFavorite(groundId);
  }

  Future<void> removeFromFavorites(int groundId) async {
    if (!isFavorite(groundId)) {
      AppUtils.showError(message: 'Ground not in saved list');
      return;
    }
    await toggleFavorite(groundId);
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
