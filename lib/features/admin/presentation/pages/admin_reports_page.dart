import 'package:flutter/material.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/widgets/app_progress_indicator.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  bool _isLoading = true;
  String _selectedPeriod = 'month';
  Map<String, dynamic> _stats = {};
  List<dynamic> _revenueTrend = [];
  List<dynamic> _topGames = [];
  List<dynamic> _peakHours = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/owner/reports?period=$_selectedPeriod');
      if (res.statusCode == 200) {
        final data = res.data;
        setState(() {
          _stats = data['stats'] ?? {};
          _revenueTrend = data['revenue_trend'] ?? data['monthly_revenue'] ?? [];
          _topGames = data['top_games'] ?? [];
          _peakHours = data['peak_hours'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin reports: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Intelligence'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetch,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppProgressIndicator())
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
                        _periodChip('This Week', 'week'),
                        _periodChip('This Month', 'month'),
                        _periodChip('This Year', 'year'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Stats Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.m,
                    mainAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.3,
                    children: [
                      _statCard(
                        'Gross Revenue',
                        '${AppConstants.currencySymbol} ${_fmt(_stats['total_revenue'] ?? 0)}',
                        Icons.payments,
                        Colors.green,
                        '+18.4% TREND',
                      ),
                      _statCard(
                        'Total Volume',
                        '${_stats['total_bookings'] ?? 0}',
                        Icons.calendar_month,
                        Colors.blue,
                        'SUCCESSFUL',
                      ),
                      _statCard(
                        'Active Users',
                        '${_stats['unique_customers'] ?? 0}',
                        Icons.people,
                        Colors.purple,
                        'PEAK DETECTED',
                      ),
                      _statCard(
                        'Avg Ticket Size',
                        '${AppConstants.currencySymbol} ${_fmt(_stats['avg_booking_value'] ?? 0)}',
                        Icons.analytics,
                        Colors.orange,
                        'KPI UPWARDS',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Revenue Trajectory
                  _sectionHeader('Revenue Trajectory', 'Financial performance'),
                  const SizedBox(height: AppSpacing.m),
                  _buildRevenueChart(),

                  const SizedBox(height: AppSpacing.l),

                  // Popularity Index
                  _sectionHeader('Popularity Index', 'Most booked sports'),
                  const SizedBox(height: AppSpacing.m),
                  _buildPopularityIndex(),

                  const SizedBox(height: AppSpacing.l),

                  // Usage Heatmap
                  _sectionHeader('Usage Heatmap', 'Peak booking hours (12H)'),
                  const SizedBox(height: AppSpacing.m),
                  _buildUsageHeatmap(),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        Text(
          subtitle.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            fontSize: 9,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _periodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _fetch();
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
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              const Icon(Icons.trending_up, color: Colors.green, size: 14),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  fontSize: 8,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 7,
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_revenueTrend.isEmpty) return _empty('Waiting for financial logs...');
    final vals = _revenueTrend.map((e) => double.tryParse(e['revenue'].toString()) ?? 0).toList();
    final maxVal = vals.isNotEmpty ? vals.reduce((a, b) => a > b ? a : b) : 1000;
    final maxRev = maxVal > 0 ? maxVal : 1000;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _revenueTrend.map((item) {
                final rev = double.tryParse(item['revenue'].toString()) ?? 0;
                final height = (rev / maxRev) * 160;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (rev > 0)
                        Text(
                          '${(rev / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        width: 14,
                        height: height.clamp(4.0, 160.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['label']?.toString().toUpperCase() ?? '',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityIndex() {
    if (_topGames.isEmpty) return _empty('No bookings recorded');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: _topGames.asMap().entries.map((e) {
          final i = e.key;
          final g = e.value;
          final pct = (g['percentage'] as num?)?.toDouble() ?? 0;
          final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
          final color = colors[i % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        g['name']?.toString().toUpperCase() ?? '',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
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
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUsageHeatmap() {
    if (_peakHours.isEmpty) return _empty('Analyzing usage patterns...');
    final maxBookings = _peakHours.map((e) => (e['bookings'] as num).toInt()).reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _peakHours.length,
        itemBuilder: (context, index) {
          final h = _peakHours[index];
          final count = (h['bookings'] as num).toInt();
          final height = (count / (maxBookings > 0 ? maxBookings : 1)) * 100;
          
          return Container(
            width: 40,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(count.toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: height.clamp(2.0, 100.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  h['formatted_hour']?.toString() ?? '',
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _empty(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          msg.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1),
        ),
      ),
    );
  }

  String _fmt(dynamic val) {
    final d = double.tryParse(val.toString()) ?? 0;
    if (d >= 1000000) return '${(d / 1000000).toStringAsFixed(1)}M';
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(0)}K';
    return d.toInt().toString();
  }
}
