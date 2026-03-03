import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/services/data_fetch_service.dart';

class BookingController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<String> selectedSlots = <String>[].obs;
  final RxBool isBooking = false.obs;
  final RxInt players = 2.obs;
  final double serviceFee = 2.0;

  final RxList<String> allSlots = <String>[
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
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

  final RxList<String> bookedSlots = <String>[].obs;
  final RxBool isLoadingSlots = false.obs;

  final RxString promoCode = ''.obs;
  final RxDouble discount = 0.0.obs;
  final RxBool isCheckingPromo = false.obs;
  final Rxn<Deal> selectedDeal = Rxn<Deal>();

  final BookingApiService _bookingApiService = BookingApiService();
  final DealApiService _dealApiService = DealApiService();
  final PaymentApiService _paymentApiService = PaymentApiService();
  final DataFetchService _dataFetchService = Get.find<DataFetchService>();

  @override
  void onInit() {
    super.onInit();
    // Don't fetch availability immediately, wait for ground to be set
    // This prevents issues when controller is initialized without arguments
  }

  /// Set ground and fetch availability for that ground
  void setGroundAndFetchAvailability(dynamic ground) {
    if (ground != null && ground['id'] != null) {
      fetchAvailability(ground['id']);
    }
  }

  Future<void> fetchAvailability(int groundId) async {
    isLoadingSlots.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final bookings = await _dataFetchService.fetchGroundBookings(
        groundId,
        date: dateStr,
      );

      final List<String> booked = [];

      for (var b in bookings) {
        try {
          final start = DateTime.parse(b['start_time']);
          final end = DateTime.parse(b['end_time']);

          // Identify which of our 1-hour slots overlap with this booking
          for (var slotStr in allSlots) {
            final slotTime = DateFormat('hh:mm a').parse(slotStr);
            // Construct a DateTime for slot on selected date
            final slotStart = DateTime(
              selectedDate.value.year,
              selectedDate.value.month,
              selectedDate.value.day,
              slotTime.hour,
              slotTime.minute,
            );
            final slotEnd = slotStart.add(const Duration(hours: 1));

            // Overlap check
            if (slotStart.isBefore(end) && slotEnd.isAfter(start)) {
              booked.add(slotStr);
            }
          }
        } catch (e) {
          print('Error parsing booking time: $e');
        }
      }

      bookedSlots.value = booked.toSet().toList(); // Unique
    } catch (e) {
      AppUtils.showError(message: 'Error fetching availability: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedSlots.clear();
    final ground = Get.arguments;
    if (ground != null && ground['id'] != null) {
      fetchAvailability(ground['id']);
    }
  }

  void toggleSlot(String slot) {
    if (selectedSlots.contains(slot)) {
      selectedSlots.remove(slot);
    } else {
      selectedSlots.add(slot);
    }
  }

  Future<void> applyPromoCode(String code) async {
    if (code.isEmpty) return;
    isCheckingPromo.value = true;
    try {
      final deals = await _dealApiService.getPublicDeals();
      final deal = deals.firstWhereOrNull(
        (d) => d.title.toLowerCase().contains(code.toLowerCase()),
      );

      if (deal != null) {
        selectedDeal.value = deal;
        final amount = subtotal * (deal.discountPercentage / 100);
        discount.value = amount;
        promoCode.value = code;
        AppUtils.showSuccess(message: 'Promo code applied: ${deal.title}');
      } else {
        AppUtils.showError(message: 'Invalid or expired promo code');
        selectedDeal.value = null;
        discount.value = 0;
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
    final isVerified = profileController.userProfile['phone_verified'] ?? false;

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

      final bookingData = {
        'ground_id': ground['id'],
        'start_time': '$formattedDate $startTimeStr:00',
        'end_time': '$formattedDate $endTimeStr:00',
        'total_price': totalPrice,
        'players': players.value,
        'coupon_id': selectedDeal.value?.id,
      };

      final booking = await _bookingApiService.createBooking(bookingData);

      Get.offAllNamed(
        '/payment',
        arguments: {
          'bookingId': booking.id,
          'totalPrice': totalPrice,
          'subtotal': subtotal,
          'discount': discount.value,
          'deal': selectedDeal.value,
        },
      );
      selectedSlots.clear();
    } catch (e) {
      AppUtils.showError(message: 'Something went wrong while booking: $e');
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> initiatePayment(int bookingId, double amount) async {
    try {
      final paymentData = {
        'amount': amount,
        'booking_id': bookingId,
        'callback_url': 'sportsstudio://payment-success',
      };

      final response = await _paymentApiService.initiateSafepayPayment(
        paymentData,
      );

      // Launch Safepay payment URL
      // You'll need to implement URL launcher here
      AppUtils.showSuccess(message: 'Payment initiated successfully');
    } catch (e) {
      AppUtils.showError(message: 'Failed to initiate payment: $e');
    }
  }

  Future<void> verifyPayment(String token) async {
    try {
      final response = await _paymentApiService.verifySafepayPayment(token);

      if (response['status'] == 'success') {
        AppUtils.showSuccess(message: 'Payment verified successfully');
        Get.offAllNamed('/my-bookings');
      } else {
        AppUtils.showError(message: 'Payment verification failed');
      }
    } catch (e) {
      AppUtils.showError(message: 'Payment verification error: $e');
    }
  }
}
