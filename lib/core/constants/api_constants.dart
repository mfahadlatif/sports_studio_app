class ApiConstants {
  static const String baseUrl =
      'https://lightcoral-goose-424965.hostingersite.com/backend/public/api';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String googleLogin = '/login/google';
  static const String appleLogin = '/login/apple';
  static const String me = '/me';

  static const String profile = '/profile';
  static const String changePassword = '/profile/password';

  // Resources
  static const String grounds = '/public/grounds';
  static const String bookings = '/bookings';
  static const String events = '/public/events';

  // Payment
  static const String safepayInit = '/safepay/init';
  static const String safepayVerify = '/safepay/verify';
}
