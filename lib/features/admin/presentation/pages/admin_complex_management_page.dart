import 'package:flutter/material.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';

class AdminComplexManagementPage extends StatefulWidget {
  final bool isTab;
  const AdminComplexManagementPage({super.key, this.isTab = false});

  @override
  State<AdminComplexManagementPage> createState() =>
      _AdminComplexManagementPageState();
}

class _AdminComplexManagementPageState extends State<AdminComplexManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = true;
  List<dynamic> _complexes = const [];
  List<dynamic> _grounds = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        ApiClient().dio.get('/admin/complexes'),
        ApiClient().dio.get('/admin/grounds'),
      ]);
      final complexes = (res[0].data is List) ? res[0].data as List : const [];
      final grounds = (res[1].data is List) ? res[1].data as List : const [];
      setState(() {
        _complexes = complexes;
        _grounds = grounds;
      });
    } catch (e) {
      AppUtils.showError(message: 'Failed to load admin data: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateGroundStatus(int groundId, String status) async {
    try {
      await ApiClient().dio.put(
        '/admin/grounds/$groundId/status',
        data: {'status': status},
      );
      AppUtils.showSuccess(message: 'Ground status updated');
      await _fetchAll();
    } catch (e) {
      AppUtils.showError(message: 'Failed to update ground status: $e');
    }
  }

  Future<void> _updateComplexStatus(int complexId, String status) async {
    try {
      await ApiClient().dio.put(
        '/admin/complexes/$complexId/status',
        data: {'status': status},
      );
      AppUtils.showSuccess(message: 'Complex status updated');
      await _fetchAll();
    } catch (e) {
      AppUtils.showError(message: 'Failed to update complex status: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    if (!widget.isTab && Navigator.canPop(context)) ...[
                      const BackButton(),
                      const SizedBox(width: 8),
                    ],
                    Text('Complex Management', style: AppTextStyles.h2),
                    const Spacer(),
                    IconButton(
                      onPressed: _fetchAll,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                const SizedBox(height: AppSpacing.s),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    padding: const EdgeInsets.all(0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: false,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.surface,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.business_outlined, size: 18), text: 'Complexes'),
                      Tab(icon: Icon(Icons.sports_soccer_outlined, size: 18), text: 'Grounds'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: AppProgressIndicator(size: 28, strokeWidth: 3),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildComplexes(),
                            _buildGrounds(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplexes() {
    if (_complexes.isEmpty) {
      return Center(
        child: Text('No complexes found', style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.separated(
      itemCount: _complexes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final c = _complexes[i] as Map? ?? {};
        final name = c['name']?.toString() ?? 'Complex';
        final location = c['location']?.toString();
        final status = c['status']?.toString();
        final owner = c['owner'] is Map ? (c['owner'] as Map) : null;
        final ownerName = owner?['name']?.toString();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (status != null) ...[
                      _statusChip(status, isWarning: status == 'pending'),
                      if (status != 'active') ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            final id = int.tryParse(c['id']?.toString() ?? '');
                            if (id != null) _updateComplexStatus(id, 'active');
                          },
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          tooltip: 'Approve Complex',
                        ),
                      ] else ...[
                        const SizedBox(width: 8),
                         IconButton(
                          onPressed: () {
                            final id = int.tryParse(c['id']?.toString() ?? '');
                            if (id != null) _updateComplexStatus(id, 'inactive');
                          },
                          icon: const Icon(Icons.pause_circle_outline, color: Colors.orange),
                          tooltip: 'Deactivate Complex',
                        ),
                      ],
                    ],
                  ],
                ),
                if (location != null || ownerName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    [
                      location,
                      if (ownerName != null) 'Owner: $ownerName',
                    ].whereType<String>().join(' • '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrounds() {
    if (_grounds.isEmpty) {
      return Center(
        child: Text('No grounds found', style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.separated(
      itemCount: _grounds.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final g = _grounds[i] as Map? ?? {};
        final id = int.tryParse(g['id']?.toString() ?? '');
        final name = g['name']?.toString() ?? 'Ground';
        final status = g['status']?.toString() ?? 'pending';
        final complex = g['complex'] is Map ? (g['complex'] as Map) : null;
        final complexName = complex?['name']?.toString();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (complexName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          complexName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (status != 'active') ...[
                  IconButton(
                    onPressed: () {
                      if (id != null) _updateGroundStatus(id, 'active');
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    tooltip: 'Approve Ground',
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () {
                      if (id != null) _updateGroundStatus(id, 'inactive');
                    },
                    icon: const Icon(Icons.pause_circle_outline, color: Colors.orange),
                    tooltip: 'Deactivate Ground',
                  ),
                ],
                const SizedBox(width: 8),
                _statusChip(status, isWarning: status == 'pending'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(String status, {bool isWarning = false}) {
    final color = isWarning ? Colors.orange : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

