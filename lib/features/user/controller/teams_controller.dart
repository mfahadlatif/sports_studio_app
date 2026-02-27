import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class TeamsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<dynamic> teams = <dynamic>[].obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    isLoading.value = true;
    try {
      final res = await ApiClient().dio.get('/teams');
      if (res.statusCode == 200) {
        teams.value = res.data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load teams');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTeam({
    required String name,
    required String sport,
    String? description,
  }) async {
    isCreating.value = true;
    try {
      final res = await ApiClient().dio.post(
        '/teams',
        data: {'name': name, 'sport': sport, 'description': description},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back(); // Close dialog
        Get.snackbar('Success', 'Team "$name" created successfully!');
        fetchTeams();
      } else {
        Get.snackbar('Error', 'Failed to create team');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while creating team');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> joinTeam(int teamId) async {
    try {
      final res = await ApiClient().dio.post('/teams/$teamId/members');
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Success', 'Joined the team!');
        fetchTeams();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to join team');
    }
  }
}
