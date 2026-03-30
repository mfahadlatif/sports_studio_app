import 'package:flutter/material.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class AdminWithdrawalsPage extends StatefulWidget {
  const AdminWithdrawalsPage({super.key});

  @override
  State<AdminWithdrawalsPage> createState() => _AdminWithdrawalsPageState();
}

class _AdminWithdrawalsPageState extends State<AdminWithdrawalsPage> {
  bool _loading = true;
  List<dynamic> _withdrawals = const [];
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().dio.get('/admin/withdrawals');
      final body = res.data;
      final list = (body is Map && body['data'] is List)
          ? body['data'] as List
          : (body is List ? body : const []);
      setState(() => _withdrawals = list);
    } catch (e) {
      AppUtils.showError(message: 'Failed to load withdrawals: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiClient().dio.post(
        '/admin/withdrawals/$id',
        data: {'status': status},
      );
      AppUtils.showSuccess(message: 'Updated to $status');
      await _fetch();
    } catch (e) {
      AppUtils.showError(message: 'Update failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? _withdrawals
        : _withdrawals.where((w) => (w as Map?)?['status']?.toString() == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawals'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: AppProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _filter,
                          decoration: const InputDecoration(labelText: 'Filter'),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'processing', child: Text('Processing')),
                            DropdownMenuItem(value: 'completed', child: Text('Completed')),
                            DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                          ],
                          onChanged: (v) => setState(() => _filter = v ?? 'all'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No withdrawals found'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final w = filtered[i] as Map? ?? {};
                            final id = int.tryParse(w['id']?.toString() ?? '');
                            final amount = w['amount']?.toString() ?? '0';
                            final status = w['status']?.toString() ?? 'pending';
                            final user = w['user'] is Map ? (w['user'] as Map) : null;
                            final userName = user?['name']?.toString() ?? 'User';
                            final createdAt = w['created_at']?.toString() ?? '';

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppColors.border.withOpacity(0.6)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.m),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${AppConstants.currencySymbol} $amount',
                                            style: AppTextStyles.h3,
                                          ),
                                        ),
                                        _chip(status),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$userName • $createdAt',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.s),
                                    if (id != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: status == 'completed'
                                                  ? null
                                                  : () => _updateStatus(id, 'processing'),
                                              child: const Text('Processing'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: status == 'completed'
                                                  ? null
                                                  : () => _updateStatus(id, 'completed'),
                                              child: const Text('Complete'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: status == 'rejected'
                                                  ? null
                                                  : () => _updateStatus(id, 'rejected'),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _chip(String status) {
    Color color = Colors.orange;
    if (status == 'completed') color = Colors.green;
    if (status == 'rejected') color = Colors.red;
    if (status == 'processing') color = Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

