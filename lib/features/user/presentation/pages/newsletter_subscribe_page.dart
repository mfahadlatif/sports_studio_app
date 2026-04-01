import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/constants/app_constants.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/core/theme/app_text_styles.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/widgets/app_button.dart';

class NewsletterSubscribePage extends StatefulWidget {
  const NewsletterSubscribePage({super.key});

  @override
  State<NewsletterSubscribePage> createState() => _NewsletterSubscribePageState();
}

class _NewsletterSubscribePageState extends State<NewsletterSubscribePage> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  final _api = NewsletterApiService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.isEmail) {
      AppUtils.showError(message: 'Enter a valid email');
      return;
    }
    setState(() => _loading = true);
    try {
      print('🌐 [NewsletterAPI] Subscribing UI >>>>> 1 : $email');
      await _api.subscribe(email);
      print('🌐 [NewsletterAPI] Subscribing UI >>>>> 2');
      AppUtils.showSuccess(message: 'Subscribed successfully');
      if (mounted) Get.back(result: true);
      print('🌐 [NewsletterAPI] Subscribing UI >>>>> 3');
    } catch (e) {
      print('🌐 [NewsletterAPI] Subscribing UI >>>>> error : $e');
      AppUtils.showError(message: 'Something went wrong. Try again later.');
    } finally {
      print('🌐 [NewsletterAPI] Finished subscription attempt');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Newsletter'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stay updated', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Get updates about new grounds, deals, and events.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton(
                  label: _loading ? 'Subscribing...' : 'Subscribe',
                  onPressed: _loading ? null : _subscribe,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

