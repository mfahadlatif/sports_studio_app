import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/theme/app_theme.dart';
import 'package:sports_studio/features/landing/presentation/landing_page.dart';
import 'package:sports_studio/features/auth/presentation/pages/auth_page.dart';
import 'package:sports_studio/features/user/presentation/pages/ground_detail_page.dart';
import 'package:sports_studio/features/user/presentation/pages/booking_slot_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_edit_ground_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/complex_detail_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_ground_detail_page.dart';
import 'package:sports_studio/features/user/presentation/pages/onboarding_page.dart';
import 'package:sports_studio/features/user/presentation/pages/event_detail_page.dart';
import 'package:sports_studio/features/user/presentation/pages/create_match_page.dart';
import 'package:sports_studio/features/user/presentation/pages/setting_detail_page.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/owner/presentation/widgets/owner_bookings_view.dart';
import 'package:sports_studio/features/user/presentation/pages/payment_page.dart';
import 'package:sports_studio/features/user/presentation/pages/user_bookings_page.dart';
import 'package:sports_studio/features/user/presentation/pages/deals_page.dart';
import 'package:sports_studio/features/user/presentation/pages/notifications_page.dart';
import 'package:sports_studio/features/user/presentation/pages/favorites_page.dart';
import 'package:sports_studio/features/user/presentation/pages/teams_page.dart';
import 'package:sports_studio/features/user/presentation/pages/privacy_policy_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_reports_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/booking_detail_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/owner_deals_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/sports_complexes_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/review_moderation_page.dart';
import 'package:sports_studio/features/owner/presentation/pages/add_complex_page.dart';
import 'package:sports_studio/features/landing/controller/landing_controller.dart';
import 'package:sports_studio/features/user/controller/favorites_controller.dart';
import 'package:sports_studio/features/user/presentation/pages/contact_page.dart';
import 'package:sports_studio/features/admin/presentation/pages/admin_users_page.dart';
import 'package:sports_studio/core/constants/user_roles.dart';

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
  final landingController = Get.put(LandingController(), permanent: true);
  Get.put(FavoritesController(), permanent: true);
  Get.put(ProfileController(), permanent: true);

  // Restore Role from storage
  final String? savedRole = await storage.read(key: 'user_role');
  if (savedRole != null) {
    if (savedRole == UserRole.owner.name) {
      landingController.currentRole.value = UserRole.owner;
    } else if (savedRole == UserRole.admin.name) {
      landingController.currentRole.value = UserRole.admin;
    } else {
      landingController.currentRole.value = UserRole.user;
    }
  }

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
          page: () => const UserBookingsPage(),
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
        GetPage(
          name: '/teams',
          page: () => const TeamsPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/privacy-policy',
          page: () => const PrivacyPolicyPage(),
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
        GetPage(
          name: '/add-complex',
          page: () => const AddComplexPage(),
          transition: Transition.downToUp,
        ),
        // ── Admin Feature Routes ──────────────────────────────
        GetPage(
          name: '/admin/users',
          page: () => const AdminUsersPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin/complexes',
          page: () => const SportsComplexesPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin/bookings',
          page: () => const OwnerBookingsView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin/reviews',
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
