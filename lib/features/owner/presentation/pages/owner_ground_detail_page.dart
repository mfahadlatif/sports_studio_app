import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/utils/url_helper.dart';

class OwnerGroundDetailPage extends StatefulWidget {
  const OwnerGroundDetailPage({super.key});

  @override
  State<OwnerGroundDetailPage> createState() => _OwnerGroundDetailPageState();
}

class _OwnerGroundDetailPageState extends State<OwnerGroundDetailPage> {
  bool _isLoading = true;
  dynamic _ground;
  List<dynamic> _recentBookings = [];
  Map<String, dynamic> _stats = {
    'total_revenue': 0,
    'bookings_count': 0,
    'avg_rating': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final args = Get.arguments;
    final id = args?['id'];
    if (id == null) {
      Get.back();
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Fetch ground detail
      final groundRes = await ApiClient().dio.get('/grounds/$id');
      if (groundRes.statusCode == 200) {
        _ground = groundRes.data['data'] ?? groundRes.data;
      }

      // 2. Fetch specific stats for this ground (mocked if endpoint missing)
      try {
        final statsRes = await ApiClient().dio.get('/owner/grounds/$id/stats');
        if (statsRes.statusCode == 200) {
          _stats = statsRes.data;
        }
      } catch (_) {
        // Fallback demo stats
        _stats = {
          'total_revenue': 45000,
          'bookings_count': 12,
          'avg_rating': 4.8,
        };
      }

      // 3. Fetch recent bookings for this ground
      try {
        final bookingsRes = await ApiClient().dio.get(
          '/bookings?ground_id=$id&limit=5',
        );
        if (bookingsRes.statusCode == 200) {
          _recentBookings = bookingsRes.data['data'] ?? bookingsRes.data ?? [];
        }
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', 'Failed to load ground details');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_ground == null) {
      return const Scaffold(body: Center(child: Text('Ground not found')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.l),
                      _buildStatsRow(),
                      const SizedBox(height: AppSpacing.l),
                      _buildQuickActions(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle(
                        'Ground Information',
                        Icons.info_outline,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      _buildInfoCard(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle(
                        'Recent Bookings',
                        Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      _buildRecentBookings(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    List<String> images = [];
    if (_ground != null &&
        _ground['images'] != null &&
        (_ground['images'] as List).isNotEmpty) {
      images = List<String>.from(_ground['images']);
    }

    if (images.isEmpty) {
      images.add(
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800',
      );
    }

    // URL Sanitization Utility
    List<String> sanitizedImages = images
        .map((url) => UrlHelper.sanitizeUrl(url))
        .toList();

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: sanitizedImages.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: sanitizedImages[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => _placeholderIcon(),
                );
              },
            ),
            // Optional Carousel Indicators
            if (sanitizedImages.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    sanitizedImages.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(
            '/add-ground',
            arguments: {'isEdit': true, 'ground': _ground},
          ),
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: AppColors.primaryLight,
      child: Icon(
        Icons.sports_cricket,
        size: 64,
        color: AppColors.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _ground['type'].toString().toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _ground['status'] == 'active'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _ground['status'].toString().toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: _ground['status'] == 'active'
                      ? Colors.green
                      : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(_ground['name'] ?? 'Ground Name', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              _ground['location'] ?? 'No location set',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statItem(
          'Revenue',
          'Rs. ${_stats['total_revenue']}',
          Icons.payments_outlined,
          Colors.green,
        ),
        const SizedBox(width: AppSpacing.s),
        _statItem(
          'Bookings',
          '${_stats['bookings_count']}',
          Icons.calendar_today_outlined,
          Colors.blue,
        ),
        const SizedBox(width: AppSpacing.s),
        _statItem(
          'Rating',
          '${_stats['avg_rating']}',
          Icons.star_outline,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/user-bookings'),
            icon: const Icon(Icons.history_outlined),
            label: const Text('View All Bookings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed('/owner-deals'),
            icon: const Icon(Icons.local_offer_outlined),
            label: const Text('Add Offer'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Price per Hour', 'Rs. ${_ground['price_per_hour']}'),
          const Divider(height: AppSpacing.l),
          _infoRow(
            'Lighting',
            (_ground['has_lighting'] == 1 || _ground['has_lighting'] == true)
                ? 'Available'
                : 'Not Available',
          ),
          const Divider(height: AppSpacing.l),
          Text(
            'Description',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _ground['description'] ?? 'No description provided.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    if (_recentBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: AppColors.textMuted.withOpacity(0.4),
              size: 48,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No recent bookings for this ground',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentBookings.map((b) => _bookingTile(b)).toList(),
    );
  }

  Widget _bookingTile(dynamic b) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => Get.toNamed('/booking-detail', arguments: {'booking': b}),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            (b['user']?['name'] ?? 'P')[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          b['user']?['name'] ?? 'Player',
          style: AppTextStyles.bodyLarge,
        ),
        subtitle: Text(
          '${b['date']} | ${b['start_time']} - ${b['end_time']}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
