import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/section_header.dart';

class ManageComplexesScreen extends StatefulWidget {
  const ManageComplexesScreen({super.key});

  @override
  State<ManageComplexesScreen> createState() => _ManageComplexesScreenState();
}

class _ManageComplexesScreenState extends State<ManageComplexesScreen> {
  final List<Map<String, dynamic>> _mockComplexes = [
    {
      'id': '1',
      'name': 'Elite Sports Complex',
      'location': 'Karachi, DHA Phase 6',
      'grounds': 3,
      'status': 'Active',
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Royal Cricket Club',
      'location': 'Lahore, Gulberg III',
      'grounds': 2,
      'status': 'Active',
      'rating': 4.5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Complexes'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_business_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SectionHeader(title: 'Your Complexes', actionText: 'Search'),
            const SizedBox(height: 20),
            ..._mockComplexes.map((complex) => _buildComplexCard(complex)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexCard(Map<String, dynamic> complex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    complex['status'],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complex['rating'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              complex['name'],
              style: AppTextStyles.heading3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  complex['location'],
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.stadium_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${complex['grounds']} Grounds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                  child: const Text('Manage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
