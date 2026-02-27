import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/owner/controller/grounds_controller.dart';
import 'package:sports_studio/widgets/app_button.dart';

class OwnerDealsPage extends StatefulWidget {
  const OwnerDealsPage({super.key});

  @override
  State<OwnerDealsPage> createState() => _OwnerDealsPageState();
}

class _OwnerDealsPageState extends State<OwnerDealsPage> {
  bool _isLoading = true;
  List<dynamic> _deals = [];

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/public/deals');
      if (res.statusCode == 200) {
        setState(() => _deals = res.data is List ? res.data : []);
      }
    } catch (_) {
      // Show empty if API fails
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDeal(dynamic deal) async {
    final id = deal['id'];
    Get.defaultDialog(
      title: 'Delete Deal?',
      middleText: 'This will permanently remove "${deal['title']}".',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          final res = await ApiClient().dio.delete('/deals/$id');
          if (res.statusCode == 200 || res.statusCode == 204) {
            setState(() => _deals.removeWhere((d) => d['id'] == id));
            Get.snackbar('Deleted', 'Deal removed successfully');
          }
        } catch (_) {
          Get.snackbar('Error', 'Failed to delete deal');
        }
      },
    );
  }

  void _openForm({dynamic deal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DealFormSheet(deal: deal, onSuccess: _fetchDeals),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Deals'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Add Deal',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _deals.isEmpty ? _emptyState() : _buildList(),
              ),
            ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: _deals.length,
      itemBuilder: (ctx, i) {
        final deal = _deals[i];
        final discount = deal['discount_percentage'];
        final code = deal['code'] ?? '';
        final validUntil = deal['valid_until'] ?? '';
        final groundName = deal['ground']?['name'];

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount badge circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$discount%',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deal['title'] ?? 'Deal',
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.green,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (groundName != null)
                      Text(
                        'For: $groundName',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Until $validUntil',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (code.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CODE: $code',
                          style: AppTextStyles.label.copyWith(
                            letterSpacing: 2,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openForm(deal: deal),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _deleteDeal(deal),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_offer_outlined,
          size: 72,
          color: AppColors.textMuted.withValues(alpha: 0.4),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('No deals yet', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Create a deal to attract more players',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add First Deal'),
        ),
      ],
    ),
  );
}

// ── Deal Form Bottom Sheet ─────────────────────────────────────────────────────
class _DealFormSheet extends StatefulWidget {
  final dynamic deal;
  final VoidCallback onSuccess;
  const _DealFormSheet({this.deal, required this.onSuccess});

  @override
  State<_DealFormSheet> createState() => _DealFormSheetState();
}

class _DealFormSheetState extends State<_DealFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  int? _selectedGroundId;
  bool _isSaving = false;

  bool get _isEdit => widget.deal != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.deal;
      _titleCtrl.text = d['title'] ?? '';
      _descCtrl.text = d['description'] ?? '';
      _discountCtrl.text = d['discount_percentage']?.toString() ?? '';
      _codeCtrl.text = d['code'] ?? '';
      _dateCtrl.text = (d['valid_until'] ?? '').toString().split('T')[0];
      _selectedGroundId = d['ground_id'];
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty ||
        _discountCtrl.text.isEmpty ||
        _dateCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'title': _titleCtrl.text,
        'description': _descCtrl.text,
        'discount_percentage': double.tryParse(_discountCtrl.text) ?? 0,
        'code': _codeCtrl.text,
        'valid_until': _dateCtrl.text,
        if (_selectedGroundId != null) 'ground_id': _selectedGroundId,
      };

      final id = widget.deal?['id'];
      final res = _isEdit
          ? await ApiClient().dio.put('/deals/$id', data: data)
          : await ApiClient().dio.post('/deals', data: data);

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back();
        widget.onSuccess();
        Get.snackbar('Success', _isEdit ? 'Deal updated' : 'Deal created');
      } else {
        Get.snackbar('Error', 'Failed to save deal');
      }
    } catch (_) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groundsCtrl = Get.put(GroundsController());
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? 'Edit Deal' : 'Create New Deal',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Deal Title *'),
                    _field(
                      _titleCtrl,
                      'e.g. Weekend Special',
                      icon: Icons.label_outline,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _label('Target Ground (Optional)'),
                    Obx(
                      () => DropdownButtonFormField<int>(
                        value: _selectedGroundId,
                        hint: const Text('All Grounds'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.sports_cricket_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Grounds'),
                          ),
                          ...groundsCtrl.grounds.map(
                            (g) => DropdownMenuItem<int>(
                              value: g.id,
                              child: Text(g.name),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedGroundId = val),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _label('Discount Percentage *'),
                    _field(
                      _discountCtrl,
                      '20',
                      icon: Icons.percent,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _label('Valid Until *'),
                    GestureDetector(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 7),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (p != null)
                          _dateCtrl.text = DateFormat('yyyy-MM-dd').format(p);
                      },
                      child: AbsorbPointer(
                        child: _field(
                          _dateCtrl,
                          'Pick a date',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _label('Promo Code (Optional)'),
                    _field(
                      _codeCtrl,
                      'SUMMER2026',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _label('Description (Optional)'),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Details about this offer...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      label: _isEdit ? 'Update Deal' : 'Create Deal',
                      onPressed: _save,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: AppSpacing.l),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    IconData? icon,
    TextInputType? type,
  }) => TextField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
