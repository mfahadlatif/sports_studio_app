import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_services.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';

class JoinRequestsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxList<dynamic> requests = <dynamic>[].obs;
  final RxString statusFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  final EventParticipantApiService _apiService = EventParticipantApiService();

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userProfile['id'];
      
      if (userId == null) return;

      final data = await _apiService.getOrganizerJoinRequests(userId);
      
      // Strict client-side filtering: Ensure every request belongs to an event organized by the current user
      final filteredData = data.where((request) {
        final event = request['event'];
        if (event == null) return false;
        return event['organizer_id']?.toString() == userId.toString();
      }).toList();

      requests.assignAll(filteredData);
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch join requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String status, {String? reason}) async {
    isUpdating.value = true;
    try {
      await _apiService.updateParticipantStatus(
        id,
        status: status,
        rejectionReason: reason,
      );
      
      // Update local state
      final index = requests.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        requests[index]['status'] = status;
        requests.refresh();
      }
      
      AppUtils.showSuccess(message: 'Request ${status == 'accepted' ? 'approved' : 'rejected'} successfully');
    } catch (e) {
      AppUtils.showError(message: 'Failed to update status: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  List<dynamic> get filteredRequests {
    return requests.where((request) {
      final playerName = request['user']?['name']?.toString().toLowerCase() ?? '';
      final eventName = request['event']?['name']?.toString().toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      
      final matchesSearch = playerName.contains(query) || eventName.contains(query);
      final matchesStatus = statusFilter.value == 'all' || request['status'] == statusFilter.value;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get pendingCount => requests.where((r) => r['status'] == 'pending').length;
}
