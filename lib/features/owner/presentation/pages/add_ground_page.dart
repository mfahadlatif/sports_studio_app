import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';

class AddGroundPage extends StatelessWidget {
  const AddGroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Ground'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: AppSpacing.l),
            _buildTextField('Ground Name', 'Enter ground name', Icons.sports_soccer),
            const SizedBox(height: AppSpacing.m),
            _buildTextField('Location', 'City, Area', Icons.location_on_outlined),
            const SizedBox(height: AppSpacing.m),
            _buildTextField('Price per Hour', 'e.g. 3000', Icons.payments_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.m),
            _buildDropdownField('Sport Type', ['Cricket', 'Football', 'Tennis', 'Badminton']),
            const SizedBox(height: AppSpacing.m),
            _buildTextField('Description', 'Tell players about your ground...', null, maxLines: 4),
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Add Ground Images', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData? icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {},
          hint: const Text('Select Sport'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Get.back();
          Get.snackbar('Success', 'Ground added successfully!', snackPosition: SnackPosition.BOTTOM);
        },
        child: const Text('Publish Ground'),
      ),
    );
  }
}
