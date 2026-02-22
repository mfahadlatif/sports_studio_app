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

  String _selectedSport = 'Cricket';
  String _selectedStatus = 'active';
  bool _hasLighting = false;
  bool _isSubmitting = false;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // Passed arguments
  bool _isEdit = false;
  dynamic _existingGround;
  int? _complexId;
  String _complexName = '';

  final List<String> _sportTypes = [
    'Cricket',
    'Football',
    'Tennis',
    'Badminton',
    'Basketball',
    'Volleyball',
    'Squash',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _isEdit = args['isEdit'] == true;
      _complexId = args['complexId'];
      _complexName = args['complexName'] ?? '';
      if (_isEdit && args['ground'] != null) {
        _existingGround = args['ground'];
        _prefillFromExisting();
      }
    }
  }

  void _prefillFromExisting() {
    final g = _existingGround;
    _nameCtrl.text = g['name'] ?? '';
    _locationCtrl.text = g['location'] ?? '';
    _priceCtrl.text = (g['price_per_hour'] ?? '').toString();
    _descCtrl.text = g['description'] ?? '';
    _selectedSport = _normalizeType(g['type'] ?? 'Cricket');
    _selectedStatus = g['status'] ?? 'active';
    _hasLighting = g['has_lighting'] == true || g['has_lighting'] == 1;
  }

  String _normalizeType(String raw) {
    final lower = raw.toLowerCase();
    return _sportTypes.firstWhere(
      (s) => s.toLowerCase() == lower,
      orElse: () => 'Other',
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Name and price are required');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> dataMap = {
        'name': _nameCtrl.text,
        'location': _locationCtrl.text,
        'price_per_hour': double.tryParse(_priceCtrl.text) ?? 0,
        'description': _descCtrl.text,
        'type': _selectedSport.toLowerCase(),
        'status': _selectedStatus,
        'has_lighting': _hasLighting ? 1 : 0,
        if (_complexId != null) 'complex_id': _complexId,
      };

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);

      if (_pickedImage != null) {
        formData.files.add(
          MapEntry(
            'image',
            await dio_form.MultipartFile.fromFile(
              _pickedImage!.path,
              filename: _pickedImage!.name,
            ),
          ),
        );
      }

      final res = _isEdit
          ? await ApiClient().dio.post(
              '/grounds/${_existingGround['id']}?_method=PUT',
              data: formData,
            )
          : await ApiClient().dio.post('/grounds', data: formData);

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar(
          'Success',
          _isEdit ? 'Ground updated successfully' : 'Ground published!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.back(result: true);
      } else {
        Get.snackbar('Error', 'Server returned an error');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
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

                _lbl('Location / Area'),
                _textField(
                  _locationCtrl,
                  'e.g. Gulberg III, Lahore',
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Sport Type'),
                _sportDropdown(),
                const SizedBox(height: AppSpacing.m),

                _lbl('Price per Hour (Rs.) *'),
                _textField(
                  _priceCtrl,
                  'e.g. 3000',
                  Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),

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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Saving...'),
                            ],
                          )
                        : Text(
                            _isEdit ? 'Update Ground' : 'Publish Ground',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _pickedImage != null
              ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
              : _isEdit &&
                    _existingGround['images'] != null &&
                    (_existingGround['images'] as List).isNotEmpty
              ? Image.network(
                  UrlHelper.sanitizeUrl(_existingGround['images'][0]),
                  fit: BoxFit.cover,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to select ground image',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '(PNG, JPG up to 5MB)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
        ),
      ),
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

  Widget _sportDropdown() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: DropdownButtonFormField<String>(
      value: _selectedSport,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.sports_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _sportTypes
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedSport = v);
      },
    ),
  );

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
    super.dispose();
  }
}
