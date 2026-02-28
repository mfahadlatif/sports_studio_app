import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class ComplexDetailPage extends StatefulWidget {
  const ComplexDetailPage({super.key});

  @override
  State<ComplexDetailPage> createState() => _ComplexDetailPageState();
}

class _ComplexDetailPageState extends State<ComplexDetailPage> {
  bool _isLoading = true;
  dynamic _complex;
  List<dynamic> _grounds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final args = Get.arguments;
    final int complexId = args is Map ? args['id'] : args;
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/complexes/$complexId');
      if (res.statusCode == 200) {
        final data = res.data['data'] ?? res.data;
        setState(() {
          _complex = data;
          _grounds = List<dynamic>.from(data['grounds'] ?? []);
        });
      }
    } catch (e) {
      AppUtils.showError(message: 'Failed to load complex details');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGround(dynamic ground) async {
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Delete Ground?',
      middleText: 'Remove "${ground['name']}" permanently?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed != true) return;
    try {
      final res = await ApiClient().dio.delete('/grounds/${ground['id']}');
      if (res.statusCode == 200 || res.statusCode == 204) {
        setState(() => _grounds.removeWhere((g) => g['id'] == ground['id']));
        AppUtils.showSuccess(message: 'Ground removed successfully');
      }
    } catch (_) {
      AppUtils.showError(message: 'Failed to delete ground');
    }
  }

  List<dynamic> get _filtered => _grounds.where((g) {
    final name = (g['name'] ?? '').toString().toLowerCase();
    final type = (g['type'] ?? '').toString().toLowerCase();
    final q = _searchQuery.toLowerCase();
    return name.contains(q) || type.contains(q);
  }).toList();

  dynamic tryDecode(String? s) {
    if (s == null) return null;
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _getFacilityInfo(String id) {
    final configs = [
      {'id': 'parking', 'name': 'Parking', 'icon': '🅿️'},
      {'id': 'washrooms', 'name': 'Washrooms', 'icon': '🚻'},
      {'id': 'changing-rooms', 'name': 'Changing Rooms', 'icon': '🚿'},
      {'id': 'seating', 'name': 'Seating Area', 'icon': '💺'},
      {'id': 'lighting', 'name': 'Floodlights', 'icon': '💡'},
      {'id': 'cafe', 'name': 'Café / Refreshments', 'icon': '☕'},
      {'id': 'first-aid', 'name': 'First Aid', 'icon': '🏥'},
      {'id': 'wifi', 'name': 'WiFi', 'icon': '📶'},
      {'id': 'lockers', 'name': 'Lockers', 'icon': '🔐'},
      {'id': 'equipment', 'name': 'Equipment Rental', 'icon': '🎯'},
    ];
    return configs.firstWhere(
      (c) => c['id'] == id,
      orElse: () => {'id': id, 'name': id, 'icon': '✓'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  AppShimmer.detailHeader(),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      children: List.generate(3, (index) => AppShimmer.card()),
                    ),
                  ),
                ],
              ),
            )
          : _complex == null
          ? _buildNotFound()
          : _buildContent(),
    );
  }

  Widget _buildNotFound() => Scaffold(
    appBar: AppBar(title: const Text('Complex Detail')),
    body: const Center(child: Text('Complex not found')),
  );

  Widget _buildCarousel() {
    List<String> images = [];
    if (_complex != null) {
      if (_complex['images'] != null &&
          (_complex['images'] as List).isNotEmpty) {
        images = List<String>.from(_complex['images']);
      } else if (_complex['image_path'] != null) {
        images.add(_complex['image_path']);
      }
    }

    if (images.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    // URL Sanitization
    List<String> sanitized = images
        .map((url) => UrlHelper.sanitizeUrl(url))
        .toList();

    return PageView.builder(
      itemCount: sanitized.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: sanitized[index],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[200]),
          errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, color: Colors.white),
        );
      },
    );
  }

  Widget _buildContent() {
    final name = _complex['name'] ?? 'Complex';
    final address = _complex['address'] ?? '';
    final description = _complex['description'] ?? '';
    final status = _complex['status'] ?? 'active';
    final isActive = status == 'active' || status == 1;
    final groundCount = _grounds.length;

    return CustomScrollView(
      slivers: [
        // ─── App Bar ────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          leading: CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => _openEditComplexSheet(),
                tooltip: 'Edit Complex',
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                _buildCarousel(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Complex Info Card ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(name, style: AppTextStyles.h2),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isActive ? 'Active' : 'Inactive',
                                            style: AppTextStyles.label.copyWith(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (address.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              address,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: AppColors.textMuted,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.m),

                          // Stats row
                          Row(
                            children: [
                              _buildStat(
                                '$groundCount',
                                'Total Grounds',
                                Icons.sports_cricket_outlined,
                              ),
                              const SizedBox(width: AppSpacing.l),
                              _buildStat(
                                '${_grounds.fold<int>(0, (sum, g) => sum + (int.tryParse(g['playing_areas_count']?.toString() ?? '1') ?? 1))}',
                                'Playing Areas',
                                Icons.layers_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.l),

                          // Facilities Section (New)
                          if (_complex['amenities'] != null) ...[
                            Text(
                              'Facilities Available',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  (_complex['amenities'] is List
                                          ? _complex['amenities'] as List
                                          : (_complex['amenities'] is String
                                                ? (tryDecode(
                                                        _complex['amenities'],
                                                      ) ??
                                                      [])
                                                : []))
                                      .map<Widget>((fId) {
                                        final f = _getFacilityInfo(
                                          fId.toString(),
                                        );
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                f['icon'] ?? '✓',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                f['name'] ?? fId.toString(),
                                                style: AppTextStyles.label
                                                    .copyWith(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                            ),
                            const SizedBox(height: AppSpacing.l),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.l),

                    // ── Grounds Section Header ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Grounds / Arenas',
                            style: AppTextStyles.h3,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Get.toNamed(
                              '/add-ground',
                              arguments: {
                                'complexId': _complex['id'],
                                'complexName': name,
                              },
                            );
                            if (result == true) _fetch();
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Ground'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.m),

                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search grounds...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.m),

                    // Grounds List
                    if (_filtered.isEmpty)
                      _buildEmptyGrounds()
                    else
                      ...(_filtered
                          .map((ground) => _buildGroundCard(ground))
                          .toList()),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ],
    );
  }

  Widget _buildGroundCard(dynamic ground) {
    final name = ground['name'] ?? 'Ground';
    final type = (ground['type'] ?? 'Cricket').toString();
    final price = ground['price_per_hour'] ?? 0;
    final status = ground['status'] ?? 'active';
    final isActive = status == 'active' || status == 1 || status == true;

    final images = ground['images'] as List?;
    String? rawUrl;
    if (images != null && images.isNotEmpty) {
      rawUrl = images[0].toString();
    }
    final imageUrl = UrlHelper.sanitizeUrl(rawUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/ground-detail', arguments: ground),
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Image Header with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _groundImagePlaceholder(type),
                        )
                      : _groundImagePlaceholder(type),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                // Price Tag
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Rs. $price',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const TextSpan(
                            text: '/hr',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(name, style: AppTextStyles.h3.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),

                  // Quick Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '06:00 - 23:00', // Mocked to match web's default
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.layers_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${ground['playing_areas_count'] ?? 1} Areas',
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _actionBtn(Icons.edit_outlined, 'Edit', () async {
                        final result = await Get.toNamed(
                          '/add-ground',
                          arguments: {
                            'ground': ground,
                            'complexId': _complex['id'],
                            'complexName': _complex['name'],
                            'isEdit': true,
                          },
                        );
                        if (result == true) _fetch();
                      }),
                      _actionBtn(Icons.calendar_month_outlined, 'Bookings', () {
                        Get.toNamed('/user-bookings');
                      }),
                      _actionBtn(Icons.delete_outline, 'Delete', () {
                        _deleteGround(ground);
                      }, color: Colors.red),
                      TextButton(
                        onPressed: () =>
                            Get.toNamed('/ground-detail', arguments: ground),
                        child: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color ?? AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groundImagePlaceholder(String type) {
    final icons = {
      'cricket': Icons.sports_cricket,
      'football': Icons.sports_soccer,
      'tennis': Icons.sports_tennis,
      'badminton': Icons.sports,
    };
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Icon(
        icons[type.toLowerCase()] ?? Icons.sports,
        size: 48,
        color: AppColors.primary.withOpacity(0.4),
      ),
    );
  }

  Widget _buildEmptyGrounds() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.sports_cricket_outlined,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: AppSpacing.m),
          Text('No grounds yet', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Add your first ground to this complex',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.l),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.toNamed(
                '/add-ground',
                arguments: {
                  'complexId': _complex['id'],
                  'complexName': _complex['name'],
                },
              );
              if (result == true) _fetch();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Ground'),
          ),
        ],
      ),
    ),
  );

  void _openEditComplexSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditComplexSheet(complex: _complex, onSuccess: _fetch),
    );
  }
}

