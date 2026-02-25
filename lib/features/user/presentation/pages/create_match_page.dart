import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
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
  final _feeCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '22');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  String _selectedSport = 'Cricket';
  bool _isSubmitting = false;

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

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
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
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final data = {
        'name': _titleCtrl.text,
        'description': _descCtrl.text,
        'start_time': '$dateStr $timeStr',
        'game_id': 1, // Default game ID for now
        'ground_id': _selectedGround['id'],
        'registration_fee': double.tryParse(_feeCtrl.text) ?? 0,
        'max_participants': int.tryParse(_limitCtrl.text) ?? 22,
        'status': 'published',
        'event_type': 'public',
      };

      final res = await ApiClient().dio.post('/events', data: data);

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Match organized successfully!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        Get.back(result: true);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organize Match'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Select Ground *', Icons.map_outlined),
                const SizedBox(height: AppSpacing.m),
                _buildGroundSelector(),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Match Details', Icons.sports_outlined),
                const SizedBox(height: AppSpacing.m),

                _lbl('Match Title *'),
                _textField(
                  _titleCtrl,
                  'e.g. Sunday Morning Friendly',
                  Icons.title,
                ),

                const SizedBox(height: AppSpacing.m),
                _lbl('Sport Category'),
                _sportDropdown(),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Schedule', Icons.calendar_today_outlined),
                const SizedBox(height: AppSpacing.m),

                Row(
                  children: [
                    Expanded(
                      child: _pickerTile(
                        'Date',
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        Icons.calendar_month,
                        _selectDate,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: _pickerTile(
                        'Time',
                        _selectedTime.format(context),
                        Icons.access_time,
                        _selectTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Participation', Icons.people_outline),
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
                          _lbl('Entry Fee (Optional)'),
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

                const SizedBox(height: AppSpacing.l),
                _sectionHeader('Description', Icons.description_outlined),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Add match rules, requirements or any other info...',
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
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Organize Now',
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
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rs. ${ground['price_per_hour']}/hr',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
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
      initialValue: _selectedSport,
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
}
