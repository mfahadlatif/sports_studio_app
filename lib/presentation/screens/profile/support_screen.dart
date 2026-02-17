import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/presentation/widgets/primary_button.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch phone call');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Support Request - Sports Studio'},
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch email');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // WhatsApp URL scheme
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help you?', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            Text(
              'If you have any questions or need assistance with your booking, feel free to contact us.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 32),

            _buildContactOption(
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+92 300 1234567',
              onTap: () => _makePhoneCall('+923001234567'),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              icon: Icons
                  .chat, // WhatsApp icon usually custom, using chat for now
              title: 'WhatsApp',
              subtitle: '+92 300 1234567',
              onTap: () => _openWhatsApp('923001234567'),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              icon: Icons.email,
              title: 'Email Us',
              subtitle: 'support@sportsstudio.com',
              onTap: () => _sendEmail('support@sportsstudio.com'),
            ),

            const SizedBox(height: 48),
            Text('FAQs', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildFaqItem(
              'How do I cancel a booking?',
              'Go to My Bookings, select the booking, and tap "Cancel Booking". Cancellation policies apply.',
            ),
            _buildFaqItem(
              'Can I reschedule?',
              'Currently, rescheduling requires cancelling and re-booking.',
            ),
            _buildFaqItem(
              'Is my payment secure?',
              'Yes, we use secure payment gateways for all transactions.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: AppTextStyles.bodyMedium),
          ),
        ],
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.surface,
        collapsedBackgroundColor: AppColors.surface,
        textColor: AppColors.textPrimary,
        collapsedTextColor: AppColors.textPrimary,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textMuted,
      ),
    );
  }
}
