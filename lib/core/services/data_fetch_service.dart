import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

/// Service to handle data fetching with proper error handling and retry logic
class DataFetchService extends GetxService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Fetch data with retry logic
  Future<T?> fetchDataWithRetry<T>(
    Future<T> Function() fetchFunction, {
    int maxRetries = _maxRetries,
    Duration? retryDelay,
    String? errorMessage,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await fetchFunction();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxRetries) {
          await Future.delayed(retryDelay ?? _retryDelay);
        }
      }
    }

    // All attempts failed
    if (errorMessage != null) {
      AppUtils.showError(message: '$errorMessage: $lastException');
    }
    return null;
  }

  /// Fetch ground bookings with enhanced error handling
  Future<List<dynamic>> fetchGroundBookings(
    int groundId, {
    String? date,
  }) async {
    return await fetchDataWithRetry<List<dynamic>>(() async {
          final response = await ApiClient().dio.get(
            '/public/grounds/$groundId/bookings',
            queryParameters: date != null ? {'date': date} : null,
          );

          if (response.statusCode == 200) {
            return response.data as List? ?? [];
          }
          throw Exception(
            'Failed to fetch bookings: Status ${response.statusCode}',
          );
        }, errorMessage: 'Error fetching ground availability') ??
        [];
  }

  /// Fetch notifications with enhanced error handling
  Future<List<dynamic>> fetchNotifications() async {
    return await fetchDataWithRetry<List<dynamic>>(() async {
          final response = await ApiClient().dio.get('/notifications');

          if (response.statusCode == 200) {
            final data = response.data['data'] ?? response.data ?? [];
            return data is List ? data : [];
          }
          throw Exception(
            'Failed to fetch notifications: Status ${response.statusCode}',
          );
        }, errorMessage: 'Error fetching notifications') ??
        [];
  }

  /// Fetch user profile with enhanced error handling
  Future<Map<String, dynamic>> fetchUserProfile() async {
    return await fetchDataWithRetry<Map<String, dynamic>>(() async {
          final response = await ApiClient().dio.get('/me');

          if (response.statusCode == 200) {
            return response.data as Map<String, dynamic>? ?? {};
          }
          throw Exception(
            'Failed to fetch profile: Status ${response.statusCode}',
          );
        }, errorMessage: 'Error fetching user profile') ??
        {};
  }

  /// Fetch grounds with enhanced error handling
  Future<List<dynamic>> fetchGrounds({
    Map<String, dynamic>? queryParams,
  }) async {
    return await fetchDataWithRetry<List<dynamic>>(() async {
          final response = await ApiClient().dio.get(
            '/public/grounds',
            queryParameters: queryParams,
          );

          if (response.statusCode == 200) {
            final data = response.data['data'] ?? response.data ?? [];
            return data is List ? data : [];
          }
          throw Exception(
            'Failed to fetch grounds: Status ${response.statusCode}',
          );
        }, errorMessage: 'Error fetching grounds') ??
        [];
  }

  /// Fetch events with enhanced error handling
  Future<List<dynamic>> fetchEvents({Map<String, dynamic>? queryParams}) async {
    return await fetchDataWithRetry<List<dynamic>>(() async {
          final response = await ApiClient().dio.get(
            '/public/events',
            queryParameters: queryParams,
          );

          if (response.statusCode == 200) {
            final data = response.data['data'] ?? response.data ?? [];
            return data is List ? data : [];
          }
          throw Exception(
            'Failed to fetch events: Status ${response.statusCode}',
          );
        }, errorMessage: 'Error fetching events') ??
        [];
  }

  /// Check API connectivity
  Future<bool> checkApiConnectivity() async {
    try {
      final response = await ApiClient().dio.get(
        '/public/grounds',
        queryParameters: {'per_page': 1},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API connectivity check failed: $e');
      return false;
    }
  }
}
