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

  // New list to hold raw combined data if needed
  final RxList<dynamic> allData = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final token = await ApiClient().storage.read(key: 'auth_token');
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // 1. Fetch Ground Bookings
      final bookingResponse = await ApiClient().dio.get(
        '/bookings',
        options: Options(headers: headers),
      );
      final List groundBookingsRaw = (bookingResponse.data is Map)
          ? (bookingResponse.data['data'] ?? [])
          : (bookingResponse.data ?? []);

      final groundBookings = groundBookingsRaw
          .map(
            (b) => {
              ...b,
              'type': 'ground',
              'display_name': b['ground']?['name'] ?? 'Ground',
              'sport_type': b['ground']?['type'] ?? 'Sports',
              'start': b['start_time'],
              'end': b['end_time'],
              'price': b['total_price'] ?? b['total_amount'] ?? 0,
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
                'price': p['event']?['registration_fee'] ?? 0,
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

      // Sort by date descending
      combined.sort((a, b) {
        final dateA = DateTime.tryParse(a['start'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['start'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      allData.value = combined;

      upcomingBookings.value = combined.where((b) {
        final status = b['status']?.toString().toLowerCase();
        return status == 'confirmed' ||
            status == 'pending' ||
            status == 'accepted';
      }).toList();

      pastBookings.value = combined.where((b) {
        final status = b['status']?.toString().toLowerCase();
        return status == 'completed';
      }).toList();

      cancelledBookings.value = combined.where((b) {
        final status = b['status']?.toString().toLowerCase();
        return status == 'cancelled' || status == 'rejected';
      }).toList();
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
      final response = await ApiClient().dio.put(
        '/bookings/$id',
        data: {'payment_status': 'paid', 'status': 'confirmed'},
      );
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

  Future<void> createManualBooking({
    required int groundId,
    required String customerName,
    required String date,
    required String startTime,
    required String endTime,
    required double totalAmount,
  }) async {
    isActioning.value = true;
    try {
      final data = {
        'ground_id': groundId,
        'customer_name': customerName,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'total_amount': totalAmount,
        'status': 'confirmed',
        'payment_status': 'paid',
      };
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
      Get.snackbar('Error', 'Could not create booking: $e');
    } finally {
      isActioning.value = false;
    }
  }
}
