import 'dart:convert';

class UrlHelper {
  static const String domain = 'lightcoral-goose-424965.hostingersite.com';
  static const String publicBase = 'https://$domain/backend/public';
  static const String apiBase = '$publicBase/api';
  static const String mediaServe = '$apiBase/media/serve';

  /// Converts ANY image URL/path from the API into a reliable URL.
  ///
  /// Strategy:
  ///   - For paths containing /uploads/ → use media/serve PHP endpoint
  ///     (bypasses static file serving, reads from disk via PHP)
  ///   - For /storage/ paths → media/serve
  ///   - For external URLs (Unsplash, Google) → pass through as-is
  ///   - For relative paths → media/serve
  static String sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return _placeholder();

    // Already a media/serve URL — return as-is
    if (url.contains('/api/media/serve')) return url;

    // External CDN (Unsplash, Google Fonts, etc.) — always works, return as-is
    if (url.startsWith('http') &&
        !url.contains(domain) &&
        !url.contains('localhost') &&
        !url.contains('127.0.0.1')) {
      return url;
    }

    // Our domain URL or localhost — extract relative path and route through media/serve
    String relativePath = '';

    if (url.startsWith('http')) {
      if (url.contains('/uploads/')) {
        // e.g. https://domain/backend/public/uploads/media/file.png
        //   → uploads/media/file.png
        relativePath = 'uploads/' + url.split('/uploads/').last;
      } else if (url.contains('/storage/')) {
        relativePath = url.split('/storage/').last;
      } else {
        // Some other absolute URL on our domain we can't parse — return as-is and hope
        return url;
      }
    } else {
      // Relative path
      relativePath = url.startsWith('/') ? url.substring(1) : url;
      if (relativePath.startsWith('storage/')) {
        relativePath = relativePath.substring(8);
      }
    }

    relativePath = relativePath.replaceAll(RegExp(r'^/+'), '');
    if (relativePath.isEmpty) return _placeholder();

    return '$mediaServe?path=${Uri.encodeComponent(relativePath)}';
  }

  static String _placeholder() =>
      'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=800&auto=format&fit=crop';

  /// Parse any image field (List, JSON string, single string) into raw strings.
  static List<String> getParsedImages(dynamic images) {
    if (images == null) return [];

    if (images is List) {
      return images
          .map((i) {
            if (i is Map) {
              return (i['url'] ??
                      i['image_url'] ??
                      i['image_path'] ??
                      i['path'] ??
                      '')
                  .toString();
            }
            return i.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (images is String && images.isNotEmpty) {
      final trimmed = images.trim();
      if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
        try {
          final cleaned = images.replaceAll('\\/', '/');
          final decoded = jsonDecode(cleaned);
          return getParsedImages(decoded);
        } catch (_) {}
      }
      return [images];
    }

    return [];
  }

  /// Get the first image URL, routed through media/serve for reliability.
  static String getFirstImage(dynamic images, {String? fallbackPath}) {
    final list = getParsedImages(images);
    if (list.isNotEmpty) {
      final url = sanitizeUrl(list[0]);
      print('📸 [UrlHelper] → $url');
      return url;
    }
    if (fallbackPath != null && fallbackPath.isNotEmpty) {
      return sanitizeUrl(fallbackPath);
    }
    return sanitizeUrl(null);
  }

  /// Get all images as sanitized media/serve URLs.
  static List<String> getSanitizedImages(
    dynamic images, {
    String? fallbackPath,
  }) {
    final list = getParsedImages(images);
    if (list.isNotEmpty) return list.map(sanitizeUrl).toList();
    if (fallbackPath != null && fallbackPath.isNotEmpty) {
      return [sanitizeUrl(fallbackPath)];
    }
    return [];
  }

  /// Get avatar URL routed through media/serve.
  static String getAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty) return '';
    return sanitizeUrl(avatar);
  }
}
