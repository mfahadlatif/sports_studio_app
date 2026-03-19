import 'package:flutter/material.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().dio.get('/owner/reports');
      final body = res.data;
      if (body is Map<String, dynamic>) {
        setState(() => _data = body);
      } else if (body is Map) {
        setState(() => _data = Map<String, dynamic>.from(body));
      } else {
        setState(() => _data = {'data': body});
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to load reports: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Global Reports', style: AppTextStyles.h2),
                    const Spacer(),
                    IconButton(
                      onPressed: _fetch,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: AppProgressIndicator(size: 28, strokeWidth: 3),
                        )
                      : _data == null
                          ? Center(
                              child: Text(
                                'No report data',
                                style: AppTextStyles.bodyMedium,
                              ),
                            )
                          : _buildReportBody(_data!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportBody(Map<String, dynamic> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      children: [
        _summaryGrid(data),
        const SizedBox(height: AppSpacing.m),
        ...entries.map((e) => _kvCard(e.key, e.value)),
      ],
    );
  }

  Widget _summaryGrid(Map<String, dynamic> data) {
    // Try common keys; otherwise show nothing here.
    final candidates = <String>[
      'total_revenue',
      'total_bookings',
      'total_users',
      'total_complexes',
      'total_grounds',
      'total_events',
    ];

    final items = candidates
        .where((k) => data.containsKey(k))
        .map((k) => _summaryItem(k, data[k]))
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items,
    );
  }

  Widget _summaryItem(String key, dynamic value) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value?.toString() ?? '-',
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _kvCard(String key, dynamic value) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _stringify(value),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stringify(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    if (value is List) return 'List(${value.length})';
    if (value is Map) return 'Object(${value.length} keys)';
    return value.toString();
  }
}

