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
  final _priceController = TextEditingController();
  final _openTimeController = TextEditingController(text: '08:00');
  final _closeTimeController = TextEditingController(text: '22:00');
  final _descCtrl = TextEditingController();
  final _dimensionsCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  final Set<String> _selectedSports = {'Cricket'};
  String _selectedStatus = 'active';
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
  int? _selectedComplexIdForStep;

  final List<Map<String, String>> _groundAmenitiesConfig = AppConstants.groundAmenities;

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
    _priceController.text = (g['price_per_hour'] ?? '').toString();
    _openTimeController.text = g['opening_time'] ?? '08:00';
    _closeTimeController.text = g['closing_time'] ?? '22:00';
    _descCtrl.text = g['description'] ?? '';
    _dimensionsCtrl.text = g['dimensions'] ?? '';
    _latCtrl.text = (g['latitude'] ?? '').toString();
    _lngCtrl.text = (g['longitude'] ?? '').toString();
    _selectedStatus = g['status'] ?? 'active';
    _hasLighting = g['has_lighting'] == true || g['has_lighting'] == 1;

    if (g['type'] != null) {
      final List sportsList = g['type'] is List
          ? g['type']
          : (g['type'] is String ? (g['type'] as String).split(',') : [g['type']]);
      _selectedSports.clear();
      _selectedSports.addAll(sportsList.map((e) => _normalizeType(e.toString())));
    }

    if (g['amenities'] != null && g['amenities'] is List) {
      _selectedAmenities.addAll((g['amenities'] as List).map((e) => e.toString()));
    }

    final images = UrlHelper.getParsedImages(g['images']);
    _existingUrls.addAll(images);
  }

  String _normalizeType(String raw) {
    final lower = raw.toLowerCase();
    for (var s in _sportConfigs) {
      if (s['name']!.toLowerCase() == lower) return s['name']!;
    }
    return 'Cricket';
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _priceController.text.isEmpty) {
      AppUtils.showError(message: 'Name and price are required.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> dataMap = {
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'price_per_hour': double.tryParse(_priceController.text) ?? 0,
        'description': _descCtrl.text.trim(),
        'dimensions': _dimensionsCtrl.text.trim(),
        'opening_time': _openTimeController.text.trim(),
        'closing_time': _closeTimeController.text.trim(),
        'type': _selectedSports.join(','),
        'status': _selectedStatus,
        'lighting': _hasLighting ? 1 : 0,
        'amenities': jsonEncode(_selectedAmenities.toList()),
        if (_complexId != null) 'complex_id': _complexId,
        'latitude': _latCtrl.text.trim(),
        'longitude': _lngCtrl.text.trim(),
      };

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);

      if (_isEdit) {
        formData.fields.add(MapEntry('images', jsonEncode(_existingUrls)));
        formData.fields.add(const MapEntry('_method', 'PUT'));
      }

      for (var file in _pickedImages) {
        formData.files.add(MapEntry(
          'images[]',
          await dio_form.MultipartFile.fromFile(file.path, filename: file.name),
        ));
      }

      final res = _isEdit
          ? await ApiClient().dio.post('/grounds/${_existingGround['id']}', data: formData)
          : await ApiClient().dio.post('/grounds', data: formData);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _onSuccess(_isEdit ? 'Ground updated' : 'Ground published');
      }
    } catch (e) {
      AppUtils.showError(message: 'Submission failed: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _onSuccess(String message) {
    try {
      Get.find<GroundsController>().fetchComplexesAndGrounds();
    } catch (_) {}
    
    Get.back(result: true);

    if (!_isEdit) {
      Get.defaultDialog(
        title: 'Ground Submitted',
        contentPadding: const EdgeInsets.all(16),
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        middleText: 'Your ground has been added successfully. Please wait for admin approval. Once approved, your ground will be activated.',
        middleTextStyle: const TextStyle(fontSize: 14),
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () => Get.back(),
      );
    } else {
      AppUtils.showSuccess(message: message);
    }
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
               Text('Adding to: $_complexName', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildSectionHeader('Basic Information', Icons.info_outline),
            _textField(_nameCtrl, 'Ground Name', Icons.sports_cricket),
            const SizedBox(height: 12),
            AddressAutocompleteField(
              controller: _locationCtrl,
              hintText: 'Location',
              prefixIcon: Icons.location_on_outlined,
              latController: _latCtrl,
              lngController: _lngCtrl,
            ),
            const SizedBox(height: 12),
            _textField(_dimensionsCtrl, 'Dimensions', Icons.square_foot),
            const SizedBox(height: 16),
            _buildSectionHeader('Pricing & Availability', Icons.attach_money),
            _textField(_priceController, 'Price per Hour', Icons.attach_money, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _textField(_openTimeController, 'Open (08:00)', Icons.access_time)),
                const SizedBox(width: 12),
                Expanded(child: _textField(_closeTimeController, 'Close (22:00)', Icons.access_time)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Sport & Amenities', Icons.sports_soccer),
            _buildSportGrid(),
            const SizedBox(height: 12),
            _buildAmenitiesGrid(),
            const SizedBox(height: 24),
            AppButton(label: 'Submit', onPressed: _submit, isLoading: _isSubmitting),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectComplexStep() {
    final controller = Get.put(GroundsController());
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.complexes.isEmpty) return const Center(child: Text('No complexes found. Add a complex first.'));
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.complexes.length,
        itemBuilder: (context, index) {
          final c = controller.complexes[index];
          final bool isActive = c.status == 'active' || c.status == '1' || c.status == 1;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'APPROVAL PENDING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: isActive 
                ? const Icon(Icons.arrow_forward_ios, size: 14) 
                : const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
              onTap: isActive ? () => setState(() {
                _complexId = c.id;
                _complexName = c.name;
              }) : () {
                AppUtils.showError(
                  title: 'Complex Not Approved',
                  message: 'You can only add grounds to complexes that have been approved by the admin.',
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

  Widget _textField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType}) => TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  Widget _buildSportGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2),
    itemCount: _sportConfigs.length,
    itemBuilder: (context, index) {
      final s = _sportConfigs[index];
      final isSelected = _selectedSports.contains(s['name']);
      return FilterChip(
        label: Text(s['name']!),
        selected: isSelected,
        onSelected: (v) => setState(() => v ? _selectedSports.add(s['name']!) : _selectedSports.remove(s['name']!)),
      );
    },
  );

  Widget _buildAmenitiesGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2),
    itemCount: _groundAmenitiesConfig.length,
    itemBuilder: (context, index) {
      final a = _groundAmenitiesConfig[index];
      final isSelected = _selectedAmenities.contains(a['id']);
      return FilterChip(
        label: Text(a['name']!),
        selected: isSelected,
        onSelected: (v) => setState(() => v ? _selectedAmenities.add(a['id']!) : _selectedAmenities.remove(a['id']!)),
      );
    },
  );

  Widget _buildImagePicker() => Wrap(
    spacing: 8,
    children: [
      ActionButton(icon: Icons.add_a_photo, label: 'Pick Images', onTap: _pickImage),
      ..._existingUrls.map((url) => Image.network(url, width: 60, height: 60, fit: BoxFit.cover)),
      ..._pickedImages.map((file) => Image.file(File(file.path), width: 60, height: 60, fit: BoxFit.cover)),
    ],
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _priceController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descCtrl.dispose();
    _dimensionsCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ActionButton({super.key, required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)]),
      ),
    );
  }
}
