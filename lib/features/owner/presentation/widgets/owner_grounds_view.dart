import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';
import 'package:sports_studio/core/models/models.dart';

class OwnerGroundsView extends StatelessWidget {
  const OwnerGroundsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroundsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grounds'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/add-ground'),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.grounds.isEmpty) {
          return const Center(
            child: Text(
              'No grounds found. Tap + to add one.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: controller.grounds.length,
              itemBuilder: (context, index) {
                final ground = controller.grounds[index];
                return _buildManageGroundCard(ground);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildManageGroundCard(Ground ground) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${ground.name}&background=random',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(ground.name, style: AppTextStyles.h3),
            subtitle: Text('Status: ${ground.status.toUpperCase()}'),
            trailing: const Icon(Icons.more_vert),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.edit_outlined, 'Edit'),
                _buildActionButton(Icons.calendar_month_outlined, 'Bookings'),
                _buildActionButton(Icons.analytics_outlined, 'Stats'),
                _buildActionButton(
                  Icons.delete_outline,
                  'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ],
    );
  }
}
