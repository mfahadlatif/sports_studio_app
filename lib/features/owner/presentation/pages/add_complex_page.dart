import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_form;

class AddComplexPage extends StatefulWidget {
  const AddComplexPage({super.key});

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
  String _selectedStatus = 'active';

  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill name and address',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> dataMap = {
        'name': _nameCtrl.text,
        'address': _addressCtrl.text,
        'description': _descCtrl.text,
        'status': _selectedStatus,
        'latitude': _latCtrl.text,
        'longitude': _lngCtrl.text,
        'amenities': _selectedAmenities.toList(),
      };

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);

      // Add images
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
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Complex created successfully!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create complex');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Sports Complex'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),

                _sectionHeader('Basic Details', Icons.business_outlined),
                const SizedBox(height: AppSpacing.m),

                _lbl('Complex Name *'),
                _textField(
                  _nameCtrl,
                  'e.g. Model Town Sports Arena',
                  Icons.business,
                ),
                const SizedBox(height: AppSpacing.m),

                _lbl('Location / Address *'),
                _textField(
                  _addressCtrl,
                  'e.g. Phase 5, DHA, Lahore',
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: AppSpacing.m),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lbl('Latitude'),
                          _textField(
                            _latCtrl,
                            '31.5204',
                            Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lbl('Longitude'),
                          _textField(
                            _lngCtrl,
                            '74.3587',
                            Icons.explore_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),

                _sectionHeader(
                  'Status & Visibility',
                  Icons.visibility_outlined,
                ),
                const SizedBox(height: AppSpacing.m),
                _buildStatusSection(),
                const SizedBox(height: AppSpacing.l),

                _sectionHeader('Media & Images', Icons.image_outlined),
                const SizedBox(height: AppSpacing.m),
                _buildImageSection(),
                const SizedBox(height: AppSpacing.l),

                _sectionHeader('Facilities & Amenities', Icons.auto_awesome),
                const SizedBox(height: AppSpacing.m),
                _lbl('Select available facilities'),
                _buildAmenitiesGrid(),
                const SizedBox(height: AppSpacing.l),

                _sectionHeader('About Facility', Icons.description_outlined),
                const SizedBox(height: AppSpacing.m),

                _lbl('Description'),
                TextField(
                  controller: _descCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tell players more about your facility...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
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
                              Text('Creating...'),
                            ],
                          )
                        : Text(
                            'Register Complex',
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

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _selectedStatus == 'active'
                    ? Icons.check_circle
                    : Icons.pause_circle_filled,
                color: _selectedStatus == 'active'
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${_selectedStatus.capitalizeFirst}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _selectedStatus == 'active'
                        ? 'Visible to all players'
                        : 'Hidden from listings',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _selectedStatus == 'active',
            onChanged: (v) =>
                setState(() => _selectedStatus = v ? 'active' : 'inactive'),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  _pickedImages.isEmpty
                      ? 'Tap to upload complex photos'
                      : '${_pickedImages.length} images selected',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_pickedImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_pickedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 10,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _pickedImages.removeAt(index)),
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
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
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
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(facility['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    facility['name']!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Register Your Facility',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'List your sports complex to start managing grounds and bookings.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
