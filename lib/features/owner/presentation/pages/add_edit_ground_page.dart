import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/widgets/app_button.dart';
import 'package:sport_studio/features/owner/controller/grounds_controller.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/widgets/address_autocomplete_field.dart';
import 'package:sport_studio/widgets/full_screen_image_viewer.dart';
import 'package:sport_studio/core/network/api_services.dart';
import 'package:sport_studio/core/controllers/system_settings_controller.dart';

class AddEditGroundPage extends StatefulWidget {
  const AddEditGroundPage({super.key});

  @override
  State<AddEditGroundPage> createState() => _AddEditGroundPageState();
}

class _AddEditGroundPageState extends State<AddEditGroundPage> {
  // Form controllers
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceController = TextEditingController();
  final _openTimeController = TextEditingController(text: '08:00');
  final _closeTimeController = TextEditingController(text: '22:00');
  final _descCtrl = TextEditingController();
  final _dimensionsCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String _selectedSport = 'cricket';
  bool _hasLighting = false;
  bool _isSubmitting = false;

  final Set<String> _selectedAmenities = {};
  final List<XFile> _pickedImages = [];
  final List<String> _existingUrls = [];
  final ImagePicker _picker = ImagePicker();

  bool _isEdit = false;
  dynamic _existingGround;
  int? _complexId;
  String _complexName = '';
  String _complexAddress = '';
  String? _complexLat;
  String? _complexLng;

  final List<Map<String, String>> _groundAmenitiesConfig =
      AppConstants.groundAmenities;

