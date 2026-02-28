import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class GroundController extends GetxController {
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingGround = false.obs;
  final RxList<dynamic> reviews = <dynamic>[].obs;
  final RxMap<String, dynamic> groundDetails = <String, dynamic>{}.obs;

  Future<void> fetchReviews(int groundId) async {
    isLoadingReviews.value = true;
    try {
      final res = await ApiClient().dio.get(
        '/public/reviews',
        queryParameters: {'ground_id': groundId},
      );
      if (res.statusCode == 200) {
        reviews.value = res.data;
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> fetchGroundBySlug(String slug) async {
    isLoadingGround.value = true;
    try {
      final res = await ApiClient().dio.get('/public/grounds/$slug');
      if (res.statusCode == 200) {
        groundDetails.value = res.data;
        // Optionally fetch reviews too if ground details found
        if (res.data['id'] != null) {
          fetchReviews(res.data['id']);
        }
      }
    } catch (e) {
      print('Error fetching ground details: $e');
    } finally {
      isLoadingGround.value = false;
    }
  }

  Future<void> submitReview({
    required int groundId,
    required double rating,
    required String comment,
  }) async {
    try {
      final res = await ApiClient().dio.post(
        '/public/reviews',
        data: {'ground_id': groundId, 'rating': rating, 'comment': comment},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Success', 'Review submitted successfully!');
        fetchReviews(groundId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit review');
    }
  }
}
