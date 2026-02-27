import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';

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

  final Map<String, String> amenitiesList = {
    'Wifi': '📡',
    'Parking': '🚗',
    'Changing Room': '👕',
    'Showers': '🚿',
    'Floodlights': '💡',
    'First Aid': '🏥',
    'Drinking Water': '💧',
    'Cafe': '☕',
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
      Get.snackbar('Error', 'Please fill required fields (Name and Price)');
      return;
    }

    isSubmitting.value = true;
    try {
      final groundsController = Get.find<GroundsController>();

      final data = {
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
        'complex_id': groundsController.complexes.isNotEmpty
            ? groundsController.complexes.first.id
            : 1,
      };

      final success = await groundsController.createGround(data);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Ground published successfully!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to publish ground: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
