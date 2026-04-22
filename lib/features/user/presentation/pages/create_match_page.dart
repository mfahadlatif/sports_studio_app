import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sport_studio/core/controllers/system_settings_controller.dart';
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/core/network/api_client.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';
import 'package:sport_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sport_studio/widgets/app_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_studio/core/utils/url_helper.dart';
import 'package:sport_studio/widgets/app_progress_indicator.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/owner/controller/bookings_controller.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '0');
  final _limitCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 20, minute: 0);
  String _eventType = 'public';
  final _rulesCtrl = TextEditingController();
  final _safetyCtrl = TextEditingController();

  final List<Map<String, TextEditingController>> _scheduleControllers = [];
  bool _isSubmitting = false;

  final List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  List<dynamic> _grounds = [];
  dynamic _selectedGround;
  bool _isLoadingGrounds = true;

  // Track validation errors (matching website)
  final Map<String, bool> _errors = {};

  // Booking linkage (matching website's selectedBooking state)
  dynamic _selectedBooking;
  final BookingsController _bookingsController = Get.put(BookingsController());

  @override
  void initState() {
    super.initState();
    _fetchGrounds();
    _bookingsController.fetchBookings();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
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
      setState(() {
        _pickedImages.addAll(images);
        _errors.remove('images');
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _selectedTime : _selectedEndTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedTime = picked;
        } else {
          _selectedEndTime = picked;
        }
        _errors.remove('time');
        _errors.remove('endTime');
      });
    }
  }

  // Validate exactly like the website's handleSubmit
  bool _validate() {
    bool isValid = true;
    final newErrors = <String, bool>{};

    if (_titleCtrl.text.trim().isEmpty) {
      newErrors['name'] = true;
      AppUtils.showError(
        message: 'Event name is required. Please enter a catchy title.',
      );
      isValid = false;
    }

    if (isValid && _pickedImages.isEmpty) {
      newErrors['images'] = true;
      AppUtils.showError(
        message: 'Event image is required. Please upload at least one image.',
      );
      isValid = false;
    }

    if (isValid && _selectedGround == null) {
      newErrors['ground'] = true;
      AppUtils.showError(
        message:
            'Venue selection required. Please select a ground via a booking.',
      );
      isValid = false;
    }

    // Time validation (only when no booking locked)
    if (_selectedBooking == null) {
      final startMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
      final endMinutes = _selectedEndTime.hour * 60 + _selectedEndTime.minute;

      if (isValid && endMinutes <= startMinutes) {
        newErrors['endTime'] = true;
        AppUtils.showError(message: 'End time must be after the start time.');
        isValid = false;
      }
    }

    // registration fee
    final fee = double.tryParse(_feeCtrl.text);
    if (isValid && (fee == null || fee < 0)) {
      newErrors['registrationFee'] = true;
      AppUtils.showError(
        message:
            'Invalid registration fee. Please set a valid fee (0 for free).',
      );
      isValid = false;
    }

    // max participants
    final maxP = int.tryParse(_limitCtrl.text);
    if (isValid && (maxP == null || maxP <= 0)) {
      newErrors['maxParticipants'] = true;
      AppUtils.showError(
        message: 'Invalid participant count. Please set a valid maximum.',
      );
      isValid = false;
    } else if (isValid && _selectedGround != null) {
      final groundCap = _selectedGround['max_participants'];
      if (groundCap != null && maxP != null && maxP > (groundCap as num)) {
        newErrors['maxParticipants'] = true;
        AppUtils.showError(
          message:
              'Capacity exceeded. The maximum capacity for ${_selectedGround['name']} is $groundCap people.',
        );
        isValid = false;
      }
    }

    setState(() {
      _errors.clear();
      _errors.addAll(newErrors);
    });

    return isValid;
  }

  void _handleSubmit() {
    if (!_validate()) return;

    // Show confirm dialog (matching website's ConfirmDialog)
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create Event?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to create this event? It will be published according to your privacy settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Discard Changes'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _submit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final profileController = Get.find<ProfileController>();
    if (!profileController.isPhoneVerified) {
      Get.dialog(
        PhoneVerificationDialog(
          initialPhone:
              profileController.userProfile['phone']?.toString() ?? '',
          onVerified: () {
            profileController.fetchProfile();
          },
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
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
        'start_time': '$dateStr $timeStr',
        'end_time': '$dateStr $endTimeStr',
        'ground_id': _selectedGround?['id'],
        'booking_id': _selectedBooking?['id'],
        'registration_fee': double.tryParse(_feeCtrl.text) ?? 0,
        'max_participants': int.tryParse(_limitCtrl.text) ?? 40,
        'rules': _rulesCtrl.text.trim(),
        'safety_policy': _safetyCtrl.text.trim(),
        'schedule': scheduleData.isEmpty ? '[]' : jsonEncode(scheduleData),
        'status': 'upcoming',
        'event_type': _eventType,
        'sport_category': _selectedGround?['type'] ?? null,
      };

      dio_form.FormData formData = dio_form.FormData.fromMap(dataMap);
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

      final res = await ApiClient().dio.post('/events', data: formData);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.find<ProfileController>().hasOrganizedEvents.value = true;
        Get.back(result: true);
        AppUtils.showSuccess(message: 'Event created successfully!');
      }
    } catch (e) {
      String msg = 'Something went wrong';
      if (e is dio_form.DioException) {
        final errorData = e.response?.data;
        if (errorData is Map) {
          if (errorData['errors'] is Map &&
              (errorData['errors'] as Map).isNotEmpty) {
            msg = (errorData['errors'] as Map).values.first[0].toString();
          } else {
            msg = errorData['message'] ?? e.message ?? msg;
          }
        }
      }
      AppUtils.showError(message: msg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Create New Event'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Event',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Set up your tournament or event',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SECTION 1: Event Details ──────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Event Details',
                        Icons.emoji_events_outlined,
                      ),
                      const SizedBox(height: 20),
                      _lbl('Event Name *'),
                      _textField(
                        _titleCtrl,
                        'e.g., Weekend Football League',
                        Icons.title,
                        hasError: _errors['name'] == true,
                      ),
                      const SizedBox(height: 16),
                      _lbl('Description'),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText:
                              'Describe your event, rules, and what participants can expect...',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SECTION 2: Select Your Secured Booking ────────────
                _card(
                  hasError: _errors['ground'] == true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Select Your Secured Booking *',
                        Icons.calendar_today_outlined,
                        hasError: _errors['ground'] == true,
                      ),
                      const SizedBox(height: 20),
                      _buildBookingSelection(),
                    ],
                  ),
                ),

                // ── SECTION 3: Event Access & Privacy ────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Event Access & Privacy',
                        Icons.people_outline,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          _privacyCard(
                            'public',
                            'Public Event',
                            'Visible to all users in exploration tools.',
                          ),
                          const SizedBox(height: 10),
                          _privacyCard(
                            'private',
                            'Private Event',
                            'Hidden from exploration. Share link to invite.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── SECTION 4: Images ─────────────────────────────────
                _card(
                  hasError: _errors['images'] == true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Event Images & Gallery *',
                        Icons.perm_media_outlined,
                      ),
                      const SizedBox(height: 20),
                      _buildImagePicker(),
                    ],
                  ),
                ),

                // ── SECTION 5: Venue Details ──────────────────────────
                _card(
                  tinted: _selectedBooking != null,
                  hasError: _errors['ground'] == true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: _errors['ground'] == true
                                ? Colors.red
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Venue Details *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _errors['ground'] == true
                                    ? Colors.red
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_selectedBooking != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Locked to Booking',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_selectedGround != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: UrlHelper.sanitizeUrl(
                                    (_selectedGround['images'] as List?)?.first,
                                  ),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    color: const Color(0xFFE2E8F0),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedGround['name'] ?? 'Ground',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedGround['complex']?['address'] ??
                                          _selectedGround['location'] ??
                                          'Location TBD',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'Select your booking above to lock the venue.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                // ── SECTION 6: Event Timing ───────────────────────────
                Opacity(
                  opacity: _selectedBooking != null ? 0.7 : 1.0,
                  child: IgnorePointer(
                    ignoring: _selectedBooking != null,
                    child: _card(
                      tinted: _selectedBooking != null,
                      hasError:
                          _errors['time'] == true ||
                          _errors['endTime'] == true ||
                          _errors['date'] == true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color:
                                    (_errors['time'] == true ||
                                        _errors['endTime'] == true)
                                    ? Colors.red
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Event Timing *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        (_errors['time'] == true ||
                                            _errors['endTime'] == true)
                                        ? Colors.red
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_selectedBooking != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF64748B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Locked to Booking',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // DATE — full width (date string is long)
                          _timingBox(
                            'DATE',
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            Icons.calendar_today,
                            _selectDate,
                            hasError: _errors['date'] == true,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 8),
                          // START and END — share a row (time values are short)
                          Row(
                            children: [
                              Expanded(
                                child: _timingBox(
                                  'START TIME',
                                  _formatTimeOfDay(_selectedTime),
                                  Icons.access_time,
                                  () => _selectTime(true),
                                  hasError: _errors['time'] == true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _timingBox(
                                  'END TIME',
                                  _formatTimeOfDay(_selectedEndTime),
                                  Icons.access_time_filled,
                                  () => _selectTime(false),
                                  hasError: _errors['endTime'] == true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── SECTION 7: Registration Settings ─────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Registration Settings *',
                        Icons.group_outlined,
                      ),
                      const SizedBox(height: 20),
                      // Registration Fee (full width)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _lbl(
                            'Registration Fee (${AppConstants.currencySymbol})',
                          ),
                          Obx(() {
                            final settings =
                                Get.find<SystemSettingsController>();
                            return Text(
                              'Admin Commission: ${settings.eventCommissionRate.toStringAsFixed(0)}%',
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
                        _feeCtrl,
                        '50',
                        Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        hasError: _errors['registrationFee'] == true,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Max Participants (full width)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Max Participants',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (_selectedGround?['max_participants'] != null)
                            Text(
                              'Ground Capacity: ${_selectedGround['max_participants']}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _textField(
                        _limitCtrl,
                        _selectedGround?['max_participants']?.toString() ??
                            '40',
                        Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                        hasError: _errors['maxParticipants'] == true,
                      ),
                      if (_selectedGround?['max_participants'] != null) ...{
                        Builder(
                          builder: (_) {
                            final maxP = int.tryParse(_limitCtrl.text) ?? 0;
                            final cap =
                                (_selectedGround['max_participants'] as num)
                                    .toInt();
                            if (maxP > cap) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Exceeds ground capacity of $cap',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      },
                      const SizedBox(height: 20),

                      // Net Earning card (matching website's slate-50 bg card)
                      Obx(() {
                        final commissionRate =
                            Get.find<SystemSettingsController>()
                                .eventCommissionRate;
                        final regFee = double.tryParse(_feeCtrl.text) ?? 0.0;
                        final platformFee = (regFee * commissionRate) / 100;
                        final netEarning = regFee - platformFee;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Platform Commission',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(
                                        0.05,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '${commissionRate.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: Color(0xFFE2E8F0),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your Net Earning',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const Text(
                                        'Per Participant',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${AppConstants.currencySymbol} ${netEarning.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                      Text(
                                        'Fee: ${AppConstants.currencySymbol} ${platformFee.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Payout Notice (matching website's orange box)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFF97316),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Payout Notice: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9A3412),
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'Registration funds are credited to your wallet 24 hours after the event ends. You can then withdraw them to your linked bank account.',
                                      style: TextStyle(
                                        color: Color(0xFF9A3412),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SECTION 8: Rules & Safety ─────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Rules & Safety', Icons.info_outline),
                      const SizedBox(height: 20),
                      _lbl('Event Rules'),
                      TextField(
                        controller: _rulesCtrl,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _textAreaDecoration(
                          'List tournament rules, equipment requirements, etc.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _lbl('Safety Policy'),
                      TextField(
                        controller: _safetyCtrl,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _textAreaDecoration(
                          'Emergency protocols, first aid info...',
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SECTION 9: Event Schedule ─────────────────────────
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        'Event Schedule',
                        Icons.access_time_outlined,
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        _scheduleControllers.length,
                        (idx) => _buildScheduleRow(idx),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _scheduleControllers.add({
                              'time': TextEditingController(),
                              'title': TextEditingController(),
                              'desc': TextEditingController(),
                            });
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Schedule Item'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            style: BorderStyle.solid,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Actions ───────────────────────────────────────────
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Discard Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Create Event',
                        onPressed: _handleSubmit,
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // HELPERS & WIDGETS
  // ──────────────────────────────────────────────────────────────

  /// Card wrapper matching website's `rounded-2xl bg-card border p-6 shadow-sm`
  Widget _card({
    required Widget child,
    bool tinted = false,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tinted ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasError
              ? Colors.red.withValues(alpha: 0.5)
              : const Color(0xFFE2E8F0),
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon, {bool hasError = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: hasError ? Colors.red : AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: hasError ? Colors.red : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) => TextField(
    controller: ctrl,
    keyboardType: keyboardType,
    textCapitalization:
        (keyboardType == TextInputType.emailAddress ||
            keyboardType == TextInputType.visiblePassword ||
            keyboardType == TextInputType.number ||
            keyboardType == TextInputType.phone)
        ? TextCapitalization.none
        : TextCapitalization.sentences,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : AppColors.primary,
          width: 1.5,
        ),
      ),
    ),
  );

  InputDecoration _textAreaDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
  );

  Widget _privacyCard(String value, String title, String subtitle) {
    final isSelected = _eventType == value;
    return GestureDetector(
      onTap: () => setState(() => _eventType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 1, right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timingBox(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap, {
    bool hasError = false,
    bool fullWidth = false,
  }) {
    final bgColor = hasError
        ? Colors.red.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final labelColor = hasError ? Colors.red : const Color(0xFF94A3B8);
    final iconColor = hasError ? Colors.red : AppColors.primary;
    final valueColor = hasError ? Colors.red : AppColors.textPrimary;
    final borderColor = hasError
        ? Colors.red.withValues(alpha: 0.5)
        : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: fullWidth
            ? Row(
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: labelColor,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(icon, size: 13, color: iconColor),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _errors['images'] == true
                    ? Colors.red.withValues(alpha: 0.5)
                    : const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 28,
                  color: _errors['images'] == true
                      ? Colors.red
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add Media',
                  style: TextStyle(
                    fontSize: 11,
                    color: _errors['images'] == true
                        ? Colors.red
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'SUPPORTED: JPG, PNG, MP4, WEBM (MAX 50MB) • FIRST FILE WILL BE FEATURED',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        if (_pickedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
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
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_pickedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 10,
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

  /// Mirrors the website's booking selection list exactly
  Widget _buildBookingSelection() {
    return Obx(() {
      if (_bookingsController.isLoading.value) {
        return const Center(child: AppProgressIndicator());
      }

      // Match website filter: (confirmed OR pending) AND no event AND in the future
      final now = DateTime.now();
      final availableBookings = _bookingsController.allData.where((b) {
        if (b['type'] != 'ground') return false;
        final status = b['status']?.toString() ?? '';
        if (status != 'confirmed' && status != 'pending') return false;
        if (b['event'] != null) return false;
        final endTime = DateTime.tryParse(b['end']?.toString() ?? '');
        if (endTime == null || endTime.isBefore(now)) return false;
        return true;
      }).toList();

      if (availableBookings.isEmpty) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "You don't have any confirmed ground bookings to host an event on.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/explore-grounds'),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Book a Ground first'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return Column(
        children: availableBookings.map((b) {
          final isSelected =
              _selectedBooking != null && _selectedBooking['id'] == b['id'];
          final startTime =
              DateTime.tryParse(b['start']?.toString() ?? '') ?? DateTime.now();
          final endTime =
              DateTime.tryParse(b['end']?.toString() ?? '') ?? DateTime.now();
          final isPaid = b['payment_status']?.toString() == 'paid';

          final dateStr = DateFormat('M/d/yyyy').format(startTime);
          final startStr = DateFormat('hh:mm a').format(startTime);
          final endStr = DateFormat('hh:mm a').format(endTime);

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedBooking = null;
                      _selectedGround = null;
                    } else {
                      _selectedBooking = b;
                      _selectedGround = b['ground'];
                      _selectedDate = startTime;
                      _selectedTime = TimeOfDay.fromDateTime(startTime);
                      _selectedEndTime = TimeOfDay.fromDateTime(endTime);
                      // Auto-fill max participants from ground capacity
                      if (b['ground']?['max_participants'] != null &&
                          _limitCtrl.text.isEmpty) {
                        _limitCtrl.text = b['ground']['max_participants']
                            .toString();
                      }
                      _errors.remove('ground');
                    }
                  });
                  if (_selectedBooking != null) {
                    AppUtils.showSuccess(
                      message: 'Venue and time locked to booking #${b['id']}',
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  b['ground']?['name'] ??
                                      b['display_name'] ??
                                      'Ground',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    '${AppConstants.currencySymbol} ${(b['price'] ?? 0).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$dateStr @ $startStr - $endStr',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Payment status badge (matching website exactly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPaid
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFCA5A5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPaid
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              size: 12,
                              color: isPaid
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPaid ? 'Paid' : 'Unpaid',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPaid
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Unpaid warning with "Complete Payment" (matching website exactly)
              if (isSelected && !isPaid)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ground fee of ${AppConstants.currencySymbol} ${(b['price'] ?? 0).toStringAsFixed(0)} is unpaid.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final id = b['id'];
                          final price = (b['price'] ?? b['total_price'] ?? 0);
                          Get.toNamed(
                            '/payment',
                            arguments: {
                              'bookingId': id is int
                                  ? id
                                  : int.tryParse(id.toString()),
                              'subtotal': price is double
                                  ? price
                                  : double.tryParse(price.toString()) ?? 0.0,
                              'totalPrice': price is double
                                  ? price
                                  : double.tryParse(price.toString()) ?? 0.0,
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Complete Payment',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildScheduleRow(int index) {
    final s = _scheduleControllers[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() => _scheduleControllers.removeAt(index)),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          // Time field (full width)
          const Text(
            'Time',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          _textField(s['time']!, 'e.g., 2:30 PM', Icons.access_time),
          const SizedBox(height: 10),

          // Title field (full width)
          const Text(
            'Title',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          _textField(s['title']!, 'e.g., Match 1', Icons.title),
          const SizedBox(height: 10),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          _textField(
            s['desc']!,
            'Short description...',
            Icons.description_outlined,
          ),
        ],
      ),
    );
  }
}
