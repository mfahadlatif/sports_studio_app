import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/section_header.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final List<Map<String, dynamic>> _mockTeams = [
    {
      'id': '1',
      'name': 'Dream XI',
      'sport': 'Cricket',
      'description': 'The official team for upcoming weekend tournament.',
      'members': 11,
      'trophies': 3,
    },
    {
      'id': '2',
      'name': 'Strikers FC',
      'sport': 'Football',
      'description': 'A competitive group for local football leagues.',
      'members': 8,
      'trophies': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Teams'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Formed Teams', actionText: 'Search'),
            const SizedBox(height: 20),
            ..._mockTeams.map((team) => _buildTeamCard(team)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    team['sport'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              team['name'],
              style: AppTextStyles.heading3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              team['description'],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${team['members']} Members',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Spacer(),
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.accent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${team['trophies']} Won',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
