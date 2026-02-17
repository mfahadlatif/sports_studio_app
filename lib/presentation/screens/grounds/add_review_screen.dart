import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/presentation/widgets/custom_text_field.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';

class AddReviewScreen extends StatefulWidget {
  final int groundId;

  const AddReviewScreen({super.key, required this.groundId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Write a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Rate your experience', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: AppColors.primary),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _commentController,
              hintText: 'Share your thoughts about this ground...',
              // maxLines: 5, // CustomTextField needs maxLines support
            ),
            const SizedBox(height: 32),
            PrimaryButton(text: 'Submit Review', onPressed: _submitReview),
          ],
        ),
      ),
    );
  }
}
