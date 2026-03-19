import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_button.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  bool _loading = true;
  Map<String, dynamic> _wallet = const {};
  List<dynamic> _walletTx = const [];
  List<dynamic> _withdrawals = const [];
  List<dynamic> _bankAccounts = const [];

  final _withdrawAmountCtrl = TextEditingController();
  int? _selectedBankAccountId;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        ApiClient().dio.get('/wallet'),
        ApiClient().dio.get('/withdrawals'),
        ApiClient().dio.get('/bank-accounts'),
      ]);

      final walletBody = res[0].data;
      final withdrawalsBody = res[1].data;
      final bankBody = res[2].data;

      final wallet =
          walletBody is Map ? Map<String, dynamic>.from(walletBody) : <String, dynamic>{};
      final walletObj =
          wallet['wallet'] is Map ? Map<String, dynamic>.from(wallet['wallet']) : <String, dynamic>{};
      final txBody = wallet['transactions'];
      final tx = (txBody is Map && txBody['data'] is List)
          ? txBody['data'] as List
          : (txBody is List ? txBody : const []);

      final withdrawals = (withdrawalsBody is Map && withdrawalsBody['data'] is List)
          ? withdrawalsBody['data'] as List
          : (withdrawalsBody is List ? withdrawalsBody : const []);

      final banks = (bankBody is Map && bankBody['data'] is List)
          ? bankBody['data'] as List
          : (bankBody is List ? bankBody : const []);

      setState(() {
        _wallet = walletObj;
        _walletTx = tx;
        _withdrawals = withdrawals;
        _bankAccounts = banks;
        _selectedBankAccountId ??= _bankAccounts.isNotEmpty
            ? int.tryParse((_bankAccounts.first as Map?)?['id']?.toString() ?? '')
            : null;
      });
    } catch (e) {
      AppUtils.showError(message: 'Failed to load wallet: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestWithdrawal() async {
    final amount = double.tryParse(_withdrawAmountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      AppUtils.showError(message: 'Enter a valid amount');
      return;
    }
    if (_selectedBankAccountId == null) {
      AppUtils.showError(message: 'Add/select a bank account first');
      return;
    }

    AppUtils.showInfo(title: 'Processing', message: 'Submitting withdrawal request...');
    try {
      await ApiClient().dio.post(
        '/withdrawals',
        data: {'amount': amount, 'bank_account_id': _selectedBankAccountId},
      );
      _withdrawAmountCtrl.clear();
      await _fetchAll();
      AppUtils.showSuccess(message: 'Withdrawal request submitted');
    } catch (e) {
      AppUtils.showError(message: 'Withdrawal failed: $e');
    }
  }

  Future<void> _addBankAccount() async {
    final bankNameCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final ibanCtrl = TextEditingController();

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Bank Account', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: bankNameCtrl,
                decoration: const InputDecoration(labelText: 'Bank Name'),
              ),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Account Title'),
              ),
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(labelText: 'Account Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ibanCtrl,
                decoration: const InputDecoration(labelText: 'IBAN (optional)'),
              ),
              const SizedBox(height: AppSpacing.m),
              AppButton(
                label: 'Save',
                onPressed: () async {
                  try {
                    await ApiClient().dio.post(
                      '/bank-accounts',
                      data: {
                        'bank_name': bankNameCtrl.text.trim(),
                        'account_title': titleCtrl.text.trim(),
                        'account_number': numberCtrl.text.trim(),
                        'iban': ibanCtrl.text.trim().isEmpty ? null : ibanCtrl.text.trim(),
                        'is_primary': true,
                      },
                    );
                    Get.back();
                    await _fetchAll();
                    AppUtils.showSuccess(message: 'Bank account added');
                  } catch (e) {
                    AppUtils.showError(message: 'Failed to add bank account: $e');
                  }
                },
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _deleteBankAccount(int id) async {
    try {
      await ApiClient().dio.delete('/bank-accounts/$id');
      if (_selectedBankAccountId == id) {
        _selectedBankAccountId = null;
      }
      await _fetchAll();
      AppUtils.showSuccess(message: 'Bank account deleted');
    } catch (e) {
      AppUtils.showError(message: 'Failed to delete bank account: $e');
    }
  }

  @override
  void dispose() {
    _withdrawAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Withdraw'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: AppProgressIndicator())
            : TabBarView(
                children: [
                  _overview(),
                  _withdraw(),
                  _history(),
                ],
              ),
      ),
    );
  }

  Widget _overview() {
    final balance = double.tryParse(_wallet['balance']?.toString() ?? '') ?? 0;
    final held = double.tryParse(_wallet['held_balance']?.toString() ?? '') ?? 0;

    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1B6CF2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance', style: AppTextStyles.label.copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Text('Rs. ${balance.toStringAsFixed(0)}', style: AppTextStyles.h2.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                Text('Held (pending withdrawals): Rs. ${held.toStringAsFixed(0)}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: AppButton(label: 'Add Bank Account', onPressed: _addBankAccount),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(onPressed: _fetchAll, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Bank Accounts', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          if (_bankAccounts.isEmpty)
            Text('No bank accounts yet.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted))
          else
            ..._bankAccounts.map((b) {
              final m = b as Map? ?? {};
              final id = int.tryParse(m['id']?.toString() ?? '');
              final isSelected = id != null && _selectedBankAccountId == id;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.border.withOpacity(0.6)),
                ),
                child: ListTile(
                  leading: Radio<int>(
                    value: id ?? -1,
                    groupValue: _selectedBankAccountId,
                    onChanged: id == null
                        ? null
                        : (v) => setState(() => _selectedBankAccountId = v),
                  ),
                  title: Text(m['bank_name']?.toString() ?? 'Bank'),
                  subtitle: Text(m['account_number']?.toString() ?? ''),
                  trailing: IconButton(
                    tooltip: 'Delete',
                    icon: Icon(
                      Icons.delete_outline,
                      color: isSelected ? Colors.red : AppColors.textMuted,
                    ),
                    onPressed: id == null
                        ? null
                        : () {
                            Get.defaultDialog(
                              title: 'Delete bank account?',
                              middleText:
                                  'This will remove the bank account from your profile.',
                              textCancel: 'Cancel',
                              textConfirm: 'Delete',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              onConfirm: () async {
                                Get.back();
                                await _deleteBankAccount(id);
                              },
                            );
                          },
                  ),
                  onTap: id == null
                      ? null
                      : () => setState(() => _selectedBankAccountId = id),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _withdraw() {
    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Text('Request Withdrawal', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _withdrawAmountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (min 10)',
              prefixText: 'Rs. ',
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          DropdownButtonFormField<int>(
            value: _selectedBankAccountId,
            decoration: const InputDecoration(labelText: 'Bank Account'),
            items: _bankAccounts
                .map((b) {
                  final m = b as Map? ?? {};
                  final id = int.tryParse(m['id']?.toString() ?? '');
                  if (id == null) return null;
                  return DropdownMenuItem(
                    value: id,
                    child: Text('${m['bank_name'] ?? 'Bank'} • ${m['account_number'] ?? ''}'),
                  );
                })
                .whereType<DropdownMenuItem<int>>()
                .toList(),
            onChanged: (v) => setState(() => _selectedBankAccountId = v),
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton(label: 'Submit Withdrawal', onPressed: _requestWithdrawal),
          const SizedBox(height: AppSpacing.l),
          Text('My Withdrawal Requests', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.s),
          if (_withdrawals.isEmpty)
            Text('No withdrawals yet.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted))
          else
            ..._withdrawals.map((w) {
              final m = w as Map? ?? {};
              return ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text('Rs. ${m['amount'] ?? 0}'),
                subtitle: Text('Status: ${m['status'] ?? 'pending'}'),
              );
            }),
        ],
      ),
    );
  }

  Widget _history() {
    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: _walletTx.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, i) {
          final tx = _walletTx[i] as Map? ?? {};
          final amount = tx['amount']?.toString() ?? '';
          final type = tx['type']?.toString() ?? tx['transaction_type']?.toString() ?? 'transaction';
          final createdAt = tx['created_at']?.toString();
          return ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text('$type • Rs. $amount'),
            subtitle: Text(createdAt ?? ''),
          );
        },
      ),
    );
  }
}

