import 'package:flutter/material.dart';
import 'package:sports_studio/data/models/event_model.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.surface),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    'Price: \$${event.price.toStringAsFixed(2)}',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildIconText(Icons.location_on, event.location),
                  const SizedBox(height: 8),
                  _buildIconText(
                    Icons.calendar_today,
                    '${event.date} at ${event.time}',
                  ),

                  const SizedBox(height: 24),

                  // Progress Bar
                  LinearProgressIndicator(
                    value: event.currentParticipants / event.maxParticipants,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants} Registered',
                        style: AppTextStyles.bodySmall,
                      ),
                      if (event.currentParticipants >= event.maxParticipants)
                        const Text(
                          'Sold Out',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Text('Description', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(event.description, style: AppTextStyles.bodyLarge),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          event.currentParticipants < event.maxParticipants
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Registration logic would invoke PaymentService here.',
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        event.currentParticipants < event.maxParticipants
                            ? 'Register Now'
                            : 'Event Full',
                        style: AppTextStyles.buttonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
      ],
    );
  }
}
