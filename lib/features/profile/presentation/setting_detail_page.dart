import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';

class SettingDetailPage extends StatelessWidget {
  const SettingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final title = args != null && args is Map
        ? args['title']
        : 'Setting Details';
    final description = args != null && args is Map
        ? args['description']
        : 'Manage your preferences here.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(description, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.l),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Feature'),
                  trailing: Switch(
                    value: true,
                    onChanged: (val) {},
                    activeColor: AppColors.primary,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Advanced Options'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
