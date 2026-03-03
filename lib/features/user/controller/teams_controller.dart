import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class TeamsController extends GetxController {
  final RxBool isLoadingTeams = false.obs;
  final RxBool isLoadingTeam = false.obs;
  final RxBool isCreatingTeam = false.obs;
  final RxBool isJoiningTeam = false.obs;
  final RxList<Team> teams = <Team>[].obs;
  final Rxn<Team> selectedTeam = Rxn<Team>();
  final RxString searchQuery = ''.obs;

  // Team creation form controllers
  final teamNameController = TextEditingController();
  final teamSportController = TextEditingController();
  final teamDescriptionController = TextEditingController();
  final teamLogoController = TextEditingController();

  final TeamApiService _teamApiService = TeamApiService();

  @override
  void onInit() {
    super.onInit();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    isLoadingTeams.value = true;
    try {
      final teamList = await _teamApiService.getUserTeams();
      teams.value = teamList;
    } catch (e) {
      AppUtils.showError(message: 'Failed to load teams: $e');
    } finally {
      isLoadingTeams.value = false;
    }
  }

  Future<void> getTeamById(int id) async {
    isLoadingTeam.value = true;
    try {
      final team = await _teamApiService.getTeam(id);
      selectedTeam.value = team;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch team: $e');
    } finally {
      isLoadingTeam.value = false;
    }
  }

  Future<void> createTeam() async {
    if (teamNameController.text.trim().isEmpty) {
      AppUtils.showError(message: 'Team name is required');
      return;
    }

    isCreatingTeam.value = true;
    try {
      final teamData = {
        'name': teamNameController.text.trim(),
        'sport': teamSportController.text.trim(),
        'description': teamDescriptionController.text.trim(),
        'logo': teamLogoController.text.trim(),
      };

      final team = await _teamApiService.createTeam(teamData);
      AppUtils.showSuccess(
        message: 'Team "${team.name}" created successfully!',
      );
      clearTeamForm();
      Get.back();
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: 'Failed to create team: $e');
    } finally {
      isCreatingTeam.value = false;
    }
  }

  Future<void> updateTeam(int teamId) async {
    if (teamNameController.text.trim().isEmpty) {
      AppUtils.showError(message: 'Team name is required');
      return;
    }

    isCreatingTeam.value = true;
    try {
      final teamData = {
        'name': teamNameController.text.trim(),
        'sport': teamSportController.text.trim(),
        'description': teamDescriptionController.text.trim(),
        'logo': teamLogoController.text.trim(),
      };

      final team = await _teamApiService.updateTeam(teamId, teamData);
      AppUtils.showSuccess(message: 'Team updated successfully!');
      selectedTeam.value = team;
      Get.back();
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: 'Failed to update team: $e');
    } finally {
      isCreatingTeam.value = false;
    }
  }

  Future<void> deleteTeam(int teamId) async {
    try {
      await _teamApiService.deleteTeam(teamId);
      AppUtils.showSuccess(message: 'Team deleted successfully');
      teams.removeWhere((team) => team.id == teamId);
      Get.back();
    } catch (e) {
      AppUtils.showError(message: 'Failed to delete team: $e');
    }
  }

  Future<void> joinTeam(int teamId, {String role = 'player'}) async {
    isJoiningTeam.value = true;
    try {
      final memberData = {
        'user_id': null, // Will be set by backend from authenticated user
        'role': role,
      };

      await _teamApiService.addTeamMember(teamId, memberData);
      AppUtils.showSuccess(message: 'Joined team successfully!');
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: 'Failed to join team: $e');
    } finally {
      isJoiningTeam.value = false;
    }
  }

  Future<void> leaveTeam(int teamId) async {
    try {
      // Get current user ID from profile or auth
      // This would need to be implemented based on your auth system
      await _teamApiService.removeTeamMember(
        teamId,
        0,
      ); // Replace 0 with actual user ID
      AppUtils.showSuccess(message: 'Left team successfully');
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: 'Failed to leave team: $e');
    }
  }

  Future<void> addMember(int teamId, int userId, String role) async {
    try {
      final memberData = {'user_id': userId, 'role': role};

      await _teamApiService.addTeamMember(teamId, memberData);
      AppUtils.showSuccess(message: 'Member added successfully!');

      // Refresh team details if selected
      if (selectedTeam.value != null && selectedTeam.value!.id == teamId) {
        await getTeamById(teamId);
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to add member: $e');
    }
  }

  Future<void> removeMember(int teamId, int userId) async {
    try {
      await _teamApiService.removeTeamMember(teamId, userId);
      AppUtils.showSuccess(message: 'Member removed successfully!');

      // Refresh team details if selected
      if (selectedTeam.value != null && selectedTeam.value!.id == teamId) {
        await getTeamById(teamId);
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to remove member: $e');
    }
  }

  void filterTeams() {
    if (searchQuery.value.isEmpty) {
      return;
    }

    var filtered = teams.where((team) {
      return team.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          (team.sport?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false) ||
          (team.description?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);
    }).toList();

    // Update filtered list (you might want to create a separate filtered list variable)
    teams.assignAll(filtered);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterTeams();
  }

  void clearTeamForm() {
    teamNameController.clear();
    teamSportController.clear();
    teamDescriptionController.clear();
    teamLogoController.clear();
  }

  void populateTeamForm(Team team) {
    teamNameController.text = team.name;
    teamSportController.text = team.sport ?? '';
    teamDescriptionController.text = team.description ?? '';
    teamLogoController.text = team.logo ?? '';
  }

  void clearFilters() {
    searchQuery.value = '';
    fetchTeams();
  }

  bool isUserTeamOwner(Team team) {
    // This would need to be implemented based on your auth system
    // Check if current user ID matches team.ownerId
    return false; // Placeholder
  }

  bool isUserTeamMember(Team team) {
    // This would need to be implemented based on your auth system
    // Check if current user ID is in team.members
    return false; // Placeholder
  }

  @override
  void onClose() {
    teamNameController.dispose();
    teamSportController.dispose();
    teamDescriptionController.dispose();
    teamLogoController.dispose();
    super.onClose();
  }
}
