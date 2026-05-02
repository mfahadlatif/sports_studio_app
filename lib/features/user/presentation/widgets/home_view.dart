import 'dart:ui';
import 'package:flutter/material.dart';
import 'hero_section.dart';
import 'grounds_preview_section.dart';
import 'events_preview_section.dart';
import 'package:get/get.dart';
import 'package:sport_studio/features/landing/controller/landing_controller.dart'
    as sports_landing;
import 'package:sport_studio/core/theme/app_colors.dart';
import 'package:sport_studio/core/theme/app_text_styles.dart';
import 'package:sport_studio/core/constants/app_constants.dart';
import 'package:sport_studio/widgets/section_header.dart';
import 'package:sport_studio/features/user/controller/home_controller.dart';
import 'package:sport_studio/features/user/presentation/pages/create_match_page.dart';
import 'package:sport_studio/features/user/presentation/pages/user_bookings_page.dart';
import 'package:sport_studio/features/user/presentation/pages/deals_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sport_studio/core/constants/user_roles.dart';
import 'package:sport_studio/core/utils/app_utils.dart';
import 'package:sport_studio/features/user/controller/profile_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final profileController = Get.put(ProfileController());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        displacement: 40,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                const HeroSection(),
                const SizedBox(height: AppSpacing.s),

                // Location & Nearby Filters
                _buildLocationFilters(controller),
                const SizedBox(height: AppSpacing.m),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Row(
                    children: [
                      _buildQuickAction(
                        'Book Now',
                        LucideIcons.calendarPlus,
                        AppColors.primary,
                        () {
                          final landingController =
                              Get.find<sports_landing.LandingController>();
                          landingController.changeNavIndex(1);
                        },
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Obx(() {
                        final landingController =
                            Get.find<sports_landing.LandingController>();
                        final isOwner =
                            landingController.currentRole.value ==
                            UserRole.owner;

                        if (isOwner) return const SizedBox.shrink();

                        return Expanded(
                          child: Row(
                            children: [
                                _buildQuickAction(
                                  'Host Match',
                                  LucideIcons.circlePlay,
                                  Colors.orange,
                                  () {
                                    if (!profileController.isPhoneVerified) {
                                      AppUtils.showPhoneVerificationRequiredDialog(
                                        title: 'Phone Verification Required',
                                        message: 'To host a new match, your phone number must be verified for security and coordination.',
                                      );
                                      return;
                                    }
                                    Get.to(() => const CreateMatchPage());
                                  },
                                ),
                              const SizedBox(width: AppSpacing.m),
                            ],
                          ),
                        );
                      }),
                      _buildQuickAction(
                        'My Tickets',
                        LucideIcons.ticket,
                        Colors.blue,
                        () => Get.to(() => const UserBookingsPage()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Sport Categories (Web Sync)
                _sectionHeader('Explore by Sport', LucideIcons.trophy),
                const SizedBox(height: AppSpacing.m),
                _buildCategorySelector(),
                const SizedBox(height: AppSpacing.l),

                const SizedBox(height: AppSpacing.l),
                const EventsPreviewSection(),
                const SizedBox(height: AppSpacing.l),
                const GroundsPreviewSection(),
                const SizedBox(height: AppSpacing.l),

                // Deals & Promotions (Hot Deals Integration)
                SectionHeader(
                  title: 'Hot Deals',
                  subtitle: 'Exclusive discounts on your favorite grounds',
                  onActionPressed: () => Get.to(() => const DealsPage()),
                ),
                Obx(() {
                  if (controller.hotDeals.isEmpty) {
                    return SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          'No active deals at the moment',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 160,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.hotDeals.length,
                      itemBuilder: (context, index) {
                        final deal = controller.hotDeals[index];

                        // Parse colors from color_theme or use defaults
                        Color startColor = AppColors.primary;
                        Color endColor = const Color(0xFF0F172A);

                        if (deal['color_theme'] == 'orange') {
                          startColor = Colors.orange;
                          endColor = Colors.deepOrange;
                        } else if (deal['color_theme'] == 'teal') {
                          startColor = Colors.teal;
                          endColor = Colors.teal.shade900;
                        } else if (deal['color_theme'] == 'blue') {
                          startColor = Colors.blue;
                          endColor = Colors.blue.shade900;
                        } else if (deal['color_theme'] == 'purple') {
                          startColor = Colors.purple;
                          endColor = Colors.purple.shade900;
                        } else if (deal['color_theme'] == 'pink') {
                          startColor = Colors.pink;
                          endColor = Colors.pink.shade900;
                        } else if (deal['color_theme'] == 'green') {
                          startColor = Colors.green;
                          endColor = Colors.green.shade900;
                        }

                        return _buildHotDealCard(
                          deal['code'] ?? 'DEAL',
                          '${deal['discount_percentage']}% OFF',
                          deal['description'] ??
                              'Exclusive discount on grounds',
                          startColor,
                          endColor,
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.l),

                // Stats Section
                Obx(() {
                  final stats = controller.dashboardStats;
                  final bookings =
                      stats['total_bookings'] ??
                      stats['bookings'] ??
                      stats['bookings_count'] ??
                      0;
                  final favorites =
                      stats['favorites'] ??
                      stats['favorites_count'] ??
                      stats['total_favorites'] ??
                      0;
                  final events = stats['hosted_events'] ?? stats['events'] ?? 0;
                  final spent = stats['total_spent'] ?? stats['total_payments'];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          bookings.toString(),
                          'Bookings',
                          LucideIcons.calendarDays,
                        ),
                        _buildStat(
                          favorites.toString(),
                          'Favorites',
                          LucideIcons.heart,
                        ),
                        _buildStat(
                          events.toString(),
                          'Hosted',
                          LucideIcons.circlePlay,
                        ),
                        if (spent != null)
                          _buildStat(
                            spent.toString(),
                            'Spent',
                            LucideIcons.walletCards,
                          ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.l),

                const SizedBox(height: AppSpacing.l),

                // Why Choose Us
                SectionHeader(
                  title: 'Why Choose Us',
                  subtitle: 'The best sports experience in the city',
                ),
                SizedBox(
                  height: 160,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFeatureCard(
                        LucideIcons.shieldCheck,
                        'Certified Grounds',
                      ),
                      _buildFeatureCard(LucideIcons.headset, '24/7 Support'),
                      _buildFeatureCard(
                        LucideIcons.creditCard,
                        'Secure Payments',
                      ),
                      _buildFeatureCard(
                        LucideIcons.award,
                        'Professional Staff',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.l),
                
                // Testimonials (Website Sync)
                _buildTestimonialsSection(),

                const SizedBox(height: AppSpacing.xxl), // Just for scroll space
              ],
            ),
          ),
        ),
      ),)
    );
  }

  Widget _buildTestimonialsSection() {
    final List<Map<String, String>> reviews = [
      {
        'name': 'Ahmed Hassan',
        'location': 'Karachi, PK',
        'avatar': 'https://i.pravatar.cc/150?u=ahmed',
        'text': 'The Safepay system gave me peace of mind. Booking grounds in Karachi has never been this secure and professional.',
        'rating': '5.0',
      },
      {
        'name': 'Zoya Khan',
        'location': 'Islamabad, PK',
        'avatar': 'https://i.pravatar.cc/150?u=zoya',
        'text': 'Finally a platform that shows real-time availability! I organized a corporate tournament in Islamabad without a single phone call.',
        'rating': '5.0',
      },
      {
        'name': 'Marcus Chen',
        'location': 'Global Traveller',
        'avatar': 'https://i.pravatar.cc/150?u=marcus',
        'text': 'Travelled to Lahore for a tournament and used Sport Studio. The facility quality matched the app photos perfectly. Impressive!',
        'rating': '4.9',
      },
    ];

    return Column(
      children: [
        SectionHeader(
          title: 'What Players Say',
          subtitle: 'Join thousands of satisfied athletes',
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final r = reviews[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(r['avatar']!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                r['location']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              r['rating']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      r['text']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(
            right: AppSpacing.m,
            bottom: AppSpacing.s,
          ),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHotDealCard(
    String code,
    String discount,
    String description,
    Color colorStart,
    Color colorEnd,
  ) {
    return GestureDetector(
      onTap: () => Get.to(() => const DealsPage()),
      child: Container(
        // width: 250,
        margin: const EdgeInsets.only(right: AppSpacing.m),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [colorStart, colorEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorEnd.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.local_offer,
                size: 100,
                color: Colors.white.withAlpha(20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      code,
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    discount,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
      ],
    ),
  );

  Widget _buildCategorySelector() {
    final controller = Get.put(HomeController());
    final List<Map<String, dynamic>> categories = [
      {'name': 'All', 'icon': LucideIcons.layoutGrid},
      {'name': 'Cricket', 'icon': Icons.sports_cricket_outlined},
      {'name': 'Football', 'icon': Icons.sports_soccer_outlined},
      {'name': 'Tennis', 'icon': Icons.sports_tennis_outlined},
      {'name': 'Padel', 'icon': Icons.sports_tennis_outlined},
      {'name': 'Volleyball', 'icon': Icons.sports_volleyball_outlined},
      {'name': 'Hockey', 'icon': Icons.sports_hockey_outlined},
      {'name': 'Basketball', 'icon': Icons.sports_basketball_outlined},
      {'name': 'Badminton', 'icon': Icons.sports_tennis_outlined},
    ];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat['name'];
            return GestureDetector(
              onTap: () => controller.updateCategory(cat['name']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat['name']!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildLocationFilters(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City Selector Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _sectionHeader('Choose City', LucideIcons.mapPin),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.m),
              child: Obx(() => FilterChip(
                label: Text(
                  'Nearby',
                  style: TextStyle(
                    color: controller.isNearbyActive.value ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                selected: controller.isNearbyActive.value,
                onSelected: (val) => controller.toggleNearby(val),
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )),
            ),
          ],
        ),
        Obx(() {
          if (controller.isNearbyActive.value) {
            return Padding(
              padding: const EdgeInsets.only(left: AppSpacing.m, right: AppSpacing.m, top: 8),
              child: Row(
                children: [
                  const Icon(Icons.my_location, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      controller.currentLocationAddress.value.isEmpty
                          ? 'Locating your area...'
                          : 'Showing within 50km of ${controller.currentLocationAddress.value}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: AppSpacing.s),
        
        // Horizontal City List
        SizedBox(
          height: 45,
          child: Obx(() {
            // Read observable to register it with Obx
            final currentCity = controller.selectedCity.value;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              scrollDirection: Axis.horizontal,
            itemCount: controller.pakistanCities.length,
            itemBuilder: (context, index) {
              final city = controller.pakistanCities[index];
              final isSelected = currentCity == city;
              
              return GestureDetector(
                onTap: () => controller.updateCity(city),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Text(
                    city,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
            );
          }),
        ),
      ],
    );
  }
}
