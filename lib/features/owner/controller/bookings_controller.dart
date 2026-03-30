import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:sports_studio/core/network/api_client.dart';

class BookingsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isActioning = false.obs;
  final RxList<dynamic> upcomingBookings = <dynamic>[].obs;
  final RxList<dynamic> pastBookings = <dynamic>[].obs;
  final RxList<dynamic> cancelledBookings = <dynamic>[].obs;

  final RxString searchQuery = ''.obs;
  final RxList<dynamic> allData = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
    // Re-fetch when search query changes (with debounce)
    debounce(searchQuery, (_) => fetchBookings(), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final token = await ApiClient().storage.read(key: 'auth_token');
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final Map<String, dynamic> queryParams = {};
      if (searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      // 1. Fetch Ground Bookings
      final bookingResponse = await ApiClient().dio.get(
        '/bookings',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      print('🌐 [Bookings] Raw response: ${bookingResponse.data}');
      final List groundBookingsRaw = (bookingResponse.data is Map)
          ? (bookingResponse.data['data'] as List? ?? [])
          : (bookingResponse.data as List? ?? []);
      
      print('✅ [Bookings] Ground bookings count: ${groundBookingsRaw.length}');

      final groundBookings = groundBookingsRaw
          .map(
            (b) => {
              ...b,
              'type': 'ground',
              'display_name': b['ground']?['name'] ?? 'Ground',
              'sport_type': b['ground']?['type'] ?? 'Sports',
              'start': b['start_time'],
              'end': b['end_time'],
              'price': double.tryParse((b['total_price'] ?? b['total_amount'] ?? 0).toString()) ?? 0.0,
            },
          )
          .toList();

      // 2. Fetch Event Participations
      List eventParticipations = [];
      try {
        final eventResponse = await ApiClient().dio.get(
          '/event-participants',
          options: Options(headers: headers),
        );
        final List eventDataRaw = (eventResponse.data is Map)
            ? (eventResponse.data['data'] ?? [])
            : (eventResponse.data ?? []);

        eventParticipations = eventDataRaw
            .map(
              (p) => {
                ...p,
                'type': 'event',
                'display_name': p['event']?['name'] ?? 'Event',
                'sport_type': 'Event',
                'start': p['event']?['start_time'],
                'end': p['event']?['end_time'],
                'price': double.tryParse((p['event']?['registration_fee'] ?? 0).toString()) ?? 0.0,
                'status': p['status'] == 'accepted'
                    ? 'confirmed'
                    : (p['status'] == 'pending' ? 'pending' : 'cancelled'),
              },
            )
            .toList();
      } catch (e) {
        print('Error fetching event participations: $e');
      }

      final List combined = [...groundBookings, ...eventParticipations];
      print('✅ [Bookings] Total combined matches: ${combined.length}');

      // Sort by date descending
      combined.sort((a, b) {
        final dateA = DateTime.tryParse(a['start']?.toString() ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['start']?.toString() ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      allData.value = combined;

      final now = DateTime.now();
      
      upcomingBookings.value = combined.where((b) {
        final status = b['status']?.toString().toLowerCase() ?? '';
        final endDate = DateTime.tryParse(b['end']?.toString() ?? '') ?? now.add(const Duration(hours: 1));
        
        // Exclude hard-cancelled states
        if (['cancelled', 'rejected', 'failed', 'refunded', 'expired'].contains(status)) {
            return false;
        }

        // Must be in the future
        return endDate.isAfter(now);
      }).toList();

      pastBookings.value = combined.where((b) {
        final status = b['status']?.toString().toLowerCase() ?? '';
        final endDate = DateTime.tryParse(b['end']?.toString() ?? '') ?? now.subtract(const Duration(hours: 1));
        
        // Exclude hard-cancelled states for "History" usually, but some want them there.
        // For this app, let's keep History as "what happened".
        if (['cancelled', 'rejected', 'failed', 'refunded', 'expired'].contains(status)) {
            return false;
        }

        return endDate.isBefore(now);
      }).toList();

      cancelledBookings.value = combined.where((b) {
        final status = b['status']?.toString().toLowerCase() ?? '';
        return status == 'cancelled' || status == 'rejected' || status == 'failed' || status == 'refunded' || status == 'expired';
      }).toList();
      
      print('✅ [Bookings] Split: Upcoming: ${upcomingBookings.length}, Past: ${pastBookings.length}, Cancelled: ${cancelledBookings.length}');
    } catch (e) {
      print('Fetch Bookings Error: $e');
      Get.snackbar('Error', 'Failed to fetch bookings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBookingStatus(
    dynamic booking,
    String newStatus, {
    String? reason,
  }) async {
    isActioning.value = true;
    try {
      final id = booking['id'];
      final payload = <String, dynamic>{'status': newStatus};
      if (newStatus == 'cancelled' && reason != null && reason.isNotEmpty) {
        payload['rejection_reason'] = reason;
        payload['payment_status'] = 'refunded';
      }

      final response = await ApiClient().dio.put(
        '/bookings/$id',
        data: payload,
      );
      if (response.statusCode == 200) {
        await fetchBookings();
        final isAccepted = newStatus == 'confirmed';
        Get.snackbar(
          'Success',
          'Booking ${isAccepted ? "accepted" : "declined"} successfully',
          backgroundColor: isAccepted
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEE2E2),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update booking');
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> markAsPaid(dynamic booking) async {
    isActioning.value = true;
    try {
      final id = booking['id'];
      // Match website/backend: POST /bookings/:id/finalize-payment (cash/COD)
      final response = await ApiClient().dio.post('/bookings/$id/finalize-payment');
      if (response.statusCode == 200) {
        await fetchBookings();
        Get.snackbar(
          'Marked as Paid',
          'Booking has been confirmed as paid',
          backgroundColor: const Color(0xFFDCFCE7),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as paid');
    } finally {
      isActioning.value = false;
    }
  }

  /// Fetch existing bookings for a specific ground and date (for availability check)
  Future<List<dynamic>> fetchGroundBookings(int groundId, String date) async {
    try {
      final response = await ApiClient().dio.get(
        '/public/grounds/$groundId/bookings',
        queryParameters: {'date': date},
      );
      if (response.statusCode == 200) {
        return response.data is List ? response.data : (response.data['data'] ?? []);
      }
    } catch (e) {
      print('Fetch Ground Bookings Error: $e');
    }
    return [];
  }

  /// Manual booking (owner). Matches website API: time_slots array.
  Future<void> createManualBooking({
    required int groundId,
    required String customerName,
    required List<Map<String, String>> timeSlots,
    required double totalAmount,
    String? customerPhone,
    String? customerEmail,
    int players = 1,
  }) async {
    isActioning.value = true;
    try {
      final data = <String, dynamic>{
        'ground_id': groundId,
        'customer_name': customerName,
        'time_slots': timeSlots,
        'total_price': totalAmount,
        'players': players,
        'status': 'confirmed',
        'payment_status': 'paid',
        'payment_method': 'cash',
      };
      if (customerPhone != null && customerPhone.isNotEmpty) data['customer_phone'] = customerPhone;
      if (customerEmail != null && customerEmail.isNotEmpty) data['customer_email'] = customerEmail;
      
      final response = await ApiClient().dio.post('/bookings', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchBookings();
        Get.snackbar(
          'Success',
          'Manual booking created successfully',
          backgroundColor: const Color(0xFFDCFCE7),
        );
      } else {
        Get.snackbar('Error', 'Failed to create manual booking');
      }
    } catch (e) {
      print('Manual Booking Error: $e');
      if (e is DioException && e.response?.data != null) {
        final msg = e.response?.data['message'] ?? e.toString();
        Get.snackbar('Error', msg);
      } else {
        Get.snackbar('Error', 'Could not create booking: $e');
      }
    } finally {
      isActioning.value = false;
    }
  }
}
