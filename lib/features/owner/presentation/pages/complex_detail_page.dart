import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';

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
      Get.snackbar('Error', 'Failed to load complex details');
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
        Get.snackbar('Deleted', 'Ground removed successfully');
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete ground');
    }
  }

  List<dynamic> get _filtered => _grounds.where((g) {
    final name = (g['name'] ?? '').toString().toLowerCase();
    final type = (g['type'] ?? '').toString().toLowerCase();
    final q = _searchQuery.toLowerCase();
    return name.contains(q) || type.contains(q);
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complex == null
          ? _buildNotFound()
          : _buildContent(),
    );
  }

  Widget _buildNotFound() => Scaffold(
    appBar: AppBar(title: const Text('Complex Detail')),
    body: const Center(child: Text('Complex not found')),
  );

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
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
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
                                'Grounds',
                                Icons.sports_cricket_outlined,
                              ),
                            ],
                          ),
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

    String imageUrl = '';
    final images = ground['images'] as List?;
    if (images != null && images.isNotEmpty) {
      imageUrl = images[0].toString();
      if (imageUrl.contains('localhost')) {
        imageUrl = imageUrl.replaceAll(
          'localhost/cricket-oasis-bookings/backend/public',
          'lightcoral-goose-424965.hostingersite.com/backend/public',
        );
      }
    }

    return Container(
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
        children: [
          // Image header
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _groundImagePlaceholder(type),
              ),
            )
          else
            _groundImagePlaceholder(type),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.capitalizeFirst ?? type,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.label.copyWith(
                          color: isActive ? Colors.green : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rs. $price/hr',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: AppTextStyles.h3),

                const SizedBox(height: AppSpacing.m),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.s),

                // Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _action(Icons.visibility_outlined, 'View', () {
                      Get.toNamed('/ground-detail', arguments: ground);
                    }),
                    _action(Icons.edit_outlined, 'Edit', () async {
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
                    _action(Icons.calendar_month_outlined, 'Bookings', () {
                      Get.toNamed('/user-bookings');
                    }),
                    _action(Icons.delete_outline, 'Delete', () {
                      _deleteGround(ground);
                    }, color: Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Widget _action(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Update Complex',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
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
