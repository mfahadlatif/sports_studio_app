import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class OwnerReportsPage extends StatefulWidget {
  const OwnerReportsPage({super.key});

  @override
  State<OwnerReportsPage> createState() => _OwnerReportsPageState();
}

class _OwnerReportsPageState extends State<OwnerReportsPage> {
  bool _isLoading = true;
  String _selectedPeriod = 'month';
  Map<String, dynamic> _stats = {};
  List<dynamic> _revenueTrend = [];
  List<dynamic> _topGames = [];
  List<dynamic> _paymentBreakdown = [];
  List<dynamic> _dayStats = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get(
        '/owner/reports?period=$_selectedPeriod',
      );
      if (res.statusCode == 200) {
        final data = res.data;
        setState(() {
          _stats = data['stats'] ?? {};
          _revenueTrend = data['revenue_trend'] ?? [];
          _topGames = data['top_games'] ?? [];
          _paymentBreakdown = data['payment_breakdown'] ?? [];
          _dayStats = data['day_stats'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _periodChip('Today', 'today'),
                        _periodChip('Week', 'week'),
                        _periodChip('Month', 'month'),
                        _periodChip('Year', 'year'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.m,
                    mainAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.4,
                    children: [
                      _statCard(
                        'Total Revenue',
                        '${AppConstants.currencySymbol} ${_fmt(_stats['total_revenue'] ?? 0)}',
                        Icons.payments_outlined,
                        AppColors.primary,
                      ),
                      _statCard(
                        'Total Bookings',
                        '${_stats['total_bookings'] ?? 0}',
                        Icons.calendar_month_outlined,
                        Colors.blue,
                      ),
                      _statCard(
                        'Avg. Booking Value',
                        '${AppConstants.currencySymbol} ${_fmt(_stats['avg_booking_value'] ?? 0)}',
                        Icons.trending_up,
                        Colors.green,
                      ),
                      _statCard(
                        'Unique Customers',
                        '${_stats['unique_customers'] ?? 0}',
                        Icons.people_outline,
                        Colors.purple,
                      ),
                      _miniStatCard(
                        'Upcoming Settlement',
                        '${AppConstants.currencySymbol} ${_fmt(_stats['pending_settlement'] ?? 0)}',
                        Icons.hourglass_bottom,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Revenue Trend
                  _buildSectionTitle('Revenue Trend', 'Business Growth'),
                  const SizedBox(height: AppSpacing.m),
                  _buildRevenueChart(),

                  const SizedBox(height: AppSpacing.l),

                  // Most Booked Sports
                  _buildSectionTitle('Popular Sports', 'Usage Breakdown'),
                  const SizedBox(height: AppSpacing.m),
                  _buildTopGames(),

                  const SizedBox(height: AppSpacing.l),
                  
                  // Payment Breakdown
                  _buildSectionTitle('Payment Methods', 'Cash vs Online'),
                  const SizedBox(height: AppSpacing.m),
                  _buildPaymentBreakdown(),

                  const SizedBox(height: AppSpacing.l),

                  // Peak Days
                  _buildSectionTitle('Busiest Days', 'Weekly Patterns'),
                  const SizedBox(height: AppSpacing.m),
                  _buildDayAnalytics(),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  Widget _periodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _fetchReports();
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.s),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textMuted),
              ),
              Text(
                value,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                   title.toUpperCase(),
                  style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppColors.textMuted),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        Text(subtitle.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildRevenueChart() {
    if (_revenueTrend.isEmpty) return _empty();
    final values = _revenueTrend
        .map((e) => double.tryParse(e['revenue'].toString()) ?? 0.0)
        .toList();
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1000;
    final maxRevenue = maxVal > 0 ? maxVal : 1000;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _revenueTrend.map((item) {
          final val = double.tryParse(item['revenue'].toString()) ?? 0;
          final height = (val / maxRevenue) * 140;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (val > 0)
                  Text(
                    _fmtShort(val),
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: height.clamp(4.0, 140.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label']?.toString().toUpperCase() ?? '',
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopGames() {
    if (_topGames.isEmpty) return _empty();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: _topGames.map((g) {
          final name = g['name']?.toString().toUpperCase() ?? 'SPORT';
          final pct = (g['percentage'] as num?)?.toDouble() ?? 0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                    Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 5,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    if (_paymentBreakdown.isEmpty) return _empty();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: _paymentBreakdown.map((method) {
          final String name = method['payment_method']?.toString() ?? 'online';
          final pct = (method['percentage'] as num?)?.toDouble() ?? 0;
          final color = name == 'cash' ? Colors.orange : Colors.blue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(name == 'cash' ? Icons.payments : Icons.credit_card, color: color, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 6,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text('${pct.toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayAnalytics() {
    if (_dayStats.isEmpty) return _empty();
    final maxCount = _dayStats.map((e) => (e['count'] as num).toInt()).reduce((a, b) => a > b ? a : b) * 1.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _dayStats.map((day) {
          final count = (day['count'] as num).toDouble();
          final height = (count / (maxCount > 0 ? maxCount : 1.0)) * 80;
          final isPeak = count == maxCount && count > 0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(day['day'].substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isPeak ? AppColors.primary : AppColors.textMuted)),
              const SizedBox(height: 8),
              Container(
                width: 16,
                height: height.clamp(4.0, 80.0),
                decoration: BoxDecoration(
                  color: isPeak ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(count.toInt().toString(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isPeak ? AppColors.primary : AppColors.textMuted)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _empty() => Center(child: Text('NO DATA AVAILABLE', style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 8, letterSpacing: 1)));

  String _fmt(dynamic val) {
    final d = double.tryParse(val.toString()) ?? 0;
    if (d >= 1000000) return '${(d / 1000000).toStringAsFixed(1)}M';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(0)}K';
    return d.toInt().toString();
  }

  String _fmtShort(double val) {
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return val.toInt().toString();
  }
}
