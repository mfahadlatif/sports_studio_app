import 'package:flutter/material.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  bool _loading = true;
  List<dynamic> _reviews = const [];
  int _page = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  Future<void> _fetch({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _page = 1;
        _reviews = const [];
      });
    }
    try {
      final res = await ApiClient().dio.get('/admin/reviews?page=$_page');
      final body = res.data;
      final data = (body is Map && body['data'] is List) ? body['data'] as List : const [];
      final currentPage = (body is Map) ? int.tryParse(body['current_page']?.toString() ?? '') : null;
      final lastPage = (body is Map) ? int.tryParse(body['last_page']?.toString() ?? '') : null;

      setState(() {
        _reviews = [..._reviews, ...data];
        _hasMore = currentPage != null && lastPage != null && currentPage < lastPage;
      });
    } catch (e) {
      AppUtils.showError(message: 'Failed to load reviews: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reviews'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _fetch(reset: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: AppProgressIndicator())
          : _reviews.isEmpty
              ? const Center(child: Text('No reviews found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  itemCount: _reviews.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_hasMore && i == _reviews.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _page += 1;
                              _fetch(reset: false);
                            },
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Load more'),
                          ),
                        ),
                      );
                    }

                    final r = _reviews[i] as Map? ?? {};
                    final user = r['user'] is Map ? (r['user'] as Map) : null;
                    final userName = user?['name']?.toString() ?? r['user_name']?.toString() ?? 'Anonymous';
                    final comment = r['comment']?.toString() ?? '';
                    final rating = r['rating']?.toString() ?? '0';
                    final status = r['status']?.toString() ?? 'pending';
                    final ground = r['ground'] is Map ? (r['ground'] as Map) : null;
                    final groundName = ground?['name']?.toString();

                    Color statusColor = Colors.orange;
                    if (status == 'active') statusColor = Colors.green;
                    if (status == 'hidden') statusColor = Colors.grey;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
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
                                    userName,
                                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    status,
                                    style: AppTextStyles.label.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(rating, style: AppTextStyles.bodySmall),
                                if (groundName != null) ...[
                                  const SizedBox(width: 10),
                                  Text('• $groundName', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                                ],
                              ],
                            ),
                            if (comment.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(comment, style: AppTextStyles.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

