import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class UserBookingDetailPage extends StatelessWidget {
  const UserBookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = Get.arguments as Map?;
    if (booking == null) {
      return const Scaffold(body: Center(child: Text('Booking not found')));
    }

    final isEvent = booking['type'] == 'event';
    final title = booking['display_name']?.toString() ?? 'Booking';
    final status = booking['status']?.toString() ?? 'pending';
    final paymentStatus = booking['payment_status']?.toString() ?? 'unpaid';

    final startRaw = booking['start']?.toString() ?? booking['start_time']?.toString() ?? '';
    final endRaw = booking['end']?.toString() ?? booking['end_time']?.toString() ?? '';
    DateTime? start = DateTime.tryParse(startRaw.replaceFirst(' ', 'T'));
    DateTime? end = DateTime.tryParse(endRaw.replaceFirst(' ', 'T'));

    final dateStr = start != null ? DateFormat('MMM dd, yyyy').format(start) : '—';
    final timeStr = (start != null && end != null)
        ? '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}'
        : '—';

    final ground = booking['ground'] is Map ? booking['ground'] as Map : null;
    final complex = (ground != null && ground['complex'] is Map) ? ground['complex'] as Map : null;
    final address = (complex?['address'] ?? ground?['location'] ?? '').toString();

    final lat = double.tryParse(complex?['latitude']?.toString() ?? '') ??
        double.tryParse(ground?['latitude']?.toString() ?? '');
    final lng = double.tryParse(complex?['longitude']?.toString() ?? '') ??
        double.tryParse(ground?['longitude']?.toString() ?? '');

    final price = double.tryParse((booking['price'] ?? booking['total_price'] ?? 0).toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(title, style: AppTextStyles.h2),
                          ),
                          _chip(status.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _row('Type', isEvent ? 'Event' : 'Ground booking'),
                      _row('Date', dateStr),
                      _row('Time', timeStr),
                      if (!isEvent) _row('Payment', paymentStatus.toUpperCase()),
                      _row('Amount', 'Rs. ${price.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                if (!isEvent) ...[
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(
                          address.isEmpty ? '—' : address,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openMaps(
                                  lat: lat,
                                  lng: lng,
                                  query: address.isEmpty ? title : address,
                                ),
                                icon: const Icon(Icons.map_outlined),
                                label: const Text('Open in Maps'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'If GPS coordinates are missing, we’ll open maps using the address.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _openMaps({double? lat, double? lng, required String query}) async {
    final q = Uri.encodeComponent(query);
    final url = (lat != null && lng != null)
        ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        : 'https://www.google.com/maps/search/?api=1&query=$q';
    final appleUrl = (lat != null && lng != null)
        ? 'http://maps.apple.com/?q=$lat,$lng'
        : 'http://maps.apple.com/?q=$q';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      await launchUrl(Uri.parse(appleUrl));
    }
  }
}

