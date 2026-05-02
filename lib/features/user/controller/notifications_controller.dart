import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';

class NotificationsController extends GetxController {
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
    // Auto-update count every 30 seconds
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      fetchUnreadCount();
      _startPolling();
    });
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await ApiClient().dio.get('/notifications/unread-count');
      if (res.statusCode == 200) {
        unreadCount.value = res.data['unread_count'] ?? res.data['count'] ?? 0;
      }
    } catch (e) {
      print('❌ [NotifCtrl] Error fetching unread count: $e');
    }
  }

  void resetCount() {
    unreadCount.value = 0;
  }

  void decrementCount() {
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }
}
