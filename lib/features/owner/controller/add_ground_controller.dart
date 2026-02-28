import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

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

  final Rx<TimeOfDay> openingTime = const TimeOfDay(hour: 6, minute: 0).obs;
  final Rx<TimeOfDay> closingTime = const TimeOfDay(hour: 23, minute: 0).obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      pickedImages.addAll(images.map((img) => File(img.path)));
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < pickedImages.length) {
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

  Future<void> submit() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      AppUtils.showError(
        message: 'Please fill required fields (Name and Price)',
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final groundsController = Get.find<GroundsController>();

      final Map<String, dynamic> dataMap = {
        'name': nameController.text,
        'location': locationController.text,
        'price_per_hour': double.tryParse(priceController.text) ?? 0,
        'type': selectedSport.value.toLowerCase(),
        'description': descriptionController.text,
        'length': double.tryParse(lengthController.text) ?? 0,
        'width': double.tryParse(widthController.text) ?? 0,
        'rules': rulesController.text,
        'cancellation_policy': cancellationPolicyController.text,
        'amenities': selectedAmenities.toList(),
        'status': 'active',
        'opening_time': _formatTime(openingTime.value),
        'closing_time': _formatTime(closingTime.value),
        'complex_id': groundsController.complexes.isNotEmpty
            ? groundsController.complexes.first.id
            : 1,
      };

      final formData = dio.FormData.fromMap(dataMap);

      // Add Images
      for (var image in pickedImages) {
        formData.files.add(
          MapEntry('images[]', await dio.MultipartFile.fromFile(image.path)),
        );
      }

      final success = await groundsController.createGround(formData);
      if (success) {
        Get.back();
        AppUtils.showSuccess(message: 'Ground published successfully!');
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to publish ground: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
