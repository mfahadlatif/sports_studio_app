import 'dart:convert';
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
import 'package:sports_studio/widgets/full_screen_image_viewer.dart';
import 'package:sports_studio/core/network/api_services.dart';

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
  final List<String> _existingUrls = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isEdit => widget.complex != null;

  final List<Map<String, String>> _facilityConfigs = [
    {
      'id': 'parking',
      'name': 'Free Parking',
      'icon': '🅿️',
      'asset': 'assets/Icons/FreeParking.png',
    },
    {
      'id': 'washrooms',
      'name': 'Washrooms',
      'icon': '🚻',
      'asset': 'assets/Icons/Washrooms.png',
    },
    {
      'id': 'changing-rooms',
      'name': 'Changing Rooms',
      'icon': '🚿',
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
      'id': 'wifi',
      'name': 'Free WiFi',
      'icon': '📶',
      'asset': 'assets/Icons/FreeWiFi.png',
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

      // Initialize existing images
      final list = UrlHelper.getParsedImages(c['images']);
      if (list.isNotEmpty) {
        _existingUrls.addAll(list.map(UrlHelper.sanitizeUrl).toList());
      } else if (c['image_path'] != null &&
          c['image_path'].toString().isNotEmpty) {
        _existingUrls.add(UrlHelper.sanitizeUrl(c['image_path'].toString()));
      }

      // Pre-select amenities with robust parsing
      try {
        final raw = c['amenities'];
        if (raw != null) {
          List<String> parsed = [];
          if (raw is List) {
            parsed = raw.map((e) => e?.toString() ?? '').toList();
          } else if (raw is String && raw.isNotEmpty) {
            if (raw.trim().startsWith('[') || raw.trim().startsWith('{')) {
              try {
                final decoded = jsonDecode(raw);
                if (decoded is List) {
                  parsed = decoded.map((e) => e?.toString() ?? '').toList();
                }
              } catch (_) {
                parsed = raw.split(',').map((e) => e.trim()).toList();
              }
            } else {
              parsed = raw.split(',').map((e) => e.trim()).toList();
            }
          }

          // Add normalized amenities (handle changing_rooms vs changing-rooms)
          _selectedAmenities.addAll(
            parsed
                .where((e) => e.isNotEmpty)
                .map((e) => e.replaceAll('_', '-').toLowerCase()),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      AppUtils.showError(message: 'Please fill name and address');
      return;
    }

    if (_pickedImages.isEmpty && _existingUrls.isEmpty) {
      AppUtils.showError(
        message: 'Please upload at least one image for your complex.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Upload NEW images first
      final List<String> finalImagePaths = _existingUrls
          .map(UrlHelper.getRawPath)
          .toList();

      final mediaApi = MediaApiService();
      for (var file in _pickedImages) {
        try {
          final formData = dio_form.FormData.fromMap({
            'file': await dio_form.MultipartFile.fromFile(file.path),
            'model_type': 'Complex',
            if (_isEdit) 'model_id': widget.complex['id'],
          });

          final uploadRes = await ApiClient().dio.post(
            '/upload',
            data: formData,
          );

          if (uploadRes.data != null && uploadRes.data['path'] != null) {
            finalImagePaths.add(uploadRes.data['path']);
          }
        } catch (e) {
          debugPrint('Error uploading file: $e');
        }
      }

      final Map<String, dynamic> dataMap = {
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'status': _isActive ? 'active' : 'inactive',
        'latitude': _latCtrl.text.trim(),
        'longitude': _lngCtrl.text.trim(),
      };

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);

      // Add amenities as multiple fields (standard for multipart arrays)
      for (var amenity in _selectedAmenities) {
        formData.fields.add(MapEntry('amenities[]', amenity));
      }

      // Add ALL images to images[] fields
      for (var path in finalImagePaths) {
        formData.fields.add(MapEntry('images[]', path));
      }

      if (_isEdit) {
        final String identifier =
            (widget.complex['slug'] ?? widget.complex['id']).toString();
        formData.fields.add(const MapEntry('_method', 'PUT'));

        final res = await ApiClient().dio.post(
          '/complexes/$identifier',
          data: formData,
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          _onSuccess('Complex updated successfully!');
        }
      } else {
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
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data;
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          msg = errors.values.first is List
              ? errors.values.first.first.toString()
              : errors.values.first.toString();
        } else if (data['message'] != null) {
          msg = data['message'];
        }
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

    AppUtils.showSuccessDialog(
      title: _isEdit ? 'Complex Updated!' : 'Complex Submitted!',
      message: _isEdit
          ? 'Your complex details have been updated successfully.'
          : 'Your complex has been added successfully. Please wait for admin approval. Once approved, your complex will be activated.',
      onConfirm: () => Get.back(),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty) {
        setState(() => _pickedImages.addAll(images));
      }
    } catch (e) {
      debugPrint('❌ [AddComplex] Pick Error: $e');
      AppUtils.showError(message: 'Failed to pick images: $e');
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
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.photo_library_outlined,
                    label: 'Complex Images & Gallery *',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _buildImageSection(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
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

  Widget _buildImageSection() {
    final allImages = [
      ..._existingUrls.map((url) => {'type': 'url', 'path': url}),
      ..._pickedImages.map((file) => {'type': 'file', 'path': file.path}),
    ];

    final List<String> displayPaths = allImages
        .map((img) => img['path']!)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
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
                const SizedBox(height: 8),
                Text(
                  allImages.isEmpty
                      ? 'Tap to upload complex photos'
                      : '${allImages.length} image${allImages.length > 1 ? 's' : ''} total — tap to add more',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (allImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                final img = allImages[index];
                final isUrl = img['type'] == 'url';

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(
                        () => FullScreenImageViewer(
                          images: displayPaths,
                          initialIndex: index,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.5),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius - 1,
                          ),
                          child: isUrl
                              ? Image.network(
                                  img['path']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _imagePlaceholder(),
                                )
                              : Image.file(
                                  File(img['path']!),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isUrl) {
                              _existingUrls.remove(img['path']);
                            } else {
                              _pickedImages.removeWhere(
                                (file) => file.path == img['path'],
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
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

  Widget _buildAmenitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: _facilityConfigs.length,
      itemBuilder: (context, index) {
        final facility = _facilityConfigs[index];
        final isSelected = _selectedAmenities.contains(facility['id']);
        final hasAsset =
            facility['asset'] != null && facility['asset']!.isNotEmpty;

        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedAmenities.remove(facility['id']);
            } else {
              _selectedAmenities.add(facility['id']!);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  child: hasAsset
                      ? Image.asset(
                          facility['asset']!,
                          color: isSelected ? Colors.white : null,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Text(facility['icon'] ?? '✓'),
                        )
                      : Text(
                          facility['icon'] ?? '✓',
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    facility['name']!.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

  Widget _textField(TextEditingController ctrl, String hint, IconData icon) =>
      TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.inputBackground,
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
        borderRadius: BorderRadius.circular(AppConstants.borderRadius + 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
