import 'package:flutter/material.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _loading = true;
  bool _saving = false;
  Map<String, dynamic> _settings = {};

  final _commissionCtrl = TextEditingController();
  final _refundPolicyCtrl = TextEditingController();
  final _minWithdrawalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().dio.get('/admin/settings');
      final body = res.data;
      final list = body is List ? body : (body is Map && body['data'] is List ? body['data'] as List : const []);

      final map = <String, dynamic>{};
      for (final item in list) {
        final m = item as Map? ?? {};
        final key = m['key']?.toString();
        if (key == null) continue;
        map[key] = m['value'];
      }

      setState(() => _settings = map);
      _commissionCtrl.text = (_settings['commission_fee'] ?? '').toString();
      _refundPolicyCtrl.text = (_settings['refund_policy'] ?? '').toString();
      _minWithdrawalCtrl.text = (_settings['minimum_withdrawal'] ?? '').toString();
    } catch (e) {
      AppUtils.showError(message: 'Failed to load settings: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiClient().dio.post(
        '/admin/settings',
        data: {
          // flat object form supported by backend
          'commission_fee': _commissionCtrl.text.trim(),
          'refund_policy': _refundPolicyCtrl.text.trim(),
          'minimum_withdrawal': _minWithdrawalCtrl.text.trim(),
        },
      );
      AppUtils.showSuccess(message: 'Settings updated');
      await _fetch();
    } catch (e) {
      AppUtils.showError(message: 'Failed to update settings: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _commissionCtrl.dispose();
    _refundPolicyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: AppProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  children: [
                    Text('Platform', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.s),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _commissionCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Commission Fee (%)',
                              hintText: 'e.g. 10',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          TextField(
                            controller: _refundPolicyCtrl,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Refund Policy',
                              hintText: 'Describe refund rules shown to users',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          TextField(
                            controller: _minWithdrawalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Minimum Withdrawal Amount',
                              hintText: 'e.g. 10',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AppButton(
                      label: _saving ? 'Saving...' : 'Save Settings',
                      onPressed: _saving ? null : _save,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Note: backend supports both flat updates and settings[] list payloads.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

