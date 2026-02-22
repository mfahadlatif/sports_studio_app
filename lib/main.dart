import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_theme.dart';
import 'package:sports_studio/features/landing/presentation/landing_page.dart';
import 'package:sports_studio/features/auth/presentation/pages/auth_page.dart';
import 'package:sports_studio/features/grounds/presentation/pages/ground_detail_page.dart';
import 'package:sports_studio/features/booking/presentation/pages/booking_slot_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_edit_ground_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/complex_detail_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_ground_detail_page.dart';
import 'package:sports_studio/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sports_studio/features/events/presentation/event_detail_page.dart';
import 'package:sports_studio/features/events/presentation/create_match_page.dart';
import 'package:sports_studio/features/profile/presentation/setting_detail_page.dart';
import 'package:sports_studio/features/profile/controller/profile_controller.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sports_studio/features/booking/presentation/pages/payment_page.dart';
// User features
import 'package:sports_studio/features/deals/presentation/deals_page.dart';
import 'package:sports_studio/features/notifications/presentation/notifications_page.dart';
import 'package:sports_studio/features/favorites/presentation/favorites_page.dart';
// Owner features
import 'package:sports_studio/features/owner/presentation/pages/owner_reports_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/booking_detail_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_deals_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/sports_complexes_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/review_moderation_page.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/favorites/controller/favorites_controller.dart';
import 'package:sports_studio/features/contact/presentation/contact_page.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  final String? hasSeenOnboarding = await storage.read(
    key: 'has_seen_onboarding',
  );
  final String? authToken = await storage.read(key: 'auth_token');

  String initialRoute = '/onboarding';
  if (hasSeenOnboarding == 'true') {
    initialRoute = authToken != null ? '/' : '/auth';
  }

  // Register Controllers permanently so all child widgets can Get.find() them
  Get.put(LandingController(), permanent: true);
  Get.put(FavoritesController(), permanent: true);
  Get.put(ProfileController(), permanent: true);

  runApp(SportsStudioApp(initialRoute: initialRoute));
}

class SportsStudioApp extends StatelessWidget {
  final String initialRoute;
  const SportsStudioApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sports Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: [
        // ── Core ──────────────────────────────────────────────
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
          page: () => const AddEditGroundPage(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/complex-detail',
          page: () => const ComplexDetailPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/owner-ground-detail',
          page: () => const OwnerGroundDetailPage(),
          transition: Transition.rightToLeft,
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
        GetPage(
          name: '/user-bookings',
          page: () => const OwnerBookingsView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/create-match',
          page: () => const CreateMatchPage(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/payment',
          page: () => const PaymentPage(),
          transition: Transition.downToUp,
        ),
        // ── User Feature Routes ───────────────────────────────
        GetPage(
          name: '/deals',
          page: () => const DealsPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationsPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/favorites',
          page: () => const FavoritesPage(),
          transition: Transition.rightToLeft,
        ),
        // ── Owner Feature Routes ──────────────────────────────
        GetPage(
          name: '/owner-reports',
          page: () => const OwnerReportsPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/booking-detail',
          page: () => const BookingDetailPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/owner-deals',
          page: () => const OwnerDealsPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/sports-complexes',
          page: () => const SportsComplexesPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/review-moderation',
          page: () => const ReviewModerationPage(),
          transition: Transition.rightToLeft,
        ),
        // ── Utility Routes ────────────────────────────────────
        GetPage(
          name: '/contact',
          page: () => const ContactPage(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
