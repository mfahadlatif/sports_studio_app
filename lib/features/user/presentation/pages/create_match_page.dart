import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sports_studio/core/utils/url_helper.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '22');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 20, minute: 0);
  String _selectedSport = 'Cricket';
  String _eventType = 'public';
  final _rulesCtrl = TextEditingController();
  final _safetyCtrl = TextEditingController();

  // Basic schedule support
  List<Map<String, TextEditingController>> _scheduleControllers = [];
  bool _isSubmitting = false;

  List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _sportTypes = [
    'Cricket',
    'Football',
    'Tennis',
    'Badminton',
    'Basketball',
    'Volleyball',
  ];

  List<dynamic> _grounds = [];
  dynamic _selectedGround;
  bool _isLoadingGrounds = true;

  @override
  void initState() {
    super.initState();
    _fetchGrounds();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _feeCtrl.dispose();
    _limitCtrl.dispose();
    _rulesCtrl.dispose();
    _safetyCtrl.dispose();
    for (var s in _scheduleControllers) {
      s['time']?.dispose();
      s['title']?.dispose();
      s['desc']?.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchGrounds() async {
    setState(() => _isLoadingGrounds = true);
    try {
      final res = await ApiClient().dio.get('/public/grounds');
      if (res.statusCode == 200) {
        setState(() {
          _grounds = List<dynamic>.from(res.data['data'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching grounds: $e');
    } finally {
      setState(() => _isLoadingGrounds = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _selectedTime : _selectedEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a match title');
      return;
    }

    if (_selectedGround == null) {
      Get.snackbar('Error', 'Please select a ground');
      return;
    }

    // Check Phone Verification
    final profileController = Get.find<ProfileController>();
    final isVerified =
        profileController.userProfile['is_phone_verified'] ?? false;

    if (!isVerified) {
      Get.dialog(
        PhoneVerificationDialog(
          initialPhone:
              profileController.userProfile['phone']?.toString() ?? '',
          onVerified: () {
            // Profile refreshed, user can retry
          },
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    print('Starting match submission...');
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeStr =
          '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}:00';

      final scheduleData = _scheduleControllers
          .map(
            (s) => {
              'time': s['time']?.text ?? '',
              'title': s['title']?.text ?? '',
              'description': s['desc']?.text ?? '',
            },
          )
          .toList();

      final Map<String, dynamic> dataMap = {
        'name': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'start_time': '$dateStr $timeStr',
        'end_time': '$dateStr $endTimeStr',
        'game_id': 1, // Default game ID
        'ground_id': _selectedGround['id'],
        'registration_fee': double.tryParse(_feeCtrl.text) ?? 0,
        'max_participants': int.tryParse(_limitCtrl.text) ?? 22,
        'rules': _rulesCtrl.text.trim(),
        'safety_policy': _safetyCtrl.text.trim(),
        'schedule': scheduleData.isEmpty ? '[]' : jsonEncode(scheduleData),
        'status': 'published',
        'event_type': _eventType,
      };

      print('Payload: $dataMap');
      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);

      if (_pickedImages.isNotEmpty) {
        for (var i = 0; i < _pickedImages.length; i++) {
          formData.files.add(
            MapEntry(
              'images[]',
              await dio_form.MultipartFile.fromFile(
                _pickedImages[i].path,
                filename: _pickedImages[i].name,
              ),
            ),
          );
        }
      }

      print('Sending POST request to /events...');
      final res = await ApiClient().dio.post('/events', data: formData);
      print('Response: ${res.statusCode} - ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.closeAllSnackbars();
        Get.snackbar(
          'Success',
          'Match organized successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        // Wait longer so user can see the snackbar
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Get.back(result: true);
      }
    } catch (e) {
      print('Submit error: $e');
      String msg = 'Something went wrong';
      if (e is dio_form.DioException) {
        final errorData = e.response?.data;
        if (errorData is Map) {
          if (errorData['errors'] != null && errorData['errors'] is Map) {
            // Extract first validation error
            final errors = errorData['errors'] as Map;
            if (errors.isNotEmpty) {
              msg = errors.values.first[0].toString();
            }
          } else {
            msg = errorData['message'] ?? e.message ?? msg;
          }
        } else {
          msg = e.message ?? msg;
        }
      } else {
        msg = e.toString();
      }
      Get.snackbar(
        'Error',
        'Failed to create event: $msg',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Organize Match'), centerTitle: true),
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

                _sectionHeader('Event Details', Icons.event_outlined),
                const SizedBox(height: AppSpacing.m),

                _lbl('Event Title *'),
                _textField(
                  _titleCtrl,
                  'e.g. Sunday Morning Friendly',
                  Icons.title,
                ),
                const SizedBox(height: AppSpacing.m),
                _lbl('Description'),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Add match description and what players can expect...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _lbl('Location (Optional)'),
                _textField(
                  _locationCtrl,
                  'e.g. Central Park (Leave empty to use Ground location)',
                  Icons.location_on_outlined,
                ),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader(
                  'Select Sport',
                  Icons.sports_basketball_outlined,
                ),
                const SizedBox(height: AppSpacing.m),
                _sportDropdown(),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Event Privacy', Icons.security_outlined),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Public',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Visible to everyone',
                          style: TextStyle(fontSize: 10),
                        ),
                        value: 'public',
                        groupValue: _eventType,
                        onChanged: (v) => setState(() => _eventType = v!),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Private',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Hidden, invite only',
                          style: TextStyle(fontSize: 10),
                        ),
                        value: 'private',
                        groupValue: _eventType,
                        onChanged: (v) => setState(() => _eventType = v!),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Event Images & Gallery', Icons.image_outlined),
                const SizedBox(height: AppSpacing.m),
                _buildImagePicker(),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Select Ground *', Icons.map_outlined),
                const SizedBox(height: AppSpacing.m),
                _buildGroundSelector(),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Date & Time', Icons.calendar_today_outlined),
                const SizedBox(height: AppSpacing.m),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pickerTile(
                      'Match Date',
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      Icons.calendar_month,
                      _selectDate,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(
                          child: _pickerTile(
                            'Start Time',
                            _selectedTime.format(context),
                            Icons.access_time,
                            () => _selectTime(true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: _pickerTile(
                            'End Time',
                            _selectedEndTime.format(context),
                            Icons.access_time_filled,
                            () => _selectTime(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader(
                  'Registration Settings',
                  Icons.settings_outlined,
                ),
                const SizedBox(height: AppSpacing.m),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lbl('Player Limit'),
                          _textField(
                            _limitCtrl,
                            '22',
                            Icons.groups_outlined,
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
                          _lbl('Registration Fee'),
                          _textField(
                            _feeCtrl,
                            '0.00',
                            Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.m),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          'Earnings Notice: A 3% platform fee will be deducted for any paid events.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader(
                  'Rules & Safety',
                  Icons.health_and_safety_outlined,
                ),
                const SizedBox(height: AppSpacing.m),
                _lbl('Event Rules'),
                TextField(
                  controller: _rulesCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. No metal spikes allowed. Bring your own kit...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _lbl('Safety Policy'),
                TextField(
                  controller: _safetyCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. First aid available on site...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader(
                  'Event Agenda (Optional)',
                  Icons.view_timeline_outlined,
                ),
                const SizedBox(height: AppSpacing.m),
                ...List.generate(
                  _scheduleControllers.length,
                  (idx) => _buildScheduleRow(idx),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _scheduleControllers.add({
                        'time': TextEditingController(),
                        'title': TextEditingController(),
                        'desc': TextEditingController(),
                      });
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Agenda Item'),
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: 'Organize Match',
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Host a Match',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Invite other players to join your game at your favorite ground.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: AppColors.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click to upload event images',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Upload multiple photos of the ground or event',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_pickedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(File(_pickedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
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
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroundSelector() {
    if (_isLoadingGrounds) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_grounds.isEmpty) {
      return const Text('No grounds available');
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _grounds.length,
        itemBuilder: (context, index) {
          final ground = _grounds[index];
          final isSelected =
              _selectedGround != null && _selectedGround['id'] == ground['id'];

          final images = ground['images'] as List?;
          final imageUrl = UrlHelper.sanitizeUrl(
            images != null && images.isNotEmpty ? images[0] : null,
          );

          return GestureDetector(
            onTap: () => setState(() => _selectedGround = ground),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected
                    ? AppColors.primary.withOpacity(0.05)
                    : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 60,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_outlined, size: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ground['name'] ?? 'Ground',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rs. ${ground['price_per_hour']}/hr',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Widget _pickerTile(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lbl(label),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(int index) {
    final s = _scheduleControllers[index];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () {
                  setState(() {
                    _scheduleControllers.removeAt(index);
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _textField(s['time']!, 'Time', Icons.access_time),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                flex: 2,
                child: _textField(s['title']!, 'Title', Icons.title),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          _textField(s['desc']!, 'Description', Icons.description_outlined),
        ],
      ),
    );
  }
}
