import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> premiumGrounds = <dynamic>[].obs;

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
        }
      }
    } catch (e) {
      print('Failed to fetch premium grounds: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
