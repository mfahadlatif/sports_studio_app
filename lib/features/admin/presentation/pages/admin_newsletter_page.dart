import 'package:flutter/material.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';

class AdminNewsletterPage extends StatefulWidget {
  const AdminNewsletterPage({super.key});

  @override
  State<AdminNewsletterPage> createState() => _AdminNewsletterPageState();
}

class _AdminNewsletterPageState extends State<AdminNewsletterPage> {
  bool _loading = true;
  List<dynamic> _subs = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().dio.get('/admin/newsletter');
      final body = res.data;
      final list = (body is Map && body['data'] is List)
          ? body['data'] as List
          : (body is List ? body : const []);
      setState(() => _subs = list);
    } catch (e) {
      AppUtils.showError(message: 'Failed to load newsletter: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter Subscribers'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: AppProgressIndicator())
          : _subs.isEmpty
              ? const Center(child: Text('No subscribers found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: _subs.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, i) {
                    final s = _subs[i] as Map? ?? {};
                    final email = s['email']?.toString() ?? '—';
                    final createdAt = s['created_at']?.toString() ?? '';
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.mail_outline, color: AppColors.primary),
                      ),
                      title: Text(email, style: AppTextStyles.bodyLarge),
                      subtitle: Text(
                        createdAt,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

