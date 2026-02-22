import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/profile/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';

class BookingController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<String> selectedSlots = <String>[].obs;
  final RxBool isBooking = false.obs;

  final RxList<String> availableSlots = <String>[
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
    '10:00 PM',
  ].obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedSlots.clear();
  }

  void toggleSlot(String slot) {
    if (selectedSlots.contains(slot)) {
      selectedSlots.remove(slot);
    } else {
      selectedSlots.add(slot);
    }
  }

  double get totalPrice {
    final ground = Get.arguments;
    final price = ground != null
        ? double.tryParse(ground['price_per_hour'].toString()) ?? 3000.0
        : 3000.0;
    return selectedSlots.length * price;
  }

  Future<void> createBooking() async {
    final ground = Get.arguments;
    if (ground == null || ground['id'] == null) {
      Get.snackbar('Error', 'Ground data is missing.');
      return;
    }

    // Check Phone Verification
    final profileController = Get.find<ProfileController>();
    final isVerified =
        profileController.userProfile['is_phone_verified'] ?? false;

    if (!isVerified) {
      Get.dialog(
        PhoneVerificationDialog(
          initialPhone:
              profileController.userProfile['phone']?.toString() ?? '',
          onVerified: () {
            // Verification successful, user can now retry booking
          },
        ),
      );
      return;
    }

    isBooking.value = true;
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final startTime = DateFormat(
        'HH:mm',
      ).format(DateFormat('hh:mm a').parse(selectedSlots.first));
      final endTime = DateFormat('HH:mm').format(
        DateFormat(
          'hh:mm a',
        ).parse(selectedSlots.last).add(const Duration(hours: 1)),
      );

      final data = {
        'ground_id': ground['id'],
        'date': formattedDate,
        'start_time': startTime,
        'end_time': endTime,
        'total_amount': totalPrice,
        'status': 'pending',
      };

      final response = await ApiClient().dio.post('/bookings', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bookingId = response.data['id'];
        Get.offAllNamed(
          '/payment',
          arguments: {'bookingId': bookingId, 'totalPrice': totalPrice},
        );
        selectedSlots.clear();
      } else {
        Get.snackbar('Error', 'Failed to create booking.');
      }
    } catch (e) {
      print('Booking error: $e');
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isBooking.value = false;
    }
  }
}
