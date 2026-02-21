import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_theme.dart';
import 'package:sports_studio/features/landing/presentation/landing_page.dart';
import 'package:sports_studio/features/auth/presentation/pages/auth_page.dart';
import 'package:sports_studio/features/grounds/presentation/pages/ground_detail_page.dart';
import 'package:sports_studio/features/booking/presentation/pages/booking_slot_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_ground_page.dart';
import 'package:sports_studio/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sports_studio/features/events/presentation/event_detail_page.dart';
import 'package:sports_studio/features/profile/presentation/setting_detail_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SportsStudioApp());
}

class SportsStudioApp extends StatelessWidget {
  const SportsStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sports Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/onboarding', // Changed to launch Onboarding first
      getPages: [
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/',
          page: () => const LandingPage(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/auth',
          page: () => const AuthPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/ground-detail',
          page: () => const GroundDetailPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/book-slot',
          page: () => const BookingSlotPage(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/add-ground',
          page: () => const AddGroundPage(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/event-detail',
          page: () => const EventDetailPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/setting-detail',
          page: () => const SettingDetailPage(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
