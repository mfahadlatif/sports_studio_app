import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/features/user/presentation/widgets/ground_card_wide.dart';
import 'package:sports_studio/features/user/controller/home_controller.dart';

class GroundsPage extends StatefulWidget {
  const GroundsPage({super.key});

  @override
  State<GroundsPage> createState() => _GroundsPageState();
}

class _GroundsPageState extends State<GroundsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light grey for modern feel
      body: CustomScrollView(
        slivers: [
          // Premium Sliver App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Explore Arenas',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1E293B)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 150,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showFilterSheet(context, controller),
                icon: const Icon(Icons.tune, color: Colors.white),
              ),
            ],
          ),

          // Search & Fast Filters
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.m),
                _buildPremiumSearchBar(
                  'Search arenas...',
                  Icons.search_outlined,
                  controller,
                ),
                const SizedBox(height: AppSpacing.m),
                _buildPremiumSearchBar(
                  'Location...',
                  Icons.map_outlined,
                  controller,
                ),
                const SizedBox(height: AppSpacing.m),
                _buildFastFilters(controller),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),

          // Grounds List
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.filteredGrounds.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No grounds match your search',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ground = controller.filteredGrounds[index];
                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _animCtrl.value)),
                        child: Opacity(opacity: _animCtrl.value, child: child),
                      );
                    },
                    child: GroundCardWide(ground: ground),
                  );
                }, childCount: controller.filteredGrounds.length),
              ),
            );
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPremiumSearchBar(
    String hint,
    IconData icon,
    HomeController controller,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: (val) => controller.updateSearchQuery(val),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFastFilters(HomeController controller) {
    final categories = [
      'All',
      'Cricket',
      'Football',
      'Tennis',
      'Badminton',
      'Basketball',
    ];
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.updateCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: AppTextStyles.h2),
                  TextButton(
                    onPressed: () => controller.resetFilters(),
                    child: Text(
                      'Reset All',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                children: [
                  Obx(
                    () => _filterSection('Price Range (per hour)', [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rs. ${controller.priceRange.value.start.round()}',
                              style: AppTextStyles.label,
                            ),
                            Text(
                              'Rs. ${controller.priceRange.value.end.round()}',
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                      ),
                      RangeSlider(
                        values: controller.priceRange.value,
                        min: 0,
                        max: 20000,
                        divisions: 20,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primaryLight,
                        onChanged: (v) => controller.updatePriceRange(v),
                      ),
                    ]),
                  ),
                  Obx(
                    () => _filterSection('Amenities', [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _filterChip('water', 'Water 🚰', controller),
                          _filterChip('washroom', 'Washroom 🚻', controller),
                          _filterChip('changing', 'Changing 👕', controller),
                          _filterChip('parking', 'Parking 🚗', controller),
                          _filterChip('lighting', 'Lights 💡', controller),
                        ],
                      ),
                    ]),
                  ),
                  Obx(
                    () => _filterSection('Sort By', [
                      _sortTile('Rating: High to Low', controller),
                      _sortTile('Price: Low to High', controller),
                      _sortTile('Price: High to Low', controller),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.l),
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.m),
        ...children,
      ],
    );
  }

  Widget _filterChip(String id, String label, HomeController controller) {
    final isSelected = controller.selectedAmenities.contains(id);
    return GestureDetector(
      onTap: () => controller.toggleAmenity(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _sortTile(String title, HomeController controller) {
    final isSelected = controller.sortBy.value == title;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => controller.updateSort(title),
    );
  }
}
