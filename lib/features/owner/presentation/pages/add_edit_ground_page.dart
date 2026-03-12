import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:sports_studio/core/utils/url_helper.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/address_autocomplete_field.dart';

class AddEditGroundPage extends StatefulWidget {
  const AddEditGroundPage({super.key});

  @override
  State<AddEditGroundPage> createState() => _AddEditGroundPageState();
}

class _AddEditGroundPageState extends State<AddEditGroundPage> {
  // Form controllers
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dimensionsCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String _selectedSport = 'Cricket';
  String _selectedStatus = 'active';
  bool _hasLighting = false;
  bool _isSubmitting = false;

  String _openTime = '06:00';
  String _closeTime = '23:00';
  final Set<String> _selectedAmenities = {};

  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Passed arguments
  bool _isEdit = false;
  dynamic _existingGround;
  int? _complexId;
  String _complexName = '';
  int? _selectedComplexIdForStep; // Step 1: selected complex (before Continue)

  final List<Map<String, String>> _groundAmenitiesConfig = [
    {'id': 'water', 'name': 'Water', 'icon': '🚰'},
    {'id': 'washroom', 'name': 'Washroom', 'icon': '🚻'},
    {'id': 'changing', 'name': 'Changing', 'icon': '👕'},
    {'id': 'dugout', 'name': 'Dugout', 'icon': '⛺'},
    {'id': 'balls', 'name': 'Balls', 'icon': '🎾'},
    {'id': 'bats', 'name': 'Bats', 'icon': '🏏'},
  ];

