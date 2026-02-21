import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class EventsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> eventsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/public/events');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          eventsList.value = data['data'];
        }
      }
    } catch (e) {
      print('Failed to fetch events: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
