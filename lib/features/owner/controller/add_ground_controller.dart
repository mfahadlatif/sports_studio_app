import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';

class AddGroundController extends GetxController {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxString selectedSport = 'Cricket'.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    descriptionController.dispose();
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
        'status': 'active',
        // In reality, this requires a complex_id but we default or pass it internally
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
