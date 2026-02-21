import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/me');
      if (response.statusCode == 200) {
        userProfile.value = response.data['user'] ?? response.data;
      }
    } catch (e) {
      print('Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
