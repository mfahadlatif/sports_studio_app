class AppSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppConstants {
  static const String appName = 'Sports Studio';
  static const double borderRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const String currencySymbol = 'Rs';

  /// Google Places / Maps API key for address autocomplete and map features.
  /// Replace the placeholder with your real key, or keep using the same key
  /// you configured in the Android manifest if desired.
  static const String googlePlacesApiKey =
      'AIzaSyBzjoXEYxmIe6ZLzzEOZhundPX1cBiGwiA';

  // Assets
  static const String appIcon = 'assets/app_icon.jpeg';
  static const String appLogo = 'assets/app-logo.png';
  static const String googleLogo = 'assets/google-logo.png';
  static const String appleLogo = 'assets/apple-logo.png';

  static const List<Map<String, String>> groundAmenities = [
    {
      'id': 'water',
      'name': 'Water',
      'icon': '🚰',
      'asset': 'assets/Icons/Washrooms.png',
    },
    {
      'id': 'washroom',
      'name': 'Washroom',
      'icon': '🚻',
      'asset': 'assets/Icons/Washrooms.png',
    },
    {
      'id': 'changing',
      'name': 'Changing',
      'icon': '👕',
      'asset': 'assets/Icons/ChangingRooms.png',
    },
    {
      'id': 'parking',
      'name': 'Parking',
      'icon': '🚗',
      'asset': 'assets/Icons/FreeParking.png',
    },
    {
      'id': 'lighting',
      'name': 'Lights',
      'icon': '💡',
      'asset': 'assets/Icons/Floodlights.png',
    },
    {
      'id': 'wifi',
      'name': 'Wifi',
      'icon': '📡',
      'asset': 'assets/Icons/FreeWiFi.png',
    },
    {
      'id': 'first_aid',
      'name': 'First Aid',
      'icon': '🏥',
      'asset': 'assets/Icons/FirstAid.png',
    },
    {
      'id': 'cafe',
      'name': 'Cafe',
      'icon': '☕',
      'asset': 'assets/Icons/Cafe.png',
    },
    {
      'id': 'dugout',
      'name': 'Dugout',
      'icon': '⛺',
      'asset': 'assets/Icons/Seating.png',
    },
    {
      'id': 'balls',
      'name': 'Balls',
      'icon': '🎾',
      'asset': 'assets/Icons/Equipment.png',
    },
    {
      'id': 'bats',
      'name': 'Bats',
      'icon': '🏏',
      'asset': 'assets/Icons/Equipment.png',
    },
  ];
}
