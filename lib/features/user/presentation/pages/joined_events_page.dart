import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/owner/controller/bookings_controller.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/features/user/presentation/pages/event_detail_page.dart';

class JoinedEventsPage extends StatelessWidget {
  const JoinedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse BookingsController as it already has the logic to fetch event participations
    final controller = Get.put(BookingsController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('My Booked Events'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EventsList(type: 'Upcoming', controller: controller),
            _EventsList(type: 'Past', controller: controller),
          ],
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final String type;
  final BookingsController controller;

  const _EventsList({required this.type, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppProgressIndicator();
      }

      // Filter only event type from the combined list
      final allEvents = controller.allData.where((b) => b['type'] == 'event').toList();
      
      final list = type == 'Upcoming'
          ? allEvents.where((e) {
              final status = e['status']?.toString().toLowerCase() ?? '';
              return status == 'confirmed' || status == 'pending' || status == 'accepted' || status == 'upcoming' || status == 'paid';
            }).toList()
          : allEvents.where((e) {
              final status = e['status']?.toString().toLowerCase() ?? '';
              return status == 'completed' || status == 'past' || status == 'played';
            }).toList();

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_seat_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No $type events found',
                style: AppTextStyles.h3.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              const Text(
                'Events you join will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final eventData = list[index];
          final event = eventData['event'] ?? {};
          final status = eventData['status']?.toString() ?? 'pending';
          final startTime = event['start_time'] != null 
              ? DateTime.tryParse(event['start_time'].toString()) 
              : null;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                if (event['id'] != null) {
                   Get.to(() => const EventDetailPage(), arguments: event['id'].toString());
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'EVENT',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event['name'] ?? 'Event Name',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['location'] ?? 'Venue TBD',
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          startTime != null 
                              ? DateFormat('EEEE, MMM dd • hh:mm a').format(startTime)
                              : 'Time TBD',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('REGISTRATION FEE', style: TextStyle(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5)),
                            Text(
                              'Rs. ${event['registration_fee'] ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: (eventData['payment_status'] == 'paid') ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Text(
                             (eventData['payment_status'] ?? 'unpaid').toString().toUpperCase(),
                             style: TextStyle(
                               color: (eventData['payment_status'] == 'paid') ? Colors.green : Colors.orange,
                               fontSize: 10,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    String label = status.toUpperCase();

    if (status.toLowerCase().contains('accept') || status.toLowerCase().contains('confirm')) {
      color = Colors.green;
      label = 'CONFIRMED';
    } else if (status.toLowerCase().contains('reject') || status.toLowerCase().contains('cancel')) {
      color = Colors.red;
      label = 'CANCELLED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
