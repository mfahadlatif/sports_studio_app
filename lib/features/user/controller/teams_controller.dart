import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sport_studio/core/network/api_services.dart';
import 'package:sport_studio/core/models/models.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';

class TeamsController extends GetxController {
  final RxBool isLoadingTeams = false.obs;
  final RxBool isLoadingTeam = false.obs;
  final RxBool isCreatingTeam = false.obs;
  final RxBool isJoiningTeam = false.obs;
  final RxList<Team> teams = <Team>[].obs; // This will be the filtered list shown in UI
  final List<Team> _allTeams = []; // Source of truth
  final Rxn<Team> selectedTeam = Rxn<Team>();
  final RxString searchQuery = ''.obs;
  final RxBool isUpdating = false.obs;

  // Team creation form controllers
  final teamNameController = TextEditingController();
  final teamSportController = TextEditingController();
  final teamDescriptionController = TextEditingController();
  final teamLogoController = TextEditingController();

  final TeamApiService _teamApiService = TeamApiService();
  final UserApiService _userApiService = UserApiService();

  Future<List<User>> searchUsers(String query) async {
    if (query.length < 3) return [];
    try {
      return await _userApiService.searchUsers(query);
    } catch (e) {
      print('❌ [TeamsCtrl] searchUsers error: $e');
      return [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    isLoadingTeams.value = true;
    try {
      final teamList = await _teamApiService.getUserTeams();
      _allTeams.clear();
      _allTeams.addAll(teamList);
      
      if (searchQuery.value.isEmpty) {
        teams.assignAll(teamList);
      } else {
        filterTeams();
      }
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
      Get.back(); // Close bottom sheet first
      AppUtils.showSuccess(
        message: 'Team "${team.name}" created successfully!',
      );
      clearTeamForm();
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
      Get.back(); // Close bottom sheet first
      AppUtils.showSuccess(message: 'Team updated successfully!');
      selectedTeam.value = team;
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
      _allTeams.removeWhere((team) => team.id == teamId);
      teams.removeWhere((team) => team.id == teamId);
      Get.back();
    } catch (e) {
      AppUtils.showError(message: 'Failed to delete team: $e');
    }
  }

  Future<void> joinTeam(int teamId, {String role = 'player'}) async {
    isJoiningTeam.value = true;
    try {
      final currentTeam = selectedTeam.value ?? teams.firstWhereOrNull((t) => t.id == teamId);

      // Guard: don't try to join if already a member or owner
      if (currentTeam != null && (isUserTeamOwner(currentTeam) || isUserTeamMember(currentTeam))) {
        AppUtils.showInfo(message: 'You are already a member of this team.');
        isJoiningTeam.value = false;
        return;
      }

      // Do NOT send user_id at all — the backend uses Auth::id() when
      // no user_id/email/phone is in the payload (join-self flow).
      final memberData = <String, dynamic>{
        'role': role,
      };

      await _teamApiService.addTeamMember(teamId, memberData);
      AppUtils.showSuccess(message: 'Joined team successfully!');
      await getTeamById(teamId);
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: AppUtils.extractErrorMessage(e.toString()));
    } finally {
      isJoiningTeam.value = false;
    }
  }

  Future<void> leaveTeam(int teamId) async {
    try {
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userProfile['id'];
      if (userId == null) return;
      
      await _teamApiService.removeTeamMember(teamId, userId);
      AppUtils.showSuccess(message: 'Left team successfully');
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: 'Failed to leave team: $e');
    }
  }

  Future<void> addMemberManual(int teamId, {String? email, String? phone, String? role}) async {
    try {
      final memberData = {
        'email': email,
        'phone': phone,
        'role': role ?? 'player',
      };

      await _teamApiService.addTeamMember(teamId, memberData);
      AppUtils.showSuccess(message: 'Member added successfully!');
      
      // Refresh selected team to see new member
      await getTeamById(teamId);
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: AppUtils.extractErrorMessage(e.toString()));
    }
  }

  Future<void> addMember(int teamId, int userId, String role) async {
    try {
      final memberData = {'user_id': userId, 'role': role};

      await _teamApiService.addTeamMember(teamId, memberData);
      AppUtils.showSuccess(message: 'Member added successfully!');
      
      // Refresh selected team to see new member
      await getTeamById(teamId);
      fetchTeams();
    } catch (e) {
      AppUtils.showError(message: AppUtils.extractErrorMessage(e.toString()));
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
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      teams.assignAll(_allTeams);
      return;
    }
 
    final filtered = _allTeams.where((team) {
      final nameMatch = team.name.toLowerCase().contains(query);
      final sportMatch = team.sport?.toLowerCase().contains(query) ?? false;
      final descMatch = team.description?.toLowerCase().contains(query) ?? false;
      return nameMatch || sportMatch || descMatch;
    }).toList();
 
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
    if (!Get.isRegistered<ProfileController>()) return false;
    final profileController = Get.find<ProfileController>();
    // Parse to int — userProfile['id'] is dynamic from JSON and may be int or String
    final userId = int.tryParse(profileController.userProfile['id']?.toString() ?? '');
    if (userId == null) return false;
    return team.ownerId == userId;
  }

  bool isUserTeamMember(Team team) {
    if (!Get.isRegistered<ProfileController>()) return false;
    final profileController = Get.find<ProfileController>();
    // Parse to int — userProfile['id'] is dynamic from JSON
    final userId = int.tryParse(profileController.userProfile['id']?.toString() ?? '');
    if (userId == null) return false;

    // Owners are implicitly members of their team.
    if (team.ownerId == userId) return true;

    final members = team.members;
    if (members != null) {
      return members.any((m) => m.userId == userId);
    }

    // Fallback: fetchTeams() loads current user's teams, so if this
    // team appears in teams list, the user belongs to it.
    return teams.any((t) => t.id == team.id);
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