  final List<Map<String, String>> _sportConfigs = [
    {'name': 'Cricket', 'icon': '🏏', 'id': 'cricket'},
    {'name': 'Football', 'icon': '⚽', 'id': 'football'},
    {'name': 'Tennis', 'icon': '🎾', 'id': 'tennis'},
    {'name': 'Padel', 'icon': '🏓', 'id': 'padel'},
    {'name': 'Volleyball', 'icon': '🏐', 'id': 'volleyball'},
    {'name': 'Hockey', 'icon': '🏑', 'id': 'hockey'},
    {'name': 'Basketball', 'icon': '🏀', 'id': 'basketball'},
    {'name': 'Badminton', 'icon': '🏸', 'id': 'badminton'},
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _isEdit = args['isEdit'] == true;
      _complexId = int.tryParse(args['complexId']?.toString() ?? '');
      _complexAddress = args['complexAddress'] ?? '';
      _complexLat = args['complexLat']?.toString();
      _complexLng = args['complexLng']?.toString();

      if (_isEdit && args['ground'] != null) {
        _existingGround = args['ground'];
        _prefillFromExisting();
      } else if (!_isEdit && _complexAddress.isNotEmpty) {
        // New ground: prefill with complex location if available
        _locationCtrl.text = _complexAddress;
        _latCtrl.text = _complexLat ?? '';
        _lngCtrl.text = _complexLng ?? '';
      }
    } else if (args is int) {
      _complexId = args;
    }
  }

  void _prefillFromExisting() {
    final g = _existingGround;
    _complexId = int.tryParse(g['complex_id']?.toString() ?? '') ?? _complexId;
    _nameCtrl.text = g['name'] ?? '';
    _locationCtrl.text = g['location'] ?? '';
    _priceController.text = (g['price_per_hour'] ?? '').toString();
    _openTimeController.text = g['opening_time'] ?? '08:00';
    _closeTimeController.text = g['closing_time'] ?? '22:00';
    _descCtrl.text = g['description'] ?? '';
    _dimensionsCtrl.text = g['dimensions'] ?? '';
    _capacityCtrl.text =
        (g['max_participants'] ?? g['capacity'] ?? g['max_players'] ?? '')
            .toString();
    _latCtrl.text = (g['latitude'] ?? '').toString();
    _lngCtrl.text = (g['longitude'] ?? '').toString();
    _hasLighting =
        g['has_lighting'] == true ||
        g['has_lighting'] == 1 ||
        g['lighting'] == true ||
        g['lighting'] == 1;

    if (g['type'] != null) {
      _selectedSport = _normalizeType(g['type'].toString());
    }

    // Pre-select amenities with robust parsing
    try {
      final raw = g['amenities'];
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

    // Robust image pre-filling from all possible API keys
    final Set<String> detectedImages = {};

    // Check various common image fields
    detectedImages.addAll(UrlHelper.getParsedImages(g['images']));
    detectedImages.addAll(UrlHelper.getParsedImages(g['media']));
    detectedImages.addAll(UrlHelper.getParsedImages(g['image_path']));
    detectedImages.addAll(UrlHelper.getParsedImages(g['image']));

    for (var img in detectedImages) {
      final sanitized = UrlHelper.sanitizeUrl(img);
      if (sanitized.isNotEmpty && !_existingUrls.contains(sanitized)) {
        _existingUrls.add(sanitized);
      }
    }
  }

  String _normalizeType(String raw) {
    final lower = raw.toLowerCase();
    for (var s in _sportConfigs) {
      if (s['id'] == lower || s['name']!.toLowerCase() == lower) {
        return s['id']!;
      }
    }
    return 'cricket';
  }

  Future<void> _submit() async {
    if (_complexId == null || _complexId == 0) {
      AppUtils.showError(
        message: 'Invalid selection',
        title: 'Complex ID is missing. Please select a sports complex first.',
      );
      return;
    }

    if (_nameCtrl.text.isEmpty || _priceController.text.isEmpty) {
      AppUtils.showError(
        message: 'Please fill name and price per hour fields.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // 1. Upload NEW images first
      final List<String> finalImagePaths = _existingUrls
          .map(UrlHelper.getRawPath)
          .toList();

      for (var file in _pickedImages) {
        try {
          // Add model info to help the backend associate the media
          final formData = dio_form.FormData.fromMap({
            'file': await dio_form.MultipartFile.fromFile(file.path),
            'model_type': 'Ground',
            if (_isEdit) 'model_id': _existingGround['id'],
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
        'location': _locationCtrl.text.trim().isEmpty
            ? _complexAddress
            : _locationCtrl.text.trim(),
        'price_per_hour': _priceController.text.trim(),
        'description': _descCtrl.text.trim(),
        'dimensions': _dimensionsCtrl.text.trim(),
        'max_participants': _capacityCtrl.text.trim().isEmpty
            ? '22'
            : _capacityCtrl.text.trim(),
        'opening_time': _openTimeController.text.trim(),
        'closing_time': _closeTimeController.text.trim(),
        'type': _selectedSport,
        'lighting': _hasLighting ? '1' : '0',
        'has_lighting': _hasLighting ? '1' : '0',
        if (_complexId != null) 'complex_id': _complexId.toString(),
        'latitude': _latCtrl.text.trim().isEmpty
            ? (_complexLat ?? '0.0')
            : _latCtrl.text.trim(),
        'longitude': _lngCtrl.text.trim().isEmpty
            ? (_complexLng ?? '0.0')
            : _lngCtrl.text.trim(),
      };

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);

      // Add amenities as multiple fields (standard for multipart arrays)
      for (var amenity in _selectedAmenities) {
        formData.fields.add(MapEntry('amenities[]', amenity));
      }

      // Add ALL images (existing and new) to the images[] array
      for (var path in finalImagePaths) {
        formData.fields.add(MapEntry('images[]', path));
      }

      if (_isEdit) {
        formData.fields.add(const MapEntry('_method', 'PUT'));
      }

      final String updateIdentifier = _isEdit
          ? (_existingGround['slug'] ?? _existingGround['id']).toString()
          : '';

      final res = _isEdit
          ? await ApiClient().dio.post(
              '/grounds/$updateIdentifier',
              data: formData,
            )
          : await ApiClient().dio.post('/grounds', data: formData);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _onSuccess(_isEdit ? 'Ground updated' : 'Ground published');
      }
    } on dio_form.DioException catch (e) {
      debugPrint('❌ [AddEditGround] Dio Error: ${e.response?.data}');
      String msg = 'Validation failed. Please verify your details.';
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
      setState(() => _isSubmitting = false);
    }
  }

  void _onSuccess(String msg) {
    try {
      final groundsController = Get.find<GroundsController>();
      groundsController.fetchComplexesAndGrounds();
    } catch (_) {}

    Get.back(result: true);

    AppUtils.showSuccessDialog(
      title: _isEdit ? 'Ground Updated!' : 'Ground Submitted!',
      message: _isEdit
          ? 'Your changes have been saved successfully.'
          : 'Your ground has been added successfully. Please wait for admin approval. Once approved, your ground will be activated.',
    );
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) setState(() => _pickedImages.addAll(images));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEdit && _complexId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add New Ground')),
        body: _buildSelectComplexStep(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Ground' : 'Add New Ground')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_complexName.isNotEmpty)
              Text(
                _isEdit ? 'Complex: $_complexName' : 'Adding to: $_complexName',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Ground Images & Gallery *',
                    Icons.photo_library_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildImageSection(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.info_outline,
                    label: 'Basic Information',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _lbl('Ground / Arena Name *'),
                  _textField(
                    _nameCtrl,
                    'e.g., Cricket Stadium, Football Arena',
                    Icons.sports_cricket,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _lbl('Location / Area (Specific to this Ground)'),
                  AddressAutocompleteField(
                    controller: _locationCtrl,
                    hintText: 'Specific location or same as complex',
                    prefixIcon: Icons.location_on_outlined,
                    latController: _latCtrl,
                    lngController: _lngCtrl,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _lbl('Select Sport Type *'),
                  _buildSportGrid(),
                  const SizedBox(height: AppSpacing.m),
                  _lbl('Description'),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Describe this ground...',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _textField(_dimensionsCtrl, 'Dimensions', Icons.square_foot),
                  const SizedBox(height: 12),
                  _textField(
                    _capacityCtrl,
                    'Max Participants (Capacity)',
                    Icons.people_outline,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildToggles(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.payments_outlined,
                    label: 'Pricing & Availability',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _lbl('Price per Hour (${AppConstants.currencySymbol}) *'),
                      Obx(() {
                        final settings = Get.find<SystemSettingsController>();
                        return Text(
                          'Admin Commission: ${settings.commissionRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        );
                      }),
                    ],
                  ),
                  _textField(
                    _priceController,
                    'Rate per hour',
                    Icons.account_balance_wallet_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _lbl('Opening Time'),
                            _timeField(_openTimeController),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _lbl('Closing Time'),
                            _timeField(_closeTimeController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Facilities & Amenities',
                    Icons.dns_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildAmenitiesGrid(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Submit',
              onPressed: _submit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectComplexStep() {
    final controller = Get.put(GroundsController());
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.complexes.isEmpty) {
        return const Center(
          child: Text('No complexes found. Add a complex first.'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.complexes.length,
        itemBuilder: (context, index) {
          final c = controller.complexes[index];
          final bool isActive = c.status == 'active' || c.status == '1';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                ],
              ),
              trailing: isActive
                  ? const Icon(Icons.arrow_forward_ios, size: 14)
                  : const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
              onTap: isActive
                  ? () => setState(() {
                      _complexId = c.id;
                      _complexName = c.name;
                      _complexAddress = c.address;
                      _complexLat = c.latitude?.toString();
                      _complexLng = c.longitude?.toString();

                      // Auto-populate location from newly selected complex
                      _locationCtrl.text = _complexAddress;
                      _latCtrl.text = _complexLat ?? '';
                      _lngCtrl.text = _complexLng ?? '';
                    })
                  : () {
                      AppUtils.showError(
                        title: 'Complex Not Approved',
                        message:
                            'You can only add grounds to complexes that have been approved by the admin.',
                      );
                    },
            ),
          );
        },
      );
    });
  }

  Widget _buildSectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    ),
  );

  Widget _buildSportGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
    ),
    itemCount: _sportConfigs.length,
    itemBuilder: (context, index) {
      final s = _sportConfigs[index];
      final isSelected = _selectedSport.toLowerCase() == s['id'];
      return GestureDetector(
        onTap: () => setState(() {
          _selectedSport = s['id']!;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s['icon']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  s['name']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

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
      itemCount: _groundAmenitiesConfig.length,
      itemBuilder: (context, index) {
        final facility = _groundAmenitiesConfig[index];
        final isSelected = _selectedAmenities.contains(facility['id']);
        final assetPath = facility['asset'] ?? '';

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
                    : AppColors.border.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primaryLight.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: assetPath.isNotEmpty
                      ? Image.asset(
                          assetPath,
                          width: 20,
                          height: 20,
                          color: isSelected ? Colors.white : AppColors.primary,
                        )
                      : Text(
                          facility['icon'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    (facility['name'] ?? '').toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
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
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
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
                      ? 'Tap to upload ground photos'
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
                            color: AppColors.border.withValues(alpha: 0.5),
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

  Widget _buildToggles() {
    return Column(
      children: [
        _toggleItem(
          'Floodlights / Night Lights',
          'Is this ground equipped for night play?',
          _hasLighting,
          (v) => setState(() => _hasLighting = v),
        ),
      ],
    );
  }

  Widget _toggleItem(
    String title,
    String sub,
    bool val,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sub,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: val,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _timeField(TextEditingController ctrl) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.tryParse(ctrl.text.split(':').first) ?? 8,
            minute: int.tryParse(ctrl.text.split(':').last) ?? 0,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final h = picked.hour.toString().padLeft(2, '0');
          final m = picked.minute.toString().padLeft(2, '0');
          setState(() {
            ctrl.text = '$h:$m';
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: AppUtils.formatTime(ctrl.text),
          ),
          style: AppTextStyles.bodySmall,
          decoration: InputDecoration(
            hintText: 'Select Time',
            prefixIcon: const Icon(Icons.access_time, size: 18),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      t,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      textCapitalization:
          (keyboardType == TextInputType.emailAddress ||
              keyboardType == TextInputType.number ||
              keyboardType == TextInputType.phone)
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      style: AppTextStyles.bodySmall,
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
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _priceController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descCtrl.dispose();
    _dimensionsCtrl.dispose();
    _capacityCtrl.dispose();
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.h3),
      ],
    );
  }
}
