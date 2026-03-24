import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/theme/app_spacing.dart';
import 'package:sports_studio/features/user/controller/teams_controller.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TeamsController controller = Get.find<TeamsController>();
    final Team team = Get.arguments as Team;
    
    // Refresh team data when opening
    controller.getTeamById(team.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final currentTeam = controller.selectedTeam.value ?? team;
        final bool isOwner = controller.isUserTeamOwner(currentTeam);
        final members = currentTeam.members ?? [];

        return CustomScrollView(
          slivers: [
            _buildAppBar(context, currentTeam, isOwner),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTeamInfo(currentTeam),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Squad Members', style: AppTextStyles.h3),
                        if (isOwner)
                          TextButton.icon(
                            onPressed: () => _showAddMemberDialog(context, controller, currentTeam),
                            icon: const Icon(Icons.person_add_outlined, size: 20),
                            label: const Text('Add Member'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildMembersList(members, isOwner, controller, currentTeam),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final currentTeam = controller.selectedTeam.value ?? team;
        final bool isOwner = controller.isUserTeamOwner(currentTeam);
        final bool isMember = controller.isUserTeamMember(currentTeam);

        if (isOwner) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: AppButton(
            label: isMember ? 'Leave Team' : 'Join Team',
            onPressed: () {
              if (isMember) {
                _showLeaveConfirmation(context, controller, currentTeam);
              } else {
                controller.joinTeam(currentTeam.id);
              }
            },
            isLoading: controller.isJoiningTeam.value,
            backgroundColor: isMember ? Colors.red : AppColors.primary,
          ),
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context, Team team, bool isOwner) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      team.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    team.sport?.toUpperCase() ?? 'GENERAL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(Team team) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(team.name, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          if (team.description != null && team.description!.isNotEmpty)
            Text(
              team.description!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Owned by ${team.owner?.name ?? 'Unknown'}',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(List<dynamic> members, bool isOwner, TeamsController controller, Team team) {
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('No members yet'),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = members[index];
        final user = member.user;
        final String role = member.role ?? 'player';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  (user?.name ?? '?')[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Unknown', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(role.capitalizeFirst!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (isOwner && user?.id != team.ownerId)
                IconButton(
                  onPressed: () => _showRemoveMemberConfirmation(context, controller, team, user),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context, TeamsController controller, Team team) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final RxString selectedRole = 'player'.obs;
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Team Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter player details to add them to your squad.'),
              const SizedBox(height: 20),
              _dialogField(nameController, 'Player Name', Icons.person_outline),
              const SizedBox(height: 12),
              _dialogField(emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _dialogField(phoneController, 'Phone Number (Optional)', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                initialValue: selectedRole.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: ['player', 'captain', 'vice-captain', 'coach']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.capitalizeFirst!)))
                    .toList(),
                onChanged: (v) => selectedRole.value = v!,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            onPressed: isSubmitting.value ? null : () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                AppUtils.showError(message: 'Name and Email are required');
                return;
              }
              isSubmitting.value = true;
              
              await controller.addMemberManual(
                team.id,
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                role: selectedRole.value,
              );
              
              if (Get.isDialogOpen!) Get.back();
              isSubmitting.value = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isSubmitting.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Add Member', style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showRemoveMemberConfirmation(BuildContext context, TeamsController controller, Team team, dynamic user) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${user?.name} from the team?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeMember(team.id, user!.id);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, TeamsController controller, Team team) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Leave Team'),
        content: Text('Are you sure you want to leave "${team.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.leaveTeam(team.id);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
