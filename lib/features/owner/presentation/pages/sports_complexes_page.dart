import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/widgets/app_shimmer.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_complex_page.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/features/owner/presentation/pages/complex_detail_page.dart';

class SportsComplexesPage extends StatefulWidget {
  const SportsComplexesPage({super.key});

  @override
  State<SportsComplexesPage> createState() => _SportsComplexesPageState();
}

class _SportsComplexesPageState extends State<SportsComplexesPage> {
  bool _isLoading = true;
  List<Complex> _complexes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchComplexes();
  }

  Future<void> _fetchComplexes() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/complexes');
      if (res.statusCode == 200) {
        final data = res.data['data'] ?? res.data;
        final list = data is List ? data : [];
        setState(() {
          _complexes = list
              .map((e) => e is Map ? Complex.fromJson(Map<String, dynamic>.from(e)) : null)
              .whereType<Complex>()
              .toList();
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComplex(Complex complex) async {
    final confirmed = await AppUtils.showDeleteConfirmation(
      title: 'Delete Complex?',
      message: 'Are you sure you want to remove "${complex.name}"? All associated grounds and arenas will also be permanently deleted.',
    );

    if (confirmed == true) {
      try {
        final res = await ApiClient().dio.delete('/complexes/${complex.id}');
        if (res.statusCode == 200 || res.statusCode == 204) {
          setState(() => _complexes.removeWhere((c) => c.id == complex.id));
          AppUtils.showSuccess(message: 'Complex removed successfully');
        }
      } catch (_) {
        AppUtils.showError(message: 'Failed to delete complex');
      }
    }
  }

  void _openForm({Complex? complex}) async {
    final result = await Get.to(
      () => AddComplexPage(complex: complex?.toJson()),
      transition: Transition.rightToLeft,
    );
    if (result == true) _fetchComplexes();
  }

  List<Complex> get _filtered => (_complexes)
      .where(
        (c) =>
            (c.name).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (c.address).toLowerCase().contains(_searchQuery.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Complexes'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Add',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search complexes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: 5,
                    itemBuilder: (_, __) => AppShimmer.card(),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: _filtered.isEmpty
                          ? _emptyState()
                          : RefreshIndicator(
                              onRefresh: _fetchComplexes,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.m,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (ctx, i) =>
                                    _complexCard(_filtered[i]),
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _complexCard(Complex complex) {
    final groundCount = complex.grounds?.length ?? 0;
    final isActive = complex.status == 'active' || complex.status == '1';

    return GestureDetector(
      onTap: () =>
          Get.to(() => const ComplexDetailPage(), arguments: {'id': complex.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.4),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _complexThumbnail(complex),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(complex.name, style: AppTextStyles.h3),
                        if (complex.address.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  complex.address,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Ground count
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.layers_outlined,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$groundCount Arena${groundCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.grey,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Facilities row: Show amenities from the first ground as representative or hide if empty
                        if (complex.grounds != null &&
                            complex.grounds!.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: (complex.grounds != null && complex.grounds!.isNotEmpty 
                                ? (complex.grounds!.first.amenities ?? []) 
                                : (complex.amenities ?? []))
                                .take(6)
                                .map<Widget>((fId) {
                                  final info = _getFacilityInfo(fId.toString());
                                  return Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.border.withOpacity(0.3),
                                      ),
                                    ),
                                    child: info['asset'] != null 
                                        ? Image.asset(info['asset']!, width: 14, height: 14)
                                        : Text(info['icon']!, style: const TextStyle(fontSize: 10)),
                                  );
                                })
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _openForm(complex: complex),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        onPressed: () => _deleteComplex(complex),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.08),
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

  Widget _complexThumbnail(Complex complex) {
    final urls = complex.images != null && complex.images!.isNotEmpty
        ? UrlHelper.getParsedImages(complex.images)
        : <String>[];
    final firstUrl = urls.isNotEmpty ? UrlHelper.sanitizeUrl(urls.first) : null;
    final hasValidUrl = firstUrl != null &&
        firstUrl.isNotEmpty &&
        !firstUrl.contains('unsplash.com');
    if (!hasValidUrl) {
      return Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.business_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: firstUrl,
      width: 44,
      height: 44,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.primaryLight,
        width: 44,
        height: 44,
      ),
      errorWidget: (context, url, error) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.business_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.business_outlined,
          size: 72,
          color: AppColors.textMuted.withOpacity(0.4),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('No complexes yet', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.l),
        ElevatedButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Complex'),
        ),
      ],
    ),
  );

  Map<String, String> _getFacilityInfo(String id) {
    // Normalize ID (e.g., 'washroom' -> 'washrooms')
    String normalizedId = id.toLowerCase().trim();
    if (normalizedId == 'washroom') normalizedId = 'washrooms';
    if (normalizedId == 'changing-room') normalizedId = 'changing-rooms';
    if (normalizedId == 'firstaid') normalizedId = 'first-aid';

    return AppConstants.groundAmenities.firstWhere(
      (a) => a['id'] == normalizedId,
      orElse: () => {'id': id, 'name': id, 'icon': '✓'},
    );
  }
}
