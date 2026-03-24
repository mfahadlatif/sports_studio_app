import 'package:flutter/material.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  bool _loading = true;
  List<dynamic> _events = const [];
  String _filter = 'all';

  static const _statuses = ['upcoming', 'ongoing', 'completed', 'cancelled', 'pending'];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().dio.get('/admin/events');
      final body = res.data;
      final list = (body is Map && body['data'] is List)
          ? body['data'] as List
          : (body is List ? body : const []);
      setState(() => _events = list);
    } catch (e) {
      AppUtils.showError(message: 'Failed to load events: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int eventId, String status) async {
    try {
      await ApiClient().dio.put(
        '/admin/events/$eventId/status',
        data: {'status': status},
      );
      AppUtils.showSuccess(message: 'Event status updated');
      await _fetch();
    } catch (e) {
      AppUtils.showError(message: 'Failed to update status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? _events
        : _events.where((e) => (e as Map?)?['status']?.toString() == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Moderation'),
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
                  child: DropdownButtonFormField<String>(
                    initialValue: _filter,
                    decoration: const InputDecoration(labelText: 'Filter by status'),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All')),
                      ...[
                        'upcoming',
                        'ongoing',
                        'completed',
                        'cancelled',
                        'pending',
                      ].map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (v) => setState(() => _filter = v ?? 'all'),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No events found'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final ev = filtered[i] as Map? ?? {};
                            final id = int.tryParse(ev['id']?.toString() ?? '');
                            final name = ev['name']?.toString() ?? 'Event';
                            final status = ev['status']?.toString() ?? 'pending';
                            final fee = ev['registration_fee']?.toString() ?? '0';
                            final organizer = ev['organizer'] is Map ? (ev['organizer'] as Map) : null;
                            final organizerName = organizer?['name']?.toString();

                            final safeStatus = _statuses.contains(status) ? status : 'pending';

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
                                            name,
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (id != null)
                                          _statusDropdown(
                                            current: safeStatus,
                                            onChanged: (next) => _updateStatus(id, next),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      [
                                        'Fee: Rs. $fee',
                                        if (organizerName != null) 'Organizer: $organizerName',
                                      ].join(' • '),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
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

  Widget _statusDropdown({
    required String current,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          onChanged: (v) {
            if (v == null || v == current) return;
            onChanged(v);
          },
          items: _statuses
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

