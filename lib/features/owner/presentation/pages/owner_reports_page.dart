import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';

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
  List<dynamic> _durationStats = [];
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
          _durationStats = data['duration_stats'] ?? [];
          _dayStats = data['day_stats'] ?? [];
        });
      }
    } catch (_) {
      // Demo data
      setState(() {
        _stats = {
          'total_revenue': 145000,
          'total_bookings': 48,
          'avg_booking_value': 3020,
          'unique_customers': 32,
          'pending_settlement': 12500,
        };
        _revenueTrend = [
          {'label': 'Jan', 'revenue': '22000'},
          {'label': 'Feb', 'revenue': '31000'},
          {'label': 'Mar', 'revenue': '18000'},
          {'label': 'Apr', 'revenue': '40000'},
          {'label': 'May', 'revenue': '34000'},
        ];
        _topGames = [
          {
            'name': 'Cricket',
            'bookings': 24,
            'revenue': '72000',
            'percentage': 72,
          },
          {
            'name': 'Football',
            'bookings': 14,
            'revenue': '49000',
            'percentage': 49,
          },
          {
            'name': 'Badminton',
            'bookings': 10,
            'revenue': '24000',
            'percentage': 24,
          },
        ];
        _paymentBreakdown = [
          {
            'payment_method': 'online',
            'revenue': 91000,
            'count': 27,
            'percentage': 63,
          },
          {
            'payment_method': 'cash',
            'revenue': 54000,
            'count': 21,
            'percentage': 37,
          },
        ];
        _durationStats = [
          {'duration': 1, 'count': 32, 'formatted_duration': '1.0 Hr'},
          {'duration': 2, 'count': 12, 'formatted_duration': '2.0 Hr'},
          {'duration': 3, 'count': 4, 'formatted_duration': '3.0 Hr'},
        ];
        _dayStats = [
          {'day': 'Mon', 'count': 12},
          {'day': 'Tue', 'count': 8},
          {'day': 'Wed', 'count': 15},
          {'day': 'Thu', 'count': 10},
          {'day': 'Fri', 'count': 22},
          {'day': 'Sat', 'count': 28},
          {'day': 'Sun', 'count': 25},
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _periodChip('Today', 'today'),
                            _periodChip('This Week', 'week'),
                            _periodChip('This Month', 'month'),
                            _periodChip('This Year', 'year'),
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
                        childAspectRatio: 1.6,
                        children: [
                          _statCard(
                            'Total Revenue',
                            'Rs. ${_fmt(_stats['total_revenue'] ?? 0)}',
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
                            'Avg. Booking',
                            'Rs. ${_fmt(_stats['avg_booking_value'] ?? 0)}',
                            Icons.trending_up_outlined,
                            Colors.green,
                          ),
                          _statCard(
                            'Customers',
                            '${_stats['unique_customers'] ?? 0}',
                            Icons.people_outline,
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Revenue Trend Bar Chart
                      _buildSectionTitle('Revenue Trend', Icons.bar_chart),
                      const SizedBox(height: AppSpacing.m),
                      _buildRevenueChart(),
                      const SizedBox(height: AppSpacing.l),

                      // Top Games
                      _buildSectionTitle('Most Booked Sports', Icons.sports),
                      const SizedBox(height: AppSpacing.m),
                      _buildTopGames(),
                      const SizedBox(height: AppSpacing.l),
                      // Payment Breakdown
                      _buildSectionTitle(
                        'Payment Methods',
                        Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildPaymentBreakdown(),
                      const SizedBox(height: AppSpacing.l),

                      // Duration Stats
                      _buildSectionTitle(
                        'Duration Analysis',
                        Icons.timer_outlined,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDurationStats(),
                      const SizedBox(height: AppSpacing.l),

                      // Day Analytics
                      _buildSectionTitle(
                        'Peak Days',
                        Icons.calendar_view_week_outlined,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDayAnalytics(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.h3.copyWith(color: color)),
              Text(
                title,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.s),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }

  Widget _buildRevenueChart() {
    if (_revenueTrend.isEmpty) return _noData();
    final values = _revenueTrend
        .map((e) => double.tryParse(e['revenue'].toString()) ?? 0.0)
        .toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final maxRevenue = maxVal > 0 ? maxVal : 1;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      height: 220,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _revenueTrend.asMap().entries.map((entry) {
                final item = entry.value;
                final val = double.tryParse(item['revenue'].toString()) ?? 0;
                final heightFraction = val / maxRevenue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _fmtShort(val),
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: Duration(
                            milliseconds: 400 + entry.key * 80,
                          ),
                          height: 120 * heightFraction + 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: _revenueTrend
                .map(
                  (e) => Expanded(
                    child: Text(
                      e['label']?.toString() ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGames() {
    if (_topGames.isEmpty) return _noData();
    final Map<String, String> sportEmoji = {
      'cricket': '🏏',
      'football': '⚽',
      'badminton': '🏸',
      'tennis': '🎾',
      'basketball': '🏀',
    };

    return Container(
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
      child: Column(
        children: _topGames.asMap().entries.map((entry) {
          final i = entry.key;
          final game = entry.value;
          final name = game['name']?.toString() ?? 'Sport';
          final pct = (game['percentage'] as num?)?.toDouble() ?? 0;
          final emoji = sportEmoji[name.toLowerCase()] ?? '🏆';
          final colors = [
            AppColors.primary,
            Colors.blue,
            Colors.green,
            Colors.orange,
          ];
          final color = colors[i % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('$emoji ', style: const TextStyle(fontSize: 20)),
                    Expanded(child: Text(name, style: AppTextStyles.bodyLarge)),
                    Text(
                      '${game['bookings']} bookings',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      'Rs. ${_fmt(game['revenue'] ?? 0)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: color.withValues(alpha: 0.1),
                    color: color,
                    minHeight: 8,
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
    if (_paymentBreakdown.isEmpty) return _noData();
    return Container(
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
      child: Column(
        children: _paymentBreakdown.map((method) {
          final name = method['payment_method']?.toString() ?? 'online';
          final revenue = (method['revenue'] as num?)?.toDouble() ?? 0;
          final count = method['count'] ?? 0;
          final pct = (method['percentage'] as num?)?.toDouble() ?? 0;
          final isCash = name == 'cash';
          final color = isCash ? Colors.orange : Colors.blue;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isCash ? Icons.money : Icons.credit_card,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        name.capitalizeFirst ?? name,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                    Text(
                      '$count txns',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      'Rs. ${_fmt(revenue)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: color.withValues(alpha: 0.1),
                    color: color,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDurationStats() {
    if (_durationStats.isEmpty) return _noData();
    final maxCount = _durationStats.isEmpty
        ? 1
        : _durationStats
              .map((e) => (e['count'] as num).toInt())
              .reduce((a, b) => a > b ? a : b);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _durationStats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.m,
        mainAxisSpacing: AppSpacing.m,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final slot = _durationStats[index];
        final count = (slot['count'] as num).toInt();
        final isHot = count == maxCount && count > 0;

        return Container(
          decoration: BoxDecoration(
            color: isHot ? AppColors.primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHot ? AppColors.primary : AppColors.border,
              width: isHot ? 2 : 1,
            ),
            boxShadow: [
              if (!isHot)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot['formatted_duration'] ?? '${slot['duration']} Hr',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: AppTextStyles.h2.copyWith(
                  color: isHot ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'bookings',
                style: TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayAnalytics() {
    if (_dayStats.isEmpty) return _noData();
    final maxCount = _dayStats
        .map((e) => (e['count'] as num).toInt())
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _dayStats.map((day) {
          final count = (day['count'] as num).toInt();
          final heightPct = count / (maxCount > 0 ? maxCount : 1);
          final isPeak = count == maxCount;

          return Column(
            children: [
              Text(
                day['day'].substring(0, 1),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 25,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 80 * heightPct,
                      decoration: BoxDecoration(
                        color: isPeak
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isPeak ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _noData() => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Text(
        'No data available for this period.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      ),
    ),
  );

  String _fmt(dynamic val) {
    final d = double.tryParse(val.toString()) ?? 0;
    if (d >= 1000000) return '${(d / 1000000).toStringAsFixed(1)}M';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(1)}K';
    return d.toInt().toString();
  }

  String _fmtShort(double val) {
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return val.toInt().toString();
  }
}
