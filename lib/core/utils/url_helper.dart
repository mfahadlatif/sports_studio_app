class UrlHelper {
  static const String domain = 'lightcoral-goose-424965.hostingersite.com';
  static const String baseAssetUrl = 'https://$domain/backend/public/storage';

  static String sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800';
    }

    // Hande relative paths
    if (!url.startsWith('http')) {
      // Ensure there's a leading slash
      final path = url.startsWith('/') ? url : '/$url';
      return '$baseAssetUrl$path';
    }

    // Handle localhost URLs
    if (url.contains('localhost')) {
      final storageIndex = url.indexOf('/storage/');
      if (storageIndex != -1) {
        final relativePath = url.substring(storageIndex + 9);
        return '$baseAssetUrl/$relativePath';
      }
      return url.replaceAll('http://localhost', 'https://$domain');
    }

    return url;
  }
}
