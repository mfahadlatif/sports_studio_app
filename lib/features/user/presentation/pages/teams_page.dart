import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/theme/app_spacing.dart';
import 'package:sports_studio/features/user/controller/teams_controller.dart';
import 'package:sports_studio/widgets/app_button.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Community Teams',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                onPressed: () => _showCreateTeamDialog(context, controller),
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
            ],
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
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50),
                          child: CircularProgressIndicator(),
                        ),
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
                        final team = controller.teams[index];
                        return _teamCard(team);
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search teams by name or sport...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: AppColors.textSecondary),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        onChanged: (v) {
          // Add search logic if needed
        },
      ),
    );
  }

  Widget _teamCard(dynamic team) {
    final members = (team['members'] as List?) ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  team['sport']?.toString() ?? 'General',
                  style: AppTextStyles.label.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(team['name'] ?? 'Team Name', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            team['description'] ?? 'No description provided.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildAvatars(members),
                  const SizedBox(width: 8),
                  Text(
                    '${members.length} Members',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatars(List members) {
    if (members.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < members.length.clamp(0, 3); i++)
            Positioned(
              left: i * 18.0,
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
                    (members[i]['user']?['name'] ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          if (members.length > 3)
            Positioned(
              left: 3 * 18.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+${members.length - 3}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TeamsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.people_alt_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No teams found',
            style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "You haven't joined or created any teams yet. Start by creating your first team!",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: AppButton(
              label: 'Create Team',
              onPressed: () => _showCreateTeamDialog(context, controller),
              leadingIcon: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context, TeamsController controller) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedSport = 'Cricket';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Your Team', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Build your roster and start competing.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),
              _lbl('Team Name'),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Dream XI',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _lbl('Primary Sport'),
              DropdownButtonFormField<String>(
                value: selectedSport,
                items: ['Cricket', 'Football', 'Badminton', 'Padel', 'Tennis']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => selectedSport = v ?? 'Cricket',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _lbl('Description (Optional)'),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Brief about your team',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => AppButton(
                  label: 'Create Team',
                  isLoading: controller.isCreating.value,
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter a team name');
                      return;
                    }
                    controller.createTeam(
                      name: nameCtrl.text,
                      sport: selectedSport,
                      description: descCtrl.text,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
