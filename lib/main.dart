import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'domain/providers/auth_provider.dart';
import 'domain/providers/ground_provider.dart';
import 'domain/providers/booking_provider.dart';
import 'data/services/booking_service.dart';
import 'domain/providers/event_provider.dart';
import 'presentation/screens/root_screen.dart'; // Keep for now if needed or remove
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Services
  final apiService = ApiService();
  final authService = AuthService(apiService: apiService);
  final bookingService = BookingService(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => GroundProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(bookingService: bookingService),
        ),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: const SportsStudioApp(),
    ),
  );
}

class SportsStudioApp extends StatelessWidget {
  const SportsStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // For now, bypass Auth check and go straight to RootScreen
      // In real app, check auth state:
      // home: Consumer<AuthProvider>(builder: (ctx, auth, _) => auth.isAuthenticated ? RootScreen() : LoginScreen()),
      home: const SplashScreen(),
    );
  }
}
