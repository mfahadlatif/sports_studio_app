import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sports_studio/core/network/api_client.dart';

class BookingsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isActioning = false.obs;
  final RxList<dynamic> upcomingBookings = <dynamic>[].obs;
  final RxList<dynamic> pastBookings = <dynamic>[].obs;
  final RxList<dynamic> cancelledBookings = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/bookings');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        upcomingBookings.value = data
            .where(
              (b) => b['status'] == 'confirmed' || b['status'] == 'pending',
            )
            .toList();
        pastBookings.value = data
            .where((b) => b['status'] == 'completed')
            .toList();
        cancelledBookings.value = data
            .where((b) => b['status'] == 'cancelled')
            .toList();
      }
    } catch (e) {
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
