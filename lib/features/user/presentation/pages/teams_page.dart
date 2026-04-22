import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/theme/app_spacing.dart';
import 'package:sport_studio/features/user/controller/teams_controller.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/widgets/app_button.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/features/user/presentation/pages/team_detail_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'teams_fab',
        onPressed: () => _showCreateTeamDialog(context, controller),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Color(0x6621AF6F),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                'Community Teams',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchHeader(controller),
                  const SizedBox(height: AppSpacing.l),
                  Obx(() {
                    if (controller.isLoadingTeams.value) {
                      return const Padding(
                        padding: EdgeInsets.all(50),
                        child: AppProgressIndicator(),
                      );
                    }

                    if (controller.teams.isEmpty) {
                      return _buildEmptyState(context, controller);
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.teams.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final Team team = controller.teams[index];
                        return _teamCard(context, team, controller);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(TeamsController controller) {
    return TextField(
      onChanged: (v) => controller.updateSearchQuery(v),
      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Search teams or sports...',
        border: InputBorder.none,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
        ),
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _teamCard(BuildContext context, Team team, TeamsController controller) {
    final members = team.members ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            controller.selectedTeam.value = team;
            Get.to(() => const TeamDetailPage(), arguments: team);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            team.sport?.toUpperCase() ?? 'GENERAL',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.isUserTeamOwner(team))
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            controller.isUpdating.value = true;
                            controller.populateTeamForm(team);
                            _showCreateTeamDialog(context, controller, isUpdating: true, teamId: team.id);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, controller, team);
                          }
                        },
                        icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Edit Team'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete Team', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      const Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textMuted,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  team.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 20),
                ),
                if (team.description != null && team.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    team.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildAvatars(members),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${members.length} Members',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Active squad',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatars(List members) {
    if (members.isEmpty) return const SizedBox.shrink();
    final count = members.length.clamp(0, 3);
    final hasMore = members.length > 3;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++)
          Align(
            widthFactor: 0.6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  (members[i].user?.name ?? '').trim().isEmpty 
                      ? '?' 
                      : (members[i].user?.name ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        if (hasMore)
          Align(
            widthFactor: 0.6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7F1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '+${members.length - 3}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, TeamsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_add_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No teams found',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't joined or created any teams yet. Start by creating your first team and bring the competition!",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Create Team Now',
                onPressed: () => _showCreateTeamDialog(context, controller),
                leadingIcon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TeamsController controller, Team team) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteTeam(team.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context, TeamsController controller, {bool isUpdating = false, int? teamId}) {
    if (!isUpdating) {
      controller.clearTeamForm();
      controller.isUpdating.value = false;
      controller.teamSportController.text = 'Cricket';
    }

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(isUpdating ? 'Edit Team' : 'Create Your Team', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                isUpdating ? 'Update your team details here.' : 'Build your roster and start competing today.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _lbl('Team Name'),
              TextField(
                controller: controller.teamNameController,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g. Dream XI',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 20),
              _lbl('Primary Sport'),
              DropdownButtonFormField<String>(
                initialValue: controller.teamSportController.text,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(20),
                items: ['Cricket', 'Football', 'Badminton', 'Padel', 'Tennis']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodyMedium)))
                    .toList(),
                onChanged: (v) =>
                    controller.teamSportController.text = v ?? 'Cricket',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              _lbl('Description (Optional)'),
              TextField(
                controller: controller.teamDescriptionController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Brief about your team mission...',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 36),
              Obx(
                () => AppButton(
                  label: isUpdating ? 'Save Changes' : 'Launch Team',
                  isLoading: controller.isCreatingTeam.value,
                  onPressed: () {
                    if (controller.teamNameController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter a team name');
                      return;
                    }
                    if (isUpdating && teamId != null) {
                      controller.updateTeam(teamId);
                    } else {
                      controller.createTeam();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      t,
      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
