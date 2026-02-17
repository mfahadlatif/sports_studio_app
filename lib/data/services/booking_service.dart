import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/booking_model.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService;

  BookingService({required ApiService apiService}) : _apiService = apiService;

  Future<List<Booking>> getUserBookings() async {
    try {
      final response = await _apiService.get(ApiConstants.bookings);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<Booking?> createBooking({
    required int groundId,
    required String date,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.bookings,
        data: {
          'ground_id': groundId,
          'booking_date': date,
          'start_time': startTime,
          'end_time': endTime,
          'duration_minutes': 60, // Calculate dynamically in real app
          'total_price': totalPrice,
          'payment_method': 'safepay', // Default for now
        },
      );

      if (response.statusCode == 201) {
        return Booking.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Booking failed: $e');
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.bookings}/$bookingId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Cancel booking failed: $e');
    }
  }

  Future<List<Booking>> getGroundBookings(int groundId, String date) async {
    try {
      // Fetch bookings for the ground.
      // Assuming the API supports filtering by date or returns list we can filter.
      // If API returns all active bookings, we can filter client side or pass query param.
      // Using query param 'date' for now.
      final response = await _apiService.get(
        '${ApiConstants.grounds}/$groundId/bookings',
        queryParameters: {'date': date},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // If API fails or 404 (no bookings), return empty
      return [];
    }
  }
}
