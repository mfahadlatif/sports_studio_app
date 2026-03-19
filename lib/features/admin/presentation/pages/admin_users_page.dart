import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_button.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final List<dynamic> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/admin/users');
      if (res.statusCode == 200) {
        setState(() {
          _users.clear();
          _users.addAll(res.data['data'] ?? []);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: AppProgressIndicator())
                : filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(user['name']?[0]?.toUpperCase() ?? 'U'),
                        ),
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: Chip(
                          label: Text(
                            user['role']?.toString().toUpperCase() ?? 'USER',
                          ),
                          backgroundColor: (user['role'] == 'admin')
                              ? Colors.red.shade100
                              : AppColors.primaryLight,
                        ),
                        onTap: () => _showUserDetails(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(dynamic user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.l),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User Details', style: AppTextStyles.h2),
                IconButton(
                  onPressed: () => _confirmDelete(user),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            _detailRow('Name', user['name']),
            _detailRow('Email', user['email']),
            _detailRow('Phone', user['phone'] ?? 'N/A'),
            _detailRow(
              'Active',
              (user['is_active']?.toString() ?? 'true') == 'true' ? 'Yes' : 'No',
            ),
            const SizedBox(height: AppSpacing.m),
            const Text(
              'Manage Role',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['user', 'owner', 'admin'].map((role) {
                  final isCurrent = user['role'] == role;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(role.toUpperCase()),
                      selected: isCurrent,
                      onSelected: (selected) {
                        if (selected && !isCurrent) {
                          Get.back(); // close bottom sheet
                          _updateUser(user, {'role': role});
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Get.back();
                      await _toggleStatus(user);
                    },
                    icon: const Icon(Icons.toggle_on_outlined),
                    label: const Text('Toggle Active'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.back();
                      await _showAdjustBalanceSheet(user);
                    },
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: const Text('Adjust Wallet'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic user) {
    Get.defaultDialog(
      title: 'Restrict User',
      middleText:
          'Are you sure you want to ban ${user['name']}? This will revoke all access.',
      textConfirm: 'Ban User',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        Get.back(); // close bottom sheet
        _deleteUser(user);
      },
    );
  }

  Future<void> _deleteUser(dynamic user) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.delete('/admin/users/${user['id']}');
      if (res.statusCode == 200) {
        Get.snackbar('Success', 'User has been restricted');
        _fetchUsers();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to restrict user');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUser(dynamic user, Map<String, dynamic> updates) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.put(
        '/admin/users/${user['id']}',
        data: updates,
      );
      if (res.statusCode == 200) {
        Get.snackbar(
          'Success',
          'User updated successfully',
        );
        _fetchUsers();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(dynamic user) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.post(
        '/admin/users/${user['id']}/toggle-status',
      );
      if (res.statusCode == 200) {
        AppUtils.showSuccess(message: res.data['message'] ?? 'Status updated');
        _fetchUsers();
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to toggle status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAdjustBalanceSheet(dynamic user) async {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'credit';

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adjust Wallet Balance', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.m),
              _detailRow('User', user['name']),
              const SizedBox(height: AppSpacing.m),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'credit', child: Text('CREDIT')),
                  DropdownMenuItem(value: 'debit', child: Text('DEBIT')),
                ],
                onChanged: (v) => type = v ?? 'credit',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: AppSpacing.m),
              AppButton(
                label: 'Submit',
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text.trim());
                  if (amount == null || amount <= 0) {
                    AppUtils.showError(message: 'Enter a valid amount');
                    return;
                  }
                  if (descCtrl.text.trim().isEmpty) {
                    AppUtils.showError(message: 'Description is required');
                    return;
                  }
                  Get.back();
                  await _adjustBalance(
                    userId: int.tryParse(user['id']?.toString() ?? '') ?? 0,
                    amount: amount,
                    type: type,
                    description: descCtrl.text.trim(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _adjustBalance({
    required int userId,
    required double amount,
    required String type,
    required String description,
  }) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.post(
        '/admin/users/$userId/adjust-balance',
        data: {
          'amount': amount,
          'type': type,
          'description': description,
        },
      );
      if (res.statusCode == 200) {
        AppUtils.showSuccess(message: res.data['message'] ?? 'Balance adjusted');
        _fetchUsers();
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to adjust balance: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _detailRow(String lbl, String? val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$lbl: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(val ?? ''),
        ],
      ),
    );
  }
}