  final List<Map<String, String>> _sportConfigs = [
    {'name': 'Cricket', 'icon': '🏏'},
    {'name': 'Football', 'icon': '⚽'},
    {'name': 'Tennis', 'icon': '🎾'},
    {'name': 'Padel', 'icon': '🎾'},
    {'name': 'Volleyball', 'icon': '🏐'},
    {'name': 'Hockey', 'icon': '🏑'},
    {'name': 'Basketball', 'icon': '🏀'},
    {'name': 'Badminton', 'icon': '🏸'},
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _isEdit = args['isEdit'] == true;
      _complexId = int.tryParse(args['complexId']?.toString() ?? '');
      _complexName = args['complexName'] ?? '';
      if (_isEdit && args['ground'] != null) {
        _existingGround = args['ground'];
        _prefillFromExisting();
      }
    } else if (args is int) {
      _complexId = args;
    }
  }

  void _prefillFromExisting() {
    final g = _existingGround;
    _nameCtrl.text = g['name'] ?? '';
    _locationCtrl.text = g['location'] ?? '';
    _priceCtrl.text = (g['price_per_hour'] ?? '').toString();
    _descCtrl.text = g['description'] ?? '';
    _dimensionsCtrl.text = g['dimensions'] ?? '';
    _latCtrl.text = (g['latitude'] ?? '').toString();
    _lngCtrl.text = (g['longitude'] ?? '').toString();
    _selectedSport = _normalizeType(g['type'] ?? 'Cricket');
    _selectedStatus = g['status'] ?? 'active';
    _hasLighting = g['has_lighting'] == true || g['has_lighting'] == 1;
    _openTime = g['open_time'] ?? '06:00';
    _closeTime = g['close_time'] ?? '23:00';

    if (g['amenities'] != null) {
      if (g['amenities'] is List) {
        final list = g['amenities'] as List;
        _selectedAmenities.addAll(
          list
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList(),
        );
      }
    }
  }

  String _normalizeType(String raw) {
    final lower = raw.toLowerCase();
    for (var s in _sportConfigs) {
      if (s['name']!.toLowerCase() == lower) return s['name']!;
    }
    return 'Cricket';
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Name and price are required');
      return;
    }
    if (!_isEdit && _complexId == null) {
      Get.snackbar('Error', 'Please select a complex first');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      debugPrint(
        '🌐 [AddGround] Starting submission... (Edit: $_isEdit, ComplexId: $_complexId)',
      );

      final Map<String, dynamic> dataMap = {
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'price_per_hour': double.tryParse(_priceCtrl.text) ?? 0,
        'description': _descCtrl.text.trim(),
        'dimensions': _dimensionsCtrl.text.trim(),
        'open_time': _openTime,
        'close_time': _closeTime,
        'type': _selectedSport.toLowerCase(),
        'status': _selectedStatus,
        'has_lighting': _hasLighting ? 1 : 0,
        'amenities': _selectedAmenities.toList(),
        if (_complexId != null) 'complex_id': _complexId,
        'latitude': _latCtrl.text.trim(),
        'longitude': _lngCtrl.text.trim(),
      };

      debugPrint('📤 [AddGround] Payload: $dataMap');

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);
      
      // Add existing images if editing, but ONLY if they are paths (strings)
      // Actually, standardizing: if we send 'images' as a list of strings, 
      // the backend will replace the list. If we don't send anything, it keeps them.
      // But if we pick NEW images, we want to append or replace?
      // Event logic REPLACES paths if provided as array, and APPENDS files.
      
      if (_isEdit && _existingGround != null) {
        final existing = UrlHelper.getParsedImages(_existingGround['images']);
        if (existing.isNotEmpty) {
           formData.fields.add(MapEntry('images', jsonEncode(existing)));
        }
        formData.fields.add(const MapEntry('_method', 'PUT'));
      }

      if (_pickedImages.isNotEmpty) {
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
      }

      final res = _isEdit
          ? await ApiClient().dio.post(
              '/grounds/${_existingGround['id']}',
              data: formData,
            )
          : await ApiClient().dio.post('/grounds', data: formData);

      debugPrint('✅ [AddGround] Response: ${res.statusCode} | ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back(result: true);
        AppUtils.showSuccess(
          message:
              _isEdit ? 'Ground updated successfully' : 'Ground published!',
        );
      } else {
        AppUtils.showError(
          message:
              'Server Error (${res.statusCode}): ${res.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      debugPrint('❌ [AddGround] Submission failed: $e');
      AppUtils.showError(message: 'Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  /// Step 1 (match website): Select complex for new ground. "Continue" → show form.
  Widget _buildSelectComplexStep() {
    final groundsController = Get.put(GroundsController());
    return Obx(() {
      if (groundsController.isLoading.value &&
          groundsController.complexes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = groundsController.complexes;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Step 1: Select the sports complex for your new ground',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.l),
                if (list.isEmpty) ...[
                  const Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Text(
                    'No complexes yet. Create one first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppButton(
                    label: 'Add Complex',
                    onPressed: () async {
                      final result = await Get.toNamed('/add-complex');
                      if (result == true)
                        groundsController.fetchComplexesAndGrounds();
                    },
                  ),
                ] else ...[
                  ...list.map((c) => _complexTile(c)),
                  const SizedBox(height: AppSpacing.l),
                  AppButton(
                    label: 'Continue to Details',
                    onPressed: _selectedComplexIdForStep == null
                        ? null
                        : () {
                            final c = list.firstWhere(
                              (x) => x.id == _selectedComplexIdForStep,
                            );
                            setState(() {
                              _complexId = c.id;
                              _complexName = c.name;
                              _selectedComplexIdForStep = null;
                            });
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _complexTile(Complex c) {
    final isSelected = _selectedComplexIdForStep == c.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedComplexIdForStep = c.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.business_outlined,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (c.address.isNotEmpty)
                    Text(
                      c.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Step 1 (match website): Choose complex when adding new ground without complexId
    if (!_isEdit && _complexId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add New Ground'), centerTitle: true),
        body: _buildSelectComplexStep(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Ground' : 'Add New Ground'),
        centerTitle: true,
        actions: [
          if (_isEdit)
            TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(
                'Save',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complex badge
                if (_complexName.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.business_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Adding to: $_complexName',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],

                // ── Image Section ───────────────────────────────────
                _sectionHeader('Ground Image', Icons.image_outlined),
                const SizedBox(height: AppSpacing.m),
                _buildImagePicker(),
                const SizedBox(height: AppSpacing.l),

                // ── Basic Info Section ──────────────────────────────
                _sectionHeader('Basic Information', Icons.info_outline),
                const SizedBox(height: AppSpacing.m),

                _lbl('Ground Name *'),
                _textField(
                  _nameCtrl,
                  'e.g. Turf A – Main Ground',
                  Icons.sports_cricket,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Location / Area (e.g. Field 1 or full address)'),
                AddressAutocompleteField(
                  controller: _locationCtrl,
                  hintText: 'Search for a location...',
                  prefixIcon: Icons.location_on_outlined,
                  latController: _latCtrl,
                  lngController: _lngCtrl,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Ground Dimensions (Optional)'),
                _textField(
                  _dimensionsCtrl,
                  'e.g. 100 x 120 ft',
                  Icons.square_foot_outlined,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Sport Selection'),
                _buildSportGrid(),
                const SizedBox(height: AppSpacing.m),

                _lbl('Price per Hour (Rs.) *'),
                _textField(
                  _priceCtrl,
                  'e.g. 3000',
                  Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.l),

                // ── Operating Hours ────────────────────────────────
                _sectionHeader('Operating Hours', Icons.access_time),
                const SizedBox(height: AppSpacing.m),
                _buildTimeSection(),
                const SizedBox(height: AppSpacing.l),

                // ── Amenities ──────────────────────────────────────
                _sectionHeader('Ground Amenities', Icons.auto_awesome),
                const SizedBox(height: AppSpacing.m),
                _buildAmenitiesGrid(),
                const SizedBox(height: AppSpacing.l),

                // ── Configuration Section ───────────────────────────
                _sectionHeader('Configuration', Icons.settings_outlined),
                const SizedBox(height: AppSpacing.m),

                _lbl('Status'),
                _statusDropdown(),
                const SizedBox(height: AppSpacing.m),

                // Lighting toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasLighting
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _hasLighting
                              ? AppColors.primaryLight
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: _hasLighting ? AppColors.primary : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lighting Available',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              'Night sessions available with floodlights',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _hasLighting,
                        onChanged: (v) => setState(() => _hasLighting = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.l),

                // ── Description ─────────────────────────────────────
                _sectionHeader('Description', Icons.description_outlined),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Tell players about your ground — size, turf quality, facilities...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Submit button
                AppButton(
                  label: _isEdit ? 'Update Ground' : 'Publish Ground',
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSportGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: _sportConfigs.length,
      itemBuilder: (context, index) {
        final sport = _sportConfigs[index];
        final isSelected = _selectedSport == sport['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedSport = sport['name']!),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sport['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  sport['name']!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    // Show existing images from backend when editing, plus newly picked images.
    final List<String> existingImages =
        (_isEdit && _existingGround != null)
            ? UrlHelper.getParsedImages(_existingGround['images'])
            : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _pickedImages.isEmpty
                    ? AppColors.border
                    : AppColors.primary.withOpacity(0.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  _pickedImages.isEmpty
                      ? 'Tap to upload ground photos'
                      : '${_pickedImages.length} new images selected',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        if (existingImages.isNotEmpty || _pickedImages.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images from backend
                ...existingImages.map(
                  (url) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(UrlHelper.sanitizeUrl(url)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Newly picked images
                ...List.generate(_pickedImages.length, (index) {
                  final img = _pickedImages[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                            image: FileImage(File(img.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
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
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: AppColors.primary.withOpacity(0.2))),
    ],
  );

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
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
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildTimeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _timeField(
              'Opening Time',
              _openTime,
              (t) => setState(() => _openTime = t),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: _timeField(
              'Closing Time',
              _closeTime,
              (t) => setState(() => _closeTime = t),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField(String label, String value, Function(String) onSelect) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(value.split(':')[0]),
            minute: int.parse(value.split(':')[1]),
          ),
        );
        if (picked != null) {
          final h = picked.hour.toString().padLeft(2, '0');
          final m = picked.minute.toString().padLeft(2, '0');
          onSelect('$h:$m');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _groundAmenitiesConfig.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final amenity = _groundAmenitiesConfig[index];
        final id = amenity['id']!;
        final isSelected = _selectedAmenities.contains(id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected)
                _selectedAmenities.remove(id);
              else
                _selectedAmenities.add(id);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(amenity['icon']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  amenity['name']!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusDropdown() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.toggle_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'active', child: Text('Active')),
        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => _selectedStatus = v);
      },
    ),
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _dimensionsCtrl.dispose();
    super.dispose();
  }
}
