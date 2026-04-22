import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';

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
      print('🌐 [GroundsCtrl] Fetching owner grounds & complexes...');

      final groundsResponse = await _apiClient.dio.get('/grounds');
      print(
        '✅ [GroundsCtrl] Grounds response: status=${groundsResponse.statusCode}',
      );
      if (groundsResponse.statusCode == 200) {
        final List data = groundsResponse.data['data'] ?? [];
        grounds.value = data.map((e) => Ground.fromJson(e)).toList();
        print('✅ [GroundsCtrl] Loaded ${grounds.length} grounds');
        for (final g in grounds) {
          print('   Ground [${g.id}] "${g.name}" images: ${g.images}');
        }
      } else {
        print(
          '❌ [GroundsCtrl] Grounds non-200: ${groundsResponse.statusCode}, body: ${groundsResponse.data}',
        );
      }

      final complexResponse = await _apiClient.dio.get('/complexes');
      print(
        '✅ [GroundsCtrl] Complexes response: status=${complexResponse.statusCode}',
      );
      if (complexResponse.statusCode == 200) {
        final List cData = complexResponse.data['data'] ?? [];
        complexes.value = cData.map((e) => Complex.fromJson(e)).toList();
        print('✅ [GroundsCtrl] Loaded ${complexes.length} complexes');
      } else {
        print(
          '❌ [GroundsCtrl] Complexes non-200: ${complexResponse.statusCode}, body: ${complexResponse.data}',
        );
      }
    } catch (e) {
      print('❌ [GroundsCtrl] fetchComplexesAndGrounds error: $e');
      AppUtils.showError(message: 'Failed to fetch grounds info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGround(dynamic data) async {
    isLoading.value = true;
    try {
      print('🌐 [GroundsCtrl] POST /grounds ...');
      final response = await _apiClient.dio.post('/grounds', data: data);
      print(
        '✅ [GroundsCtrl] Create ground response: status=${response.statusCode}',
      );
      print('   Body: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchComplexesAndGrounds();
        return true;
      } else {
        print(
          '❌ [GroundsCtrl] Create ground non-200: ${response.statusCode}, body: ${response.data}',
        );
        AppUtils.showError(
          message: 'Failed to create ground. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [GroundsCtrl] createGround error: $e');
      AppUtils.showError(message: 'Failed to create ground: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> deleteGround(int id) async {
    try {
      print('🌐 [GroundsCtrl] DELETE /grounds/$id...');
      final response = await _apiClient.dio.delete('/grounds/$id');
      print(
        '✅ [GroundsCtrl] Delete ground response: status=${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        grounds.removeWhere((g) => g.id == id);
        AppUtils.showSuccess(message: 'Ground deleted successfully');
        return true;
      } else {
        print(
          '❌ [GroundsCtrl] Delete ground non-200: ${response.statusCode}, body: ${response.data}',
        );
        AppUtils.showError(message: 'Failed to delete ground');
      }
    } catch (e) {
      print('❌ [GroundsCtrl] deleteGround error: $e');
      AppUtils.showError(message: 'Failed to delete ground: $e');
    }
    return false;
  }
}
