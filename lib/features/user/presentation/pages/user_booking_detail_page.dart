import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/features/user/presentation/pages/ground_detail_page.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final groundId = ground?['id'];
    final groundImage = UrlHelper.getFirstImage(ground?['images']);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Immersive Header
            Stack(
              children: [
                Hero(
                  tag: 'booking_img_${booking['id']}',
                  child: CachedNetworkImage(
                    imageUrl: groundImage,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                        height: 300, color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: AppColors.primary,
                      child: const Icon(Icons.sports_soccer,
                          size: 80, color: Colors.white24),
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & ID
                      Row(
                        children: [
                          _statusBadge(status),
                          const Spacer(),
                          Text(
                             'Booking ID: #${booking['id']}',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(title, style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isEvent ? 'EVENT REGISTRATION' : 'GROUND BOOKING',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.l),

                      // Details Section
                      _sectionCard(
                        child: Column(
                          children: [
                            _detailRow(Icons.calendar_today_rounded, 'Date', dateStr),
                            const Divider(height: 24),
                            _detailRow(Icons.alarm_rounded, 'Time Slot', timeStr),
                            const Divider(height: 24),
                            if (!isEvent) ...[
                              _detailRow(Icons.payment_rounded, 'Payment',
                                  paymentStatus.toUpperCase()),
                              const Divider(height: 24),
                            ],
                            _detailRow(
                              Icons.money_rounded,
                              'Total Amount',
                              '${AppConstants.currencySymbol} ${NumberFormat('#,###').format(price)}',
                              valueColor: AppColors.primary,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.m),

                      // Ground Quick Link (Click to View Ground)
                      if (ground != null)
                        _sectionCard(
                          onTap: () => Get.to(() => const GroundDetailPage(), arguments: {'ground': ground}),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.stadium_rounded,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('View Ground Details',
                                        style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                    Text('Photos, facilities & address',
                                        style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.textMuted),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSpacing.m),

                      // Location & Contact
                      if (!isEvent)
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location & Contact', style: AppTextStyles.h3),
                              const SizedBox(height: AppSpacing.m),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      address.isEmpty ? 'Location details unavailable' : address,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.l),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      label: 'Get Directions',
                                      leadingIcon: const Icon(Icons.directions_rounded, size: 18, color: Colors.white),
                                      onPressed: () => _openMaps(
                                        lat: lat,
                                        lng: lng,
                                        query: address.isEmpty ? title : address,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  if (complex?['phone'] != null || ground?['owner_phone'] != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          final phone = complex?['phone'] ?? ground?['owner_phone'];
                                          if (phone != null) {
                                            launchUrl(Uri.parse('tel:$phone'));
                                          }
                                        },
                                        icon: const Icon(Icons.call, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSpacing.l),

                      // Cancellation Info
                      if (status != 'cancelled' && status != 'completed')
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.orange.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.help_outline_rounded, color: Colors.orange),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Need to change plans?',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'To cancel or reschedule, please contact the venue owner via the call button above. Cancellations are subject to the facility\'s terms.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
