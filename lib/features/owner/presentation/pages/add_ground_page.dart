import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/owner/controller/add_ground_controller.dart';

class AddGroundPage extends StatelessWidget {
  const AddGroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddGroundController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Add New Ground'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),

                _sectionHeader('Ground Media', Icons.image_outlined),
                const SizedBox(height: AppSpacing.m),
                _buildImagePicker(),
                const SizedBox(height: AppSpacing.l),

                _sectionHeader('Ground Details', Icons.info_outline),
                const SizedBox(height: AppSpacing.m),

                _lbl('Ground Name *'),
                _textField(
                  'e.g. Center Pitch 1',
                  Icons.sports_soccer,
                  textController: controller.nameController,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Location / Area *'),
                _textField(
                  'e.g. Gulberg, Lahore',
                  Icons.location_on_outlined,
                  textController: controller.locationController,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Price per Hour (Rs.) *'),
                _textField(
                  'e.g. 3000',
                  Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  textController: controller.priceController,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Sport Category'),
                _buildDropdownField([
                  'Cricket',
                  'Football',
                  'Tennis',
                  'Badminton',
                ], controller),
                const SizedBox(height: AppSpacing.l),

                _sectionHeader('Description', Icons.description_outlined),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: controller.descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your ground, facilities, etc...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                _buildSubmitButton(controller),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'List Your Ground',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add a new sports arena to your complex and start receiving bookings.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Ground Images',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: AppColors.primary.withOpacity(0.2))),
    ],
  );

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _textField(
    String hint,
    IconData? icon, {
    TextInputType? keyboardType,
    TextEditingController? textController,
  }) {
    return TextField(
      controller: textController,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    List<String> items,
    AddGroundController controller,
  ) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedSport.value,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.sports_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) controller.selectedSport.value = v;
        },
        hint: const Text('Select Sport'),
      ),
    );
  }

  Widget _buildSubmitButton(AddGroundController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isSubmitting.value
              ? null
              : () => controller.submit(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isSubmitting.value
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Publishing...'),
                  ],
                )
              : Text(
                  'Publish Ground',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
