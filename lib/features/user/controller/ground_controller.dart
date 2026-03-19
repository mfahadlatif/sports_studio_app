import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class GroundController extends GetxController {
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingGround = false.obs;
  final RxBool isLoadingGrounds = false.obs;
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<Ground> grounds = <Ground>[].obs;
  final RxList<Ground> filteredGrounds = <Ground>[].obs;
  final RxMap<String, dynamic> groundDetails = <String, dynamic>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'all'.obs;
  final RxString selectedComplex = 'all'.obs;
  final RxList<Complex> complexes = <Complex>[].obs;

  final GroundApiService _groundApiService = GroundApiService();
  final ComplexApiService _complexApiService = ComplexApiService();
  final ReviewApiService _reviewApiService = ReviewApiService();
  final FavoriteApiService _favoriteApiService = FavoriteApiService();

  @override
  void onInit() {
    super.onInit();
    fetchComplexes();
  }

  Future<void> fetchReviews(int groundId) async {
    isLoadingReviews.value = true;
    try {
      final reviewList = await _reviewApiService.getPublicReviews(
        groundId: groundId,
      );
      reviews.value = reviewList;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> fetchGroundBySlug(String slug) async {
    isLoadingGround.value = true;
    try {
      final ground = await _groundApiService.getGroundBySlug(slug);
      groundDetails.value = ground.toJson();

      // Fetch reviews for this ground
      await fetchReviews(ground.id);
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch ground details: $e');
    } finally {
      isLoadingGround.value = false;
    }
  }

  Future<void> fetchPublicGrounds() async {
    isLoadingGrounds.value = true;
    try {
      final groundList = await _groundApiService.getPublicGrounds();
      grounds.value = groundList;
      filteredGrounds.value = groundList;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch grounds: $e');
    } finally {
      isLoadingGrounds.value = false;
    }
  }

  Future<void> fetchComplexes() async {
    try {
      final complexList = await _complexApiService.getPublicComplexes();
      complexes.value = complexList;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch complexes: $e');
    }
  }

  void filterGrounds() {
    var filtered = grounds.where((ground) {
      bool matchesSearch =
          ground.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (ground.description?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);

      bool matchesType =
          selectedType.value == 'all' || ground.type == selectedType.value;

      bool matchesComplex =
          selectedComplex.value == 'all' ||
          ground.complexId.toString() == selectedComplex.value;

      return matchesSearch && matchesType && matchesComplex;
    }).toList();

    filteredGrounds.value = filtered;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterGrounds();
  }

  void updateSelectedType(String type) {
    selectedType.value = type;
    filterGrounds();
  }

  void updateSelectedComplex(String complexId) {
    selectedComplex.value = complexId;
    filterGrounds();
  }

  Future<void> submitReview({
    required int groundId,
    required double rating,
    required String comment,
    String? userName,
    String? userEmail,
  }) async {
    try {
      final reviewData = {
        'ground_id': groundId,
        'rating': rating,
        'comment': comment,
        if (userName != null && userName.trim().isNotEmpty)
          'user_name': userName.trim(),
        if (userEmail != null && userEmail.trim().isNotEmpty)
          'user_email': userEmail.trim(),
      };

      await _reviewApiService.createPublicReview(reviewData);
      AppUtils.showSuccess(message: 'Review submitted successfully!');
      await fetchReviews(groundId);
    } catch (e) {
      AppUtils.showError(message: 'Failed to submit review: $e');
    }
  }

  Future<void> toggleFavorite(int groundId) async {
    try {
      // Check if ground is already favorited
      final favorites = await _favoriteApiService.getUserFavorites();
      final isFavorited = favorites.any((fav) => fav.groundId == groundId);

      if (isFavorited) {
        await _favoriteApiService.removeFavorite(groundId);
        AppUtils.showSuccess(message: 'Removed from favorites');
      } else {
        await _favoriteApiService.addFavorite(groundId);
        AppUtils.showSuccess(message: 'Added to favorites');
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to update favorite: $e');
    }
  }

  Future<List<dynamic>> getGroundBookings(int groundId, {String? date}) async {
    try {
      return await _groundApiService.getGroundBookings(groundId, date: date);
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch ground bookings: $e');
      return [];
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'all';
    selectedComplex.value = 'all';
    filterGrounds();
  }
}
