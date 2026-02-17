import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/ground_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/ground_card.dart';
import 'package:sports_studio/presentation/widgets/section_header.dart';
import 'package:sports_studio/presentation/screens/grounds/ground_detail_screen.dart';
import 'package:sports_studio/domain/providers/event_provider.dart';
import 'package:sports_studio/presentation/screens/events/events_screen.dart';
import 'package:sports_studio/presentation/widgets/event_card.dart';
import 'package:sports_studio/presentation/screens/events/event_detail_screen.dart';
import 'package:sports_studio/presentation/widgets/app_logo.dart';
import 'package:sports_studio/presentation/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch grounds on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroundProvider>().fetchGrounds();
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: Builder(
        builder: (context) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Cinematic Header
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const AppLogo(
                                size: 40,
                                iconSize: 20,
                                showText: false,
                              ),
                              const SizedBox(width: 12),
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors
                                    .premiumGradient
                                    .createShader(bounds),
                                child: const Text(
                                  'Sports Studio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level up your game!',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Profile
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.premiumGradient,
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.surface,
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar Placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search grounds, sports...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withOpacity(0.6),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Game Filters (Chips)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'All Sports',
                        Icons.sports_rounded,
                        true,
                      ),
                      _buildFilterChip(
                        'Cricket',
                        Icons.sports_cricket_rounded,
                        false,
                      ),
                      _buildFilterChip(
                        'Football',
                        Icons.sports_soccer_rounded,
                        false,
                      ),
                      _buildFilterChip(
                        'Tennis',
                        Icons.sports_tennis_rounded,
                        false,
                      ),
                      _buildFilterChip(
                        'Badminton',
                        Icons.sports_handball_rounded,
                        false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Featured Grounds Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SectionHeader(
                    title: 'Featured Grounds',
                    actionText: 'See All',
                    onActionTap: () {},
                  ),
                ),
                const SizedBox(height: 16),

                // Ground List (Horizontal)
                SizedBox(
                  height: 280,
                  child: Consumer<GroundProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        );
                      }

                      if (provider.grounds.isEmpty &&
                          provider.status == GroundStatus.success) {
                        return const Center(
                          child: Text(
                            "No grounds found",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.grounds.length,
                        itemBuilder: (context, index) {
                          final ground = provider.grounds[index];
                          return GroundCard(
                            ground: ground,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GroundDetailScreen(ground: ground),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Hot Deals Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'PROMO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '30% OFF on Weekend Bookings!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Use Code: WKND30',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Events Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SectionHeader(
                    title: 'Upcoming Events',
                    actionText: 'View All',
                    onActionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 240,
                  child: Consumer<EventProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading)
                        return const Center(child: CircularProgressIndicator());
                      if (provider.events.isEmpty)
                        return const SizedBox.shrink();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.events.length,
                        itemBuilder: (context, index) {
                          final event = provider.events[index];
                          return SizedBox(
                            width: 280, // Fixed width for horizontal card
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: EventCard(
                                event: event,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailScreen(event: event),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SectionHeader(title: 'Categories'),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      _buildCategoryItem('All', Icons.apps_rounded, true),
                      _buildCategoryItem(
                        'Cricket',
                        Icons.sports_cricket_rounded,
                        false,
                      ),
                      _buildCategoryItem(
                        'Football',
                        Icons.sports_soccer_rounded,
                        false,
                      ),
                      _buildCategoryItem(
                        'Badminton',
                        Icons.sports_tennis_rounded,
                        false,
                      ),
                      _buildCategoryItem(
                        'Tennis',
                        Icons.sports_baseball_rounded,
                        false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          // TODO: Filter by category
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.glassBorder,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
