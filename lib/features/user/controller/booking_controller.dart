import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/core/services/data_fetch_service.dart';
import 'package:sports_studio/core/services/safepay_service.dart';
import 'package:sports_studio/widgets/safepay_payment_widget.dart';

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
  final DataFetchService _dataFetchService = Get.find<DataFetchService>();
  final SafepayService _safepayService = Get.find<SafepayService>();


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
      // FIX 4: Match on deal's `code` field (not title). Also check validity dates.
      final now = DateTime.now();
      final ground = Get.arguments;
      final groundSport = (ground?['type'] ?? '').toString().toLowerCase();
      final deal = deals.firstWhereOrNull(
        (d) =>
            (d.code?.toLowerCase() == code.toLowerCase()) &&
            d.isActive &&
            d.validUntil.isAfter(now) &&
            _dealAppliesToSport(d.applicableSports, groundSport),
      );

      if (deal != null) {
        selectedDeal.value = deal;
        final amount = subtotal * (deal.discountPercentage / 100);
        discount.value = amount;
        promoCode.value = code;
        AppUtils.showSuccess(
          message:
              'Promo code applied: ${deal.title} (${deal.discountPercentage.toStringAsFixed(0)}% off)',
        );
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

  bool _dealAppliesToSport(String? applicableSportsRaw, String groundSport) {
    if (groundSport.isEmpty) return true;
    if (applicableSportsRaw == null) return true;
    final raw = applicableSportsRaw.trim();
    if (raw.isEmpty) return true;

    // Backend stores applicable_sports as a string. Accept common formats:
    // - "cricket"
    // - "cricket,football"
    // - '["cricket","football"]'
    final lower = raw.toLowerCase();
    if (lower == 'all') return true;

    // JSON-ish list
    if (lower.startsWith('[') && lower.endsWith(']')) {
      final cleaned = lower.replaceAll('[', '').replaceAll(']', '');
      final parts = cleaned
          .split(',')
          .map((p) => p.replaceAll('"', '').replaceAll("'", '').trim())
          .where((p) => p.isNotEmpty)
          .toList();
      return parts.contains(groundSport);
    }

    // Comma-separated
    final parts = lower
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.contains(groundSport);
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
        'total_price': totalPrice, // Discount is already factored in
        'players': players.value,
        // FIX 12: Removed coupon_id — backend doesn't accept it, discount is pre-applied in total_price
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

  /// Start a booking with direct Safepay payment flow.
  /// This implements: "if completed payment then book the ground"
  Future<void> bookWithSafepay() async {
    final ground = Get.arguments;
    if (ground == null || ground['id'] == null) {
      AppUtils.showError(message: 'Ground data is missing.');
      return;
    }


    if (selectedSlots.isEmpty) {
      AppUtils.showError(message: 'Please select at least one time slot.');
      return;
    }

    isBooking.value = true;
    try {
      // Step 1: Initiate Safepay via Service to get tracker
      final response = await _safepayService.initiateCheckout(
        amount: totalPrice,
      );

      final tracker = response?['tracker'];
      final token = response?['token'];

      if (tracker == null) {
        AppUtils.showError(message: 'Failed to generate payment tracker. Please try again.');
        isBooking.value = false;
        return;
      }

      // Step 2: Open Safepay Widget (Package)
      final result = await Get.to(() => SafepayPaymentWidget(
        amount: totalPrice,
        tracker: tracker,
        token: token,
      ));

      if (result == true) {
        // Step 3: Payment successful - Now actually create the booking
        final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
        final startTimeStr = DateFormat('HH:mm').format(
          DateFormat('hh:mm a').parse(selectedSlots.first),
        );
        final endTimeStr = DateFormat('HH:mm').format(
          DateFormat('hh:mm a').parse(selectedSlots.last).add(const Duration(hours: 1)),
        );

        final bookingData = {
          'ground_id': ground['id'],
          'start_time': '$formattedDate $startTimeStr:00',
          'end_time': '$formattedDate $endTimeStr:00',
          'total_price': totalPrice,
          'players': players.value,
          'payment_method': 'safepay',
          'payment_status': 'paid',
        };

        final booking = await _bookingApiService.createBooking(bookingData);
        
        // Finalize if needed (some backends require a separate call)
        try {
          await _bookingApiService.finalizePayment(booking.id);
        } catch (_) {}

        AppUtils.showSuccess(message: 'Payment and booking successful!');
        Get.offAllNamed('/landing');
        selectedSlots.clear();
      } else {
        AppUtils.showInfo(title: 'Cancelled', message: 'Payment cancelled. Booking was not completed.');
      }
    } catch (e) {
      AppUtils.showError(message: e);
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> initiatePayment(int bookingId, double amount) async {
    try {
      final response = await _safepayService.initiateCheckout(
        amount: amount,
      );
      
      final tracker = response?['tracker'];

      if (tracker != null) {
        final token = response?['token'];
        Get.to(() => SafepayPaymentWidget(
              amount: amount,
              tracker: tracker,
              token: token,
            ));
        AppUtils.showSuccess(message: 'Payment initiated successfully');
      }
    } catch (e) {
      AppUtils.showError(message: e);
    }
  }

  Future<void> verifyPayment(String token) async {
    try {
      final isValid = await _safepayService.verifyPayment(token);
      if (isValid) {
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