// ─── Edit Complex Bottom Sheet ────────────────────────────────────────────────
class _EditComplexSheet extends StatefulWidget {
  final dynamic complex;
  final VoidCallback onSuccess;
  const _EditComplexSheet({required this.complex, required this.onSuccess});

  @override
  State<_EditComplexSheet> createState() => _EditComplexSheetState();
}

class _EditComplexSheetState extends State<_EditComplexSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _descCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.complex['name'] ?? '');
    _addressCtrl = TextEditingController(text: widget.complex['address'] ?? '');
    _descCtrl = TextEditingController(
      text: widget.complex['description'] ?? '',
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Name and address are required');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final id = widget.complex['id'];
      final res = await ApiClient().dio.put(
        '/complexes/$id',
        data: {
          'name': _nameCtrl.text,
          'address': _addressCtrl.text,
          'description': _descCtrl.text,
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back();
        widget.onSuccess();
        Get.snackbar('Success', 'Complex updated successfully');
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to update complex');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Edit Complex', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.l),
              _lbl('Complex Name *'),
              _field(
                _nameCtrl,
                'e.g. Star Sports Complex',
                Icons.business_outlined,
              ),
              const SizedBox(height: AppSpacing.m),
              _lbl('Address *'),
              _field(
                _addressCtrl,
                'e.g. Gulberg, Lahore',
                Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.m),
              _lbl('Description'),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your facility...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Update Complex',
                onPressed: _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s),
    child: Text(t, style: AppTextStyles.label),
  );

  Widget _field(TextEditingController c, String hint, IconData icon) =>
      TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
