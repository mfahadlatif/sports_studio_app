import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  bool _isMarkingAll = false;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await ApiClient().dio.get('/notifications');
      if (res.statusCode == 200) {
        final data = res.data['data'] ?? res.data ?? [];
        setState(() {
          _notifications = (data as List)
              .map<Map<String, dynamic>>(
                (n) => {
                  'id': n['id'],
                  'title': n['data']?['title'] ?? 'Notification',
                  'message': n['data']?['message'] ?? '',
                  'type': n['data']?['type'] ?? 'system',
                  'read': n['read_at'] != null,
                  'createdAt': n['created_at'] ?? '',
                },
              )
              .toList();
        });
      }
    } catch (_) {
      // Demo notifications if API unavailable
      setState(() {
        _notifications = [
          {
            'id': '1',
            'title': 'Booking Confirmed',
            'message':
                'Your booking for Cricket Ground A on Feb 22 is confirmed.',
            'type': 'booking',
            'read': false,
            'createdAt': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
          },
          {
            'id': '2',
            'title': 'Payment Received',
            'message': 'Rs. 3,000 payment received for booking #1042.',
            'type': 'payment',
            'read': false,
            'createdAt': DateTime.now()
                .subtract(const Duration(hours: 3))
                .toIso8601String(),
          },
          {
            'id': '3',
            'title': 'Event Starting Soon',
            'message':
                'Your registered event "Weekend League" starts in 2 hours.',
            'type': 'event',
            'read': true,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
          {
            'id': '4',
            'title': 'Welcome to SportSpot!',
            'message':
                'Thanks for joining. Explore premium grounds and events near you.',
            'type': 'welcome',
            'read': true,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 3))
                .toIso8601String(),
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiClient().dio.post('/notifications/$id/read');
    } catch (_) {}
    setState(() {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1)
        _notifications[idx] = {..._notifications[idx], 'read': true};
    });
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAll = true);
    try {
      await ApiClient().dio.post('/notifications/read-all');
    } catch (_) {}
    setState(() {
      _notifications = _notifications.map((n) => {...n, 'read': true}).toList();
      _isMarkingAll = false;
    });
    Get.snackbar(
      'Done',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_month_outlined;
      case 'event':
        return Icons.emoji_events_outlined;
      case 'payment':
        return Icons.attach_money;
      case 'welcome':
        return Icons.celebration_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'booking':
        return AppColors.primary;
      case 'event':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'welcome':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['read'] == false).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n['read']))
            TextButton(
              onPressed: _isMarkingAll ? null : _markAllRead,
              child: _isMarkingAll
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Mark All Read',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // Unread count banner
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.all(AppSpacing.m),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.s,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.mail_outline,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Text(
                              '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // List
                    Expanded(
                      child: _notifications.isEmpty
                          ? _emptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.m,
                              ),
                              itemCount: _notifications.length,
                              itemBuilder: (ctx, i) =>
                                  _buildNotificationCard(_notifications[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;
    final type = notification['type'] as String;
    final iconColor = _getIconColor(type);

    return GestureDetector(
      onTap: () {
        if (!isRead) _markAsRead(notification['id'].toString());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : AppColors.primaryLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent bar for unread
            if (!isRead)
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.only(
                left: isRead ? AppSpacing.m : AppSpacing.s,
                right: AppSpacing.m,
                top: AppSpacing.m,
                bottom: AppSpacing.m,
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_getIcon(type), color: iconColor, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.m),

                  // Content
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'] ?? '',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'] ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _timeAgo(notification['createdAt'] ?? ''),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text("You're All Caught Up", style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.s),
          Text(
            "No new notifications at the moment.",
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
