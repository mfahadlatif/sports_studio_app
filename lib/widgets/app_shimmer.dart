import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/constants/app_constants.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const AppShimmer.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  const AppShimmer.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }

  /// A standard card shimmer for lists
  static Widget card({double height = 100}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const AppShimmer.rectangular(
              width: 60,
              height: 60,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppShimmer.rectangular(height: 16, width: 120),
                  const SizedBox(height: 8),
                  const AppShimmer.rectangular(height: 12, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A grid/card shimmer for grounds
  static Widget groundCard() {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: AppSpacing.m, bottom: AppSpacing.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer.rectangular(
            height: 140,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmer.rectangular(height: 16, width: 140),
                const SizedBox(height: 8),
                const AppShimmer.rectangular(height: 12, width: 100),
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppShimmer.rectangular(height: 14, width: 60),
                    const AppShimmer.circular(height: 18, width: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A complex detailed header shimmer
  static Widget detailHeader() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(color: Colors.white),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.grey[300]),
      ),
    );
  }
}
