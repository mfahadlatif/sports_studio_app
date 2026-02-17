import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_studio/domain/providers/ground_provider.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/presentation/widgets/ground_card.dart';
import 'package:sports_studio/presentation/screens/grounds/ground_detail_screen.dart';
import 'package:sports_studio/presentation/widgets/custom_text_field.dart';
import 'package:sports_studio/presentation/widgets/app_logo.dart';

import 'package:sports_studio/presentation/widgets/app_drawer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 32, iconSize: 20, showText: false),
            const SizedBox(width: 12),
            const Text(
              'Sports Studio',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search by name, city...',
              prefixIcon: Icons.search,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),

          // Grid
          Expanded(
            child: Consumer<GroundProvider>(
              builder: (context, provider, _) {
                final allGrounds = provider.grounds;
                final filteredGrounds = allGrounds.where((ground) {
                  final name = ground.name.toLowerCase();
                  final city = ground.city.toLowerCase();
                  final address = ground.address.toLowerCase();
                  return name.contains(_searchQuery) ||
                      city.contains(_searchQuery) ||
                      address.contains(_searchQuery);
                }).toList();

                if (filteredGrounds.isEmpty) {
                  return const Center(
                    child: Text('No grounds found matching your search.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns
                    childAspectRatio: 0.75, // Taller cards
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredGrounds.length,
                  itemBuilder: (context, index) {
                    final ground = filteredGrounds[index];
                    return GroundCard(
                      ground: ground,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GroundDetailScreen(ground: ground),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
