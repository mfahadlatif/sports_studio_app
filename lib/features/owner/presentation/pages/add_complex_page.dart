import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/widgets/address_autocomplete_field.dart';

class AddComplexPage extends StatefulWidget {
  /// Pass an existing complex map to enter edit mode.
  final dynamic complex;

  const AddComplexPage({super.key, this.complex});

  @override
  State<AddComplexPage> createState() => _AddComplexPageState();
}

class _AddComplexPageState extends State<AddComplexPage> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isActive = true;

  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isEdit => widget.complex != null;

  List<String> get _existingImageUrls {
    if (!_isEdit || widget.complex == null) return [];
    final c = widget.complex as Map<String, dynamic>;
    final list = UrlHelper.getParsedImages(c['images']);
    if (list.isNotEmpty) return list.map(UrlHelper.sanitizeUrl).toList();
    if (c['image_path'] != null && c['image_path'].toString().isNotEmpty) {
      return [UrlHelper.sanitizeUrl(c['image_path'].toString())];
    }
    return [];
  }

  final List<Map<String, String>> _facilityConfigs = [
    {'id': 'parking', 'name': 'Parking', 'icon': '🅿️'},
    {'id': 'washrooms', 'name': 'Washrooms', 'icon': '🚻'},
    {'id': 'changing-rooms', 'name': 'Changing Rooms', 'icon': '🚿'},
    {'id': 'seating', 'name': 'Seating Area', 'icon': '💺'},
    {'id': 'lighting', 'name': 'Floodlights', 'icon': '💡'},
    {'id': 'cafe', 'name': 'Café', 'icon': '☕'},
    {'id': 'first-aid', 'name': 'First Aid', 'icon': '🏥'},
    {'id': 'wifi', 'name': 'WiFi', 'icon': '📶'},
    {'id': 'lockers', 'name': 'Lockers', 'icon': '🔐'},
    {'id': 'equipment', 'name': 'Equipment Rental', 'icon': '🎯'},
  ];

  final Set<String> _selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.complex;
      _nameCtrl.text = c['name'] ?? '';
      _addressCtrl.text = c['address'] ?? '';
      _descCtrl.text = c['description'] ?? '';
      _latCtrl.text = (c['latitude'] ?? '').toString();
      _lngCtrl.text = (c['longitude'] ?? '').toString();
      final status = c['status'];
      _isActive = status == 'active' || status == 1 || status == true;

      // Pre-select amenities
      List amenities = [];
      try {
        amenities = c['amenities'] is List
            ? c['amenities']
            : (c['amenities'] is String
                  ? (c['amenities'] as String).split(',')
                  : []);
      } catch (_) {}
      _selectedAmenities.addAll(amenities.map((e) => e.toString()));
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      AppUtils.showError(message: 'Please fill name and address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isEdit) {
        // Edit: PUT with JSON (no file re-upload unless images are picked)
        final id = widget.complex['id'];
        final data = {
          'name': _nameCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'status': _isActive ? 'active' : 'inactive',
          'latitude': _latCtrl.text.trim(),
          'longitude': _lngCtrl.text.trim(),
          'amenities': _selectedAmenities.toList(),
        };
        final res = await ApiClient().dio.put('/complexes/$id', data: data);
        if (res.statusCode == 200 || res.statusCode == 201) {
          _onSuccess('Complex updated successfully!');
        }
      } else {
        // Add: POST with FormData (supports image upload)
        final Map<String, dynamic> dataMap = {
          'name': _nameCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'status': _isActive ? 'active' : 'inactive',
          'latitude': _latCtrl.text.trim(),
          'longitude': _lngCtrl.text.trim(),
          'amenities': _selectedAmenities.toList(),
        };

        dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);
        for (var file in _pickedImages) {
          formData.files.add(
            MapEntry(
              'images[]',
              await dio_form.MultipartFile.fromFile(
                file.path,
                filename: file.name,
              ),
            ),
          );
        }

        final res = await ApiClient().dio.post('/complexes', data: formData);
        if (res.statusCode == 200 || res.statusCode == 201) {
          _onSuccess('Complex created successfully!');
        }
      }
    } on dio_form.DioException catch (e) {
      debugPrint('❌ [AddComplex] Error: ${e.response?.data}');
      String msg = _isEdit
          ? 'Failed to update complex'
          : 'Failed to create complex';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        msg = e.response?.data['message'];
      }
      AppUtils.showError(message: msg);
    } catch (e) {
      AppUtils.showError(message: 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSuccess(String message) {
    try {
      final groundsController = Get.find<GroundsController>();
      groundsController.fetchComplexesAndGrounds();
    } catch (_) {}
    Get.back(result: true);
    AppUtils.showSuccess(message: message);
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEdit ? 'Edit Sports Complex' : 'Add Sports Complex',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Basic Information Card ──────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.info_outline,
                    label: 'Basic Information',
                  ),
                  const SizedBox(height: AppSpacing.m),

                  _lbl('Complex Name *'),
                  _textField(
                    _nameCtrl,
                    'e.g. Elite Sports Complex',
                    Icons.business_outlined,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  _lbl('Location / Area *'),
                  AddressAutocompleteField(
                    controller: _addressCtrl,
                    hintText: 'Search for a location...',
                    prefixIcon: Icons.map_outlined,
                    latController: _latCtrl,
                    lngController: _lngCtrl,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  _lbl('Description'),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Describe your sports complex, highlights, and special features...',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // ── Status toggle (inside same card, like web) ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s + 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complex Status',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Active complexes are visible to customers',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // ── Complex Images & Gallery Card ───────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.photo_library_outlined,
                    label: 'Complex Images & Gallery',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _buildImageSection(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // ── Facilities Card ─────────────────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.apartment_outlined,
                    label: 'Facilities Available',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select all facilities available at your complex',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _buildAmenitiesGrid(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            // ── Action Buttons ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.buttonRadius + 4,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.7,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.buttonRadius + 4,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const AppProgressIndicator(
                              size: 20,
                              color: Colors.white,
                              strokeWidth: 2.5,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isEdit
                                      ? Icons.update_rounded
                                      : Icons.save_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEdit
                                      ? 'Update Complex'
                                      : 'Save & Continue',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.add_photo_alternate_outlined,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  // ── Image Section ────────────────────────────────────────────────
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: _pickedImages.isEmpty
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  _pickedImages.isEmpty
                      ? 'Tap to upload complex photos'
                      : '${_pickedImages.length} image${_pickedImages.length > 1 ? 's' : ''} selected — tap to add more',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_pickedImages.isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG supported',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_existingImageUrls.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            'Current photos',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                final url = _existingImageUrls[index];
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    child: url.startsWith('http')
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        if (_pickedImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            'New photos',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length,
              itemBuilder: (context, index) {
                final file = File(_pickedImages[index].path);
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _pickedImages.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ── Facilities Grid ──────────────────────────────────────────────
  Widget _buildAmenitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemCount: _facilityConfigs.length,
      itemBuilder: (context, index) {
        final facility = _facilityConfigs[index];
        final isSelected = _selectedAmenities.contains(facility['id']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(facility['id']);
              } else {
                _selectedAmenities.add(facility['id']!);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Text(
                  facility['icon']!,
                  style: TextStyle(fontSize: isSelected ? 22 : 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    facility['name']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) => TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySmall,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide.none,
      ),
    ),
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }
}

// ── Reusable Card wrapper ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section title row ──────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
