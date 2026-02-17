import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

class ReviewItem extends StatelessWidget {
  final String author;
  final double rating;
  final String comment;
  final String date;

  const ReviewItem({
    super.key,
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) =>
                const Icon(Icons.star, color: AppColors.primary),
            itemCount: 5,
            itemSize: 16.0,
            unratedColor: AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(comment, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
