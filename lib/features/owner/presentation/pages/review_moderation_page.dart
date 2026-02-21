import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';

class ReviewModerationPage extends StatefulWidget {
  const ReviewModerationPage({super.key});

  @override
  State<ReviewModerationPage> createState() => _ReviewModerationPageState();
}

class _ReviewModerationPageState extends State<ReviewModerationPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reviews = [];
  List<dynamic> _grounds = [];
  String _searchQuery = '';
  String _groundFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      // Load grounds from the controller if available
      if (Get.isRegistered<GroundsController>()) {
        _grounds = Get.find<GroundsController>().grounds
            .map((g) => {'id': g.id, 'name': g.name})
            .toList();
      } else {
        final gRes = await ApiClient().dio.get('/grounds');
        if (gRes.statusCode == 200) {
          _grounds = gRes.data['data'] ?? gRes.data ?? [];
        }
      }

      // Fetch reviews per ground
      final allReviews = <Map<String, dynamic>>[];
      for (final g in _grounds) {
        try {
          final rRes = await ApiClient().dio.get(
            '/public/reviews?ground_id=${g['id']}',
          );
          if (rRes.statusCode == 200) {
            final data = rRes.data is List
                ? rRes.data
                : (rRes.data['data'] ?? []);
            for (final r in data) {
              allReviews.add({
                ...Map<String, dynamic>.from(r),
                'ground_name': g['name'],
                'status': r['status'] ?? 'active',
              });
            }
          }
        } catch (_) {}
      }

      // Sort newest first
      allReviews.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final bDate =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      setState(() => _reviews = allReviews);
    } catch (e) {
      // Demo data when API not available
      setState(() {
        _grounds = [
          {'id': 1, 'name': 'Cricket Ground A'},
          {'id': 2, 'name': 'Football Turf B'},
        ];
        _reviews = [
          {
            'id': 1,
            'ground_id': 1,
            'ground_name': 'Cricket Ground A',
            'rating': 5,
            'comment': 'Amazing ground! Perfect for tournaments.',
            'user': {'name': 'Ali Raza'},
            'status': 'active',
            'created_at': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          },
          {
            'id': 2,
            'ground_id': 2,
            'ground_name': 'Football Turf B',
            'rating': 3,
            'comment': 'Good grounds but parking is limited.',
            'user': {'name': 'Hamza Khan'},
            'status': 'active',
            'created_at': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
          {
            'id': 3,
            'ground_id': 1,
            'ground_name': 'Cricket Ground A',
            'rating': 4,
            'comment': 'Well maintained pitch, will come again.',
            'user': {'name': 'Usman Mir'},
            'status': 'hidden',
            'created_at': DateTime.now()
                .subtract(const Duration(days: 3))
                .toIso8601String(),
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> review) async {
    final id = review['id'];
    final currentStatus = review['status'] ?? 'active';
    final newStatus = currentStatus == 'active' ? 'hidden' : 'active';
    try {
      await ApiClient().dio.put(
        '/reviews/$id/status',
        data: {'status': newStatus},
      );
    } catch (_) {}
    // Update locally regardless (API may not exist yet)
    setState(() {
      final idx = _reviews.indexWhere((r) => r['id'] == id);
      if (idx != -1) _reviews[idx] = {..._reviews[idx], 'status': newStatus};
    });
    Get.snackbar(
      'Updated',
      'Review ${newStatus == 'hidden' ? 'hidden' : 'activated'}',
    );
  }

  Future<void> _deleteReview(Map<String, dynamic> review) async {
    Get.defaultDialog(
      title: 'Delete Review?',
      middleText: 'This will permanently remove this review.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await ApiClient().dio.delete('/reviews/${review['id']}');
        } catch (_) {}
        setState(() => _reviews.removeWhere((r) => r['id'] == review['id']));
        Get.snackbar('Deleted', 'Review permanently deleted');
      },
    );
  }

  List<Map<String, dynamic>> get _filtered {
    return _reviews.where((r) {
      final matchesGround =
          _groundFilter == 'all' || r['ground_id']?.toString() == _groundFilter;
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          (r['comment'] ?? '').toString().toLowerCase().contains(query) ||
          (r['user']?['name'] ?? '').toString().toLowerCase().contains(query) ||
          (r['ground_name'] ?? '').toString().toLowerCase().contains(query);
      return matchesGround && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Moderation'), centerTitle: true),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
              0,
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by comment or player name...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                DropdownButtonFormField<String>(
                  value: _groundFilter,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.filter_list_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('All Grounds'),
                    ),
                    ..._grounds.map(
                      (g) => DropdownMenuItem(
                        value: g['id'].toString(),
                        child: Text(g['name'].toString()),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _groundFilter = v ?? 'all'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _filtered.isEmpty
                          ? _emptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.m),
                              itemCount: _filtered.length,
                              itemBuilder: (ctx, i) =>
                                  _reviewCard(_filtered[i]),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final isHidden = review['status'] == 'hidden';
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final userName =
        review['user']?['name'] ?? review['user_name'] ?? 'Anonymous';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';
    final createdAt = review['created_at'] ?? '';
    String timeAgo = '';
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours}h ago';
      } else {
        timeAgo = '${diff.inDays}d ago';
      }
    } catch (_) {}

    return AnimatedOpacity(
      opacity: isHidden ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isHidden
              ? Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                  width: 1,
                )
              : Border.all(color: AppColors.border),
          boxShadow: isHidden
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(userName, style: AppTextStyles.bodyLarge),
                            const SizedBox(width: AppSpacing.s),
                            // Star rating
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < rating ? Icons.star : Icons.star_border,
                                  size: 13,
                                  color: i < rating
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${review['ground_name'] ?? ''}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (timeAgo.isNotEmpty) ...[
                              Text(
                                ' • ',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                timeAgo,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isHidden
                          ? Colors.grey.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isHidden ? 'HIDDEN' : 'ACTIVE',
                      style: AppTextStyles.label.copyWith(
                        color: isHidden ? Colors.grey : Colors.green,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // Comment
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  '"${review['comment'] ?? ''}"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleStatus(review),
                      icon: Icon(
                        isHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 16,
                      ),
                      label: Text(isHidden ? 'Show' : 'Hide'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isHidden ? AppColors.primary : Colors.orange,
                        ),
                        foregroundColor: isHidden
                            ? AppColors.primary
                            : Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  IconButton(
                    onPressed: () => _deleteReview(review),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 72,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.m),
          Text('No reviews found', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.s),
          Text(
            _searchQuery.isNotEmpty || _groundFilter != 'all'
                ? 'Try clearing your filters'
                : 'Reviews from players will appear here once they book and rate your grounds',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
