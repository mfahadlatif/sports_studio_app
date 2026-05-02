import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/features/user/controller/join_requests_controller.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/widgets/app_button.dart';

class JoinRequestsPage extends StatelessWidget {
  const JoinRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinRequestsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Join Requests'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // Search & Filter Section
          _buildSearchAndFilters(controller),

          // List Section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: AppProgressIndicator());
              }

              final list = controller.filteredRequests;

              if (list.isEmpty) {
                return _buildEmptyState(controller);
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchRequests(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildRequestCard(context, list[index], controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(JoinRequestsController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: const InputDecoration(
                  hintText: 'Search player or event...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Status Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(
              () => Row(
                children: [
                  _buildStatusTab('all', 'All', controller),
                  _buildStatusTab('pending', 'Pending', controller),
                  _buildStatusTab('accepted', 'Approved', controller),
                  _buildStatusTab('confirmed', 'Confirmed', controller),
                  _buildStatusTab('rejected', 'Rejected', controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(
    String value,
    String label,
    JoinRequestsController controller,
  ) {
    final isSelected = controller.statusFilter.value == value;
    return GestureDetector(
      onTap: () => controller.statusFilter.value = value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    dynamic request,
    JoinRequestsController controller,
  ) {
    final user = request['user'] ?? {};
    final event = request['event'] ?? {};
    final status = request['status']?.toString().toLowerCase() ?? 'pending';
    final requestDate = request['created_at'] != null
        ? DateFormat(
            'MMM dd, yyyy',
          ).format(DateTime.parse(request['created_at']))
        : 'TBD';

    Color statusColor;
    switch (status) {
      case 'accepted':
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Player Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      (user['avatar'] != null &&
                          user['avatar'].toString().isNotEmpty)
                      ? CachedNetworkImageProvider(
                          UrlHelper.sanitizeUrl(user['avatar']),
                        )
                      : null,
                  child:
                      (user['avatar'] == null ||
                          user['avatar'].toString().isEmpty)
                      ? Text(
                          (user['name'] ?? request['name'] ?? 'P')[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                // Player & Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? request['name'] ?? 'Unknown Player',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.sports_cricket,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event['name'] ?? 'Unknown Event',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Detail Grid (Email/Phone)
            Row(
              children: [
                Expanded(
                  child: _infoRow(
                    Icons.email_outlined,
                    user['email'] ?? request['email'] ?? 'No email',
                    'Email Address',
                  ),
                ),
                Expanded(
                  child: _infoRow(
                    Icons.phone_outlined,
                    user['phone'] ?? request['phone'] ?? 'No phone',
                    'Contact Number',
                  ),
                ),
              ],
            ),

            if (request['message'] != null &&
                request['message'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PARTICIPANT MESSAGE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request['message'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REQUEST DATE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requestDate,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (status == 'pending') ...[
                  Row(
                    children: [
                      _buildActionButton(
                        'Reject',
                        Colors.red,
                        () => _showRejectDialog(
                          context,
                          request['id'],
                          controller,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        'Approve',
                        const Color(0xFF10B981), // Website green
                        () =>
                            controller.updateStatus(request['id'], 'accepted'),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (request['payment_status'] == 'paid'
                                  ? Colors.green
                                  : Colors.orange)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PAYMENT: ${request['payment_status']?.toString().toUpperCase() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: request['payment_status'] == 'paid'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (request['rejection_reason'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'REJECTION REASON: ${request['rejection_reason']}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
  return SizedBox(
    height: 32,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

void _showRejectDialog(
  BuildContext context,
  int requestId,
  JoinRequestsController controller,
) {
  final reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reject Request'),
      content: TextField(
        controller: reasonController,
        decoration: const InputDecoration(
          hintText: 'Enter reason for rejection...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (reasonController.text.trim().isNotEmpty) {
              controller.updateStatus(
                requestId,
                'rejected',
                reason: reasonController.text.trim(),
              );
              Get.back();
            } else {
              Get.snackbar('Error', 'Please provide a reason');
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Confirm Reject'),
        ),
      ],
    ),
  );
}

Widget _buildEmptyState(JoinRequestsController controller) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_add_disabled_outlined,
          size: 64,
          color: AppColors.textMuted.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Text(
          controller.searchQuery.isNotEmpty
              ? 'No matching requests'
              : 'No join requests yet',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
        ),
        if (controller.searchQuery.isEmpty)
          TextButton(
            onPressed: () => controller.fetchRequests(),
            child: const Text('Refresh'),
          ),
      ],
    ),
  );
}
