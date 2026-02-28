import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/network/api_client.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/core/utils/app_utils.dart';

class BookingController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<String> selectedSlots = <String>[].obs;
  final RxBool isBooking = false.obs;
  final RxInt players = 2.obs;
  final double serviceFee = 2.0;

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

  final RxString promoCode = ''.obs;
  final RxDouble discount = 0.0.obs;
  final RxBool isCheckingPromo = false.obs;

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

  final Rxn<dynamic> selectedDeal = Rxn<dynamic>();

  Future<void> applyPromoCode(String code) async {
    if (code.isEmpty) return;
    isCheckingPromo.value = true;
    try {
      final res = await ApiClient().dio.get('/public/deals');
      if (res.statusCode == 200) {
        final deals = res.data ?? [];
        final deal = (deals as List).firstWhereOrNull(
          (d) => d['code'].toString().toLowerCase() == code.toLowerCase(),
        );

        if (deal != null) {
          selectedDeal.value = deal;
          final percentage =
              double.tryParse(deal['discount_percentage'].toString()) ?? 0.0;
          final amount = subtotal * (percentage / 100);
          discount.value = amount;
          promoCode.value = code;
          AppUtils.showSuccess(message: 'Promo code applied: ${deal['title']}');
        } else {
          AppUtils.showError(message: 'Invalid or expired promo code');
          selectedDeal.value = null;
          discount.value = 0;
        }
      } else {
        AppUtils.showError(message: 'Invalid or expired promo code');
      }
    } catch (e) {
      AppUtils.showError(message: 'Could not validate promo code');
    } finally {
      isCheckingPromo.value = false;
    }
  }

  double get subtotal {
    final ground = Get.arguments;
    final price = ground != null
        ? double.tryParse(ground['price_per_hour'].toString()) ?? 100.0
        : 100.0;
    return selectedSlots.length * price;
  }

  double get totalPrice {
    final total = subtotal + serviceFee;
    return (total - discount.value).clamp(0, double.infinity);
  }

  void incrementPlayers(int max) {
    if (players.value < max) {
      players.value++;
    }
  }

  void decrementPlayers() {
    if (players.value > 1) {
      players.value--;
    }
  }

  Future<void> createBooking() async {
    final ground = Get.arguments;
    if (ground == null || ground['id'] == null) {
      AppUtils.showError(message: 'Ground data is missing.');
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
      final startTimeStr = DateFormat(
        'HH:mm',
      ).format(DateFormat('hh:mm a').parse(selectedSlots.first));
      final endTimeStr = DateFormat('HH:mm').format(
        DateFormat(
          'hh:mm a',
        ).parse(selectedSlots.last).add(const Duration(hours: 1)),
      );

      final data = {
        'ground_id': ground['id'],
        'start_time': '$formattedDate $startTimeStr:00',
        'end_time': '$formattedDate $endTimeStr:00',
        'total_price': totalPrice,
        'players': players.value,
        'coupon_id': selectedDeal.value?['id'],
      };

      final response = await ApiClient().dio.post('/bookings', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bookingId = response.data['id'];
        Get.offAllNamed(
          '/payment',
          arguments: {
            'bookingId': bookingId,
            'totalPrice': totalPrice,
            'subtotal': subtotal,
            'discount': discount.value,
            'deal': selectedDeal.value,
          },
        );
        selectedSlots.clear();
      } else {
        AppUtils.showError(message: 'Failed to create booking.');
      }
    } catch (e) {
      print('Booking error: $e');
      AppUtils.showError(message: 'Something went wrong while booking.');
    } finally {
      isBooking.value = false;
    }
  }
}
