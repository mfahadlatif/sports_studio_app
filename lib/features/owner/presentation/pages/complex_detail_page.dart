import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/widgets/app_shimmer.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/owner/presentation/pages/add_complex_page.dart';
import 'package:sport_studio/widgets/full_screen_image_viewer.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';

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
  final RxInt _currentPage = 0.obs;
  final PageController _pageController = PageController();
  Timer? _carouselTimer;
  String? _complexId;

  @override
  void initState() {
    super.initState();
    _extractComplexId();
    _fetch();
    _startAutoScroll();
  }

  void _extractComplexId() {
    final args = Get.arguments;
    if (args == null) return;

    dynamic rawId;
    if (args is Map) {
      rawId =
          args['id'] ?? (args['complex'] is Map ? args['complex']['id'] : null);
    } else {
      rawId = args;
    }

    if (rawId != null) {
      _complexId = rawId.toString();
    }
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 3800), (
      timer,
    ) {
      if (_complex != null) {
        List<String> images = [];
        if (_complex['images'] != null &&
            (_complex['images'] as List).isNotEmpty) {
          images = (_complex['images'] as List)
              .where((e) => e != null)
              .map((e) => e.toString())
              .toList();
        } else if (_complex['image_path'] != null) {
          images.add(_complex['image_path'].toString());
        }

        if (images.length > 1) {
          int next = _currentPage.value + 1;
          if (next >= images.length) next = 0;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (_complexId == null) {
      if (!mounted) return;
      AppUtils.showError(message: 'Invalid arguments: No complex ID found');
      setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      debugPrint('🌐 [ComplexDetail] Fetching complex: $_complexId');
      final res = await ApiClient().dio.get(
        '/complexes/$_complexId',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final raw = res.data;
        final data = raw is Map ? (raw['data'] ?? raw) : null;
        final map = data is Map ? data : null;
        setState(() {
          _complex = map;
          _grounds = map != null
              ? List<dynamic>.from(map['grounds'] ?? [])
              : <dynamic>[];
        });
      } else {
        setState(() => _complex = null);
        AppUtils.showError(message: 'Failed to load complex details');
      }
    } on DioException catch (e) {
      debugPrint('❌ [ComplexDetail] DioException: ${e.type} ${e.message}');
      if (mounted) {
        setState(() => _complex = null);
        final msg =
            e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout
            ? 'Request timed out. Please try again.'
            : 'Failed to load complex details';
        AppUtils.showError(message: msg);
      }
    } catch (e) {
      debugPrint('❌ [ComplexDetail] Error: $e');
      if (mounted) {
        setState(() => _complex = null);
        AppUtils.showError(message: 'Failed to load complex details');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGround(dynamic ground) async {
    final confirmed = await AppUtils.showDeleteConfirmation(
      title: 'Delete Ground?',
      message:
          'Are you sure you want to remove "${ground['name']}" permanently? This action cannot be undone.',
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

  String _formatOperatingHours(dynamic open, dynamic close) {
    if (open == null ||
        close == null ||
        open.toString().isEmpty ||
        close.toString().isEmpty) {
      return '—';
    }
    return AppUtils.formatTimeRange(open, close);
  }

  Map<String, String> _getFacilityInfo(String id) {
    final configs = [
      {
        'id': 'parking',
        'name': 'Free Parking',
        'icon': '🚗',
        'asset': 'assets/Icons/FreeParking.png',
      },
      {
        'id': 'washrooms',
        'name': 'Washrooms',
        'icon': '🚻',
        'asset': 'assets/Icons/Washrooms.png',
      },
      {
        'id': 'washroom',
        'name': 'Washrooms',
        'icon': '🚻',
        'asset': 'assets/Icons/Washrooms.png',
      },
      {
        'id': 'changing-rooms',
        'name': 'Changing Rooms',
        'icon': '👕',
        'asset': 'assets/Icons/ChangingRooms.png',
      },
      {
        'id': 'changing',
        'name': 'Changing Rooms',
        'icon': '👕',
        'asset': 'assets/Icons/ChangingRooms.png',
      },
      {
        'id': 'seating',
        'name': 'Seating Area',
        'icon': '💺',
        'asset': 'assets/Icons/Seating.png',
      },
      {
        'id': 'lighting',
        'name': 'Floodlights',
        'icon': '💡',
        'asset': 'assets/Icons/Floodlights.png',
      },
      {
        'id': 'cafe',
        'name': 'Cafeteria',
        'icon': '☕',
        'asset': 'assets/Icons/Cafe.png',
      },
      {
        'id': 'first-aid',
        'name': 'First Aid',
        'icon': '🏥',
        'asset': 'assets/Icons/FirstAid.png',
      },
      {
        'id': 'first_aid',
        'name': 'First Aid',
        'icon': '🏥',
        'asset': 'assets/Icons/FirstAid.png',
      },
      {
        'id': 'wifi',
        'name': 'Free WiFi',
        'icon': '📶',
        'asset': 'assets/Icons/FreeWiFi.png',
      },
      {
        'id': 'water',
        'name': 'Drinking Water',
        'icon': '🚰',
        'asset': 'assets/Icons/Washrooms.png',
      },
      {
        'id': 'lockers',
        'name': 'Lockers',
        'icon': '🔐',
        'asset': 'assets/Icons/Lockers.png',
      },
      {
        'id': 'equipment',
        'name': 'Equipment',
        'icon': '🎯',
        'asset': 'assets/Icons/Equipment.png',
      },
    ];
    return configs.firstWhere(
      (c) => c['id'] == id.replaceAll('_', '-'),
      orElse: () => configs.firstWhere(
        (c) => c['id'] == id,
        orElse: () => {'id': id, 'name': id, 'icon': '✓', 'asset': ''},
      ),
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
        // Safely convert, skipping any null entries
        images = (_complex['images'] as List)
            .where((e) => e != null)
            .map((e) => e.toString())
            .toList();
      } else if (_complex['image_path'] != null) {
        images.add(_complex['image_path'].toString());
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
      controller: _pageController,
      onPageChanged: (v) => _currentPage.value = v,
      itemCount: sanitized.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Get.to(
            () => FullScreenImageViewer(images: sanitized, initialIndex: index),
          ),
          child: CachedNetworkImage(
            imageUrl: sanitized[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final name = _complex['name'] ?? 'Complex';
    final address = _complex['address'] ?? '';
    final description = _complex['description'] ?? '';
    final status = (_complex['status'] ?? 'active').toString().toLowerCase();
    final isActive = status == 'active' || status == '1' || status == 'true';
    final groundCount = _grounds.length;

    return CustomScrollView(
      slivers: [
        // ─── App Bar ────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          leadingWidth: 50,

          leading: Container(
            height: 20,
            width: 20,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          actions: [
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.all(0),

                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => _openEditComplexSheet(),
                  tooltip: 'Edit Complex',
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _buildCarousel(),
                if (_complex != null &&
                    ((_complex['images'] as List?)?.length ?? 0) > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        (_complex['images'] as List).length,
                        (index) => Obx(
                          () => Container(
                            width: _currentPage.value == index ? 16 : 8,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _currentPage.value == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
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
                            color: Colors.black.withValues(alpha: 0.05),
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
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: AppTextStyles.h2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.green.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.red.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            isActive ? 'ACTIVE' : 'INACTIVE',
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
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
                                        final hasAsset =
                                            f['asset'] != null &&
                                            f['asset']!.isNotEmpty;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: hasAsset
                                                    ? Image.asset(
                                                        f['asset']!,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Text(
                                                        f['icon'] ?? '✓',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                f['name'] ?? fId.toString(),
                                                style: AppTextStyles.label
                                                    .copyWith(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                            ),
                            const SizedBox(height: AppSpacing.l),
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
                            final profileController =
                                Get.find<ProfileController>();
                            if (!profileController.isPhoneVerified) {
                              AppUtils.showPhoneVerificationRequiredDialog(
                                title: 'Phone Verification Required',
                                message:
                                    'To add a ground, your phone number must be verified for security and contact purposes.',
                              );
                              return;
                            }
                            if (!isActive) {
                              AppUtils.showError(
                                message:
                                    'You can add grounds only after your complex is approved.',
                              );
                              return;
                            }
                            final result = await Get.toNamed(
                              '/add-ground',
                              arguments: {
                                'complexId': _complex['id'],
                                'complexName': name,
                                'complexAddress': address,
                                'complexLat': _complex['latitude'],
                                'complexLng': _complex['longitude'],
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
                      textCapitalization: TextCapitalization.sentences,
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
    final status = (ground['status'] ?? 'active').toString().toLowerCase();
    final isActive = status == 'active' || status == '1' || status == 'true';

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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                          Colors.black.withValues(alpha: 0.6),
                        ],
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
                            text: '${AppConstants.currencySymbol} $price',
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
                          color: AppColors.primary.withValues(alpha: 0.1),
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive ? Colors.green : Colors.red,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'INACTIVE',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
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
                                  _formatOperatingHours(
                                    ground['opening_time'],
                                    ground['closing_time'],
                                  ),
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
                        Get.toNamed(
                          '/owner-bookings',
                          arguments: {
                            'groundId': ground['id'],
                            'groundName': ground['name'],
                          },
                        );
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
        color: AppColors.primary.withValues(alpha: 0.4),
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
            color: AppColors.textMuted.withValues(alpha: 0.4),
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
              final profileController = Get.find<ProfileController>();
              if (!profileController.isPhoneVerified) {
                AppUtils.showPhoneVerificationRequiredDialog(
                  title: 'Phone Verification Required',
                  message:
                      'To add a ground, your phone number must be verified for security and contact purposes.',
                );
                return;
              }
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

  void _openEditComplexSheet() async {
    final result = await Get.to(
      () => AddComplexPage(complex: _complex),
      transition: Transition.rightToLeft,
    );
    if (result == true) _fetch();
  }
}
