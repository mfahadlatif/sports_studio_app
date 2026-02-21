import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';

class SportsComplexesPage extends StatefulWidget {
  const SportsComplexesPage({super.key});

  @override
  State<SportsComplexesPage> createState() => _SportsComplexesPageState();
}

class _SportsComplexesPageState extends State<SportsComplexesPage> {
  bool _isLoading = true;
  List<dynamic> _complexes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchComplexes();
  }

  Future<void> _fetchComplexes() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/complexes');
      if (res.statusCode == 200) {
        final data = res.data['data'] ?? res.data;
        setState(() => _complexes = data is List ? data : []);
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComplex(dynamic complex) async {
    Get.defaultDialog(
      title: 'Delete Complex?',
      middleText: 'Remove "${complex['name']}" and all its grounds?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          final res = await ApiClient().dio.delete(
            '/complexes/${complex['id']}',
          );
          if (res.statusCode == 200 || res.statusCode == 204) {
            setState(
              () => _complexes.removeWhere((c) => c['id'] == complex['id']),
            );
            Get.snackbar('Deleted', 'Complex removed');
          }
        } catch (_) {
          Get.snackbar('Error', 'Failed to delete');
        }
      },
    );
  }

  void _openForm({dynamic complex}) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _ComplexFormSheet(complex: complex, onSuccess: _fetchComplexes),
  );

  List<dynamic> get _filtered => _complexes
      .where(
        (c) =>
            (c['name'] ?? '').toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (c['address'] ?? '').toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Complexes'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: Text(
              'Add',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search complexes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: _filtered.isEmpty
                          ? _emptyState()
                          : RefreshIndicator(
                              onRefresh: _fetchComplexes,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.m,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (ctx, i) =>
                                    _complexCard(_filtered[i]),
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _complexCard(dynamic complex) {
    final groundCount =
        complex['grounds_count'] ?? (complex['grounds'] as List?)?.length ?? 0;
    final status = complex['status'] ?? 'active';
    final isActive = status == 'active' || status == 1;

    return GestureDetector(
      onTap: () =>
          Get.toNamed('/complex-detail', arguments: {'id': complex['id']}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.4),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complex['name'] ?? 'Complex',
                          style: AppTextStyles.h3,
                        ),
                        if ((complex['address'] ?? '').isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  complex['address'],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.sports_cricket_outlined,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$groundCount grounds',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: AppTextStyles.label.copyWith(
                                  color: isActive ? Colors.green : Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _openForm(complex: complex),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        onPressed: () => _deleteComplex(complex),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.business_outlined,
          size: 72,
          color: AppColors.textMuted.withOpacity(0.4),
        ),
        const SizedBox(height: AppSpacing.m),
        Text('No complexes yet', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.l),
        ElevatedButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Complex'),
        ),
      ],
    ),
  );
}

// ─── Form Sheet ───────────────────────────────────────────────────────────────
class _ComplexFormSheet extends StatefulWidget {
  final dynamic complex;
  final VoidCallback onSuccess;
  const _ComplexFormSheet({this.complex, required this.onSuccess});

  @override
  State<_ComplexFormSheet> createState() => _ComplexFormSheetState();
}

class _ComplexFormSheetState extends State<_ComplexFormSheet> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSaving = false;

  bool get _isEdit => widget.complex != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text = widget.complex['name'] ?? '';
      _addressCtrl.text = widget.complex['address'] ?? '';
      _descCtrl.text = widget.complex['description'] ?? '';
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Name and address are required');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameCtrl.text,
        'address': _addressCtrl.text,
        'description': _descCtrl.text,
      };
      final id = widget.complex?['id'];
      final res = _isEdit
          ? await ApiClient().dio.put('/complexes/$id', data: data)
          : await ApiClient().dio.post('/complexes', data: data);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back();
        widget.onSuccess();
        Get.snackbar(
          'Success',
          _isEdit ? 'Complex updated' : 'Complex created',
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s),
    child: Text(t, style: AppTextStyles.label),
  );
  Widget _fld(TextEditingController c, String hint, IconData icon) => TextField(
    controller: c,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                _isEdit ? 'Edit Complex' : 'Add Sports Complex',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.l),
              _lbl('Complex Name *'),
              _fld(
                _nameCtrl,
                'e.g. Star Sports Complex',
                Icons.business_outlined,
              ),
              const SizedBox(height: AppSpacing.m),
              _lbl('Address *'),
              _fld(
                _addressCtrl,
                'e.g. Gulberg, Lahore',
                Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.m),
              _lbl('Description'),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe your facility...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEdit ? 'Update Complex' : 'Create Complex',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
