import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/models/models.dart';

class AddGroundController extends GetxController {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final rulesController = TextEditingController();
  final cancellationPolicyController = TextEditingController();

  final RxString selectedSport = 'Cricket'.obs;
  final RxList<String> selectedAmenities = <String>[].obs;
  final RxList<File> pickedImages = <File>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxString uploadStatus = ''.obs;

  final Rx<TimeOfDay> openingTime = const TimeOfDay(hour: 6, minute: 0).obs;
  final Rx<TimeOfDay> closingTime = const TimeOfDay(hour: 23, minute: 0).obs;
  final RxBool hasLighting = true.obs;
  final RxString status = 'active'.obs;

  // Complex Selection
  final RxList<Complex> availableComplexes = <Complex>[].obs;
  final Rx<Complex?> selectedComplex = Rx<Complex?>(null);
  final RxBool isLoadingComplexes = false.obs;

  final ImagePicker _picker = ImagePicker();
  final ApiClient _apiClient = ApiClient();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    fetchComplexes(preSelectedId: args?['complexId']);
  }

  Future<void> fetchComplexes({int? preSelectedId}) async {
    try {
      isLoadingComplexes.value = true;
      final groundsController = Get.find<GroundsController>();

      // Try to get from existing controller first
      if (groundsController.complexes.isEmpty) {
        await groundsController.fetchComplexesAndGrounds();
      }

      availableComplexes.assignAll(groundsController.complexes);

      if (preSelectedId != null) {
        selectedComplex.value = availableComplexes.firstWhereOrNull(
          (c) => c.id == preSelectedId,
        );
      } else if (availableComplexes.isNotEmpty) {
        selectedComplex.value = availableComplexes.first;
      }
    } catch (e) {
      debugPrint('Error fetching complexes: $e');
    } finally {
      isLoadingComplexes.value = false;
    }
  }

  Future<void> pickImages() async {
    debugPrint('🌐 [AddGround] Opening image picker (multi-select)...');
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      pickedImages.addAll(images.map((img) => File(img.path)));
      debugPrint(
        '✅ [AddGround] ${images.length} images selected. Total: ${pickedImages.length}',
      );
    } else {
      debugPrint('⚠️ [AddGround] No images selected');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < pickedImages.length) {
      debugPrint('🗑️ [AddGround] Removing image at index $index');
      pickedImages.removeAt(index);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  final Map<String, String> amenitiesList = {
    'Wifi': '📶',
    'Parking': '🅿️',
    'Changing Room': '🚿',
    'Showers': '🧼',
    'Floodlights': '💡',
    'First Aid': '🏥',
    'Drinking Water': '💧',
    'Cafe': '☕',
    'Lockers': '🔐',
    'Equipment': '🎯',
  };

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    lengthController.dispose();
    widthController.dispose();
    rulesController.dispose();
    cancellationPolicyController.dispose();
    super.onClose();
  }

  /// Uploads a single image file to /upload and returns the URL string.
  Future<String?> _uploadSingleImage(
    File imageFile,
    int index,
    int total,
  ) async {
    try {
      uploadStatus.value = 'Uploading image ${index + 1} of $total...';
      debugPrint(
        '🌐 [AddGround] Uploading image ${index + 1}/$total: ${imageFile.path}',
      );

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename:
              'ground_image_${index}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiClient.dio.post('/upload', data: formData);

      debugPrint(
        '✅ [AddGround] Upload ${index + 1} response: status=${response.statusCode}',
      );
      debugPrint('   data=${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final url = response.data['url'] as String?;
        if (url != null && url.isNotEmpty) {
          debugPrint('✅ [AddGround] Image ${index + 1} URL: $url');
          return url;
        }
        debugPrint('⚠️ [AddGround] No URL in response: ${response.data}');
      } else {
        debugPrint(
          '❌ [AddGround] Upload ${index + 1} failed: status=${response.statusCode}',
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ [AddGround] Upload ${index + 1} DioException: ${e.type}');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Body: ${e.response?.data}');
    } catch (e) {
      debugPrint('❌ [AddGround] Upload ${index + 1} exception: $e');
    }
    return null;
  }

  Future<void> submit() async {
    if (selectedComplex.value == null) {
      AppUtils.showError(message: 'Please select a sports complex first');
      return;
    }

    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      AppUtils.showError(
        message: 'Please fill required fields (Name and Price)',
      );
      return;
    }

    isSubmitting.value = true;
    uploadStatus.value = '';

    try {
      final complexId = selectedComplex.value!.id;
      debugPrint('✅ [AddGround] Using complex_id: $complexId');

      // ── Step 1: Upload images ───────────────────────────────────────────────
      final List<String> imageUrls = [];
      if (pickedImages.isNotEmpty) {
        debugPrint(
          '🌐 [AddGround] Uploading ${pickedImages.length} image(s)...',
        );
        for (int i = 0; i < pickedImages.length; i++) {
          final url = await _uploadSingleImage(
            pickedImages[i],
            i,
            pickedImages.length,
          );
          if (url != null) imageUrls.add(url);
        }
        debugPrint(
          '✅ [AddGround] Uploaded ${imageUrls.length}/${pickedImages.length} images',
        );
      }

      uploadStatus.value = 'Creating ground...';

      // ── Step 2: Build payload ───────────────────────────────────────────────
      final dimensions =
          (lengthController.text.trim().isNotEmpty &&
              widthController.text.trim().isNotEmpty)
          ? '${lengthController.text.trim()}x${widthController.text.trim()} ft'
          : null;

      final Map<String, dynamic> payload = {
        'name': nameController.text.trim(),
        'price_per_hour': double.tryParse(priceController.text.trim()) ?? 0,
        'type': selectedSport.value.toLowerCase(),
        'description': descriptionController.text.trim(),
        'complex_id': complexId,
        'opening_time': _formatTime(openingTime.value),
        'closing_time': _formatTime(closingTime.value),
        'amenities': selectedAmenities.toList(),
        'status': status.value,
        'lighting': hasLighting.value ? '1' : '0',
        if (dimensions != null) 'dimensions': dimensions,
        if (imageUrls.isNotEmpty) 'images': imageUrls,
      };

      debugPrint('🌐 [AddGround] POST /grounds with payload:');
      debugPrint('   name: ${payload['name']}');
      debugPrint('   images (${imageUrls.length}): $imageUrls');

      // ── Step 3: POST to /grounds ────────────────────────────────────────────
      final response = await _apiClient.dio.post('/grounds', data: payload);

      debugPrint(
        '✅ [AddGround] Ground creation response: status=${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        uploadStatus.value = '';
        final groundsController = Get.find<GroundsController>();
        await groundsController.fetchComplexesAndGrounds();
        Get.back();
        AppUtils.showSuccess(message: 'Ground published successfully!');
      } else {
        AppUtils.showError(
          message: 'Failed to publish ground. Status: ${response.statusCode}',
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ [AddGround] DioException: ${e.response?.data}');
      String errorMsg = 'Failed to publish ground';
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('errors')) {
        final errors = responseData['errors'] as Map;
        errorMsg = errors.values.expand((v) => v is List ? v : [v]).join(', ');
      }
      AppUtils.showError(message: errorMsg);
    } catch (e) {
      debugPrint('❌ [AddGround] Unexpected error: $e');
      AppUtils.showError(message: 'Failed to publish ground: $e');
    } finally {
      isSubmitting.value = false;
      uploadStatus.value = '';
    }
  }
}
