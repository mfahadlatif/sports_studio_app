import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class GroundsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxList<Ground> grounds = <Ground>[].obs;
  final RxList<Complex> complexes = <Complex>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComplexesAndGrounds();
  }

  Future<void> fetchComplexesAndGrounds() async {
    isLoading.value = true;
    try {
      final groundsResponse = await _apiClient.dio.get('/grounds');
      if (groundsResponse.statusCode == 200) {
        final List data = groundsResponse.data['data'] ?? [];
        grounds.value = data.map((e) => Ground.fromJson(e)).toList();
      }

      final complexResponse = await _apiClient.dio.get('/complexes');
      if (complexResponse.statusCode == 200) {
        final List cData = complexResponse.data['data'] ?? [];
        complexes.value = cData.map((e) => Complex.fromJson(e)).toList();
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch grounds info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGround(dynamic data) async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post('/grounds', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchComplexesAndGrounds();
        return true;
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to create ground');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> deleteGround(int id) async {
    try {
      final response = await _apiClient.dio.delete('/grounds/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        grounds.removeWhere((g) => g.id == id);
        AppUtils.showSuccess(message: 'Ground deleted successfully');
        return true;
      }
    } catch (e) {
      print('Delete Error: $e');
      AppUtils.showError(message: 'Failed to delete ground');
    }
    return false;
  }
}
